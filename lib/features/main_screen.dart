import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/navigation/auth_guard.dart';
import 'package:roadmaps/core/navigation/app_route_observer.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/widgets/app_appbar.dart';
import 'package:roadmaps/core/widgets/app_bottom_nav.dart';
import 'package:roadmaps/core/utils/page_refresh.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/announcements/presentation/announcements_provider.dart';
import 'package:roadmaps/features/community/presentation/community_provider.dart';
import 'package:roadmaps/features/community/presentation/community_screen.dart';
import 'package:roadmaps/features/homepage/presentation/home_screen.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_provider.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_screen.dart';
import 'package:roadmaps/features/profile/presentation/profile_screen.dart';
import 'package:roadmaps/features/settings/presentation/settings_screen.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> with RouteAware {
  int currentIndex = 2;
  PageRoute<dynamic>? _route;

  final List<Widget> pages = [
    const SmartInstructorScreen(),
    const CommunityScreen(),
    const HomeScreen(),
    const ProfileScreen(),
  ];

  Future<void> _onNavTap(int index) async {
    setState(() {
      currentIndex = index;
    });

    if (index == 2) {
      await refreshHomePageData(context);
    } else if (index == 3) {
      await refreshProfilePageData(context);
    }

    await _refreshUnreadCount();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<dynamic> && route != _route) {
      _route = route;
      appRouteObserver.subscribe(this, route);
    }
  }

  @override
  void didPopNext() {
    final shouldRefreshHome = currentIndex == 2;
    final shouldRefreshProfile = currentIndex == 3;

    if (shouldRefreshHome) {
      refreshHomePageData(context);
    } else if (shouldRefreshProfile) {
      refreshProfilePageData(context);
    }

    _refreshUnreadCount();
  }

  @override
  void dispose() {
    if (_route != null) {
      appRouteObserver.unsubscribe(this);
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      if (!mounted) return;
      context.read<AnnouncementsProvider>().loadAnnouncements();
      context.read<CommunityProvider>().loadRooms();
      context.read<NotificationsProvider>().loadNotifications();
    });
  }

  Future<void> _refreshUnreadCount() async {
    if (!mounted) return;
    await context.read<NotificationsProvider>().loadUnreadCount();
  }

  @override
  Widget build(BuildContext context) {
    final hasUnread = context.watch<NotificationsProvider>().hasUnread;
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: buildAppBar(
        context: context,
        showUnreadDot: hasUnread,
        onNotificationsTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => AuthGuard(
                child: const NotificationsScreen(),
                unauthenticatedBuilder: (_) => const LoginScreen(),
              ),
            ),
          );
        },
        onSettingsTap: () {
          Navigator.of(
            context,
          ).push(
            MaterialPageRoute(
              builder: (_) => AuthGuard(
                child: const SettingsScreen(),
                unauthenticatedBuilder: (_) => const LoginScreen(),
              ),
            ),
          );
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
          onTap: (index) => _onNavTap(index),
        ),
      ),
    );
  }
}
