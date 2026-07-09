import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/offers_provider.dart';
import '../theme/offers_tokens.dart';
import '../widgets/offer_card.dart';

class OffersScreen extends ConsumerStatefulWidget {
  const OffersScreen({super.key});

  @override
  ConsumerState<OffersScreen> createState() => _OffersScreenState();
}

class _OffersScreenState extends ConsumerState<OffersScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(offersControllerProvider.notifier).loadOffers();
    });
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(offersControllerProvider);
    final c = ref.read(offersControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.05).clamp(18.0, 22.0);
    final offers = state.offers;

    return Scaffold(
      backgroundColor: OffersTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad * 0.2, 8, hPad, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: IconButton(
                  onPressed: _goBack,
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: OffersTokens.white,
                  ),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                ),
              ),
            ),
            Expanded(
              child: state.isLoading && offers.isEmpty
                  ? const Center(
                      child: CircularProgressIndicator(
                        color: OffersTokens.muted,
                        strokeWidth: 2,
                      ),
                    )
                  : ListView.builder(
                      padding: EdgeInsets.only(
                        bottom: MediaQuery.paddingOf(context).bottom + 24,
                      ),
                      itemCount: offers.length,
                      itemBuilder: (context, index) {
                        final offer = offers[index];
                        return OfferCard(
                          offer: offer,
                          showDivider: index < offers.length - 1,
                          onBookNow: () => c.bookOffer(offer.id),
                        );
                      },
                    ),
            ),
            if (state.errorMessage != null)
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 12),
                child: Text(
                  state.errorMessage!,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: 13,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
