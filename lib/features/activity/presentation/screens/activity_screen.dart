import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/shell_scroll_padding.dart';
import '../providers/activity_controller.dart';
import '../theme/activity_screen_tokens.dart';
import '../widgets/activity_empty_state.dart';
import '../widgets/activity_filter_bottom_sheet.dart';

class ActivityScreen extends ConsumerStatefulWidget {
  const ActivityScreen({super.key});

  @override
  ConsumerState<ActivityScreen> createState() => _ActivityScreenState();
}

class _ActivityScreenState extends ConsumerState<ActivityScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(activityControllerProvider.notifier).resetForActivityTab();
    });
  }

  Future<void> _showFilterSheet() async {
    ref.read(activityControllerProvider.notifier).openFilter();
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black.withValues(alpha: 0.55),
      shape: const RoundedRectangleBorder(side: BorderSide.none),
      builder: (ctx) {
        final h = MediaQuery.sizeOf(ctx).height;
        final navClearance = ShellScrollPadding.tabScrollBottom(ctx);
        return Padding(
          padding: EdgeInsets.only(top: h * 0.12),
          child: ConstrainedBox(
            constraints: BoxConstraints(maxHeight: h * 0.88 - navClearance),
            child: const ActivityFilterBottomSheet(),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(activityControllerProvider);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.12).clamp(36.0, 44.0);
    final pastSize = (w * 0.065).clamp(22.0, 26.0);
    final filterBtn = (w * 0.12).clamp(44.0, 48.0);
    final viewHeight = MediaQuery.sizeOf(context).height;

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          hPad,
          16,
          hPad,
          ShellScrollPadding.tabScrollBottom(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Activity',
              style: TextStyle(
                color: ActivityScreenTokens.white,
                fontSize: titleSize,
                fontWeight: FontWeight.w800,
                height: 1.05,
              ),
            ),
            SizedBox(height: (w * 0.06).clamp(22.0, 32.0)),
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Past',
                    style: TextStyle(
                      color: ActivityScreenTokens.white,
                      fontSize: pastSize,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Material(
                  color: Colors.transparent,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: s.isLoading ? null : _showFilterSheet,
                    child: Ink(
                      width: filterBtn,
                      height: filterBtn,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: ActivityScreenTokens.sheet,
                        border: Border.all(color: ActivityScreenTokens.border),
                      ),
                      child: Icon(
                        Icons.tune_rounded,
                        color: ActivityScreenTokens.muted,
                        size: filterBtn * 0.42,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (s.errorMessage != null) ...[
              const SizedBox(height: 12),
              Text(
                s.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
            SizedBox(height: (w * 0.08).clamp(28.0, 40.0)),
            if (s.isEmptyFeed)
              SizedBox(
                height: (viewHeight * 0.32).clamp(180.0, 260.0),
                child: const ActivityEmptyState(),
              )
            else
              ...s.activities.map(
                (e) => Card(
                  color: ActivityScreenTokens.sheet,
                  margin: const EdgeInsets.only(bottom: 10),
                  child: ListTile(
                    title: Text(
                      e.title,
                      style: const TextStyle(
                        color: ActivityScreenTokens.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: Text(
                      e.subtitle,
                      style: const TextStyle(color: ActivityScreenTokens.muted),
                    ),
                    trailing: Text(
                      e.timestampLabel,
                      style: const TextStyle(
                        color: ActivityScreenTokens.muted,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
