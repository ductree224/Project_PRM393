class NotificationEntity {
  final String id;
  final int type;
  final int source;
  final String title;
  final String message;
  final String? metadataJson;
  final bool isRead;
  final DateTime createdAt;
  final DateTime? readAt;
  final DateTime? expiresAt;

  const NotificationEntity({
    required this.id,
    required this.type,
    required this.source,
    required this.title,
    required this.message,
    required this.metadataJson,
    required this.isRead,
    required this.createdAt,
    required this.readAt,
    required this.expiresAt,
  });

  String get typeLabel {
    switch (type) {
      case 1:
        return 'Tin nhắn';
      case 2:
        return 'Cảnh báo vi phạm';
      case 3:
        return 'Cập nhật bài hát';
      case 4:
        return 'Thông báo hệ thống';
      default:
        return 'Thông báo';
    }
  }
}
