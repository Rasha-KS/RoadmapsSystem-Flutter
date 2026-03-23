import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/features/auth/presentation/forget_password_screen.dart';

class VerifyMessageScreen extends StatelessWidget {
  final String? email;

  const VerifyMessageScreen({super.key, required this.email});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        appBar: AppBar(
          actionsPadding: const EdgeInsets.all(8),
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
              icon: const Icon(
                Icons.arrow_right_alt_rounded,
                size: 35,
                color: AppColors.text_3,
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.background,
        body: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Container(
                        width: screenWidth * 0.9,
                        padding: EdgeInsets.symmetric(
                          horizontal: screenWidth * 0.02,
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: screenHeight * 0.01),
                            Text(
                              'تحقق من الرسالة',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.text_1,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: screenHeight * 0.01),
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              child: Text(
                                'لقد أرسلنا رسالة إلى بريدك الإلكتروني لإعادة تعيين كلمة المرور',
                                style: AppTextStyles.body.copyWith(
                                  color: AppColors.text_3,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            SizedBox(height: screenHeight * 0.05),
                            Padding(
                              padding: EdgeInsets.all(screenWidth * 0.02),
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
                                  hintText: email ?? '',
                                  hintStyle: AppTextStyles.heading5.copyWith(
                                    color: AppColors.text_1,
                                  ),
                                ),
                              ),
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
      ),
    );
  }
}
