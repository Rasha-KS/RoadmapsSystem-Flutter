import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/auth_custom_button.dart';
import 'package:roadmaps/core/widgets/auth_custom_text_field.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/auth/presentation/verify_message_screen.dart';


class ForgetPasswordScreen extends StatefulWidget {
  
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  
GlobalKey<FormState> formStateKey = GlobalKey();
final TextEditingController emailController = TextEditingController();
final emailFocus = FocusNode();

@override
void dispose() {
    super.dispose();
  emailController.dispose();
  emailFocus.dispose();
}
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
                  clearFieldsAndFocusForget();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginScreen(),
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
                    "ادخل البريد الالكتروني هنا",
                    style: AppTextStyles.heading3.copyWith(
                      color: AppColors.text_1,
                    ),
                  ),

                  const SizedBox(height: 8),

                  /// الوصف
                  Text(
                    "سنرسل لك رسالة عبر البريد الالكتروني",
                    style: AppTextStyles.body.copyWith(color: AppColors.text_4),
                  ),

                  const SizedBox(height: 30),

                  Form(
                    key: formStateKey,
                    child: Column(
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: CustomTextFormField(
                              label: "البريد الالكتروني",
                              controller: emailController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال البريد الإلكتروني';
                                }
                                if (!value.contains('@')) {
                                  return 'البريد الإلكتروني غير صحيح';
                                }
                                return null;
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomButton(
                      onPressed: () {
                        if (formStateKey.currentState?.validate() ?? false) {
                          // Proceed with login logic here
                          FocusScope.of(context).unfocus();
                          final email = emailController.text.trim();

                          if (email.isEmpty) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => VerifyMessageScreen(email: email),
                            ),
                          );
                          clearFieldsAndFocusForget();
                        }
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
  
void clearFieldsAndFocusForget() {
  emailController.clear();
  emailFocus.unfocus();
  FocusManager.instance.primaryFocus?.unfocus();
}

}
