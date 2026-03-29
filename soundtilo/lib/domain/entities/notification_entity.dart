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
        return 'Tin nhan';
      case 2:
        return 'Canh bao vi pham';
      case 3:
        return 'Cap nhat bai hat';
      case 4:
        return 'Thong bao he thong';
      default:
        return 'Thong bao';
    }
  }
}
