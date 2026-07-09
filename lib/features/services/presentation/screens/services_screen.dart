import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/shell_scroll_padding.dart';
import '../providers/services_controller.dart';
import '../theme/services_screen_tokens.dart';
import '../widgets/services_grid.dart';

class ServicesScreen extends ConsumerStatefulWidget {
  const ServicesScreen({super.key});

  @override
  ConsumerState<ServicesScreen> createState() => _ServicesScreenState();
}

class _ServicesScreenState extends ConsumerState<ServicesScreen> {
  late final List<ServiceGridItem> _items;

  @override
  void initState() {
    super.initState();
    _items = defaultServiceGridItems(ref);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(servicesControllerProvider.notifier).resetForServicesTab();
    });
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(servicesControllerProvider);
    final c = ref.read(servicesControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(16.0, 22.0);
    final titleSize = (w * 0.09).clamp(30.0, 36.0);
    final subSize = (w * 0.045).clamp(15.0, 17.0);
    return SafeArea(
      bottom: false,
      child: AbsorbPointer(
        absorbing: s.isLoading,
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
                'Services',
                style: TextStyle(
                  color: ServicesScreenTokens.white,
                  fontSize: titleSize,
                  fontWeight: FontWeight.w800,
                  height: 1.1,
                ),
              ),
              SizedBox(height: (w * 0.02).clamp(8.0, 12.0)),
              Text(
                'Go anywhere, get anything',
                style: TextStyle(
                  color: ServicesScreenTokens.muted,
                  fontSize: subSize,
                  fontWeight: FontWeight.w400,
                  height: 1.35,
                ),
              ),
              SizedBox(height: (w * 0.06).clamp(22.0, 28.0)),
              if (s.errorMessage != null) ...[
                Text(
                  s.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 12),
              ],
              ServicesGrid(
                items: _items,
                selectedService: s.selectedService,
                onOpenService: (id) => c.openService(id),
              ),
              if (s.isLoading) ...[
                const SizedBox(height: 12),
                const Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
