import '../domain/announcement_entity.dart';

class AnnouncementsRepository {
  Future<List<AnnouncementEntity>> getActiveAnnouncements() async {
    await Future.delayed(const Duration(milliseconds: 400));

    return [
    AnnouncementEntity(
      id: 1,
      title: 'يوم التقني العالمي',
      description: 'ابدأ رحلتك البرمجية اليوم 🚀',
      startsAt: DateTime(2026, 2, 1),
      endsAt: DateTime(2026, 2, 15),
      isActive: true,
      link: 'https://google.com',
    ),

    AnnouncementEntity(
      id: 2,
      title: 'إطلاق دورة Flutter',
      description: 'دورة جديدة لبناء تطبيقات احترافية من الصفر',
      startsAt: DateTime(2026, 1, 1),
      endsAt: DateTime(2026, 3, 20),
      isActive: true,
      link: 'https://google.com',
    ),

    AnnouncementEntity(
      id: 3,
      title: 'خصم لفترة محدودة',
      description: 'خصم 30٪ على جميع الدورات البرمجية',
      startsAt: DateTime(2026, 2, 1),
      endsAt: DateTime(2026, 2, 25),
      isActive: true,
      link: 'https://google.com',
    ),

    AnnouncementEntity(
      id: 4,
      title: 'تحديث المنصة',
      description: 'تحسينات جديدة على الأداء وتجربة المستخدم',
      startsAt: DateTime(2026, 2, 1),
      endsAt: DateTime(2026, 2, 12),
      isActive: true,
      link: 'https://google.com',
    ),
    ];
  }
}
