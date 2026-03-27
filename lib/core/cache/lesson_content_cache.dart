import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:roadmaps/features/learning_path/domain/learning_path_entity.dart';
import 'package:roadmaps/features/learning_path/domain/learning_unit_entity.dart';
import 'package:roadmaps/features/lessons/domain/resource_entity.dart';
import 'package:roadmaps/features/lessons/domain/sub_lesson_entity.dart';
import 'package:roadmaps/features/roadmaps/domain/roadmap_entity.dart';

class LessonContentCache {
  LessonContentCache._({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static final LessonContentCache instance = LessonContentCache._();

  final FlutterSecureStorage _storage;
  final Map<String, _CachedValue> _memoryCache = {};
  final Set<String> _knownKeys = <String>{};
  final Set<String> _knownProgressKeys = <String>{};
  final Set<String> _knownRoadmapProgressKeys = <String>{};

  static const Duration _defaultTtl = Duration(hours: 72);
  static const String _indexKey = 'lesson_content_cache_index_v1';
  static const String _progressIndexKey = 'lesson_progress_cache_index_v1';
  static const String _roadmapProgressIndexKey =
      'roadmap_progress_cache_index_v1';

  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
  );

  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock,
  );

  Future<LearningPathEntity?> readLearningPath(int roadmapId) {
    return _readValue(
      _learningPathKey(roadmapId),
      _decodeLearningPath,
    );
  }

  Future<void> writeLearningPath(
    int roadmapId,
    LearningPathEntity value,
  ) {
    return _writeValue(
      _learningPathKey(roadmapId),
      _encodeLearningPath(value),
    );
  }

  Future<List<SubLessonEntity>?> readSubLessons(int lessonId) {
    return _readValue(
      _subLessonsKey(lessonId),
      _decodeSubLessons,
    );
  }

  Future<void> writeSubLessons(
    int lessonId,
    List<SubLessonEntity> value,
  ) {
    return _writeValue(
      _subLessonsKey(lessonId),
      _encodeSubLessons(value),
    );
  }

  Future<List<ResourceEntity>?> readResources(int subLessonId) {
    return _readValue(
      _resourcesKey(subLessonId),
      _decodeResources,
    );
  }

  Future<void> writeResources(
    int subLessonId,
    List<ResourceEntity> value,
  ) {
    return _writeValue(
      _resourcesKey(subLessonId),
      _encodeResources(value),
    );
  }

  Future<void> clearAll() async {
    await clearContentCache();
    await clearAllProgress();
    await clearAllRoadmapProgress();
  }

  Future<void> clearContentCache() async {
    _memoryCache.clear();

    final persistedKeys = await _readPersistedKeys();
    if (persistedKeys.isEmpty) {
      await _storage.delete(
        key: _indexKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      _knownKeys.clear();
      return;
    }

    for (final key in persistedKeys) {
      try {
        await _storage.delete(
          key: key,
          aOptions: _androidOptions,
          iOptions: _iosOptions,
        );
      } catch (e) {
        debugPrint('LessonContentCache.clearContentCache delete error for $key: $e');
      }
    }

    await _storage.delete(
      key: _indexKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    _knownKeys.clear();
  }

  Future<LearningPathEntity> applyProgressOverrides(
    LearningPathEntity path,
  ) async {
    final completedUnits = await readCompletedUnits(path.roadmap.id);
    if (completedUnits.isEmpty) {
      return path;
    }

    final updatedUnits = [...path.units];
    for (var index = 0; index < updatedUnits.length; index++) {
      final unit = updatedUnits[index];
      if (completedUnits.contains(unit.id)) {
        updatedUnits[index] = unit.copyWith(
          status: LearningUnitStatus.completed,
          isLocked: false,
          isCompleted: true,
        );
        if (index + 1 < updatedUnits.length) {
          final nextUnit = updatedUnits[index + 1];
          if (nextUnit.status == LearningUnitStatus.locked) {
            updatedUnits[index + 1] = nextUnit.copyWith(
              status: LearningUnitStatus.unlocked,
              isLocked: false,
            );
          }
        }
      }
    }

    return LearningPathEntity(
      roadmap: path.roadmap,
      units: updatedUnits,
    );
  }

  Future<Set<int>> readCompletedUnits(int roadmapId) async {
    try {
      final raw = await _storage.read(
        key: _progressKey(roadmapId),
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      if (raw == null || raw.trim().isEmpty) {
        return <int>{};
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <int>{};
      }

      return decoded
          .map((value) => _asInt(value))
          .where((value) => value > 0)
          .toSet();
    } catch (error) {
      debugPrint('LessonContentCache.readCompletedUnits error: $error');
      return <int>{};
    }
  }

  Future<void> markUnitCompleted(int roadmapId, int unitId) async {
    final completed = await readCompletedUnits(roadmapId);
    if (!completed.add(unitId)) {
      await _registerProgressKey(_progressKey(roadmapId));
      return;
    }

    await _storage.write(
      key: _progressKey(roadmapId),
      value: jsonEncode(completed.toList(growable: false)),
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
    await _registerProgressKey(_progressKey(roadmapId));
  }

  Future<void> clearProgressForRoadmap(int roadmapId) async {
    try {
      await _storage.delete(
        key: _progressKey(roadmapId),
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (error) {
      debugPrint('LessonContentCache.clearProgressForRoadmap error: $error');
    }
    await _removeProgressKey(_progressKey(roadmapId));
    await clearRoadmapProgress(roadmapId);
  }

  Future<void> clearAllProgress() async {
    _knownProgressKeys.clear();
    try {
      final raw = await _storage.read(
        key: _progressIndexKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded.whereType<String>()) {
            await _storage.delete(
              key: item,
              aOptions: _androidOptions,
              iOptions: _iosOptions,
            );
          }
        }
      }
    } catch (error) {
      debugPrint('LessonContentCache.clearAllProgress error: $error');
    }

    await _storage.delete(
      key: _progressIndexKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }

  Future<int?> readRoadmapProgress(int roadmapId) async {
    final progress = await _readValue<int>(
      _roadmapProgressKey(roadmapId),
      (payload) => _asInt(payload, fallback: 0),
    );
    if (progress == null || progress < 0) {
      return null;
    }
    return progress.clamp(0, 100);
  }

  Future<void> writeRoadmapProgress(int roadmapId, int progress) async {
    await _writeValue(
      _roadmapProgressKey(roadmapId),
      progress.clamp(0, 100),
    );
    await _registerRoadmapProgressKey(_roadmapProgressKey(roadmapId));
  }

  Future<void> clearRoadmapProgress(int roadmapId) async {
    try {
      await _storage.delete(
        key: _roadmapProgressKey(roadmapId),
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (error) {
      debugPrint('LessonContentCache.clearRoadmapProgress error: $error');
    }
    await _removeRoadmapProgressKey(_roadmapProgressKey(roadmapId));
  }

  Future<void> clearAllRoadmapProgress() async {
    _knownRoadmapProgressKeys.clear();
    try {
      final raw = await _storage.read(
        key: _roadmapProgressIndexKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      if (raw != null && raw.trim().isNotEmpty) {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          for (final item in decoded.whereType<String>()) {
            await _storage.delete(
              key: item,
              aOptions: _androidOptions,
              iOptions: _iosOptions,
            );
          }
        }
      }
    } catch (error) {
      debugPrint('LessonContentCache.clearAllRoadmapProgress error: $error');
    }

    await _storage.delete(
      key: _roadmapProgressIndexKey,
      aOptions: _androidOptions,
      iOptions: _iosOptions,
    );
  }

  Future<T?> _readValue<T>(
    String key,
    T Function(dynamic payload) decode,
  ) async {
    final cached = _memoryCache[key];
    if (cached != null) {
      if (!cached.isExpired) {
        return cached.value as T;
      }
      await _removeKey(key);
    }

    try {
      final raw = await _storage.read(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      if (raw == null || raw.trim().isEmpty) {
        return null;
      }

      final envelope = jsonDecode(raw);
      if (envelope is! Map<String, dynamic>) {
        await _removeKey(key);
        return null;
      }

      final expiresAtMs = _asInt(envelope['expiresAt']);
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(expiresAtMs);
      if (DateTime.now().isAfter(expiresAt)) {
        await _removeKey(key);
        return null;
      }

      final value = decode(envelope['payload']);
      _memoryCache[key] = _CachedValue(value: value as Object, expiresAt: expiresAt);
      return value;
    } catch (error) {
      debugPrint('LessonContentCache._readValue error for $key: $error');
      await _removeKey(key);
      return null;
    }
  }

  Future<void> _writeValue(String key, Object payload) async {
    try {
      final expiresAt = DateTime.now().add(_defaultTtl);
      final envelope = <String, dynamic>{
        'savedAt': DateTime.now().toUtc().millisecondsSinceEpoch,
        'expiresAt': expiresAt.toUtc().millisecondsSinceEpoch,
        'payload': payload,
      };

      await _storage.write(
        key: key,
        value: jsonEncode(envelope),
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );

      _memoryCache[key] = _CachedValue(value: payload, expiresAt: expiresAt);
      await _registerKey(key);
    } catch (error) {
      debugPrint('LessonContentCache._writeValue error for $key: $error');
    }
  }

  Future<void> _removeKey(String key) async {
    _memoryCache.remove(key);
    try {
      await _storage.delete(
        key: key,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (error) {
      debugPrint('LessonContentCache._removeKey error for $key: $error');
    }

    _knownKeys.remove(key);
    await _persistKnownKeys();
  }

  Future<void> _registerKey(String key) async {
    if (_knownKeys.add(key)) {
      await _persistKnownKeys();
    }
  }

  Future<void> _registerProgressKey(String key) async {
    final keys = await _readPersistedProgressKeys();
    if (!keys.add(key)) {
      _knownProgressKeys.add(key);
      return;
    }

    _knownProgressKeys
      ..clear()
      ..addAll(keys);
    await _persistKnownProgressKeys();
  }

  Future<void> _registerRoadmapProgressKey(String key) async {
    final keys = await _readPersistedRoadmapProgressKeys();
    if (!keys.add(key)) {
      _knownRoadmapProgressKeys.add(key);
      return;
    }

    _knownRoadmapProgressKeys
      ..clear()
      ..addAll(keys);
    await _persistKnownRoadmapProgressKeys();
  }

  Future<void> _removeProgressKey(String key) async {
    final keys = await _readPersistedProgressKeys();
    if (!keys.remove(key)) {
      _knownProgressKeys.remove(key);
      return;
    }

    _knownProgressKeys
      ..clear()
      ..addAll(keys);
    await _persistKnownProgressKeys();
  }

  Future<void> _removeRoadmapProgressKey(String key) async {
    final keys = await _readPersistedRoadmapProgressKeys();
    if (!keys.remove(key)) {
      _knownRoadmapProgressKeys.remove(key);
      return;
    }

    _knownRoadmapProgressKeys
      ..clear()
      ..addAll(keys);
    await _persistKnownRoadmapProgressKeys();
  }

  Future<void> _persistKnownKeys() async {
    try {
      await _storage.write(
        key: _indexKey,
        value: jsonEncode(_knownKeys.toList(growable: false)),
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (error) {
      debugPrint('LessonContentCache._persistKnownKeys error: $error');
    }
  }

  Future<void> _persistKnownProgressKeys() async {
    try {
      await _storage.write(
        key: _progressIndexKey,
        value: jsonEncode(_knownProgressKeys.toList(growable: false)),
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (error) {
      debugPrint('LessonContentCache._persistKnownProgressKeys error: $error');
    }
  }

  Future<void> _persistKnownRoadmapProgressKeys() async {
    try {
      await _storage.write(
        key: _roadmapProgressIndexKey,
        value: jsonEncode(_knownRoadmapProgressKeys.toList(growable: false)),
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
    } catch (error) {
      debugPrint('LessonContentCache._persistKnownRoadmapProgressKeys error: $error');
    }
  }

  Future<Set<String>> _readPersistedProgressKeys() async {
    try {
      final raw = await _storage.read(
        key: _progressIndexKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      if (raw == null || raw.trim().isEmpty) {
        return <String>{};
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <String>{};
      }

      return decoded
          .whereType<String>()
          .map((key) => key.trim())
          .where((key) => key.isNotEmpty)
          .toSet();
    } catch (error) {
      debugPrint('LessonContentCache._readPersistedProgressKeys error: $error');
      return <String>{};
    }
  }

  Future<Set<String>> _readPersistedRoadmapProgressKeys() async {
    try {
      final raw = await _storage.read(
        key: _roadmapProgressIndexKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      if (raw == null || raw.trim().isEmpty) {
        return <String>{};
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <String>{};
      }

      return decoded
          .whereType<String>()
          .map((key) => key.trim())
          .where((key) => key.isNotEmpty)
          .toSet();
    } catch (error) {
      debugPrint('LessonContentCache._readPersistedRoadmapProgressKeys error: $error');
      return <String>{};
    }
  }

  Future<Set<String>> _readPersistedKeys() async {
    try {
      final raw = await _storage.read(
        key: _indexKey,
        aOptions: _androidOptions,
        iOptions: _iosOptions,
      );
      if (raw == null || raw.trim().isEmpty) {
        return <String>{};
      }

      final decoded = jsonDecode(raw);
      if (decoded is! List) {
        return <String>{};
      }

      return decoded
          .whereType<String>()
          .map((key) => key.trim())
          .where((key) => key.isNotEmpty)
          .toSet();
    } catch (error) {
      debugPrint('LessonContentCache._readPersistedKeys error: $error');
      return <String>{};
    }
  }

  Map<String, dynamic> _encodeLearningPath(LearningPathEntity value) {
    return <String, dynamic>{
      'roadmap': _encodeRoadmap(value.roadmap),
      'units': value.units
          .map(_encodeLearningUnit)
          .toList(growable: false),
    };
  }

  LearningPathEntity _decodeLearningPath(dynamic payload) {
    final data = _asMap(payload);
    final roadmap = _decodeRoadmap(data['roadmap']);
    final units = _extractUnits(data['units'], roadmap.id);
    return LearningPathEntity(roadmap: roadmap, units: units);
  }

  Map<String, dynamic> _encodeRoadmap(RoadmapEntity roadmap) {
    return <String, dynamic>{
      'id': roadmap.id,
      'title': roadmap.title,
      'level': roadmap.level,
      'description': roadmap.description,
      'status': roadmap.status,
      'isActive': roadmap.isActive,
      'isEnrolled': roadmap.isEnrolled,
    };
  }

  RoadmapEntity _decodeRoadmap(dynamic payload) {
    final data = _asMap(payload);
    return RoadmapEntity(
      id: _asInt(data['id']),
      title: _asString(data['title']),
      level: _asString(data['level']),
      description: _asString(data['description']),
      status: _asNullableString(data['status']),
      isActive: _asBool(data['isActive'], fallback: true),
      isEnrolled: _asBool(data['isEnrolled']),
    );
  }

  Map<String, dynamic> _encodeLearningUnit(LearningUnitEntity unit) {
    return <String, dynamic>{
      'id': unit.id,
      'roadmapId': unit.roadmapId,
      'title': unit.title,
      'label': unit.label,
      'position': unit.position,
      'type': unit.type.name,
      'status': unit.status.name,
      'entityId': unit.entityId,
      'description': unit.description,
      'isLocked': unit.isLocked,
      'isCompleted': unit.isCompleted,
      'isActive': unit.isActive,
      'trackingExists': unit.trackingExists,
      'trackingIsComplete': unit.trackingIsComplete,
      'trackingLastUpdatedAt': unit.trackingLastUpdatedAt?.toUtc().toIso8601String(),
      'requiredXp': unit.requiredXp,
    };
  }

  List<LearningUnitEntity> _extractUnits(dynamic payload, int roadmapId) {
    if (payload is! List) return <LearningUnitEntity>[];
    return payload
        .whereType<Map<String, dynamic>>()
        .map((item) => _decodeLearningUnit(item, roadmapId))
        .toList(growable: false)
      ..sort((left, right) => left.position.compareTo(right.position));
  }

  LearningUnitEntity _decodeLearningUnit(
    Map<String, dynamic> data,
    int roadmapId,
  ) {
    final type = _decodeLearningUnitType(_asString(data['type']));
    final status = _decodeLearningUnitStatus(_asString(data['status']));

    return LearningUnitEntity(
      id: _asInt(data['id']),
      roadmapId: _asInt(data['roadmapId'], fallback: roadmapId),
      title: _asString(data['title']),
      label: _asString(data['label']),
      position: _asInt(data['position']),
      type: type,
      status: status,
      entityId: _asInt(data['entityId']),
      description: _asNullableString(data['description']),
      isLocked: _asBool(data['isLocked']),
      isCompleted: _asBool(data['isCompleted']),
      isActive: _asBool(data['isActive'], fallback: true),
      trackingExists: _asBool(data['trackingExists']),
      trackingIsComplete: _asBool(data['trackingIsComplete']),
      trackingLastUpdatedAt:
          _parseDateTime(data['trackingLastUpdatedAt']),
      requiredXp: _asInt(data['requiredXp']),
    );
  }

  LearningUnitType _decodeLearningUnitType(String value) {
    switch (value) {
      case 'quiz':
        return LearningUnitType.quiz;
      case 'challenge':
        return LearningUnitType.challenge;
      case 'lesson':
      default:
        return LearningUnitType.lesson;
    }
  }

  LearningUnitStatus _decodeLearningUnitStatus(String value) {
    switch (value) {
      case 'locked':
        return LearningUnitStatus.locked;
      case 'completed':
        return LearningUnitStatus.completed;
      case 'unlocked':
      default:
        return LearningUnitStatus.unlocked;
    }
  }

  Map<String, dynamic> _encodeSubLessons(List<SubLessonEntity> values) {
    return <String, dynamic>{
      'items': values.map(_encodeSubLesson).toList(growable: false),
    };
  }

  List<SubLessonEntity> _decodeSubLessons(dynamic payload) {
    final data = _asMap(payload);
    final items = data['items'];
    if (items is! List) return <SubLessonEntity>[];

    return items
        .whereType<Map<String, dynamic>>()
        .map(_decodeSubLesson)
        .toList(growable: false)
      ..sort((left, right) => left.position.compareTo(right.position));
  }

  Map<String, dynamic> _encodeSubLesson(SubLessonEntity value) {
    return <String, dynamic>{
      'id': value.id,
      'lessonId': value.lessonId,
      'title': value.title,
      'position': value.position,
      'description': value.description,
      'resourcesCount': value.resourcesCount,
      'resources': value.resources
          .map(_encodeResource)
          .toList(growable: false),
    };
  }

  SubLessonEntity _decodeSubLesson(Map<String, dynamic> data) {
    final resources = _decodeResources(_asMap(data)['resources']);
    return SubLessonEntity(
      id: _asInt(data['id']),
      lessonId: _asInt(data['lessonId']),
      title: _asString(data['title'], fallback: 'الجزء'),
      position: _asInt(data['position']),
      description: _asNullableString(data['description']),
      resourcesCount: _asInt(data['resourcesCount']),
      resources: resources,
    );
  }

  Map<String, dynamic> _encodeResources(List<ResourceEntity> values) {
    return <String, dynamic>{
      'items': values.map(_encodeResource).toList(growable: false),
    };
  }

  List<ResourceEntity> _decodeResources(dynamic payload) {
    final items = payload is Map<String, dynamic> ? payload['items'] : payload;
    if (items is! List) return <ResourceEntity>[];

    return items
        .whereType<Map<String, dynamic>>()
        .map(_decodeResource)
        .toList(growable: false);
  }

  Map<String, dynamic> _encodeResource(ResourceEntity value) {
    return <String, dynamic>{
      'id': value.id,
      'title': value.title,
      'type': value.type.name,
      'language': value.language,
      'link': value.link,
    };
  }

  ResourceEntity _decodeResource(Map<String, dynamic> data) {
    return ResourceEntity(
      id: _asInt(data['id']),
      title: _asString(data['title']),
      type: _decodeResourceType(_asString(data['type'])),
      language: _asString(data['language']),
      link: _asString(data['link']),
    );
  }

  ResourceType _decodeResourceType(String value) {
    switch (value) {
      case 'article':
        return ResourceType.article;
      case 'video':
        return ResourceType.video;
      case 'book':
        return ResourceType.book;
      default:
        return ResourceType.other;
    }
  }

  Map<String, dynamic> _asMap(dynamic value) {
    if (value is Map<String, dynamic>) return value;
    return <String, dynamic>{};
  }

  int _asInt(dynamic value, {int fallback = 0}) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? '') ?? fallback;
  }

  String _asString(dynamic value, {String fallback = ''}) {
    final text = value?.toString().trim();
    if (text != null && text.isNotEmpty) return text;
    return fallback;
  }

  String? _asNullableString(dynamic value) {
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return text;
  }

  bool _asBool(dynamic value, {bool fallback = false}) {
    if (value is bool) return value;
    if (value is num) return value != 0;

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
        return fallback;
    }
  }

  DateTime? _parseDateTime(dynamic value) {
    if (value is DateTime) return value;
    final text = value?.toString().trim();
    if (text == null || text.isEmpty) return null;
    return DateTime.tryParse(text);
  }

  String _learningPathKey(int roadmapId) => 'learning_path_$roadmapId';
  String _subLessonsKey(int lessonId) => 'lesson_sub_lessons_$lessonId';
  String _resourcesKey(int subLessonId) => 'lesson_resources_$subLessonId';
  String _progressKey(int roadmapId) => 'lesson_progress_$roadmapId';
  String _roadmapProgressKey(int roadmapId) => 'roadmap_progress_$roadmapId';
}

class _CachedValue {
  _CachedValue({
    required this.value,
    required this.expiresAt,
  });

  final Object value;
  final DateTime expiresAt;

  bool get isExpired => DateTime.now().isAfter(expiresAt);
}
