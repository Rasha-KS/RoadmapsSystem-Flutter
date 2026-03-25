import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/auth_custom_button.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/auth/presentation/register_screen.dart';

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

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: SizedBox(
                      width: screenWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Column(
                            children: [
                              Text(
                                'مرحبًا بك في',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.heading1.copyWith(
                                  color: AppColors.text_3,
                                ),
                              ),
                              SizedBox(height: screenHeight * 0.01),
                              Text(
                                'أُفُق',
                                textAlign: TextAlign.center,
                                style: AppTextStyles.heading1.copyWith(
                                  color: AppColors.primary2,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: screenHeight * 0.045),
                          Image.asset(
                            'assets/images/navi_compass.png',
                            width: screenWidth * 0.60,
                            fit: BoxFit.contain,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Column(
                            children: [
                              CustomButton(
                                width:
                                    screenWidth > 420 ? 280 : screenWidth * 0.7,
                                height: 50,
                                text: 'تسجيل دخول',
                                fontsize: 20,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const LoginScreen(),
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: screenHeight * 0.05),
                              CustomButton(
                                width:
                                    screenWidth > 420 ? 280 : screenWidth * 0.7,
                                height: 50,
                                text: 'إنشاء حساب',
                                fontsize: 20,
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const RegisterScreen(),
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
          },
        ),
      ),
    );
  }
}
