/*

"إنَّ الحمد لله نحمده ونستعينه ونستغفره،
 ونعوذ بالله من شرور أنفسنا وسيِّئات أعمالنا
 ، مَن يهده الله فلا مُضلَّ له، ومَن يُضلل فلا هادي له، وأشهد أن لا إله إلا الله وحده لا شريكَ له،
  وأشهد أنَّ محمدًا عبده ورسوله، صلَّى الله وسلَّم وبارك عليه، وعلى آله وصحبه أجمعين."

رَبِّ اشْرَحْ لِي صَدْرِي وَيَسِّرْ لِي أَمْرِي وَاحْلُلْ عُقْدَةً مِّن لِّسَانِي يَفْقَهُوا قَوْلِي

اللَّهُمَّ اجْعَلْ عَمَلَنَا هذَا خَالِصًا لِجَلَالِ وَجْهِكَ الكَرِيمِ، وَاجْعَلْهُ عَوْنًا لَنَا عَلَى طَاعَتِكَ.
اللَّهُمَّ انْفَعْنَا بِمَا عَلَّمْتَنَا، وَعَلِّمْنَا مَا يَنْفَعُنَا.
رَبِّ يَسَّهِّلْ عَلَيْنَا وَيُوَفِّقْنَا إِلَى مَا يُحِبُّهُ وَيَرْضَاهُ.


بسم الله الرحمن الرحيم
 */

// import 'package:flutter/material.dart';
// import 'package:roadmaps/features/auth/presentation/splash_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       home: const SplashScreen(),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// // استدعاء الـ HomeScreen
// import 'features/homepage/presentation/home_screen.dart';

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'Test HomeScreen',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const HomeScreen(),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/features/auth/presentation/splash_screen.dart';
import 'package:roadmaps/features/main_Screen.dart';
import 'package:roadmaps/features/roadmaps/presentation/roadmaps_screen.dart';
import 'package:roadmaps/injection.dart'; // هنا نستدعي MainScreen

void main() {
  // لضمان استقرار التطبيق عند البدء
  WidgetsFlutterBinding.ensureInitialized();

  runApp(
    MultiProvider(
      providers: [
        // نقوم بإنشاء الـ Provider فقط بدون استدعاء دوال التحميل
        ChangeNotifierProvider(
          create: (_) => Injection.provideHomeProvider(),
        ),
         ChangeNotifierProvider(
          create: (_) => Injection.provideRoadmapsProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => Injection.provideAnnouncementsProvider(),
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
        // يمكنك تخصيص الألوان والخطوط هنا لتكون متناسقة مع AppColors و AppTextStyles
        primarySwatch: Colors.blue,
        fontFamily: 'Tajawal_R', 
        scaffoldBackgroundColor: AppColors.background// مثال للون الخلفية
      ),
      home: const SplashScreen(), // أول شاشة بعد اللوجين
    );
  }
}