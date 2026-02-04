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
    return SafeArea(
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
          child: Column(
            children: [
              Center(
                child: Container(
                  padding: EdgeInsets.only(bottom: 40, top: 150),
                  child: Column(
                   
                    children: [
                      Column(
                        children: [
                          Text(
                            " مرحبا بك في  ",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.text_3,
                            ),
                          ),
                          Text(
                            " أفق ",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.heading1.copyWith(
                              color: AppColors.primary2,
                            ),
                          ),
                        ],
                      ),
               SizedBox(height: 150),
                      Column(
                        children: [
                          SizedBox(height: 150),
                          CustomButton(
                            height:50 ,
                            width: 241,
                            text: "تسجيل دخول",
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const LoginScreen(),
                                ),
                              );
                            },
                          ),
                          SizedBox(height: 40),
                          CustomButton(
                             height:50 ,
                            width: 241,
                            text: "إنشاء حساب ",fontsize: 20,
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
            ],
          ),
        ),
      ),
    );
  }
}

