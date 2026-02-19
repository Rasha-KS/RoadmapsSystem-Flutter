import 'package:roadmaps/core/entities/user_entity.dart';
import 'package:roadmaps/core/domain/repositories/user_repository.dart';
import '../domain/user_roadmap_entity.dart';
import 'profile_user_model.dart';
import 'user_roadmap_model.dart';

class ProfileRepository {
ProfileRepository({required UserRepository userRepository})
    : _userRepository = userRepository;

final UserRepository _userRepository;
final List<Map<String, dynamic>> _roadmapsTable = [
  {
    'id': 1,
    'title': 'Flutter',
    'level': 'متوسط',
    'description': 'تعلم بناء تطبيقات موبايل متقدمة من الصفر باستخدام Flutter.',
    'is_active': true,
  },
  {
    'id': 2,
    'title': 'Python',
    'level': 'مبتدئ',
    'description': 'تعلم أساسيات لغة Python والبرمجة العامة.',
    'is_active': true,
  },
  {
    'id': 3,
    'title': 'C++',
    'level': 'متقدم',
    'description': 'التعمق في البرمجة الكائنية، مكتبة STL، وأساسيات الذاكرة.',
    'is_active': true,
  },
  {
    'id': 4,
    'title': 'JavaScript',
    'level': 'مبتدئ',
    'description': 'تعلم أساسيات لغة JavaScript لتطوير الويب.',
    'is_active': true,
  },
  {
    'id': 5,
    'title': 'Dart',
    'level': 'متوسط',
    'description': 'تعلم لغة Dart لاستخدامها مع Flutter أو البرمجة العامة.',
    'is_active': true,
  },
  {
    'id': 6,
    'title': 'React',
    'level': 'متقدم',
    'description': 'تعلم بناء واجهات مستخدم ديناميكية باستخدام React.',
    'is_active': true,
  },
];

final List<Map<String, dynamic>> _roadmapEnrollmentsTable = [
  {
    'id': 101,
    'user_id': 1,
    'roadmap_id': 1,
    'started_at': DateTime(2026, 1, 1),
    'completed_at': null,
    'xp_points': 50,
    'progress_percentage': 90,
    'status': 'في تقدم',
  },
  {
    'id': 102,
    'user_id': 1,
    'roadmap_id': 2,
    'started_at': DateTime(2026, 1, 25),
    'completed_at': null,
    'xp_points': 50,
    'progress_percentage': 70,
    'status': 'في تقدم',
  },
  {
    'id': 103,
    'user_id': 1,
    'roadmap_id': 3,
    'started_at': DateTime(2026, 2, 1),
    'completed_at': null,
    'xp_points': 20,
    'progress_percentage': 40,
    'status': 'في تقدم',
  },
  {
    'id': 104,
    'user_id': 1,
    'roadmap_id': 4,
    'started_at': DateTime(2026, 2, 5),
    'completed_at': null,
    'xp_points': 10,
    'progress_percentage': 15,
    'status': 'في تقدم',
  },
  {
    'id': 105,
    'user_id': 1,
    'roadmap_id': 5,
    'started_at': DateTime(2025, 2, 8),
    'completed_at': DateTime(2025, 4, 8),
    'xp_points': 90,
    'progress_percentage': 100,
    'status': 'مكتمل',
  },
  {
    'id': 106,
    'user_id': 1,
    'roadmap_id': 6,
    'started_at': DateTime(2026, 2, 10),
    'completed_at': null,
    'xp_points': 5,
    'progress_percentage': 5,
    'status': 'في تقدم',
  },
];



  Future<UserEntity> getUserProfile() async {
    final user = await _userRepository.getCurrentUser();
    return ProfileUserModel(
      id: user.id,
      username: user.username,
      email: user.email,
      createdAt: user.createdAt,
      updatedAt: user.updatedAt,
      lastActivityAt: user.lastActivityAt,
      isNotificationsEnabled: user.isNotificationsEnabled,
      profileImageUrl: user.profileImageUrl,
    );
  }

  Future<List<UserRoadmapEntity>> getUserRoadmaps(int userId) async {
    await Future.delayed(const Duration(milliseconds: 250));

    final enrollments = _roadmapEnrollmentsTable
        .where((row) => row['user_id'] == userId)
        .toList();

    return enrollments.map((enrollment) {
      final roadmap = _roadmapsTable.firstWhere(
        (row) => row['id'] == enrollment['roadmap_id'],
      );

      return UserRoadmapModel.fromJson({
        'enrollment_id': enrollment['id'],
        'user_id': enrollment['user_id'],
        'roadmap_id': enrollment['roadmap_id'],
        'title': roadmap['title'],
        'level': roadmap['level'],
        'description': roadmap['description'],
        'is_active': roadmap['is_active'],
        'status': enrollment['status'],
        'started_at': enrollment['started_at'],
        'completed_at': enrollment['completed_at'],
        'xp_points': enrollment['xp_points'],
        'progress_percentage': enrollment['progress_percentage'],
      });
    }).toList();
  }

  Future<void> deleteUserRoadmap(int enrollmentId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    _roadmapEnrollmentsTable.removeWhere((row) => row['id'] == enrollmentId);
  }

  Future<void> resetUserRoadmap(int enrollmentId) async {
    await Future.delayed(const Duration(milliseconds: 150));
    final index = _roadmapEnrollmentsTable.indexWhere(
      (row) => row['id'] == enrollmentId,
    );
    if (index == -1) return;

    _roadmapEnrollmentsTable[index] = {
      ..._roadmapEnrollmentsTable[index],
      'xp_points': 0,
      'progress_percentage': 0,
      'status': 'في تقدم',
      'completed_at': null,
      'started_at': DateTime.now(),
    };
  }
}

