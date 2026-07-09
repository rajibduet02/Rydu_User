import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'email_support_controller.dart';

import 'email_support_controller.dart';

final emailSupportControllerProvider =
    NotifierProvider<EmailSupportController, EmailSupportState>(
      EmailSupportController.new,
    );
