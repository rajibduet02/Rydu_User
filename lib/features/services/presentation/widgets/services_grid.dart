import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/service_catalog_entry_entity.dart';
import '../providers/services_dependencies.dart';
import 'service_card.dart';

class ServiceGridItem {
  const ServiceGridItem({
    required this.id,
    required this.label,
    required this.emoji,
    this.discountLabel,
    required this.iconAccent,
    required this.dimmed,
  });

  final String id;
  final String label;
  final String emoji;
  final String? discountLabel;
  final Color iconAccent;
  final bool dimmed;
}

/// Two-column responsive grid of [ServiceCard]s.
class ServicesGrid extends StatelessWidget {
  const ServicesGrid({
    super.key,
    required this.items,
    required this.selectedService,
    required this.onOpenService,
  });

  final List<ServiceGridItem> items;
  final String? selectedService;
  final ValueChanged<String> onOpenService;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final gap = (w * 0.04).clamp(14.0, 18.0);
    final ratio = (w * 0.0024).clamp(0.68, 0.78);

    return LayoutBuilder(
      builder: (context, constraints) {
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: gap,
            crossAxisSpacing: gap,
            childAspectRatio: ratio,
          ),
          itemCount: items.length,
          itemBuilder: (context, index) {
            final item = items[index];
            return ServiceCard(
              label: item.label,
              emoji: item.emoji,
              discountLabel: item.discountLabel,
              iconAccent: item.iconAccent,
              isDimmed: item.dimmed,
              isSelected: selectedService == item.id,
              onTap: () => onOpenService(item.id),
            );
          },
        );
      },
    );
  }
}

ServiceGridItem serviceGridItemFromEntity(ServiceCatalogEntryEntity entry) {
  return ServiceGridItem(
    id: entry.id,
    label: entry.label,
    emoji: entry.emoji,
    discountLabel: entry.discountLabel,
    iconAccent: Color(entry.iconAccentArgb),
    dimmed: entry.dimmed,
  );
}

/// Default catalog matching React / screenshot.
List<ServiceGridItem> defaultServiceGridItems(WidgetRef ref) {
  final catalog = ref.read(getServicesCatalogUsecaseProvider).call();
  return catalog.map(serviceGridItemFromEntity).toList();
}
