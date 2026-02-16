import 'package:flutter/material.dart';
import 'package:roadmaps/core/widgets/app_appbar.dart';
import 'package:roadmaps/core/widgets/app_bottom_nav.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_provider.dart';
import '../features/homepage/presentation/home_screen.dart'; // الصفحة الرئيسية بعد اللوجين
import '../features/homepage/presentation/home_provider.dart';
import '../features/announcements/presentation/announcements_provider.dart';
import 'package:provider/provider.dart';
//import 'roadmaps_screen.dart'; // صفحة الكورسات
//import 'profile_screen.dart'; // صفحة البروفايل
//import 'settings_screen.dart'; // صفحة الإعدادات

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int currentIndex = 2;

  final List<Widget> pages = [
    const Center(child: Text("صفحة الكورسات", style: AppTextStyles.heading3)),
    const Center(child: Text("صفحة البروفايل", style: AppTextStyles.heading3)),
    const HomeScreen(),
    const Center(child: Text("صفحة الإعدادات", style: AppTextStyles.heading3)),
  ];

  @override
  void initState() {
    super.initState();
    // استدعاء البيانات عند الدخول للشاشة الرئيسية لأول مرة
    // نستخدم microtask لضمان أن الـ Build اكتمل أو نستخدم listen: false
    Future.microtask(() {
      if (mounted) {
        context.read<RoadmapsProvider>().loadRoadmaps();
        context.read<HomeProvider>().loadHome();
        context.read<AnnouncementsProvider>().loadAnnouncements();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: buildAppBar(
          context: context,
          onNotificationsTap: () => 0, //print("تم الضغط على التنبيهات"),
          onSettingsTap: () => 0, // print("تم الضغط على الإعدادات"),
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
