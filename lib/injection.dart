import 'package:roadmaps/features/homepage/data/home_repository.dart';
import 'package:roadmaps/features/homepage/domain/get_home_data_usecase.dart';
import 'package:roadmaps/features/homepage/presentation/home_provider.dart';
import 'package:roadmaps/features/announcements/data/announcements_repository.dart';
import 'package:roadmaps/features/announcements/presentation/announcements_provider.dart';
import 'package:roadmaps/features/announcements/domain/get_active_announcements_usecase.dart';


class Injection {
  // دالة لتجهيز الـ HomeProvider
  static HomeProvider provideHomeProvider() {
    final homerepository = HomeRepository();
    final useCase = GetHomeDataUseCase(homerepository);
    return HomeProvider(useCase);
  }

  // دالة لتجهيز الـ AnnouncementsProvider
 static AnnouncementsProvider provideAnnouncementsProvider() {
  final announcementsrepository = AnnouncementsRepository();
  final useCase = GetActiveAnnouncementsUseCase(announcementsrepository); // إضافة الـ UseCase هنا
  return AnnouncementsProvider(useCase);
}
}