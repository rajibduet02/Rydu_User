import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../../data/utils/profile_phone.dart';
import '../../domain/repositories/passenger_profile_repository.dart';
import '../providers/account_deactivation_listener.dart';
import '../providers/passenger_profile_controller.dart';
import '../theme/profile_details_tokens.dart';
import '../widgets/passenger_avatar.dart';
import '../widgets/profile_avatar_actions.dart';
import '../widgets/profile_details_header.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late final TextEditingController _nameController;
  late final TextEditingController _countryController;
  late final TextEditingController _numberController;
  String? _localError;
  bool _hydrated = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _countryController = TextEditingController();
    _numberController = TextEditingController();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(passengerProfileControllerProvider.notifier).loadIfNeeded();
      _hydrateFromState();
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _countryController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  void _hydrateFromState() {
    if (_hydrated) return;
    final profile = ref.read(passengerProfileControllerProvider).profile;
    if (profile == null) return;
    _nameController.text = profile.name;
    final parts = splitProfilePhone(profile.phone);
    _countryController.text = parts.countryCode;
    _numberController.text = parts.number;
    _hydrated = true;
  }

  void _popOrAccount() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.account);
    }
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.length < 2) {
      setState(() => _localError = 'Enter a name with at least 2 characters.');
      return;
    }

    final country = _countryController.text.trim();
    final number = _numberController.text.trim().replaceAll(RegExp(r'\D'), '');
    PassengerProfilePhoneUpdate? phoneUpdate;
    if (country.isEmpty && number.isEmpty) {
      final current = ref.read(passengerProfileControllerProvider).profile;
      if (current?.phone != null && current!.phone!.trim().isNotEmpty) {
        phoneUpdate = const PassengerProfilePhoneUpdate.clear();
      }
    } else {
      if (number.isEmpty) {
        setState(() => _localError = 'Enter a phone number or clear both fields.');
        return;
      }
      final code = country.isEmpty
          ? ''
          : (country.startsWith('+') ? country : '+$country');
      if (code.isEmpty || code == '+') {
        setState(
          () => _localError =
              'Enter a country code (for example +880) or clear the phone.',
        );
        return;
      }
      phoneUpdate = PassengerProfilePhoneUpdate.set(
        countryCode: code,
        number: number,
      );
    }

    setState(() => _localError = null);
    final ok = await ref
        .read(passengerProfileControllerProvider.notifier)
        .updateProfile(name: name, phone: phoneUpdate);
    if (!mounted) return;
    if (ok) {
      _popOrAccount();
      return;
    }
    final error = ref.read(passengerProfileControllerProvider).errorMessage;
    setState(() => _localError = error);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  @override
  Widget build(BuildContext context) {
    listenForAccountDeactivation(ref);
    final state = ref.watch(passengerProfileControllerProvider);
    ref.listen(passengerProfileControllerProvider, (prev, next) {
      if (!_hydrated && next.profile != null) {
        _hydrateFromState();
        setState(() {});
      }
    });
    final profile = state.profile;
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.05).clamp(18.0, 22.0);

    return Scaffold(
      backgroundColor: ProfileDetailsTokens.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad - 8, 8, hPad, 0),
              child: ProfileDetailsHeader(onBack: _popOrAccount),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 24),
                children: [
                  Center(
                    child: PassengerAvatar(
                      profile: profile,
                      size: 112,
                      isUploading: state.isUploadingAvatar,
                      onTap: () => showProfileAvatarActions(
                        context: context,
                        ref: ref,
                        hasAvatar: profile?.hasAvatar ?? false,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () => showProfileAvatarActions(
                      context: context,
                      ref: ref,
                      hasAvatar: profile?.hasAvatar ?? false,
                    ),
                    child: const Text('Change photo'),
                  ),
                  const SizedBox(height: 20),
                  _label('Name'),
                  const SizedBox(height: 8),
                  _field(
                    controller: _nameController,
                    hint: 'Your name',
                    textInputAction: TextInputAction.next,
                  ),
                  const SizedBox(height: 18),
                  _label('Phone (optional)'),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      SizedBox(
                        width: 92,
                        child: _field(
                          controller: _countryController,
                          hint: '+880',
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.next,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _field(
                          controller: _numberController,
                          hint: 'Phone number',
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  _label('Email'),
                  const SizedBox(height: 8),
                  DecoratedBox(
                    decoration: BoxDecoration(
                      color: ProfileDetailsTokens.card,
                      borderRadius: BorderRadius.circular(14),
                      border: const Border.fromBorderSide(
                        BorderSide(color: ProfileDetailsTokens.border),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 16,
                      ),
                      child: Text(
                        profile?.email.trim().isNotEmpty == true
                            ? profile!.email
                            : '—',
                        style: const TextStyle(
                          color: ProfileDetailsTokens.muted,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Email is managed by your sign-in account and cannot be changed here.',
                    style: TextStyle(
                      color: ProfileDetailsTokens.muted,
                      fontSize: 12,
                    ),
                  ),
                  if (_localError != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      _localError!,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 13,
                      ),
                    ),
                  ],
                  const SizedBox(height: 28),
                  SizedBox(
                    height: 52,
                    child: FilledButton(
                      onPressed: state.isSaving ? null : _save,
                      style: FilledButton.styleFrom(
                        backgroundColor: ProfileDetailsTokens.accent,
                        foregroundColor: Colors.white,
                      ),
                      child: state.isSaving
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Text('Save'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: ProfileDetailsTokens.label,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _field({
    required TextEditingController controller,
    required String hint,
    bool readOnly = false,
    TextInputType? keyboardType,
    TextInputAction? textInputAction,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      style: const TextStyle(color: ProfileDetailsTokens.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: ProfileDetailsTokens.muted),
        filled: true,
        fillColor: ProfileDetailsTokens.card,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ProfileDetailsTokens.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: ProfileDetailsTokens.accent),
        ),
      ),
    );
  }
}
