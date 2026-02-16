import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/features/auth/presentation/splash_screen.dart';
import 'package:roadmaps/features/main_Screen.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_screen.dart';
import 'package:roadmaps/injection.dart'; // هنا نستدعي MainScreen

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // إذا كان أي شيء يحتاج وقت هنا مثل SharedPreferences أو Firebase
  // await SomeService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => Injection.provideHomeProvider(),
        ),
         ChangeNotifierProvider(
          create: (_) => Injection.provideRoadmapsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Injection.provideAnnouncementsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Injection.provideProfileProvider(),
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
      home: const SplashScreen(), // أول شاشة بعد اللوجين
    );
  }
}
