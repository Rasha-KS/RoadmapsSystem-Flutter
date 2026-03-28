import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/providers/safe_change_notifier.dart';
import '../domain/announcement_entity.dart';
import '../domain/get_active_announcements_usecase.dart';

enum AnnouncementsState { loading, loaded, connectionError }

class AnnouncementsProvider extends SafeChangeNotifier {
  final GetActiveAnnouncementsUseCase useCase;
  AnnouncementsProvider(this.useCase);

  List<AnnouncementEntity> _announcements = [];
  List<AnnouncementEntity> get announcements => _announcements;

  AnnouncementsState state = AnnouncementsState.loading;
  String? error;

  Future<void> loadAnnouncements() async {
    state = AnnouncementsState.loading;
    error = null;
    notifyListeners();

    try {
      // Load announcements from API and update the Home UI list.
      _announcements = await useCase.execute();
      final repositoryError = useCase.repository.lastLoadErrorMessage;
      if (repositoryError != null) {
        error = repositoryError;
        state = _announcements.isEmpty
            ? AnnouncementsState.connectionError
            : AnnouncementsState.loaded;
      } else {
        state = AnnouncementsState.loaded;
      }
    } catch (e) {
      error = _friendlyError(e);
      state = AnnouncementsState.connectionError;
    }

    notifyListeners();
  }

  String _friendlyError(Object error) {
    if (error is TimeoutApiException) {
      return 'استغرق تحميل الإعلانات وقتًا أطول من المعتاد. حاول مرة أخرى.';
    }
    if (error is NetworkException) {
      return 'تعذر الاتصال حالياً. تحقق من الشبكة وحاول مرة أخرى.';
    }
    if (error is ApiException) {
      return error.message;
    }
    return 'تعذر تحميل الإعلانات.';
  }
}
