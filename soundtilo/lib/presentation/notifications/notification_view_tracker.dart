import 'package:flutter/foundation.dart';

class NotificationViewTracker {
  static final ValueNotifier<bool> isNotificationViewOpen = ValueNotifier<bool>(
    false,
  );
}
