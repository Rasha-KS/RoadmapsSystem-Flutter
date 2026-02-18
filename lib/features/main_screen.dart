import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/app_appbar.dart';
import 'package:roadmaps/core/widgets/app_bottom_nav.dart';
import 'package:roadmaps/features/announcements/presentation/announcements_provider.dart';
import 'package:roadmaps/features/homepage/presentation/home_provider.dart';
import 'package:roadmaps/features/homepage/presentation/home_screen.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_provider.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_screen.dart';
import 'package:roadmaps/features/profile/presentation/profile_provider.dart';
import 'package:roadmaps/features/profile/presentation/profile_screen.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_provider.dart';
import 'package:roadmaps/features/settings/presentation/settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 2;

  final List<Widget> pages = [
    const Center(child: Text('صفحة الكورسات', style: AppTextStyles.heading3)),
    const Center(child: Text('صفحة المجتمع', style: AppTextStyles.heading3)),
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
      context.read<NotificationsProvider>().loadNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: buildAppBar(
          context: context,
          onNotificationsTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const NotificationsScreen(),
              ),
            );
          },
          onSettingsTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const SettingsScreen(),
              ),
            );
          },
        ),
        body: IndexedStack(index: currentIndex, children: pages),
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
      ),
    );
  }
}
