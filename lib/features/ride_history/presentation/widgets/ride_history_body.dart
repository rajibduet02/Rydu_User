import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/router/route_names.dart';
import '../../../../app/router/shell_scroll_padding.dart';
import '../../../../core/widgets/app_loader.dart';
import '../../../home/presentation/widgets/home_active_ride_card.dart';
import '../../../ride_booking/presentation/providers/ride_booking_provider.dart';
import '../providers/ride_history_provider.dart';
import '../theme/ride_history_tokens.dart';
import 'ride_history_card.dart';

class RideHistoryBody extends ConsumerStatefulWidget {
  const RideHistoryBody({
    super.key,
    required this.title,
    this.showBackButton = false,
    this.useShellBottomPadding = false,
  });

  final String title;
  final bool showBackButton;
  final bool useShellBottomPadding;

  @override
  ConsumerState<RideHistoryBody> createState() => _RideHistoryBodyState();
}

class _RideHistoryBodyState extends ConsumerState<RideHistoryBody> {
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _scroll.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(rideHistoryControllerProvider.notifier).loadInitial();
    });
  }

  @override
  void dispose() {
    _scroll.removeListener(_onScroll);
    _scroll.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scroll.hasClients) return;
    final position = _scroll.position;
    if (position.pixels >= position.maxScrollExtent - 240) {
      ref.read(rideHistoryControllerProvider.notifier).loadMore();
    }
  }

  Future<void> _onRefresh() async {
    await ref.read(rideHistoryControllerProvider.notifier).refresh();
  }

  void _openPreviousRide(String bookingId) {
    final ride = ref.read(rideBookingControllerProvider);
    if (ride.hasActiveBooking && ride.bookingId == bookingId) {
      ref.read(rideBookingControllerProvider.notifier).resumeActiveRide();
      return;
    }
    ref.read(goRouterProvider).push('${RouteNames.rideDetails}?rideId=$bookingId');
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(rideHistoryControllerProvider);
    final ride = ref.watch(rideBookingControllerProvider);
    final c = ref.read(rideHistoryControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final titleSize = (w * 0.12).clamp(32.0, 44.0);
    final sectionSize = (w * 0.055).clamp(20.0, 24.0);
    final bottom = widget.useShellBottomPadding
        ? ShellScrollPadding.tabScrollBottom(context)
        : 24.0 + MediaQuery.paddingOf(context).bottom;
    final activeId = ride.hasActiveBooking ? ride.bookingId : null;
    final previous = history.previousRides(activeBookingId: activeId);
    final showInitialLoader =
        history.isInitialLoading && !history.hasFetched && previous.isEmpty;

    return ColoredBox(
      color: RideHistoryTokens.background,
      child: SafeArea(
        bottom: false,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
              child: Row(
                children: [
                  if (widget.showBackButton) ...[
                    IconButton(
                      onPressed: () {
                        final router = ref.read(goRouterProvider);
                        if (router.canPop()) {
                          router.pop();
                        } else {
                          router.go(RouteNames.account);
                        }
                      },
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: RideHistoryTokens.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                  ],
                  Expanded(
                    child: Text(
                      widget.title,
                      style: TextStyle(
                        color: RideHistoryTokens.white,
                        fontSize: widget.showBackButton
                            ? (w * 0.075).clamp(26.0, 30.0)
                            : titleSize,
                        fontWeight: FontWeight.w800,
                        height: 1.05,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: RefreshIndicator(
                color: RideHistoryTokens.accent,
                backgroundColor: RideHistoryTokens.sheet,
                onRefresh: _onRefresh,
                child: showInitialLoader
                    ? ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        padding: EdgeInsets.fromLTRB(hPad, 48, hPad, bottom),
                        children: [
                          if (ride.hasActiveBooking) ...[
                            const Text(
                              'Active Ride',
                              style: TextStyle(
                                color: RideHistoryTokens.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 20,
                              ),
                            ),
                            const SizedBox(height: 12),
                            const HomeActiveRideCard(showCancel: false),
                            const SizedBox(height: 28),
                          ],
                          const Padding(
                            padding: EdgeInsets.only(top: 32),
                            child: AppLoader(),
                          ),
                        ],
                      )
                    : CustomScrollView(
                        controller: _scroll,
                        physics: const AlwaysScrollableScrollPhysics(),
                        slivers: [
                          SliverPadding(
                            padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 0),
                            sliver: SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (ride.hasActiveBooking) ...[
                                    Text(
                                      'Active Ride',
                                      style: TextStyle(
                                        color: RideHistoryTokens.white,
                                        fontSize: sectionSize,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    const HomeActiveRideCard(showCancel: false),
                                    const SizedBox(height: 28),
                                  ],
                                  Text(
                                    'Previous rides',
                                    style: TextStyle(
                                      color: RideHistoryTokens.white,
                                      fontSize: sectionSize,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  RideHistoryFilterChips(
                                    selected: history.selectedFilter,
                                    onSelected: c.setFilter,
                                  ),
                                  if (history.errorMessage != null) ...[
                                    const SizedBox(height: 12),
                                    _ErrorBanner(
                                      message: history.errorMessage!,
                                      onRetry: history.hasFetched
                                          ? c.refresh
                                          : c.loadInitial,
                                    ),
                                  ],
                                  const SizedBox(height: 16),
                                ],
                              ),
                            ),
                          ),
                          if (previous.isEmpty)
                            SliverFillRemaining(
                              hasScrollBody: false,
                              child: Padding(
                                padding: EdgeInsets.fromLTRB(
                                  hPad,
                                  0,
                                  hPad,
                                  bottom,
                                ),
                                child: _EmptyPrevious(
                                  hasActive: ride.hasActiveBooking,
                                ),
                              ),
                            )
                          else
                            SliverPadding(
                              padding: EdgeInsets.fromLTRB(hPad, 0, hPad, bottom),
                              sliver: SliverList.separated(
                                itemCount:
                                    previous.length +
                                    (history.isLoadingMore ? 1 : 0),
                                separatorBuilder: (_, _) =>
                                    const SizedBox(height: 10),
                                itemBuilder: (context, index) {
                                  if (index >= previous.length) {
                                    return const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Center(
                                        child: SizedBox(
                                          width: 22,
                                          height: 22,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  final booking = previous[index];
                                  return RideHistoryCard(
                                    booking: booking,
                                    onTap: () => _openPreviousRide(booking.id),
                                  );
                                },
                              ),
                            ),
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

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Text(
            message,
            style: const TextStyle(
              color: RideHistoryTokens.danger,
              fontSize: 13,
            ),
          ),
        ),
        TextButton(
          onPressed: onRetry,
          child: const Text('Retry'),
        ),
      ],
    );
  }
}

class _EmptyPrevious extends StatelessWidget {
  const _EmptyPrevious({required this.hasActive});

  final bool hasActive;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        hasActive
            ? 'No previous rides yet.'
            : "You don't have any recent activity",
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: RideHistoryTokens.muted,
          fontSize: 16,
          height: 1.35,
        ),
      ),
    );
  }
}
