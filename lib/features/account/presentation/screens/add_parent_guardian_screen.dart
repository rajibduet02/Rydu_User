import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../../../app/theme/app_colors.dart';
import '../providers/add_parent_guardian_provider.dart';
import '../theme/family_add_member_tokens.dart';
import '../widgets/contact_import_card.dart';
import '../widgets/guardian_phone_field.dart';

class AddParentGuardianScreen extends ConsumerStatefulWidget {
  const AddParentGuardianScreen({super.key});

  @override
  ConsumerState<AddParentGuardianScreen> createState() =>
      _AddParentGuardianScreenState();
}

class _AddParentGuardianScreenState
    extends ConsumerState<AddParentGuardianScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _phoneController;
  late final FocusNode _nameFocus;
  late final FocusNode _phoneFocus;

  static const _formBackground = AppDarkSurfaces.scaffold;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _phoneController = TextEditingController();
    _nameFocus = FocusNode();
    _phoneFocus = FocusNode();

    _nameController.addListener(() {
      ref
          .read(addParentGuardianControllerProvider.notifier)
          .updateName(_nameController.text);
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _nameFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _popOrAddMember(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.addFamilyMember);
    }
  }

  Future<void> _onChooseContacts() async {
    ref.read(addParentGuardianControllerProvider.notifier).chooseFromContacts();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Contact import is not available yet.')),
    );
  }

  Future<void> _onSendInvite() async {
    FocusScope.of(context).unfocus();
    final c = ref.read(addParentGuardianControllerProvider.notifier);
    final ok = await c.sendGuardianInvite();
    if (!mounted) return;

    if (ok) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Guardian invite sent')));
      c.navigateAfterSuccess();
    } else {
      final err = ref.read(addParentGuardianControllerProvider).errorMessage;
      if (err != null) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(err)));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(addParentGuardianControllerProvider);
    final c = ref.read(addParentGuardianControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = 16.0;
    final titleSize = (w * 0.065).clamp(24.0, 28.0);
    final subtitleSize = (w * 0.038).clamp(14.0, 15.0);
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final canSend = state.isFormValid && !state.isLoading;

    final formContent = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IconButton(
          alignment: Alignment.centerLeft,
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints(minWidth: 40, minHeight: 40),
          onPressed: () => _popOrAddMember(context),
          icon: Icon(
            Icons.arrow_back_ios_new_rounded,
            color: FamilyAddMemberTokens.white,
            size: (w * 0.05).clamp(20.0, 22.0),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Now, let's add your\nparent or guardian",
          style: TextStyle(
            color: FamilyAddMemberTokens.white,
            fontWeight: FontWeight.w700,
            fontSize: titleSize,
            height: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          "We'll send them a request to approve your account.",
          style: TextStyle(
            color: FamilyAddMemberTokens.muted,
            fontSize: subtitleSize,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 24),
        ContactImportCard(onChooseContacts: _onChooseContacts),
        const SizedBox(height: 24),
        _GuardianNameField(
          controller: _nameController,
          focusNode: _nameFocus,
          onSubmitted: (_) => _phoneFocus.requestFocus(),
        ),
        const SizedBox(height: 20),
        GuardianPhoneField(
          controller: _phoneController,
          focusNode: _phoneFocus,
          countryCode: state.countryCode,
          onChanged: c.updatePhoneNumber,
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

    return Scaffold(
      backgroundColor: _formBackground,
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
                        ? FamilyAddMemberTokens.sendEnabled
                        : FamilyAddMemberTokens.sendDisabled,
                    foregroundColor: canSend
                        ? FamilyAddMemberTokens.continueText
                        : FamilyAddMemberTokens.continueTextDisabled,
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

class _GuardianNameField extends StatelessWidget {
  const _GuardianNameField({
    required this.controller,
    required this.focusNode,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    final labelSize = (w * 0.038).clamp(14.0, 15.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Name',
          style: TextStyle(
            color: FamilyAddMemberTokens.white,
            fontWeight: FontWeight.w600,
            fontSize: labelSize,
          ),
        ),
        const SizedBox(height: 10),
        ListenableBuilder(
          listenable: focusNode,
          builder: (context, _) {
            final focused = focusNode.hasFocus;
            return TextField(
              controller: controller,
              focusNode: focusNode,
              textInputAction: TextInputAction.next,
              onSubmitted: onSubmitted,
              style: const TextStyle(
                color: FamilyAddMemberTokens.white,
                fontSize: 16,
              ),
              decoration: InputDecoration(
                hintText: 'Name',
                hintStyle: const TextStyle(color: FamilyAddMemberTokens.muted),
                filled: true,
                fillColor: FamilyAddMemberTokens.field,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(
                    color: focused
                        ? FamilyAddMemberTokens.fieldBorder
                        : FamilyAddMemberTokens.fieldBorderMuted,
                    width: focused ? 1.5 : 1,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                    color: FamilyAddMemberTokens.fieldBorder,
                    width: 1.5,
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
