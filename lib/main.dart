import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/features/auth/presentation/splash_screen.dart';
import 'package:roadmaps/features/challenge/presentation/challenge_provider.dart';
import 'package:roadmaps/features/checkpoints/presentation/checkpoints_provider.dart';
import 'package:roadmaps/features/learning_path/presentation/learning_path_provider.dart';
import 'package:roadmaps/features/lessons/presentation/lessons_provider.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_provider.dart';
import 'package:roadmaps/features/smart_instructor/presentation/smart_instructor_provider.dart';
import 'package:roadmaps/injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final currentUserProvider = Injection.provideCurrentUserProvider();
  await currentUserProvider.loadCurrentUser();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: currentUserProvider),

        ChangeNotifierProvider(create: (_) => Injection.provideHomeProvider()),

        ChangeNotifierProvider(
          create: (_) => Injection.provideRoadmapsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Injection.provideAnnouncementsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Injection.provideProfileProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Injection.provideSettingsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Injection.provideCommunityProvider(),
        ),
        ChangeNotifierProvider<LearningPathProvider>(
          create: (_) => Injection.provideLearningPathProvider(),
        ),
        ChangeNotifierProvider<LessonsProvider>(
          create: (_) => Injection.provideLessonsProvider(),
        ),
        ChangeNotifierProvider<CheckpointsProvider>(
          create: (_) => Injection.provideCheckpointsProvider(),
        ),
        ChangeNotifierProvider<NotificationsProvider>(
          create: (_) => Injection.provideNotificationsProvider(),
        ),
        ChangeNotifierProvider<SmartInstructorProvider>(
          create: (_) => Injection.provideSmartInstructorProvider(),
        ),
        ChangeNotifierProvider<ChallengeProvider>(
          create: (_) => Injection.provideChallengeProvider(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Roadmaps App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Tajawal_R',
        scaffoldBackgroundColor: AppColors.background,
      ),
      home: const SplashScreen(), //SplashScreen(),
    );
  }
}
