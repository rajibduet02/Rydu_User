import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/inbox_controller.dart';
import '../providers/inbox_provider.dart';
import '../theme/inbox_tokens.dart';
import '../widgets/inbox_filter_chip.dart';
import '../widgets/inbox_message_card.dart';

class InboxScreen extends ConsumerStatefulWidget {
  const InboxScreen({super.key});

  @override
  ConsumerState<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends ConsumerState<InboxScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(inboxControllerProvider.notifier).loadMessages();
    });
  }

  void _goBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.account);
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(inboxControllerProvider);
    final c = ref.read(inboxControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.075).clamp(26.0, 30.0);
    final backBtn = (w * 0.1).clamp(40.0, 44.0);
    final chipGap = (w * 0.025).clamp(10.0, 12.0);
    final list = s.filteredMessages;

    return Scaffold(
      backgroundColor: InboxTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
              child: Row(
                children: [
                  Material(
                    color: InboxTokens.iconWell,
                    shape: const CircleBorder(),
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () => _goBack(context),
                      child: DecoratedBox(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: InboxTokens.border),
                        ),
                        child: SizedBox(
                          width: backBtn,
                          height: backBtn,
                          child: Icon(
                            Icons.chevron_left_rounded,
                            color: InboxTokens.white,
                            size: backBtn * 0.55,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(width: (w * 0.03).clamp(12.0, 16.0)),
                  Expanded(
                    child: Text(
                      'Inbox',
                      style: TextStyle(
                        color: InboxTokens.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    InboxFilterChip(
                      label: 'All',
                      selected: s.selectedFilter == InboxFilters.all,
                      onTap: () => c.selectFilter(InboxFilters.all),
                    ),
                    SizedBox(width: chipGap),
                    InboxFilterChip(
                      label: 'Promotions',
                      selected: s.selectedFilter == InboxFilters.promotions,
                      onTap: () => c.selectFilter(InboxFilters.promotions),
                    ),
                    SizedBox(width: chipGap),
                    InboxFilterChip(
                      label: 'Trips',
                      selected: s.selectedFilter == InboxFilters.trips,
                      onTap: () => c.selectFilter(InboxFilters.trips),
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1, thickness: 1, color: InboxTokens.border),
            if (s.isLoading)
              const LinearProgressIndicator(
                minHeight: 2,
                backgroundColor: InboxTokens.border,
                color: InboxTokens.accent,
              ),
            if (s.errorMessage != null)
              Material(
                color: InboxTokens.cardTop,
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.errorMessage!,
                          style: const TextStyle(
                            color: Colors.redAccent,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      TextButton(
                        onPressed: c.clearError,
                        child: const Text('Dismiss'),
                      ),
                    ],
                  ),
                ),
              ),
            Expanded(
              child: ListView.separated(
                padding: EdgeInsets.fromLTRB(
                  hPad,
                  (w * 0.04).clamp(16.0, 20.0),
                  hPad,
                  (w * 0.08).clamp(28.0, 36.0),
                ),
                itemCount: list.length,
                separatorBuilder: (_, _) =>
                    SizedBox(height: (w * 0.03).clamp(10.0, 12.0)),
                itemBuilder: (context, index) {
                  final m = list[index];
                  return InboxMessageCard(
                    message: m,
                    onTap: () => c.openMessage(m.id),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
