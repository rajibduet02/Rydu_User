import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'faqs_controller.dart';

import 'faqs_controller.dart';

final faqsControllerProvider = NotifierProvider<FaqsController, FaqsState>(
  FaqsController.new,
);
