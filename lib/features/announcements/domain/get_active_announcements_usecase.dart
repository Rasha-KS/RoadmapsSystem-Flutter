import 'announcement_entity.dart';
import '../data/announcements_repository.dart';

class GetActiveAnnouncementsUseCase {
  final AnnouncementsRepository repository;
  GetActiveAnnouncementsUseCase(this.repository);

  Future<List<AnnouncementEntity>> execute() async {
    final allList = await repository.getActiveAnnouncements();
   // final now = DateTime.now();

    return allList;
    
    // .where((a) =>
    //     a.isActive &&
    //     a.startsAt.isBefore(now) &&
    //     a.endsAt.isAfter(now)).toList();
  }
}