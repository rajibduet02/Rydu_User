import 'package:flutter/material.dart';

import '../../../ride_history/presentation/widgets/ride_history_body.dart';

class ActivityScreen extends StatelessWidget {
  const ActivityScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const RideHistoryBody(
      title: 'Activity',
      useShellBottomPadding: true,
    );
  }
}
