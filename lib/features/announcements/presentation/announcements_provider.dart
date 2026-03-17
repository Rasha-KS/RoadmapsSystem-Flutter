// features/announcements/presentation/announcements_provider.dart
import 'package:flutter/material.dart';
import 'package:roadmaps/core/api/api_exceptions.dart';
import '../domain/announcement_entity.dart';
import '../domain/get_active_announcements_usecase.dart';

enum AnnouncementsState { loading, loaded, connectionError }

class AnnouncementsProvider extends ChangeNotifier {
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
      state = AnnouncementsState.loaded;
    } catch (e) {
      error = e is ApiException ? e.message : 'تعذر تحميل الإعلانات.';
      state = AnnouncementsState.connectionError;
    }

    notifyListeners();
  }
}
