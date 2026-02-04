import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/theme/app_colors.dart';

// home
import '../data/home_repository.dart';
import '../domain/get_home_data_usecase.dart';
import 'home_provider.dart';

// announcements
import '../../announcements/data/announcements_repository.dart';
import '../../announcements/presentation/announcements_provider.dart';
import '../../announcements/presentation/announcement_widget.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // 🏠 Home
        ChangeNotifierProvider(
          create: (_) => HomeProvider(
            GetHomeDataUseCase(
              HomeRepository(),
            ),
          )..loadHome(),
        ),

        // 🔔 Announcements
        ChangeNotifierProvider(
          create: (_) => AnnouncementsProvider(
            AnnouncementsRepository(),
          )..loadAnnouncement(),
        ),
      ],
      child: const _HomeView(),
    );
  }
}


class _HomeView extends StatefulWidget {
  const _HomeView();

  @override
  State<_HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<_HomeView> {
  int navIndex = 2;

  @override
  Widget build(BuildContext context) {
    final homeProvider = context.watch<HomeProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: homeProvider.loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                const AnnouncementWidget(),

                _sectionTitle('كورسات مقترحة'),
                _coursesList(homeProvider.recommended),

                _sectionTitle('كورساتي'),
                _coursesList(homeProvider.myCourses),
              ],
            ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _coursesList(List courses) {
    return Column(
      children: courses.map((c) {
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          child: ListTile(
            title: Text(c.title),
            subtitle: Text(c.description),
            trailing: const Icon(Icons.arrow_back),
          ),
        );
      }).toList(),
    );
  }
}
