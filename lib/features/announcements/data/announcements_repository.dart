import '../domain/announcement_entity.dart';

class AnnouncementsRepository {
  Future<List<AnnouncementEntity>> getActiveAnnouncements() async {
    await Future.delayed(const Duration(milliseconds: 400));

    final now = DateTime.now();

    return [
      AnnouncementEntity(
        id: 1,
        title: 'يوم التقني العالمي',
        description: 'ابدأ رحلتك البرمجية اليوم 🚀',
        startsAt: now.subtract(const Duration(minutes: 1)),
        endsAt: now.add(const Duration(seconds: 10)),
        isActive: true,
        link: null,
      ),
    ];
  }
}
