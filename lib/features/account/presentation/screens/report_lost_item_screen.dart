import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/report_lost_item_provider.dart';
import '../theme/report_lost_item_tokens.dart';
import '../widgets/contact_preference_selector.dart';
import '../widgets/lost_item_notice_card.dart';
import '../widgets/lost_item_trip_selector.dart';

class ReportLostItemScreen extends ConsumerStatefulWidget {
  const ReportLostItemScreen({super.key});

  @override
  ConsumerState<ReportLostItemScreen> createState() =>
      _ReportLostItemScreenState();
}

class _ReportLostItemScreenState extends ConsumerState<ReportLostItemScreen> {
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(reportLostItemControllerProvider.notifier).loadTrips();
    });
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  void _popOrHelpCenter(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.helpCenter);
    }
  }

  void _showTripPicker() {
    final s = ref.read(reportLostItemControllerProvider);
    final c = ref.read(reportLostItemControllerProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ReportLostItemTokens.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Select completed trip',
                  style: TextStyle(
                    color: ReportLostItemTokens.white,
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                  ),
                ),
              ),
              ...s.trips.map((trip) {
                final selected = s.selectedTrip?.id == trip.id;
                return ListTile(
                  leading: Icon(
                    Icons.directions_car_outlined,
                    color: selected
                        ? ReportLostItemTokens.accentSolid
                        : ReportLostItemTokens.muted,
                  ),
                  title: Text(
                    trip.vehicleName,
                    style: TextStyle(
                      color: ReportLostItemTokens.white,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    trip.subtitle,
                    style: const TextStyle(color: ReportLostItemTokens.muted),
                  ),
                  trailing: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: ReportLostItemTokens.accentSolid,
                        )
                      : null,
                  onTap: () {
                    c.selectTrip(trip.id);
                    Navigator.of(ctx).pop();
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionLabel(String text, double w) {
    return Padding(
      padding: EdgeInsets.only(bottom: (w * 0.02).clamp(8.0, 10.0)),
      child: Text(
        text,
        style: TextStyle(
          color: ReportLostItemTokens.label,
          fontSize: (w * 0.028).clamp(10.0, 11.0),
          fontWeight: FontWeight.w600,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  InputDecoration _fieldDecoration(String hint, double w) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(
        color: ReportLostItemTokens.placeholder,
        fontSize: (w * 0.038).clamp(14.0, 15.0),
      ),
      filled: true,
      fillColor: ReportLostItemTokens.field,
      contentPadding: const EdgeInsets.all(14),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: ReportLostItemTokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(
          color: ReportLostItemTokens.accentSolid,
          width: 1.2,
        ),
      ),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(reportLostItemControllerProvider);
    final c = ref.read(reportLostItemControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = 16.0;
    final titleSize = (w * 0.05).clamp(18.0, 20.0);
    final subSize = (w * 0.038).clamp(14.0, 15.0);
    final gap = (w * 0.05).clamp(18.0, 22.0);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    ref.listen(reportLostItemControllerProvider, (prev, next) {
      final snack = next.snackMessage;
      if (snack != null && snack.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snack),
            backgroundColor: ReportLostItemTokens.card,
          ),
        );
        c.clearSnack();
        if (next.submitSucceeded) {
          Future<void>.delayed(const Duration(milliseconds: 400), () {
            if (!context.mounted) return;
            c.navigateAfterSuccess();
          });
        }
      }
    });

    return Scaffold(
      backgroundColor: ReportLostItemTokens.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => _popOrHelpCenter(context),
                    icon: Icon(
                      Icons.arrow_back_ios_new_rounded,
                      color: ReportLostItemTokens.white,
                      size: (w * 0.05).clamp(20.0, 22.0),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Report Lost Item',
                      style: TextStyle(
                        color: ReportLostItemTokens.white,
                        fontWeight: FontWeight.w800,
                        fontSize: titleSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Text(
                "Tell us what you lost and we'll help contact the driver.",
                style: TextStyle(
                  color: ReportLostItemTokens.muted,
                  fontSize: subSize,
                  height: 1.4,
                ),
              ),
            ),
            if (s.errorMessage != null)
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                child: Text(
                  s.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _sectionLabel('SELECT COMPLETED TRIP', w),
                    LostItemTripSelector(
                      trip: s.selectedTrip,
                      onTap: _showTripPicker,
                    ),
                    SizedBox(height: gap),
                    _sectionLabel('ITEM DESCRIPTION', w),
                    TextField(
                      controller: _descriptionController,
                      onChanged: c.updateItemDescription,
                      maxLines: 5,
                      minLines: 4,
                      style: TextStyle(
                        color: ReportLostItemTokens.white,
                        fontSize: (w * 0.038).clamp(14.0, 15.0),
                        height: 1.45,
                      ),
                      decoration: _fieldDecoration(
                        'Describe the item (color, brand, etc.)...',
                        w,
                      ),
                    ),
                    SizedBox(height: gap),
                    _sectionLabel('LAST SEEN LOCATION', w),
                    TextField(
                      controller: _locationController,
                      onChanged: c.updateLastSeenLocation,
                      style: TextStyle(
                        color: ReportLostItemTokens.white,
                        fontSize: (w * 0.038).clamp(14.0, 15.0),
                      ),
                      decoration:
                          _fieldDecoration(
                            'Where was it left? (e.g., Back seat, trunk)',
                            w,
                          ).copyWith(
                            prefixIcon: Icon(
                              Icons.location_on_outlined,
                              color: ReportLostItemTokens.muted,
                              size: (w * 0.05).clamp(20.0, 22.0),
                            ),
                          ),
                    ),
                    SizedBox(height: gap),
                    _sectionLabel('CONTACT PREFERENCE', w),
                    ContactPreferenceSelector(
                      selected: s.contactPreference,
                      onSelected: c.selectContactPreference,
                    ),
                    SizedBox(height: (w * 0.035).clamp(12.0, 14.0)),
                    const LostItemNoticeCard(),
                    const SizedBox(height: 88),
                  ],
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                hPad,
                8,
                hPad,
                12 + MediaQuery.paddingOf(context).bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                height: (w * 0.14).clamp(52.0, 56.0),
                child: FilledButton(
                  onPressed: s.isFormValid && !s.isSubmitting
                      ? () => c.submitReport()
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: ReportLostItemTokens.accent,
                    disabledBackgroundColor: ReportLostItemTokens.accent
                        .withValues(alpha: 0.35),
                    foregroundColor: ReportLostItemTokens.buttonTextDark,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        (w * 0.04).clamp(14.0, 16.0),
                      ),
                    ),
                    elevation: 0,
                  ),
                  child: s.isSubmitting
                      ? SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: ReportLostItemTokens.buttonTextDark,
                          ),
                        )
                      : Text(
                          'Submit Report',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: (w * 0.042).clamp(15.0, 16.0),
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
