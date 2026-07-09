import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'add_family_member_controller.dart';

import 'add_family_member_controller.dart';

final addFamilyMemberControllerProvider =
    NotifierProvider<AddFamilyMemberController, AddFamilyMemberState>(
      AddFamilyMemberController.new,
    );
