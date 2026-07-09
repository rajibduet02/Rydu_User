import '../models/inbox_message_model.dart';

abstract interface class InboxLocalDatasource {
  Future<List<InboxMessageModel>> fetchMessages();
  Future<List<InboxMessageModel>> markMessageRead(String messageId);
}

class InboxLocalDatasourceImpl implements InboxLocalDatasource {
  List<InboxMessageModel>? _cache;

  @override
  Future<List<InboxMessageModel>> fetchMessages() async {
    // TODO: Fetch inbox messages from notifications API.
    await Future<void>.delayed(const Duration(milliseconds: 200));
    _cache = InboxMessageModel.seed();
    return List<InboxMessageModel>.from(_cache!);
  }

  @override
  Future<List<InboxMessageModel>> markMessageRead(String messageId) async {
    final list = _cache ?? InboxMessageModel.seed();
    _cache = list
        .map(
          (m) => m.id == messageId
              ? InboxMessageModel(
                  id: m.id,
                  title: m.title,
                  subtitle: m.subtitle,
                  time: m.time,
                  category: m.category,
                  iconType: m.iconType,
                  iconColorArgb: m.iconColorArgb,
                  isUnread: false,
                )
              : m,
        )
        .toList();
    return List<InboxMessageModel>.from(_cache!);
  }
}
