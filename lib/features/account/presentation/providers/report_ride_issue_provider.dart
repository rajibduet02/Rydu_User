import 'package:flutter_riverpod/flutter_riverpod.dart';

export 'report_ride_issue_controller.dart';

import 'report_ride_issue_controller.dart';

final reportRideIssueControllerProvider =
    NotifierProvider<ReportRideIssueController, ReportRideIssueState>(
      ReportRideIssueController.new,
    );
