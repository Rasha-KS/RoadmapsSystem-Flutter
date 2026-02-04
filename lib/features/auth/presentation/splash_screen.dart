import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/auth_custom_button.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/auth/presentation/register_screen.dart';

/*
  SplashScreen

  This is the app's initial screen, displayed when the user opens the app 
  for the first time before logging in or registering.

  Key Features:
  1. Fully responsive: all sizes, and spacings are calculated relative to screen dimensions.
  2. Displays the app title ("مرحبا بك في أفق") centered on the screen.
  3. Contains two main buttons:
     - Login: navigates the user to LoginScreen
     - Register: navigates the user to RegisterScreen
  4. Uses a Column centered on the screen within a SingleChildScrollView to avoid overflow issues on smaller screens.
  5. Text styles and colors are taken from AppTextStyles and AppColors for consistent app design.

  Notes:
  - You can adjust the ratios (screenHeight * 0.07) and (screenWidth * 0.6) to scale the buttons proportionally on different screens.
  - For landscape support, additional adjustments using MediaQuery may be necessary.
*/

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: SizedBox(
            height: screenHeight, 
            width: screenWidth,
            child:  FittedBox(
            fit: BoxFit.scaleDown,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    Text(
                      "مرحبا بك في",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.text_3,
                      ),
                    ),
                    Text(
                      "أفق",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading1.copyWith(
                        color: AppColors.primary2,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: screenHeight * 0.20), 

                Column(
                  children: [
                    CustomButton(
                      width:241,
                      height:50,
                      // height: screenHeight * 0.07,
                      // width: screenWidth * 0.6,
                      text: "تسجيل دخول",
                      fontsize: 20, 
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LoginScreen(),
                          ),
                        );
                      },
                    ),
                    SizedBox(height: screenHeight * 0.05),
                    CustomButton(
                      width:241,
                      height:50,
                      // height: screenHeight * 0.07,
                      // width: screenWidth * 0.6,
                      text: "إنشاء حساب",
                      fontsize: 20, 
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const RegisterScreen(),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          ),
        ),
      ),
    );
  }
}
