import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/faqs_provider.dart';
import '../theme/faqs_tokens.dart';
import '../widgets/faq_category_chip.dart';
import '../widgets/faq_item_tile.dart';
import '../widgets/faq_search_bar.dart';
import '../widgets/faq_support_card.dart';

class FaqsScreen extends ConsumerStatefulWidget {
  const FaqsScreen({super.key});

  @override
  ConsumerState<FaqsScreen> createState() => _FaqsScreenState();
}

class _FaqsScreenState extends ConsumerState<FaqsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(faqsControllerProvider.notifier).loadFaqs();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _popOrHelpCenter(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.helpCenter);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(faqsControllerProvider);
    final c = ref.read(faqsControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.045).clamp(16.0, 20.0);
    final titleSize = (w * 0.048).clamp(17.0, 19.0);
    final headingSize = (w * 0.065).clamp(22.0, 26.0);
    final subSize = (w * 0.038).clamp(14.0, 15.0);

    return Scaffold(
      backgroundColor: FaqsTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(4, 4, hPad, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _popOrHelpCenter(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: FaqsTokens.white,
                      size: (w * 0.05).clamp(20.0, 22.0),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'FAQs',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: FaqsTokens.white,
                        fontWeight: FontWeight.w700,
                        fontSize: titleSize,
                      ),
                    ),
                  ),
                  Text(
                    'SUPPORT',
                    style: TextStyle(
                      color: FaqsTokens.supportHeader,
                      fontSize: (w * 0.028).clamp(10.0, 11.0),
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: s.isLoading && s.faqs.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: FaqsTokens.accentSolid,
                      ),
                    )
                  : SingleChildScrollView(
                      padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            'How can we help?',
                            style: TextStyle(
                              color: FaqsTokens.white,
                              fontWeight: FontWeight.w800,
                              fontSize: headingSize,
                              height: 1.15,
                            ),
                          ),
                          SizedBox(height: (w * 0.025).clamp(8.0, 10.0)),
                          Text(
                            'Find instant answers to common questions about your premium travel experience.',
                            style: TextStyle(
                              color: FaqsTokens.muted,
                              fontSize: subSize,
                              height: 1.45,
                            ),
                          ),
                          SizedBox(height: (w * 0.045).clamp(16.0, 20.0)),
                          FaqSearchBar(
                            controller: _searchController,
                            onChanged: c.updateSearchQuery,
                          ),
                          SizedBox(height: (w * 0.035).clamp(12.0, 16.0)),
                          SizedBox(
                            height: (w * 0.11).clamp(42.0, 48.0),
                            child: ListView(
                              scrollDirection: Axis.horizontal,
                              children: kFaqCategories.map((cat) {
                                return FaqCategoryChip(
                                  label: cat,
                                  isSelected: s.selectedCategory == cat,
                                  onTap: () => c.selectCategory(cat),
                                );
                              }).toList(),
                            ),
                          ),
                          if (s.errorMessage != null) ...[
                            SizedBox(height: 12),
                            Text(
                              s.errorMessage!,
                              style: const TextStyle(
                                color: Colors.redAccent,
                                fontSize: 13,
                              ),
                            ),
                          ],
                          SizedBox(height: (w * 0.04).clamp(14.0, 18.0)),
                          ...s.filteredFaqs.map((faq) {
                            return FaqItemTile(
                              faq: faq,
                              isExpanded: s.expandedFaqIds.contains(faq.id),
                              onTap: () => c.toggleFaq(faq.id),
                              onNeedHelpTap: c.openLiveChat,
                            );
                          }),
                          if (s.filteredFaqs.isEmpty && !s.isLoading)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 24),
                              child: Text(
                                'No questions match your search.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: FaqsTokens.muted,
                                  fontSize: subSize,
                                ),
                              ),
                            ),
                          SizedBox(height: (w * 0.05).clamp(18.0, 24.0)),
                          FaqSupportCard(onContactSupport: c.openLiveChat),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
