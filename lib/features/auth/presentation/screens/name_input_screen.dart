import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/name_input_controller.dart';
import '../theme/name_input_tokens.dart';
import '../widgets/name_input_card.dart';

/// Collects first / last name (React `NameInputScreen.tsx` + Figma reference).
class NameInputScreen extends ConsumerStatefulWidget {
  const NameInputScreen({super.key});

  @override
  ConsumerState<NameInputScreen> createState() => _NameInputScreenState();
}

class _NameInputScreenState extends ConsumerState<NameInputScreen> {
  late final TextEditingController _firstController;
  late final TextEditingController _lastController;
  late final FocusNode _firstFocus;
  late final FocusNode _lastFocus;

  @override
  void initState() {
    super.initState();
    _firstController = TextEditingController();
    _lastController = TextEditingController();
    _firstFocus = FocusNode();
    _lastFocus = FocusNode();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(nameInputControllerProvider.notifier).reset();
      _firstController.clear();
      _lastController.clear();
    });

    _firstController.addListener(() {
      ref
          .read(nameInputControllerProvider.notifier)
          .updateFirstName(_firstController.text);
    });
    _lastController.addListener(() {
      ref
          .read(nameInputControllerProvider.notifier)
          .updateLastName(_lastController.text);
    });
  }

  @override
  void dispose() {
    _firstController.dispose();
    _lastController.dispose();
    _firstFocus.dispose();
    _lastFocus.dispose();
    super.dispose();
  }

  Future<void> _onContinue() async {
    FocusScope.of(context).unfocus();
    final ok = await ref
        .read(nameInputControllerProvider.notifier)
        .submitName();
    if (!mounted || !ok) return;
    context.go(RouteNames.home);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(nameInputControllerProvider);
    final w = MediaQuery.sizeOf(context).width;
    final titleSize = (w * 0.085).clamp(26.0, 32.0);
    final subtitleSize = (w * 0.045).clamp(16.0, 18.0);
    final horizontal = (w * 0.06).clamp(20.0, 28.0);
    final insets = MediaQuery.viewInsetsOf(context);
    final keyboardOpen = insets.bottom > 0;

    final showFieldError = s.hasInteracted && s.errorMessage != null;

    return Scaffold(
      backgroundColor: NameInputTokens.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final topPad = keyboardOpen
                ? 12.0
                : (constraints.maxHeight * 0.02).clamp(12.0, 28.0);

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
                    'What should we\ncall you?',
                    style: TextStyle(
                      color: NameInputTokens.white,
                      fontSize: titleSize,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Enter your name to continue',
                    style: TextStyle(
                      color: NameInputTokens.muted,
                      fontSize: subtitleSize,
                      fontWeight: FontWeight.w400,
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: keyboardOpen ? 16 : 24),
                  NameInputCard(
                    label: 'First Name',
                    hint: 'Enter first name',
                    controller: _firstController,
                    errorText: showFieldError ? s.errorMessage : null,
                    textInputAction: TextInputAction.next,
                    onSubmitted: (_) => _lastFocus.requestFocus(),
                    focusNode: _firstFocus,
                  ),
                  SizedBox(height: (w * 0.04).clamp(14.0, 18.0)),
                  NameInputCard(
                    label: 'Last Name (Optional)',
                    hint: 'Enter last name',
                    controller: _lastController,
                    textInputAction: TextInputAction.done,
                    onSubmitted: (_) => FocusScope.of(context).unfocus(),
                    focusNode: _lastFocus,
                  ),
                  SizedBox(height: keyboardOpen ? 12 : 20),
                  Padding(
                    padding: EdgeInsets.only(bottom: keyboardOpen ? 8 : 0),
                    child: _NameContinueButton(
                      enabled: s.isFirstNameValid && !s.isLoading,
                      isLoading: s.isLoading,
                      onPressed: _onContinue,
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

class _NameContinueButton extends StatelessWidget {
  const _NameContinueButton({
    required this.enabled,
    required this.isLoading,
    required this.onPressed,
  });

  final bool enabled;
  final bool isLoading;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final fontSize = (w * 0.04).clamp(15.0, 17.0);

    return Opacity(
      opacity: enabled ? 1 : 0.45,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: enabled && !isLoading ? onPressed : null,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: const LinearGradient(
                colors: [
                  NameInputTokens.buttonBlue,
                  NameInputTokens.buttonBlueEnd,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: NameInputTokens.buttonBlue.withValues(alpha: 0.45),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
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
                          color: NameInputTokens.white,
                        ),
                      )
                    : Text(
                        'Continue',
                        style: TextStyle(
                          color: NameInputTokens.white,
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
