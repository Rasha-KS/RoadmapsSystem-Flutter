import 'dart:async';
import 'package:flutter/material.dart';
import '../data/announcements_repository.dart';
import '../domain/announcement_entity.dart';

class AnnouncementsProvider extends ChangeNotifier {
  final AnnouncementsRepository repository;

  AnnouncementsProvider(this.repository);

  AnnouncementEntity? current;
  Timer? _timer;

  Future<void> loadAnnouncement() async {
    final list = await repository.getActiveAnnouncements();
    final now = DateTime.now();

    final active = list.where((a) =>
        a.isActive &&
        a.startsAt.isBefore(now) &&
        a.endsAt.isAfter(now));

    if (active.isEmpty) return;

    current = active.first;
    notifyListeners();

    _timer?.cancel();
    _timer = Timer(
      current!.endsAt.difference(now),
      () {
        current = null;
        notifyListeners();
      },
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
