import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/router/route_names.dart';
import '../providers/add_family_member_provider.dart';
import '../theme/family_add_member_tokens.dart';
import '../widgets/member_type_option_tile.dart';

class AddFamilyMemberScreen extends ConsumerWidget {
  const AddFamilyMemberScreen({super.key});

  void _close(BuildContext context) {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(RouteNames.family);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(addFamilyMemberControllerProvider);
    final c = ref.read(addFamilyMemberControllerProvider.notifier);
    final w = MediaQuery.sizeOf(context).width;
    final hPad = (w * 0.05).clamp(18.0, 22.0);
    final titleSize = (w * 0.048).clamp(18.0, 20.0);

    final canContinue = state.canContinue && !state.isLoading;

    return Scaffold(
      backgroundColor: FamilyAddMemberTokens.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 16, hPad, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Add new member',
                      style: TextStyle(
                        color: FamilyAddMemberTokens.white,
                        fontWeight: FontWeight.w700,
                        fontSize: titleSize,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => _close(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: FamilyAddMemberTokens.white,
                      size: 26,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: hPad),
                child: Column(
                  children: [
                    MemberTypeOptionTile(
                      icon: Icons.child_care_outlined,
                      title: 'Teen (ages 13–17)',
                      subtitle: 'Enhanced safety features',
                      isSelected: state.selectedMemberType == kMemberTypeTeen,
                      onTap: () => c.selectMemberType(kMemberTypeTeen),
                    ),
                    MemberTypeOptionTile(
                      icon: Icons.person_outline_rounded,
                      title: 'Adult',
                      subtitle: 'Core experience for adults',
                      isSelected: state.selectedMemberType == kMemberTypeAdult,
                      onTap: () => c.selectMemberType(kMemberTypeAdult),
                    ),
                    MemberTypeOptionTile(
                      icon: Icons.elderly_outlined,
                      title: 'Senior',
                      subtitle: 'Simplified app for older adults',
                      isSelected: state.selectedMemberType == kMemberTypeSenior,
                      onTap: () => c.selectMemberType(kMemberTypeSenior),
                      showDivider: false,
                    ),
                    if (state.errorMessage != null) ...[
                      const SizedBox(height: 16),
                      Text(
                        state.errorMessage!,
                        style: const TextStyle(
                          color: Colors.redAccent,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ],
                ),
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
                  onPressed: canContinue ? c.continueFlow : null,
                  style: FilledButton.styleFrom(
                    backgroundColor: canContinue
                        ? FamilyAddMemberTokens.continueEnabled
                        : FamilyAddMemberTokens.continueDisabled,
                    foregroundColor: canContinue
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
                          'Continue',
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
