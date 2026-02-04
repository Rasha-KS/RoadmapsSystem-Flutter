import 'package:flutter/material.dart';
import 'package:roadmaps/core/widgets/app_appbar.dart';
import 'package:roadmaps/core/widgets/app_bottom_nav.dart';

import '../features/homepage/presentation/home_screen.dart'; // الصفحة الرئيسية بعد اللوجين
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
    const Text("data"),//CoursesScreen(),
    const Text("data"),//ProfileScreen(),
    const HomeScreen(),
    const Text("data")//SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return SafeArea(child: Scaffold(
      appBar: buildAppBar(onNotificationsTap: ()=> print("Hi"), onSettingsTap: () => print("hello") ,context: context),
      body: pages[currentIndex],
      bottomNavigationBar: buildAppBottomNav(currentIndex: currentIndex, onTap: (index) => setState(() => currentIndex = index),)
    )
    );
  }
}
