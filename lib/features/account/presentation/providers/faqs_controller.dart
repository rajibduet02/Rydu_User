import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../models/faq_item.dart';
import 'account_dependencies.dart';

const kFaqCategoryAll = 'All';
const kFaqCategories = <String>[
  kFaqCategoryAll,
  'Account',
  'Booking',
  'Payment',
  'Rides',
];

class FaqsState {
  const FaqsState({
    this.searchQuery = '',
    this.selectedCategory = kFaqCategoryAll,
    this.expandedFaqIds = const {},
    this.faqs = const [],
    this.filteredFaqs = const [],
    this.isLoading = false,
    this.errorMessage,
  });

  final String searchQuery;
  final String selectedCategory;
  final Set<String> expandedFaqIds;
  final List<FaqItem> faqs;
  final List<FaqItem> filteredFaqs;
  final bool isLoading;
  final String? errorMessage;

  FaqsState copyWith({
    String? searchQuery,
    String? selectedCategory,
    Set<String>? expandedFaqIds,
    List<FaqItem>? faqs,
    List<FaqItem>? filteredFaqs,
    bool? isLoading,
    String? errorMessage,
    bool clearError = false,
  }) {
    return FaqsState(
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      expandedFaqIds: expandedFaqIds ?? this.expandedFaqIds,
      faqs: faqs ?? this.faqs,
      filteredFaqs: filteredFaqs ?? this.filteredFaqs,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }
}

class FaqsController extends Notifier<FaqsState> {
  @override
  FaqsState build() => const FaqsState();

  List<FaqItem> _applyFilters(
    List<FaqItem> source, {
    required String query,
    required String category,
  }) {
    final q = query.trim().toLowerCase();
    return source.where((faq) {
      final matchesCategory =
          category == kFaqCategoryAll || faq.category == category;
      if (!matchesCategory) return false;
      if (q.isEmpty) return true;
      return faq.question.toLowerCase().contains(q) ||
          faq.category.toLowerCase().contains(q) ||
          faq.answer.toLowerCase().contains(q);
    }).toList();
  }

  void _emitFiltered() {
    state = state.copyWith(
      filteredFaqs: _applyFilters(
        state.faqs,
        query: state.searchQuery,
        category: state.selectedCategory,
      ),
      clearError: true,
    );
  }

  void clearError() {
    state = state.copyWith(clearError: true);
  }

  Future<void> loadFaqs() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final data = await ref.read(getFaqsUsecaseProvider).call();
      state = state.copyWith(
        faqs: data.faqs,
        isLoading: false,
        expandedFaqIds: {data.defaultExpandedId},
      );
      _emitFiltered();
    } catch (_) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Could not load FAQs.',
      );
    }
  }

  void updateSearchQuery(String value) {
    state = state.copyWith(searchQuery: value);
    _emitFiltered();
  }

  void selectCategory(String category) {
    if (!kFaqCategories.contains(category)) return;
    state = state.copyWith(selectedCategory: category);
    _emitFiltered();
  }

  void toggleFaq(String faqId) {
    final next = Set<String>.from(state.expandedFaqIds);
    if (next.contains(faqId)) {
      next.remove(faqId);
    } else {
      next.add(faqId);
    }
    state = state.copyWith(expandedFaqIds: next);
  }

  void openLiveChat() {
    ref.read(goRouterProvider).push(RouteNames.liveChat);
  }
}
