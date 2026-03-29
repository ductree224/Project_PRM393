import 'package:soundtilo/domain/entities/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.type,
    required super.source,
    required super.title,
    required super.message,
    required super.metadataJson,
    required super.isRead,
    required super.createdAt,
    required super.readAt,
    required super.expiresAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    DateTime? parseDate(dynamic value) {
      if (value is String) {
        return DateTime.tryParse(value)?.toLocal();
      }
      return null;
    }

    return NotificationModel(
      id: (json['id'] ?? '').toString(),
      type: (json['type'] as num?)?.toInt() ?? 0,
      source: (json['source'] as num?)?.toInt() ?? 0,
      title: (json['title'] ?? '').toString(),
      message: (json['message'] ?? '').toString(),
      metadataJson: json['metadataJson']?.toString(),
      isRead: (json['isRead'] as bool?) ?? false,
      createdAt: parseDate(json['createdAt']) ?? DateTime.now(),
      readAt: parseDate(json['readAt']),
      expiresAt: parseDate(json['expiresAt']),
    );
  }
}
