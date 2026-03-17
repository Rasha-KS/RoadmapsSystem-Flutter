import 'package:roadmaps/core/api/api_exceptions.dart';

import '../domain/announcement_entity.dart';

class AnnouncementModel extends AnnouncementEntity {
  AnnouncementModel({
    required super.id,
    required super.title,
    required super.description,
    required super.startsAt,
    required super.endsAt,
    required super.isActive,
    super.link,
  });

  factory AnnouncementModel.fromJson(Map<String, dynamic> json) {
    final id = _asInt(json['id']);
    final title = _asString(json['title']);
    final description = _asString(json['description']);

    return AnnouncementModel(
      id: id,
      title: title,
      description: description,
      startsAt: _asDate(json['starts_at'] ?? json['start_at']),
      endsAt: _asDate(json['ends_at'] ?? json['end_at']),
      isActive: _asBool(json['is_active']) ?? true,
      link: _asOptionalString(json['link'] ?? json['url']),
    );
  }

  static int _asInt(dynamic value) {
    if (value is int) return value;
    final parsed = int.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    throw const ParsingException();
  }

  static String _asString(dynamic value) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
    throw const ParsingException();
  }

  static String? _asOptionalString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  static DateTime _asDate(dynamic value) {
    if (value is DateTime) return value;
    final parsed = DateTime.tryParse(value?.toString() ?? '');
    if (parsed != null) return parsed;
    return DateTime.now();
  }

  static bool? _asBool(dynamic value) {
    if (value is bool) return value;
    if (value is num) return value != 0;
    final text = value?.toString().toLowerCase();
    if (text == 'true') return true;
    if (text == 'false') return false;
    return null;
  }
}
