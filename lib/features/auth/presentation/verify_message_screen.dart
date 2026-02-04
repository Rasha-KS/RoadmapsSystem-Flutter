// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';

import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/auth_custom_button.dart';
import 'package:roadmaps/features/auth/presentation/forget_password_screen.dart';


class VerifyMessageScreen extends StatelessWidget {
  final String? email;

  const VerifyMessageScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actionsPadding: EdgeInsets.all(8),
            automaticallyImplyLeading: false,
            backgroundColor: AppColors.background,
            actions: [
              IconButton(
                alignment: Alignment.center,
                onPressed: () {
                 
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgetPasswordScreen(),
                    ),
                  );
                },
                icon: Icon(
                  Icons.arrow_right_alt_rounded,
                  size: 35,
                  color: AppColors.text_3,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.background,
          body: Padding(
            padding: const EdgeInsets.fromLTRB(20, 100, 20, 50),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  /// العنوان
                  Text(
                    "تحقق من الرسالة",
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.text_1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// الوصف
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Text(
                      textAlign: TextAlign.center,
                      "لقد أرسلنا رسالة إلى بريدك الالكتروني لإعادة تعيين كلمة المرور",
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.text_3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: TextField(
                      canRequestFocus: false,
                      readOnly: true,
                      textAlign: TextAlign.center,
                      decoration: InputDecoration(
                        alignLabelWithHint: true,
                        filled: true,
                        fillColor: AppColors.accent_3,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        hintText: email!,
                        hintStyle: AppTextStyles.heading5.copyWith(
                          color: AppColors.text_1,
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(40),
                    child: CustomButton(
                      onPressed: () {
                      
                      },
                      height: 45,
                      width: 187,
                      text:
                        "متابعة",
                       fontsize:17,
                      ),
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
