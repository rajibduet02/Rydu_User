import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/theme/app_colors.dart';
import '../providers/rental_driver_found_provider.dart';

/// Cancel rental reasons sheet — matches design / React flow.
abstract final class _CancelRentalSheetTokens {
  static const sheetBg = AppDarkSurfaces.surfaceElevated;
  static const reasonBg = AppDarkSurfaces.surfaceContainerLow;
  static const keepBg = AppDarkSurfaces.inputSurface;
  static const border = AppDarkSurfaces.border;
  static const topBorder = AppBrand.primaryBorder;
  static const white = Color(0xFFFFFFFF);
  static const topRadius = 32.0;
  static const reasonRadius = 16.0;
  static const keepRadius = 20.0;
}

const _kCancelReasons = <String>[
  'Driver not getting closer',
  'No helmet provided',
  'Wait time too long',
  'Could not find driver',
  'Driver asked to cancel',
  'Other',
];

class CancelRentalBottomSheet extends ConsumerWidget {
  const CancelRentalBottomSheet({super.key, required this.hostContext});

  /// Scaffold context under the modal (for SnackBar after pop).
  final BuildContext hostContext;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = ref.read(rentalDriverFoundControllerProvider.notifier);
    final media = MediaQuery.of(context);
    final w = media.size.width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final maxH = media.size.height * 0.7;
    final titleSize = (w * 0.05).clamp(18.0, 20.0);
    final reasonSize = (w * 0.04).clamp(15.0, 16.0);

    void closeSheet() {
      Navigator.of(context).pop();
    }

    void onPickReason(String reason) {
      Navigator.of(context).pop();
      final messenger = ScaffoldMessenger.maybeOf(hostContext);
      messenger?.showSnackBar(
        const SnackBar(content: Text('Rental cancelled')),
      );
      c.cancelRental(reason);
    }

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: SizedBox(
          height: maxH,
          child: Container(
            width: double.infinity,
            decoration: const BoxDecoration(
              color: _CancelRentalSheetTokens.sheetBg,
              borderRadius: BorderRadius.vertical(
                top: Radius.circular(_CancelRentalSheetTokens.topRadius),
              ),
              border: Border(
                top: BorderSide(
                  color: _CancelRentalSheetTokens.topBorder,
                  width: 1.5,
                ),
              ),
            ),
            child: SafeArea(
              top: false,
              child: Padding(
                padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            'Why do you want to cancel?',
                            style: TextStyle(
                              color: _CancelRentalSheetTokens.white,
                              fontSize: titleSize,
                              fontWeight: FontWeight.w700,
                              height: 1.25,
                            ),
                          ),
                        ),
                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: closeSheet,
                            customBorder: const CircleBorder(),
                            child: Ink(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: _CancelRentalSheetTokens.keepBg,
                              ),
                              child: const Icon(
                                Icons.close_rounded,
                                color: _CancelRentalSheetTokens.white,
                                size: 20,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Expanded(
                      child: ListView.separated(
                        physics: const ClampingScrollPhysics(),
                        itemCount: _kCancelReasons.length,
                        separatorBuilder: (_, i) => const SizedBox(height: 12),
                        itemBuilder: (ctx, i) {
                          final label = _kCancelReasons[i];
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () => onPickReason(label),
                              borderRadius: BorderRadius.circular(
                                _CancelRentalSheetTokens.reasonRadius,
                              ),
                              child: Ink(
                                width: double.infinity,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 16,
                                ),
                                decoration: BoxDecoration(
                                  color: _CancelRentalSheetTokens.reasonBg,
                                  borderRadius: BorderRadius.circular(
                                    _CancelRentalSheetTokens.reasonRadius,
                                  ),
                                  border: Border.all(
                                    color: _CancelRentalSheetTokens.border,
                                  ),
                                ),
                                child: Text(
                                  label,
                                  textAlign: TextAlign.left,
                                  style: TextStyle(
                                    color: _CancelRentalSheetTokens.white,
                                    fontSize: reasonSize,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: closeSheet,
                      style: FilledButton.styleFrom(
                        backgroundColor: _CancelRentalSheetTokens.keepBg,
                        foregroundColor: _CancelRentalSheetTokens.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                            _CancelRentalSheetTokens.keepRadius,
                          ),
                        ),
                        minimumSize: Size(
                          double.infinity,
                          (w * 0.13).clamp(50.0, 54.0),
                        ),
                      ),
                      child: Text(
                        'Keep my ride',
                        style: TextStyle(
                          fontSize: (w * 0.042).clamp(15.0, 17.0),
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
