import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/terms_controller.dart';
import '../theme/terms_screen_tokens.dart';
import '../widgets/terms_agreement_row.dart';
import '../widgets/terms_description_text.dart';

/// Terms & privacy notice gate before name setup (React `TermsScreen.tsx`).
class TermsScreen extends ConsumerStatefulWidget {
  const TermsScreen({super.key});

  @override
  ConsumerState<TermsScreen> createState() => _TermsScreenState();
}

class _TermsScreenState extends ConsumerState<TermsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(termsControllerProvider.notifier).reset();
    });
  }

  Future<void> _onNext() async {
    final ok = await ref.read(termsControllerProvider.notifier).acceptTerms();
    if (!mounted || !ok) return;
    context.go(RouteNames.nameInput);
  }

  void _openTermsOfUse() => context.push(RouteNames.termsOfUse);

  void _openPrivacyNotice() => context.push(RouteNames.privacyNotice);

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(termsControllerProvider);
    final w = MediaQuery.sizeOf(context).width;
    final horizontal = (w * 0.06).clamp(20.0, 28.0);
    final titleSize = (w * 0.085).clamp(26.0, 32.0);
    final bodySize = (w * 0.042).clamp(15.0, 18.0);
    final insets = MediaQuery.viewInsetsOf(context);
    final keyboardOpen = insets.bottom > 0;

    return Scaffold(
      backgroundColor: TermsScreenTokens.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final topPad = keyboardOpen
                ? 12.0
                : (constraints.maxHeight * 0.02).clamp(12.0, 24.0);
            final afterTitleGap = keyboardOpen
                ? 16.0
                : (constraints.maxHeight * 0.03).clamp(20.0, 32.0);

            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                horizontal,
                topPad,
                horizontal,
                16 + insets.bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Accept RYD U's\nTerms &\nReview Privacy\nNotice",
                    style: TextStyle(
                      color: TermsScreenTokens.title,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      height: 1.12,
                    ),
                  ),
                  SizedBox(height: afterTitleGap),
                  TermsDescriptionText(
                    fontSize: bodySize,
                    height: 1.45,
                    onTermsOfUseTap: _openTermsOfUse,
                    onPrivacyNoticeTap: _openPrivacyNotice,
                  ),
                  SizedBox(height: keyboardOpen ? 20 : 28),
                  TermsAgreementRow(
                    isSelected: s.isAgreed,
                    labelFontSize: bodySize,
                    onTap: () => ref
                        .read(termsControllerProvider.notifier)
                        .toggleAgreement(),
                  ),
                  const SizedBox(height: 12),
                  if (s.errorMessage != null) ...[
                    Text(
                      s.errorMessage!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                  Padding(
                    padding: EdgeInsets.only(bottom: keyboardOpen ? 12 : 0),
                    child: _TermsNextButton(
                      enabled: s.isAgreed && !s.isLoading,
                      isLoading: s.isLoading,
                      fontSize: (w * 0.04).clamp(15.0, 17.0),
                      onPressed: _onNext,
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _TermsNextButton extends StatelessWidget {
  const _TermsNextButton({
    required this.enabled,
    required this.isLoading,
    required this.fontSize,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final double fontSize;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity: enabled ? 1 : 0.35,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: enabled && !isLoading ? onPressed : null,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                colors: [
                  TermsScreenTokens.buttonBlue,
                  TermsScreenTokens.buttonBlueEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: TermsScreenTokens.buttonBlue.withValues(alpha: 0.35),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: SizedBox(
              height: 56,
              width: double.infinity,
              child: Center(
                child: isLoading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: TermsScreenTokens.title,
                        ),
                      )
                    : Text(
                        'Next',
                        style: TextStyle(
                          color: TermsScreenTokens.title,
                          fontSize: fontSize,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
