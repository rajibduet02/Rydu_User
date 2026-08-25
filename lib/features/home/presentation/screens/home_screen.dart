import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/shell_scroll_padding.dart';
import '../../../push/presentation/passenger_push_controller.dart';
import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';
import '../providers/home_controller.dart';
import '../theme/home_screen_tokens.dart';
import '../widgets/home_active_ride_card.dart';
import '../widgets/home_promo_card.dart';
import '../widgets/home_search_bar.dart';
import '../widgets/home_top_bar.dart';
import '../widgets/ride_category_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(homeControllerProvider.notifier).resetBottomNav();
      unawaited(_restoreActiveBookingQuietly());
      unawaited(
        ref
            .read(passengerPushControllerProvider.notifier)
            .onAuthenticatedSurfaceReady(),
      );
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_restoreActiveBookingQuietly());
    }
  }

  Future<void> _restoreActiveBookingQuietly() async {
    try {
      await ref
          .read(rideBookingControllerProvider.notifier)
          .restoreActiveBooking(navigate: false);
    } catch (_) {
      // Keep browsing Home; card appears if restore succeeds later.
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(homeControllerProvider);
    final c = ref.read(homeControllerProvider.notifier);
    final ride = ref.watch(rideBookingControllerProvider);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final sectionGap = (w * 0.045).clamp(18.0, 24.0);
    final categories =
        <
          ({
            String id,
            String label,
            String emoji,
            String? discount,
            bool bookable,
          })
        >[
          (
            id: HomeCategoryIds.ride,
            label: 'Ride',
            emoji: '🚗',
            discount: '25% OFF',
            bookable: true,
          ),
          (
            id: HomeCategoryIds.bike,
            label: 'Bike',
            emoji: '🏍️',
            discount: '30% OFF',
            bookable: true,
          ),
          (
            id: HomeCategoryIds.cng,
            label: 'CNG',
            emoji: '⚡',
            discount: '20% OFF',
            bookable: true,
          ),
          (
            id: HomeCategoryIds.rentals,
            label: 'Rentals',
            emoji: '🚙',
            discount: null,
            bookable: false,
          ),
        ];

    return SafeArea(
      bottom: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          hPad,
          12,
          hPad,
          ShellScrollPadding.tabScrollBottom(context),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HomeTopBar(
              onLocationTap: () => c.getCurrentLocation(),
              onNotificationTap: c.openNotifications,
              hasUnreadNotification: s.hasUnreadNotification,
            ),
            const SizedBox(height: 28),
            HomeSearchBar(
              onSearchTap: c.openSearch,
              onLaterTap: c.openReserveFlow,
            ),
            if (ride.hasActiveBooking) ...[
              const SizedBox(height: 16),
              const HomeActiveRideCard(),
            ],
            if (s.errorMessage != null) ...[
              const SizedBox(height: 8),
              Text(
                s.errorMessage!,
                style: TextStyle(
                  color: Theme.of(context).colorScheme.error,
                  fontSize: 13,
                ),
              ),
            ],
            const SizedBox(height: 22),
            _ForYouHeader(onArrowTap: c.openOffers),
            SizedBox(height: (w * 0.035).clamp(12.0, 16.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (var i = 0; i < categories.length; i++) ...[
                  if (i > 0) SizedBox(width: (w * 0.025).clamp(8.0, 12.0)),
                  Expanded(
                    child: RideCategoryCard(
                      label: categories[i].label,
                      emoji: categories[i].emoji,
                      discountLabel: categories[i].discount,
                      isSelected: s.selectedCategory == categories[i].id,
                      bookable: categories[i].bookable,
                      onTap: () {
                        if (categories[i].id == HomeCategoryIds.rentals) {
                          c.openRentals();
                        } else if (categories[i].bookable) {
                          c.openRideBooking(categories[i].id);
                        }
                      },
                    ),
                  ),
                ],
              ],
            ),
            SizedBox(height: sectionGap),
            _SectionTitle('Commute smarter'),
            SizedBox(height: (w * 0.035).clamp(12.0, 16.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: HomePromoCard(
                    title: 'Go with RYD U CNG',
                    subtitle: 'Eco-friendly rides',
                    style: HomePromoStyle.green,
                    backgroundEmoji: '⚡',
                    onTap: c.selectPromoCng,
                  ),
                ),
                SizedBox(width: (w * 0.025).clamp(10.0, 14.0)),
                Expanded(
                  child: HomePromoCard(
                    title: 'Hop on RYD U',
                    subtitle: 'Move through',
                    style: HomePromoStyle.dark,
                    backgroundEmoji: '🏍️',
                    onTap: c.selectPromoHopOn,
                  ),
                ),
              ],
            ),
            SizedBox(height: sectionGap),
            _SectionTitle('Elevate your ride'),
            SizedBox(height: (w * 0.035).clamp(12.0, 16.0)),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: HomePromoCard(
                    title: 'Premium',
                    subtitle: 'Luxury experience',
                    style: HomePromoStyle.blue,
                    backgroundEmoji: '🚗',
                    onTap: c.selectPromoPremium,
                  ),
                ),
                SizedBox(width: (w * 0.025).clamp(10.0, 14.0)),
                Expanded(
                  child: HomePromoCard(
                    title: 'Comfort',
                    subtitle: 'Affordable luxury',
                    style: HomePromoStyle.darkOutlined,
                    backgroundEmoji: '🚙',
                    onTap: c.selectPromoComfort,
                  ),
                ),
              ],
            ),
            SizedBox(height: (w * 0.2).clamp(72.0, 100.0)),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final size = (w * 0.045).clamp(16.0, 18.0);
    return Text(
      text,
      style: TextStyle(
        color: HomeScreenTokens.white,
        fontSize: size,
        fontWeight: FontWeight.w700,
      ),
    );
  }
}

class _ForYouHeader extends StatelessWidget {
  const _ForYouHeader({required this.onArrowTap});

  final VoidCallback onArrowTap;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.045).clamp(16.0, 18.0);
    final btn = (w * 0.1).clamp(36.0, 40.0);

    return Row(
      children: [
        Expanded(
          child: Text(
            'For you',
            style: TextStyle(
              color: HomeScreenTokens.white,
              fontSize: titleSize,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onArrowTap,
            customBorder: const CircleBorder(),
            child: Ink(
              width: btn,
              height: btn,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    HomeScreenTokens.accent.withValues(alpha: 0.18),
                    HomeScreenTokens.accentSoft.withValues(alpha: 0.12),
                  ],
                ),
                border: Border.all(
                  color: HomeScreenTokens.accent.withValues(alpha: 0.45),
                ),
              ),
              child: Icon(
                Icons.arrow_forward_rounded,
                color: HomeScreenTokens.accent,
                size: btn * 0.45,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
