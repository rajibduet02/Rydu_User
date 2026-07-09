import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/otp_controller.dart';
import '../theme/otp_tokens.dart';

/// Four single-digit OTP boxes with focus advance, backspace, and paste support.
class OtpPinInputField extends ConsumerStatefulWidget {
  const OtpPinInputField({super.key});

  @override
  ConsumerState<OtpPinInputField> createState() => _OtpPinInputFieldState();
}

class _OtpPinInputFieldState extends ConsumerState<OtpPinInputField> {
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(4, (_) => TextEditingController());
    _focusNodes = List.generate(4, (_) => FocusNode());
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) _focusNodes.first.requestFocus();
    });
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.dispose();
    }
    for (final f in _focusNodes) {
      f.dispose();
    }
    super.dispose();
  }

  void _syncControllersFromState(List<String> digits) {
    for (var i = 0; i < 4; i++) {
      final d = i < digits.length ? digits[i] : '';
      if (_controllers[i].text != d) {
        _controllers[i].value = TextEditingValue(
          text: d,
          selection: TextSelection.collapsed(offset: d.length),
        );
      }
    }
  }

  void _onChanged(int index, String raw) {
    final notifier = ref.read(otpControllerProvider.notifier);
    final digitsOnly = raw.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length > 1) {
      notifier.setOtpCode(digitsOnly);
      _syncControllersFromState(ref.read(otpControllerProvider).otpDigits);
      final focusIndex = digitsOnly.length >= 4 ? 3 : digitsOnly.length - 1;
      _focusNodes[focusIndex.clamp(0, 3)].requestFocus();
      return;
    }

    notifier.updateOtpDigit(index, raw);

    if (digitsOnly.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    }
  }

  KeyEventResult _onKey(int index, KeyEvent event) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    if (event.logicalKey != LogicalKeyboardKey.backspace) {
      return KeyEventResult.ignored;
    }
    if (_controllers[index].text.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
      return KeyEventResult.handled;
    }
    return KeyEventResult.ignored;
  }

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final boxWidth = (w * 0.18).clamp(56.0, 68.0);
    final boxHeight = (w * 0.22).clamp(68.0, 82.0);
    final fontSize = (w * 0.055).clamp(20.0, 26.0);
    final gap = (w * 0.03).clamp(12.0, 16.0);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(4, (index) {
        return Padding(
          padding: EdgeInsets.only(right: index < 3 ? gap : 0),
          child: Focus(
            onKeyEvent: (node, event) => _onKey(index, event),
            child: SizedBox(
              width: boxWidth,
              height: boxHeight,
              child: TextField(
                controller: _controllers[index],
                focusNode: _focusNodes[index],
                textAlign: TextAlign.center,
                keyboardType: TextInputType.number,
                style: TextStyle(
                  color: OtpTokens.white,
                  fontSize: fontSize,
                  fontWeight: FontWeight.w600,
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(index == 0 ? 4 : 1),
                ],
                decoration: InputDecoration(
                  filled: true,
                  fillColor: OtpTokens.boxFill,
                  contentPadding: EdgeInsets.zero,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: OtpTokens.border,
                      width: 1.5,
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: OtpTokens.border,
                      width: 1.5,
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: const BorderSide(
                      color: OtpTokens.borderFocused,
                      width: 2,
                    ),
                  ),
                ),
                onChanged: (v) => _onChanged(index, v),
              ),
            ),
          ),
        );
      }),
    );
  }
}
