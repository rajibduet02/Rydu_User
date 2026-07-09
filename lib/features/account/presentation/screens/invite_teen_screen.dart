import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/invite_teen_provider.dart';
import '../theme/invite_teen_tokens.dart';
import '../widgets/invite_teen_contact_card.dart';
import '../widgets/invite_teen_phone_field.dart';
import '../widgets/invite_teen_text_field.dart';

class InviteTeenScreen extends ConsumerStatefulWidget {
  const InviteTeenScreen({super.key});

  @override
  ConsumerState<InviteTeenScreen> createState() => _InviteTeenScreenState();
}

class _InviteTeenScreenState extends ConsumerState<InviteTeenScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final TextEditingController _dobController;
  late final FocusNode _nameFocus;
  late final FocusNode _phoneFocus;
  late final FocusNode _dobFocus;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _dobController = TextEditingController();
    _nameFocus = FocusNode();
    _phoneFocus = FocusNode();
    _dobFocus = FocusNode();

    _nameController.addListener(() {
      ref
          .read(inviteTeenControllerProvider.notifier)
          .updateName(_nameController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _dobController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    _dobFocus.dispose();
    super.dispose();
  }

  void _popOrFamily(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.family);
    }
  }

  String _formatDob(DateTime date) {
    final m = date.month.toString().padLeft(2, '0');
    final d = date.day.toString().padLeft(2, '0');
    return '$m/$d/${date.year}';
  }

  Future<void> _pickDateOfBirth() async {
    final now = DateTime.now();
    final latest = DateTime(now.year - 13, now.month, now.day);
    final earliest = DateTime(now.year - 17, now.month, now.day);

    final picked = await showDatePicker(
      context: context,
      initialDate: latest,
      firstDate: earliest,
      lastDate: latest,
      helpText: 'Select date of birth',
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: InviteTeenTokens.fieldBorder,
              surface: InviteTeenTokens.card,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked == null || !mounted) return;

    final c = ref.read(inviteTeenControllerProvider.notifier);
    c.selectDateOfBirth(picked);
    _dobController.text = _formatDob(picked);

    if (!c.validateForm(setError: true) && mounted) {
      final err = ref.read(inviteTeenControllerProvider).errorMessage;
      if (err != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  Future<void> _onChooseContacts() async {
    ref.read(inviteTeenControllerProvider.notifier).chooseFromContacts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact import is not available yet.')),
    );
  }

  Future<void> _onSendInvite() async {
    FocusScope.of(context).unfocus();
    final c = ref.read(inviteTeenControllerProvider.notifier);
    final ok = await c.sendInvite();
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Invite sent')));
      c.navigateAfterSuccess();
    } else {
      final err = ref.read(inviteTeenControllerProvider).errorMessage;
      if (err != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(inviteTeenControllerProvider);
    final c = ref.read(inviteTeenControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = 16.0;
    final titleSize = (w * 0.065).clamp(24.0, 28.0);
    final helperSize = (w * 0.034).clamp(13.0, 14.0);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    final formContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IconButton(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          onPressed: () => _popOrFamily(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: InviteTeenTokens.white,
            size: (w * 0.05).clamp(20.0, 22.0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Invite a teen',
          style: TextStyle(
            color: InviteTeenTokens.white,
            fontWeight: FontWeight.w700,
            fontSize: titleSize,
          ),
        ),
        const SizedBox(height: 24),
        InviteTeenContactCard(onChooseContacts: _onChooseContacts),
        const SizedBox(height: 24),
        InviteTeenTextField(
          label: 'Name',
          controller: _nameController,
          focusNode: _nameFocus,
          hintText: 'Name',
          textInputAction: TextInputAction.next,
          onSubmitted: (_) => _phoneFocus.requestFocus(),
        ),
        const SizedBox(height: 20),
        InviteTeenPhoneField(
          controller: _phoneController,
          focusNode: _phoneFocus,
          countryCode: state.countryCode,
          onChanged: c.updatePhoneNumber,
        ),
        const SizedBox(height: 20),
        InviteTeenTextField(
          label: 'Date of birth',
          controller: _dobController,
          focusNode: _dobFocus,
          hintText: 'MM/DD/YYYY',
          readOnly: true,
          onTap: _pickDateOfBirth,
          suffixIcon: const Icon(
            Icons.keyboard_arrow_down_rounded,
            color: InviteTeenTokens.muted,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "Teen's age must be 13-17 years old. This information won't be shared with anyone. It's only used to personalize the member's experience.",
          style: TextStyle(
            color: InviteTeenTokens.muted,
            fontSize: helperSize,
            height: 1.45,
          ),
        ),
        if (state.errorMessage != null &&
            state.name.isNotEmpty &&
            state.phoneNumber.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text(
            state.errorMessage!,
            style: const TextStyle(color: Colors.redAccent, fontSize: 13),
          ),
        ],
      ],
    );

    final canSend = state.isFormValid && !state.isLoading;

    return Scaffold(
      backgroundColor: InviteTeenTokens.background,
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24 + bottomInset),
                child: formContent,
              ),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(
                hPad,
                12,
                hPad,
                16 + MediaQuery.paddingOf(context).bottom,
              ),
              child: SizedBox(
                width: double.infinity,
                height: (w * 0.14).clamp(52.0, 56.0),
                child: FilledButton(
                  onPressed: canSend ? _onSendInvite : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: canSend
                        ? InviteTeenTokens.sendEnabled
                        : InviteTeenTokens.sendDisabled,
                    foregroundColor: canSend
                        ? InviteTeenTokens.sendText
                        : InviteTeenTokens.sendTextDisabled,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: state.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(
                          'Send invite',
                          style: TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
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
