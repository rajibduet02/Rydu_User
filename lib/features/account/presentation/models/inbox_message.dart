import 'package:flutter/material.dart';

import '../../domain/entities/inbox_message_entity.dart';

export '../../domain/entities/inbox_message_entity.dart';

typedef InboxMessage = InboxMessageEntity;

extension InboxMessagePresentation on InboxMessageEntity {
  Color get iconColor => Color(iconColorArgb);
}
