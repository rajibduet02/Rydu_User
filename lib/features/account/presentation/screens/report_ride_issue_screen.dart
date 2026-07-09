import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/report_ride_issue_provider.dart';
import '../theme/report_ride_issue_tokens.dart';
import '../widgets/issue_type_chip.dart';
import '../widgets/ride_issue_trip_selector.dart';
import '../widgets/support_notice_card.dart';
import '../widgets/upload_photo_box.dart';

class ReportRideIssueScreen extends ConsumerStatefulWidget {
  const ReportRideIssueScreen({super.key});

  @override
  ConsumerState<ReportRideIssueScreen> createState() =>
      _ReportRideIssueScreenState();
}

class _ReportRideIssueScreenState extends ConsumerState<ReportRideIssueScreen> {
  final _detailsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(reportRideIssueControllerProvider.notifier).loadTrips();
    });
  }

  @override
  void dispose() {
    _detailsController.dispose();
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
    final s = ref.read(reportRideIssueControllerProvider);
    final c = ref.read(reportRideIssueControllerProvider.notifier);
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ReportRideIssueTokens.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Select trip',
                  style: TextStyle(
                    color: ReportRideIssueTokens.white,
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
                        ? ReportRideIssueTokens.accentSolid
                        : ReportRideIssueTokens.muted,
                  ),
                  title: Text(
                    trip.title,
                    style: TextStyle(
                      color: ReportRideIssueTokens.white,
                      fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    trip.subtitle,
                    style: const TextStyle(color: ReportRideIssueTokens.muted),
                  ),
                  trailing: selected
                      ? const Icon(
                          Icons.check_rounded,
                          color: ReportRideIssueTokens.accentSolid,
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

  Widget _labeledCard({
    required String label,
    required Widget child,
    required double w,
  }) {
    final radius = (w * 0.04).clamp(14.0, 16.0);
    final labelSize = (w * 0.028).clamp(10.0, 11.0);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all((w * 0.045).clamp(16.0, 18.0)),
      decoration: BoxDecoration(
        color: ReportRideIssueTokens.card,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: ReportRideIssueTokens.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            label,
            style: TextStyle(
              color: ReportRideIssueTokens.label,
              fontSize: labelSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.1,
            ),
          ),
          SizedBox(height: (w * 0.035).clamp(12.0, 14.0)),
          child,
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(reportRideIssueControllerProvider);
    final c = ref.read(reportRideIssueControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.035).clamp(14.0, 16.0);
    final titleSize = (w * 0.05).clamp(18.0, 20.0);
    final subSize = (w * 0.038).clamp(14.0, 15.0);
    final gap = (w * 0.035).clamp(12.0, 14.0);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final hasPhoto =
        s.uploadedPhotoPath != null && s.uploadedPhotoPath!.isNotEmpty;

    ref.listen(reportRideIssueControllerProvider, (prev, next) {
      final snack = next.snackMessage;
      if (snack != null && snack.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(snack),
            backgroundColor: ReportRideIssueTokens.card,
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
      backgroundColor: ReportRideIssueTokens.background,
      resizeToAvoidBottomInset: true,
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
                      color: ReportRideIssueTokens.white,
                      size: (w * 0.05).clamp(20.0, 22.0),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      'Report Ride Issue',
                      style: TextStyle(
                        color: ReportRideIssueTokens.white,
                        fontWeight: FontWeight.w800,
                        fontSize: titleSize,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
              child: Text(
                'Tell us what happened so our support team can review it.',
                style: TextStyle(
                  color: ReportRideIssueTokens.muted,
                  fontSize: subSize,
                  height: 1.4,
                ),
              ),
            ),
            if (s.errorMessage != null)
              Padding(
                padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 0),
                child: Text(
                  s.errorMessage!,
                  style: const TextStyle(color: Colors.redAccent, fontSize: 13),
                ),
              ),
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 24 + bottomInset),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _labeledCard(
                      label: 'SELECT TRIP',
                      w: w,
                      child: RideIssueTripSelector(
                        trip: s.selectedTrip,
                        onTap: _showTripPicker,
                      ),
                    ),
                    SizedBox(height: gap),
                    _labeledCard(
                      label: 'ISSUE TYPE',
                      w: w,
                      child: GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: gap,
                        crossAxisSpacing: gap,
                        childAspectRatio: 2.6,
                        children: kIssueTypes.map((type) {
                          return IssueTypeChip(
                            issueType: type,
                            label: kIssueTypeLabels[type] ?? type,
                            isSelected: s.selectedIssueType == type,
                            onTap: () => c.selectIssueType(type),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: gap),
                    _labeledCard(
                      label: 'DETAILS',
                      w: w,
                      child: TextField(
                        controller: _detailsController,
                        onChanged: c.updateDetails,
                        maxLines: 6,
                        minLines: 5,
                        style: TextStyle(
                          color: ReportRideIssueTokens.white,
                          fontSize: (w * 0.038).clamp(14.0, 15.0),
                          height: 1.45,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Describe what happened in detail...',
                          hintStyle: TextStyle(
                            color: ReportRideIssueTokens.placeholder,
                            fontSize: (w * 0.038).clamp(14.0, 15.0),
                          ),
                          filled: true,
                          fillColor: ReportRideIssueTokens.field,
                          contentPadding: const EdgeInsets.all(14),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: ReportRideIssueTokens.border,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(
                              color: ReportRideIssueTokens.accentSolid,
                              width: 1.2,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: gap),
                    _labeledCard(
                      label: 'UPLOAD PHOTO',
                      w: w,
                      child: Row(
                        children: [
                          UploadPhotoBox(
                            kind: UploadPhotoBoxKind.camera,
                            onTap: c.pickFromCamera,
                          ),
                          SizedBox(width: gap),
                          UploadPhotoBox(
                            kind: UploadPhotoBoxKind.gallery,
                            onTap: c.pickFromGallery,
                          ),
                          if (hasPhoto) ...[
                            SizedBox(width: gap),
                            UploadPhotoBox(
                              kind: UploadPhotoBoxKind.preview,
                              onRemove: c.removePhoto,
                            ),
                          ],
                        ],
                      ),
                    ),
                    SizedBox(height: gap + 4),
                    const SupportNoticeCard(),
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
                      ? () => c.submitTicket()
                      : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: ReportRideIssueTokens.accent,
                    disabledBackgroundColor: ReportRideIssueTokens.accent
                        .withValues(alpha: 0.35),
                    foregroundColor: ReportRideIssueTokens.buttonTextDark,
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
                            color: ReportRideIssueTokens.buttonTextDark,
                          ),
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              'Submit Ticket',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                fontSize: (w * 0.042).clamp(15.0, 16.0),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(
                              Icons.send_rounded,
                              size: (w * 0.05).clamp(20.0, 22.0),
                              color: ReportRideIssueTokens.buttonTextDark,
                            ),
                          ],
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
