import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/shell_scroll_padding.dart';
import '../providers/activity_controller.dart';
import '../theme/activity_screen_tokens.dart';
import 'filter_chip_button.dart';

/// Rounded filter sheet (React `ActivityScreen` modal).
class ActivityFilterBottomSheet extends ConsumerWidget {
  const ActivityFilterBottomSheet({super.key});

  static const _categories = <({String id, String label, String emoji})>[
    (id: ActivityCategoryIds.myOrders, label: 'My orders', emoji: '👤'),
    (id: ActivityCategoryIds.business, label: 'Business', emoji: '💼'),
    (id: ActivityCategoryIds.family, label: 'Family', emoji: '👨‍👩‍👧'),
  ];

  static const _services = <String>[
    ActivityServiceIds.all,
    ActivityServiceIds.rides,
    ActivityServiceIds.eats,
    ActivityServiceIds.twoWheeler,
    ActivityServiceIds.rentals,
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(activityControllerProvider);
    final c = ref.read(activityControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final radius = BorderRadius.vertical(
      top: Radius.circular((w * 0.08).clamp(28.0, 32.0)),
    );
    final bottomPadding = ShellScrollPadding.tabScrollBottom(context);

    return Material(
      color: Colors.transparent,
      child: Container(
        decoration: BoxDecoration(
          color: ActivityScreenTokens.sheet,
          borderRadius: radius,
        ),
        child: SafeArea(
          top: false,
          bottom: false,
          child: Padding(
            padding: EdgeInsets.fromLTRB(
              (w * 0.06).clamp(18.0, 24.0),
              12,
              (w * 0.06).clamp(18.0, 24.0),
              bottomPadding,
            ),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 48,
                      height: 4,
                      decoration: BoxDecoration(
                        color: ActivityScreenTokens.handle,
                        borderRadius: BorderRadius.circular(999),
                      ),
                    ),
                  ),
                  SizedBox(height: (w * 0.045).clamp(16.0, 22.0)),
                  Text(
                    'Filter by...',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: ActivityScreenTokens.white,
                      fontSize: (w * 0.055).clamp(20.0, 24.0),
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
                  Text(
                    'Category',
                    style: TextStyle(
                      color: ActivityScreenTokens.white,
                      fontSize: (w * 0.045).clamp(16.0, 18.0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: (w * 0.03).clamp(12.0, 16.0)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < _categories.length; i++) ...[
                          if (i > 0)
                            SizedBox(width: (w * 0.02).clamp(8.0, 12.0)),
                          FilterChipButton(
                            label: _categories[i].label,
                            selected: s.selectedCategory == _categories[i].id,
                            leading: Text(
                              _categories[i].emoji,
                              style: TextStyle(
                                fontSize: (w * 0.04).clamp(14.0, 16.0),
                              ),
                            ),
                            onTap: () => c.selectCategory(_categories[i].id),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
                  Text(
                    'Services',
                    style: TextStyle(
                      color: ActivityScreenTokens.white,
                      fontSize: (w * 0.045).clamp(16.0, 18.0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: (w * 0.03).clamp(12.0, 16.0)),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < _services.length; i++) ...[
                          if (i > 0)
                            SizedBox(width: (w * 0.02).clamp(8.0, 12.0)),
                          FilterChipButton(
                            label: _services[i],
                            selected: s.selectedService == _services[i],
                            onTap: () => c.selectService(_services[i]),
                          ),
                        ],
                      ],
                    ),
                  ),
                  SizedBox(height: (w * 0.05).clamp(18.0, 24.0)),
                  SizedBox(
                    width: double.infinity,
                    height: (w * 0.14).clamp(52.0, 58.0),
                    child: FilledButton(
                      onPressed: () async {
                        final ok = await c.applyFilters();
                        if (context.mounted && ok) {
                          Navigator.of(context).pop();
                        }
                      },
                      style: FilledButton.styleFrom(
                        backgroundColor: ActivityScreenTokens.white,
                        foregroundColor: ActivityScreenTokens.onLight,
                        elevation: 8,
                        shadowColor: Colors.black26,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        textStyle: TextStyle(
                          fontSize: (w * 0.045).clamp(16.0, 18.0),
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      child: const Text('Apply'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
