import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../domain/constants/inbox_categories.dart';
import '../models/inbox_message.dart';
import 'account_dependencies.dart';

/// Filter segment values (chips).
abstract final class InboxFilters {
  static const all = 'all';
  static const promotions = 'promotions';
  static const trips = 'trips';
}

class InboxState {
  const InboxState({
    this.selectedFilter = InboxFilters.all,
    this.messages = const [],
    this.selectedMessage,
    this.isLoading = false,
    this.errorMessage,
  });

  final String selectedFilter;
  final List<InboxMessage> messages;
  final InboxMessage? selectedMessage;
  final bool isLoading;
  final String? errorMessage;

  List<InboxMessage> get filteredMessages {
    switch (selectedFilter) {
      case InboxFilters.promotions:
        return messages
            .where((m) => m.category == InboxCategories.promotion)
            .toList();
      case InboxFilters.trips:
        return messages
            .where((m) => m.category == InboxCategories.trip)
            .toList();
      default:
        return messages;
    }
  }

  InboxState copyWith({
    String? selectedFilter,
    List<InboxMessage>? messages,
    InboxMessage? selectedMessage,
    bool clearSelectedMessage = false,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return InboxState(
      selectedFilter: selectedFilter ?? this.selectedFilter,
      messages: messages ?? this.messages,
      selectedMessage: clearSelectedMessage
          ? null
          : (selectedMessage ?? this.selectedMessage),
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class InboxController extends Notifier<InboxState> {
  @override
  InboxState build() => const InboxState();

  Future<void> loadMessages() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final messages = await ref.read(getInboxMessagesUsecaseProvider).call();
      state = state.copyWith(messages: messages, isLoading: false);
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load inbox.',
      );
    }
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  void selectFilter(String filter) {
    state = state.copyWith(selectedFilter: filter, clearError: true);
  }

  Future<void> markAsRead(String messageId) async {
    try {
      final messages = await ref
          .read(markInboxMessageReadUsecaseProvider)
          .call(messageId);
      state = state.copyWith(messages: messages);
    } catch (_) {
      // Keep UI responsive if mark-read fails.
    }
  }

  Future<void> openMessage(String messageId) async {
    await markAsRead(messageId);
    final msg = state.messages.firstWhere((m) => m.id == messageId);
    state = state.copyWith(selectedMessage: msg, clearError: true);
    ref.read(goRouterProvider).push(RouteNames.inboxDetail, extra: msg);
  }
}
