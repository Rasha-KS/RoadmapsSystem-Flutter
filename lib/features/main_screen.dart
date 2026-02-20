import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/widgets/app_appbar.dart';
import 'package:roadmaps/core/widgets/app_bottom_nav.dart';
import 'package:roadmaps/features/announcements/presentation/announcements_provider.dart';
import 'package:roadmaps/features/community/presentation/community_provider.dart';
import 'package:roadmaps/features/community/presentation/community_screen.dart';
import 'package:roadmaps/features/homepage/presentation/home_provider.dart';
import 'package:roadmaps/features/homepage/presentation/home_screen.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_provider.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_screen.dart';
import 'package:roadmaps/features/profile/presentation/profile_provider.dart';
import 'package:roadmaps/features/profile/presentation/profile_screen.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_provider.dart';
import 'package:roadmaps/features/settings/presentation/settings_screen.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_provider.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 2;

  final List<Widget> pages = [
    const SmartInstructorScreen(),
    const CommunityScreen(),
    const HomeScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<RoadmapsProvider>().loadRoadmaps();
      context.read<ProfileProvider>().loadProfileData();
      context.read<HomeProvider>().loadHome();
      context.read<AnnouncementsProvider>().loadAnnouncements();
      context.read<CommunityProvider>().loadRooms();
      context.read<NotificationsProvider>().loadNotifications();
      context.read<SmartInstructorProvider>().loadIntro();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(
        context: context,
        onNotificationsTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const NotificationsScreen()),
          );
        },
        onSettingsTap: () {
          Navigator.of(
            context,
          ).push(MaterialPageRoute(builder: (_) => const SettingsScreen()));
        },
      ),
      body: SafeArea(
        child: IndexedStack(index: currentIndex, children: pages),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 10,
              spreadRadius: 2,
            ),
          ],
        ),
        child: buildAppBottomNav(
          currentIndex: currentIndex,
          onTap: (index) {
            setState(() {
              currentIndex = index;
            });
          },
        ),
      ),
    );
  }
}
