import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/add_card_provider.dart';
import '../theme/add_card_tokens.dart';
import '../widgets/card_preview.dart';
import '../widgets/payment_text_field.dart';
import '../widgets/save_card_tile.dart';
import '../widgets/secure_payment_card.dart';

class AddCardScreen extends ConsumerStatefulWidget {
  const AddCardScreen({super.key});

  @override
  ConsumerState<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends ConsumerState<AddCardScreen> {
  late final TextEditingController _cardNumberCtrl;
  late final TextEditingController _expiryCtrl;
  late final TextEditingController _cvvCtrl;
  late final TextEditingController _nameCtrl;

  @override
  void initState() {
    super.initState();
    _cardNumberCtrl = TextEditingController();
    _expiryCtrl = TextEditingController();
    _cvvCtrl = TextEditingController();
    _nameCtrl = TextEditingController();
  }

  @override
  void dispose() {
    _cardNumberCtrl.dispose();
    _expiryCtrl.dispose();
    _cvvCtrl.dispose();
    _nameCtrl.dispose();
    super.dispose();
  }

  void _syncCtrl(TextEditingController ctrl, String value) {
    if (ctrl.text != value) {
      ctrl.value = TextEditingValue(
        text: value,
        selection: TextSelection.collapsed(offset: value.length),
      );
    }
  }

  String _previewNumber(String formatted) {
    if (formatted.isEmpty) return '•••• •••• •••• ••••';
    return formatted;
  }

  void _onCardNumberChanged(String v) {
    ref.read(addCardControllerProvider.notifier).updateCardNumber(v);
    final next = ref.read(addCardControllerProvider);
    _syncCtrl(_cardNumberCtrl, next.cardNumber);
  }

  void _onExpiryChanged(String v) {
    ref.read(addCardControllerProvider.notifier).updateExpiryDate(v);
    final next = ref.read(addCardControllerProvider);
    _syncCtrl(_expiryCtrl, next.expiryDate);
  }

  void _onCvvChanged(String v) {
    ref.read(addCardControllerProvider.notifier).updateCvv(v);
    final next = ref.read(addCardControllerProvider);
    _syncCtrl(_cvvCtrl, next.cvv);
  }

  void _onNameChanged(String v) {
    ref.read(addCardControllerProvider.notifier).updateCardholderName(v);
    final next = ref.read(addCardControllerProvider);
    _syncCtrl(_nameCtrl, next.cardholderName);
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(addCardControllerProvider);
    final c = ref.read(addCardControllerProvider.notifier);

    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.06).clamp(20.0, 24.0);
    final bottomInset = MediaQuery.paddingOf(context).bottom;

    return Scaffold(
      backgroundColor: AddCardTokens.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 8, hPad, 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () {
                            if (context.canPop()) {
                              context.pop();
                            } else {
                              context.go(RouteNames.rentalRideSelection);
                            }
                          },
                          customBorder: const CircleBorder(),
                          child: Ink(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AddCardTokens.iconWell,
                              border: Border.all(color: AddCardTokens.border),
                            ),
                            child: const Icon(
                              Icons.chevron_left_rounded,
                              color: AddCardTokens.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                      const Spacer(),
                      Row(
                        children: [
                          Icon(
                            Icons.lock_outline_rounded,
                            color: AddCardTokens.muted,
                            size: 18,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Secure payment',
                            style: TextStyle(
                              color: AddCardTokens.muted,
                              fontSize: (w * 0.032).clamp(12.5, 13.5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Add card',
                    style: TextStyle(
                      color: AddCardTokens.white,
                      fontSize: (w * 0.075).clamp(26.0, 30.0),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: AddCardTokens.border),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(hPad, 20, hPad, 16),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    CardPreview(
                      cardNumberDisplay: _previewNumber(s.cardNumber),
                      cardholderDisplay: s.cardholderName.isEmpty
                          ? 'YOUR NAME'
                          : s.cardholderName,
                      expiryDisplay: s.expiryDate.isEmpty
                          ? 'MM/YY'
                          : s.expiryDate,
                    ),
                    const SizedBox(height: 28),
                    PaymentTextField(
                      label: 'Card number',
                      hint: '1234 5678 9012 3456',
                      controller: _cardNumberCtrl,
                      keyboardType: TextInputType.number,
                      onChanged: _onCardNumberChanged,
                    ),
                    const SizedBox(height: 18),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: PaymentTextField(
                            label: 'Expiry date',
                            hint: 'MM/YY',
                            controller: _expiryCtrl,
                            keyboardType: TextInputType.number,
                            onChanged: _onExpiryChanged,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: PaymentTextField(
                            label: 'CVV',
                            hint: '123',
                            controller: _cvvCtrl,
                            obscureText: true,
                            keyboardType: TextInputType.number,
                            onChanged: _onCvvChanged,
                            textInputAction: TextInputAction.next,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),
                    PaymentTextField(
                      label: 'Cardholder name',
                      hint: 'JOHN DOE',
                      controller: _nameCtrl,
                      textCapitalization: TextCapitalization.characters,
                      onChanged: _onNameChanged,
                      textInputAction: TextInputAction.done,
                    ),
                    const SizedBox(height: 18),
                    SaveCardTile(
                      value: s.saveCard,
                      onChanged: c.toggleSaveCard,
                    ),
                    const SizedBox(height: 18),
                    const SecurePaymentCard(),
                    if (s.errorMessage != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        s.errorMessage!,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                          fontSize: 13,
                        ),
                      ),
                    ],
                    SizedBox(height: 88 + bottomInset),
                  ],
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.fromLTRB(hPad, 12, hPad, 12 + bottomInset),
              decoration: const BoxDecoration(
                color: AddCardTokens.background,
                border: Border(
                  top: BorderSide(color: AddCardTokens.border, width: 1),
                ),
              ),
              child: s.isFormValid
                  ? DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        gradient: const LinearGradient(
                          colors: [
                            AddCardTokens.accent,
                            AddCardTokens.accentEnd,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AddCardTokens.accent.withValues(alpha: 0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Material(
                        color: Colors.transparent,
                        child: IgnorePointer(
                          ignoring: s.isLoading,
                          child: InkWell(
                            onTap: () => c.addCard(),
                            borderRadius: BorderRadius.circular(20),
                            child: SizedBox(
                              height: (w * 0.14).clamp(52.0, 56.0),
                              width: double.infinity,
                              child: Center(
                                child: s.isLoading
                                    ? const SizedBox(
                                        width: 24,
                                        height: 24,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AddCardTokens.white,
                                        ),
                                      )
                                    : Text(
                                        'Add card',
                                        style: TextStyle(
                                          color: AddCardTokens.white,
                                          fontSize: (w * 0.045).clamp(
                                            16.0,
                                            18.0,
                                          ),
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                  : Container(
                      height: (w * 0.14).clamp(52.0, 56.0),
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AddCardTokens.disabledButton,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Add card',
                        style: TextStyle(
                          color: AddCardTokens.muted,
                          fontSize: (w * 0.045).clamp(16.0, 18.0),
                          fontWeight: FontWeight.w700,
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
