import 'package:flutter/material.dart';

class FeedbackEntity {
  final String id;
  final String userId;
  final String category;
  final String priority;
  final String title;
  final String content;
  final String? deviceInfo;
  final String? appVersion;
  final String? platform;
  final String? attachmentUrl;
  final String status;
  final String? adminReply;
  final String? handledByAdminId;
  final DateTime createdAt;
  final DateTime? handledAt;

  const FeedbackEntity({
    required this.id,
    required this.userId,
    required this.category,
    required this.priority,
    required this.title,
    required this.content,
    this.deviceInfo,
    this.appVersion,
    this.platform,
    this.attachmentUrl,
    required this.status,
    this.adminReply,
    this.handledByAdminId,
    required this.createdAt,
    this.handledAt,
  });

  String get statusLabel {
    switch (status) {
      case 'pending':
        return 'Chờ xử lý';
      case 'reviewing':
        return 'Đang xem xét';
      case 'in_progress':
        return 'Đang xử lý';
      case 'resolved':
        return 'Đã giải quyết';
      case 'rejected':
        return 'Đã từ chối';
      default:
        return status;
    }
  }

  Color get statusColor {
    switch (status) {
      case 'pending':
        return const Color(0xFFFFB74D);
      case 'reviewing':
        return const Color(0xFF42A5F5);
      case 'in_progress':
        return const Color(0xFF8B5CF6);
      case 'resolved':
        return const Color(0xFF66BB6A);
      case 'rejected':
        return const Color(0xFFEF5350);
      default:
        return Colors.grey;
    }
  }

  String get priorityLabel {
    switch (priority) {
      case 'low':
        return 'Thấp';
      case 'medium':
        return 'Trung bình';
      case 'high':
        return 'Cao';
      case 'critical':
        return 'Khẩn cấp';
      default:
        return priority;
    }
  }

  Color get priorityColor {
    switch (priority) {
      case 'low':
        return const Color(0xFF66BB6A);
      case 'medium':
        return const Color(0xFFFFB74D);
      case 'high':
        return const Color(0xFFEF5350);
      case 'critical':
        return const Color(0xFFD32F2F);
      default:
        return Colors.grey;
    }
  }

  String get categoryLabel {
    switch (category) {
      case 'bug':
        return 'Lỗi kỹ thuật';
      case 'ux':
        return 'Trải nghiệm UI/UX';
      case 'performance':
        return 'Hiệu suất';
      case 'payment':
        return 'Thanh toán';
      case 'other':
        return 'Khác';
      default:
        return 'Chung';
    }
  }

  bool get isResolved => status == 'resolved' || status == 'rejected';
  bool get hasAdminReply => adminReply != null && adminReply!.isNotEmpty;
}
