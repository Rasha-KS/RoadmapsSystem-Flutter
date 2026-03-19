import 'package:roadmaps/core/api/api_exceptions.dart';

import '../domain/notification_entity.dart';

class NotificationModel extends NotificationEntity {
  const NotificationModel({
    required super.id,
    required super.title,
    required super.message,
    required super.scheduledAt,
    required super.isRead,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    final payload = _extractPayload(json);
    final title =
        _asOptionalString(json['title']) ??
        _asOptionalString(payload['title']) ??
        _asOptionalString(payload['subject']) ??
        _asOptionalString(payload['heading']) ??
        'Notification';
    final message =
        _asOptionalString(json['message']) ??
        _asOptionalString(json['body']) ??
        _asOptionalString(json['description']) ??
        _asOptionalString(payload['message']) ??
        _asOptionalString(payload['body']) ??
        _asOptionalString(payload['description']) ??
        _asOptionalString(payload['content']) ??
        title;

    return NotificationModel(
      id: _asId(json['id'] ?? payload['id']),
      title: title,
      message: message,
      scheduledAt: _asDate(
        json['scheduled_at'] ??
            json['created_at'] ??
            json['sent_at'] ??
            json['date'] ??
            payload['scheduled_at'] ??
            payload['created_at'] ??
            payload['sent_at'] ??
            payload['date'],
      ),
      isRead:
          _asBool(json['is_read'] ?? json['read']) ??
          _asBool(payload['is_read'] ?? payload['read']) ??
          (json['read_at'] != null || payload['read_at'] != null),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'scheduled_at': scheduledAt.toIso8601String(),
      'is_read': isRead,
    };
  }

  static Map<String, dynamic> _extractPayload(Map<String, dynamic> json) {
    final data = json['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }
    return json;
  }

  static String _asId(dynamic value) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) {
      return text;
    }
    throw const ParsingException();
  }

  static String? _asOptionalString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) {
      return null;
    }
    return text;
  }

  static DateTime _asDate(dynamic value) {
    if (value is DateTime) {
      return value;
    }

    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed != null) {
      return parsed;
    }

    return DateTime.now();
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) {
      return value;
    }
    if (value is num) {
      return value != 0;
    }

    final normalized = value?.toString().trim().toLowerCase();
    switch (normalized) {
      case '1':
      case 'true':
      case 'yes':
        return true;
      case '0':
      case 'false':
      case 'no':
        return false;
      default:
        return null;
    }
  }
}
