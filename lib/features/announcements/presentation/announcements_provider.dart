// features/announcements/presentation/announcements_provider.dart
import 'package:flutter/material.dart';
import '../domain/announcement_entity.dart';
import '../domain/get_active_announcements_usecase.dart';

class AnnouncementsProvider extends ChangeNotifier {
  final GetActiveAnnouncementsUseCase useCase;
  AnnouncementsProvider(this.useCase);

  List<AnnouncementEntity> _announcements = [];
  List<AnnouncementEntity> get announcements => _announcements;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadAnnouncements() async {
    _isLoading = true;
    notifyListeners();

    _announcements = await useCase.execute();

    _isLoading = false;
    notifyListeners();
  }
}