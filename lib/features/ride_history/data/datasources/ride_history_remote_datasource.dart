import 'package:dio/dio.dart';

import '../../../../core/constants/passenger_api_paths.dart';
import '../../../../core/network/api_client.dart';
import '../../../../core/network/api_response_parser.dart';
import '../../../../core/network/passenger_api_error_mapper.dart';
import '../../../ride_booking/data/utils/ride_planning_parsers.dart';
import '../../../ride_booking/domain/entities/ride_planning_entities.dart';
import '../../domain/entities/pagination_meta.dart';
import '../../domain/entities/ride_history_page.dart';
import '../../domain/ride_history_filter.dart';

abstract interface class RideHistoryRemoteDatasource {
  Future<RideHistoryPage> fetchRides({
    required int page,
    required int limit,
    required RideHistoryFilter filter,
  });

  Future<BookingEntity?> fetchRide(String id);
}

class RideHistoryRemoteDatasourceImpl implements RideHistoryRemoteDatasource {
  RideHistoryRemoteDatasourceImpl(this._apiClient);

  final ApiClient _apiClient;

  @override
  Future<RideHistoryPage> fetchRides({
    required int page,
    required int limit,
    required RideHistoryFilter filter,
  }) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.bookings,
        queryParameters: {
          'page': page,
          'limit': limit,
          'filter': filter.queryValue,
        },
      );
      _throwIfFailed(response.data);
      final items = <BookingEntity>[];
      for (final raw in ApiResponseParser.unwrapList(response.data)) {
        final booking = RidePlanningParsers.booking(raw);
        if (booking != null) items.add(booking);
      }
      return RideHistoryPage(
        items: items,
        pagination: _pagination(
          response.data,
          page: page,
          limit: limit,
          itemCount: items.length,
        ),
      );
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  @override
  Future<BookingEntity?> fetchRide(String id) async {
    try {
      final response = await _apiClient.dio.get<dynamic>(
        PassengerApiPaths.bookingById(id),
      );
      _throwIfFailed(response.data);
      final data = ApiResponseParser.unwrapData(response.data);
      return RidePlanningParsers.booking(data['booking'] ?? data);
    } on DioException catch (e) {
      throw PassengerApiErrorMapper.fromDio(e);
    }
  }

  PaginationMeta _pagination(
    dynamic raw, {
    required int page,
    required int limit,
    required int itemCount,
  }) {
    Map<String, dynamic>? pag;
    if (raw is Map) {
      final root = Map<String, dynamic>.from(raw);
      final metadata = root['metadata'];
      if (metadata is Map && metadata['pagination'] is Map) {
        pag = Map<String, dynamic>.from(metadata['pagination'] as Map);
      } else if (root['pagination'] is Map) {
        pag = Map<String, dynamic>.from(root['pagination'] as Map);
      }
    }
    final parsedPage = RidePlanningParsers.asInt(pag?['page']) ?? page;
    final parsedLimit = RidePlanningParsers.asInt(pag?['limit']) ?? limit;
    final total = RidePlanningParsers.asInt(pag?['total']);
    final explicitTotalPages = RidePlanningParsers.asInt(pag?['totalPages']);
    final fallbackTotalPages = itemCount < parsedLimit
        ? parsedPage
        : parsedPage + 1;
    var totalPages = explicitTotalPages ??
        (total != null && parsedLimit > 0
            ? ((total + parsedLimit - 1) / parsedLimit).ceil()
            : fallbackTotalPages);
    if (totalPages < 1) totalPages = 1;
    return PaginationMeta(
      page: parsedPage,
      limit: parsedLimit,
      total: total ?? itemCount,
      totalPages: totalPages,
    );
  }

  void _throwIfFailed(dynamic raw) {
    final error = PassengerApiErrorMapper.fromEnvelope(raw);
    if (error != null) throw error;
  }
}
