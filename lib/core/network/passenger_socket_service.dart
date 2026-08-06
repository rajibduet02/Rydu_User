import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;

import '../constants/api_constants.dart';
import '../constants/auth_constants.dart';
import '../storage/secure_storage_service.dart';
import '../../features/ride_booking/data/utils/ride_planning_parsers.dart';
import '../../features/ride_booking/domain/entities/ride_planning_entities.dart';

enum PassengerSocketConnectionStatus {
  disconnected,
  connecting,
  connected,
  reconnecting,
  authFailed,
}

/// Lifecycle-aware Socket.IO client for passenger booking events.
class PassengerSocketService {
  PassengerSocketService(this._secureStorage);

  final SecureStorageService _secureStorage;

  io.Socket? _socket;
  bool _connecting = false;
  String? _activeBookingId;
  PassengerSocketConnectionStatus _status =
      PassengerSocketConnectionStatus.disconnected;

  final _bookingStatusController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _driverLocationController =
      StreamController<DriverLocationEntity>.broadcast();
  final _recordingEventController =
      StreamController<Map<String, dynamic>>.broadcast();
  final _authenticatedController = StreamController<bool>.broadcast();
  final _connectionStatusController =
      StreamController<PassengerSocketConnectionStatus>.broadcast();

  Stream<Map<String, dynamic>> get bookingStatusStream =>
      _bookingStatusController.stream;
  Stream<DriverLocationEntity> get driverLocationStream =>
      _driverLocationController.stream;
  Stream<Map<String, dynamic>> get recordingEventStream =>
      _recordingEventController.stream;
  Stream<bool> get authenticatedStream => _authenticatedController.stream;
  Stream<PassengerSocketConnectionStatus> get connectionStatusStream =>
      _connectionStatusController.stream;

  bool get isConnected => _socket?.connected == true;
  PassengerSocketConnectionStatus get connectionStatus => _status;

  void setActiveBookingId(String? bookingId) {
    _activeBookingId = bookingId;
  }

  void _setStatus(PassengerSocketConnectionStatus next) {
    _status = next;
    if (!_connectionStatusController.isClosed) {
      _connectionStatusController.add(next);
    }
  }

  Future<void> connect() async {
    if (_socket?.connected == true || _connecting) return;

    final token = await _secureStorage.read(AuthConstants.backendJwtKey);
    if (token == null || token.isEmpty) {
      if (kDebugMode) {
        debugPrint('PassengerSocket: missing backend JWT — skip connect');
      }
      _setStatus(PassengerSocketConnectionStatus.authFailed);
      return;
    }

    _connecting = true;
    _setStatus(PassengerSocketConnectionStatus.connecting);
    try {
      await disconnect(preserveActiveBooking: true);
      final socket = io.io(
        ApiConstants.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setAuth({'token': token})
            .enableReconnection()
            .build(),
      );

      socket.onConnect((_) {
        if (kDebugMode) debugPrint('PassengerSocket: connected');
        _setStatus(PassengerSocketConnectionStatus.connected);
      });
      socket.onReconnect((_) {
        _setStatus(PassengerSocketConnectionStatus.connected);
      });
      socket.onReconnectAttempt((_) {
        _setStatus(PassengerSocketConnectionStatus.reconnecting);
      });
      socket.on('authenticated', (_) {
        _authenticatedController.add(true);
        _setStatus(PassengerSocketConnectionStatus.connected);
      });
      socket.on('unauthorized', (_) {
        _setStatus(PassengerSocketConnectionStatus.authFailed);
      });
      socket.on('booking:searching', (data) => _emitBooking('searching', data));
      socket.on('booking:accepted', (data) => _emitBooking('accepted', data));
      socket.on('booking:status', (data) => _emitBooking('status', data));
      socket.on('booking:expired', (data) => _emitBooking('expired', data));
      socket.on(
        'recording:consent_updated',
        (data) => _emitRecording('recording:consent_updated', data),
      );
      socket.on(
        'recording:session_available',
        (data) => _emitRecording('recording:session_available', data),
      );
      socket.on('driver:location', (data) {
        final location = RidePlanningParsers.driverLocation(data);
        if (location == null) return;
        if (_activeBookingId != null &&
            location.bookingId != _activeBookingId) {
          return;
        }
        if (!location.latitude.isFinite ||
            !location.longitude.isFinite ||
            (location.latitude == 0 && location.longitude == 0)) {
          return;
        }
        _driverLocationController.add(location);
      });
      socket.onDisconnect((_) {
        if (kDebugMode) debugPrint('PassengerSocket: disconnected');
        if (_status != PassengerSocketConnectionStatus.authFailed) {
          _setStatus(PassengerSocketConnectionStatus.disconnected);
        }
      });
      socket.onConnectError((err) {
        if (kDebugMode) debugPrint('PassengerSocket: connect error $err');
        _setStatus(PassengerSocketConnectionStatus.disconnected);
      });

      _socket = socket;
      socket.connect();
    } finally {
      _connecting = false;
    }
  }

  void _emitBooking(String event, dynamic data) {
    final map = <String, dynamic>{'event': event};
    if (data is Map) {
      map.addAll(Map<String, dynamic>.from(data));
    } else if (data != null) {
      map['payload'] = data;
    }
    final bookingId = map['bookingId']?.toString();
    if (_activeBookingId != null &&
        bookingId != null &&
        bookingId != _activeBookingId) {
      return;
    }
    _bookingStatusController.add(map);
  }

  void _emitRecording(String event, dynamic data) {
    final map = <String, dynamic>{'event': event};
    if (data is Map) {
      map.addAll(Map<String, dynamic>.from(data));
    } else if (data != null) {
      map['payload'] = data;
    }
    final bookingId =
        map['bookingId']?.toString() ?? map['booking_id']?.toString();
    if (_activeBookingId != null &&
        bookingId != null &&
        bookingId.isNotEmpty &&
        bookingId != _activeBookingId) {
      return;
    }
    if (!_recordingEventController.isClosed) {
      _recordingEventController.add(map);
    }
  }

  Future<void> disconnect({bool preserveActiveBooking = false}) async {
    final socket = _socket;
    _socket = null;
    if (!preserveActiveBooking) {
      _activeBookingId = null;
    }
    _setStatus(PassengerSocketConnectionStatus.disconnected);
    if (socket == null) return;
    try {
      socket.clearListeners();
      socket.disconnect();
      socket.dispose();
    } catch (_) {}
  }

  Future<void> dispose() async {
    await disconnect();
    await _bookingStatusController.close();
    await _driverLocationController.close();
    await _recordingEventController.close();
    await _authenticatedController.close();
    await _connectionStatusController.close();
  }
}
