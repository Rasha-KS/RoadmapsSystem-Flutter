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

import 'package:flutter/material.dart';
import 'package:roadmaps/features/auth/presentation/splash_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}



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


// import 'package:flutter/material.dart';
// import 'package:roadmaps/features/main_Screen.dart'; // هنا نستدعي MainScreen

// void main() {
//   runApp(const MyApp());
// }

// class MyApp extends StatelessWidget {
//   const MyApp({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       title: 'MainScreen Test',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: const MainScreen(), // أول شاشة بعد اللوجين
//     );
//   }
// }
