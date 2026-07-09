import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'report_lost_item_controller.dart';

import 'report_lost_item_controller.dart';

final reportLostItemControllerProvider =
    NotifierProvider<ReportLostItemController, ReportLostItemState>(
      ReportLostItemController.new,
    );
