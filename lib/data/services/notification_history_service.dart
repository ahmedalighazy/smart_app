import 'package:hive_flutter/hive_flutter.dart';
import 'dart:convert';

class NotificationHistory {
  final String id;
  final String title;
  final String body;
  final DateTime timestamp;
  final String type; // 'meal', 'tip', 'reminder'
  final Map<String, dynamic>? data;

  NotificationHistory({
    required this.id,
    required this.title,
    required this.body,
    required this.timestamp,
    required this.type,
    this.data,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'body': body,
      'timestamp': timestamp.toIso8601String(),
      'type': type,
      'data': data,
    };
  }

  factory NotificationHistory.fromMap(Map<String, dynamic> map) {
    return NotificationHistory(
      id: map['id'] as String,
      title: map['title'] as String,
      body: map['body'] as String,
      timestamp: DateTime.parse(map['timestamp'] as String),
      type: map['type'] as String,
      data: map['data'] != null ? Map<String, dynamic>.from(map['data'] as Map) : null,
    );
  }
}

class NotificationHistoryService {
  static const String _boxName = 'notification_history';
  static late Box<String> _box;

  static Future<void> init() async {
    _box = await Hive.openBox<String>(_boxName);
  }

  static Future<void> addNotification({
    required String title,
    required String body,
    required String type,
    Map<String, dynamic>? data,
  }) async {
    final notification = NotificationHistory(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      title: title,
      body: body,
      timestamp: DateTime.now(),
      type: type,
      data: data,
    );

    final jsonString = _notificationToJson(notification);
    await _box.put(notification.id, jsonString);
  }

  static List<NotificationHistory> getAllNotifications() {
    final notifications = <NotificationHistory>[];
    for (var value in _box.values) {
      notifications.add(_jsonToNotification(value));
    }
    // ترتيب من الأحدث للأقدم
    notifications.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return notifications;
  }

  static List<NotificationHistory> getNotificationsByType(String type) {
    final notifications = getAllNotifications();
    return notifications.where((n) => n.type == type).toList();
  }

  static Future<void> deleteNotification(String id) async {
    await _box.delete(id);
  }

  static Future<void> clearAll() async {
    await _box.clear();
  }

  static int getNotificationCount() {
    return _box.length;
  }

  static int getUnreadCount() {
    return _box.length;
  }

  // Helper methods for JSON conversion
  static String _notificationToJson(NotificationHistory notification) {
    final map = {
      'id': notification.id,
      'title': notification.title,
      'body': notification.body,
      'timestamp': notification.timestamp.toIso8601String(),
      'type': notification.type,
      'data': notification.data,
    };
    return jsonEncode(map);
  }

  static NotificationHistory _jsonToNotification(String json) {
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return NotificationHistory.fromMap(map);
    } catch (e) {
      // Fallback for old format
      final parts = json.split('|');
      return NotificationHistory(
        id: parts[0],
        title: parts[1],
        body: parts[2],
        timestamp: DateTime.parse(parts[3]),
        type: parts[4],
      );
    }
  }
}
