import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/utils/enrollment_sync.dart';
import 'package:roadmaps/features/homepage/presentation/home_provider.dart';
import 'package:roadmaps/features/profile/presentation/profile_provider.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_provider.dart';

import 'package:roadmaps/features/announcements/presentation/announcements_provider.dart';

Future<bool> retryUntilSuccess(
  Future<void> Function() action, {
  required String label,
  int maxAttempts = 2,
  Duration delay = const Duration(seconds: 2),
}) async {
  var attempt = 0;
  while (attempt < maxAttempts) {
    attempt++;
    try {
      await action();
      return true;
    } catch (error) {
      // Simple backoff: later retries wait a bit longer.
      if (attempt >= maxAttempts) {
        return false;
      }
      final wait = Duration(
        milliseconds: delay.inMilliseconds * attempt,
      );
      await Future.delayed(wait);
    }
  }

  return false;
}

Future<void> refreshHomePageData(BuildContext context) async {
  final announcementsProvider = context.read<AnnouncementsProvider>();
  final profileProvider = context.read<ProfileProvider>();
  final roadmapsProvider = context.read<RoadmapsProvider>();
  final homeProvider = context.read<HomeProvider>();

  await retryUntilSuccess(
    () => EnrollmentSync.refreshAll(
      homeProvider: homeProvider,
      roadmapsProvider: roadmapsProvider,
      profileProvider: profileProvider,
    ),
    label: 'Home page sync',
  );
  await retryUntilSuccess(
    announcementsProvider.loadAnnouncements,
    label: 'Home announcements refresh',
  );
}

Future<void> refreshProfilePageData(BuildContext context) async {
  final homeProvider = context.read<HomeProvider>();
  final roadmapsProvider = context.read<RoadmapsProvider>();
  final profileProvider = context.read<ProfileProvider>();

  await retryUntilSuccess(
    () => EnrollmentSync.refreshAll(
      homeProvider: homeProvider,
      roadmapsProvider: roadmapsProvider,
      profileProvider: profileProvider,
    ),
    label: 'Profile page sync',
  );
}

Future<void> refreshRoadmapsPageData(BuildContext context) async {
  final homeProvider = context.read<HomeProvider>();
  final profileProvider = context.read<ProfileProvider>();
  final roadmapsProvider = context.read<RoadmapsProvider>();

  await retryUntilSuccess(
    () => EnrollmentSync.refreshAll(
      homeProvider: homeProvider,
      roadmapsProvider: roadmapsProvider,
      profileProvider: profileProvider,
    ),
    label: 'Roadmaps page sync',
  );
}
