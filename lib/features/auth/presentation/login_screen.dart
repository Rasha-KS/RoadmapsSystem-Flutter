import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/auth_custom_button.dart';
import 'package:roadmaps/core/widgets/auth_custom_text_field.dart';
import 'package:roadmaps/features/auth/presentation/forget_password_screen.dart';
import 'package:roadmaps/features/auth/presentation/register_screen.dart';
import 'package:roadmaps/features/auth/presentation/splash_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<LoginScreen> {
  GlobalKey<FormState> formStateKey = GlobalKey();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  bool isPasswordHidden = true;
  bool isPasswordHiddenVisibile = false;
  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isPasswordHiddenVisibile = false;
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
                  clearFieldsAndFocusLogin();
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SplashScreen(),
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
                  Container(
                    padding: EdgeInsets.all(30),
                    child: Text(
                      "تسجيل دخول",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                  ),

                  Form(
                    key: formStateKey,
                    child: Column(
                      children: [
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: CustomTextFormField(
                              onTap: () {
                                setState(() {
                                  isPasswordHiddenVisibile = false;
                                });
                              },
                              fieldFocuse: emailFocus,
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
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: CustomTextFormField(
                              onTap: () {
                                setState(() {
                                  isPasswordHiddenVisibile = true;
                                });
                              },
                              fieldFocuse: passwordFocus,
                              label: "كلمة المرور",
                              controller: passwordController,
                              obscureText: isPasswordHidden ? true : false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }
                                return null;
                              },
                              suffixIcon: isPasswordHiddenVisibile
                                  ? IconButton(
                                      padding: const EdgeInsets.all(10),
                                      icon: Icon(
                                        isPasswordHidden
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.primary1,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isPasswordHidden = !isPasswordHidden;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              clearFieldsAndFocusLogin();
                              FocusManager.instance.primaryFocus?.unfocus();
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const ForgetPasswordScreen(),
                                ),
                              );
                            },
                            child: Text(
                              "هل نسيت كلمة المرور؟",
                              style: AppTextStyles.smallText.copyWith(
                                color: AppColors.text_4,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: CustomButton(
                      text: "تسجيل",
                      fontsize: 17,
                      onPressed: () {
                        if (formStateKey.currentState?.validate() ?? false) {
                          // Proceed with login logic here
                          FocusScope.of(context).unfocus();
                          clearFieldsAndFocusLogin();
                        }
                      },
                      height: 45,
                      width: 187,
                    ),
                  ),

                  /// إنشاء حساب جديد
                  TextButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      clearFieldsAndFocusLogin();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: Text(
                      "إنشاء حساب جديد",
                      style: AppTextStyles.smallText.copyWith(
                        fontSize: 17,
                        color: AppColors.text_4,
                      ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  /// أو تسجيل دخول بـ
                  Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 8),
                        child: Text(
                          "او تسجيل دخول بـ",
                          style: AppTextStyles.smallText.copyWith(
                            color: AppColors.text_1,
                          ),
                        ),
                      ),
                      Expanded(child: Divider()),
                    ],
                  ),
                  const SizedBox(height: 25),
                  Column(
                    children: [
                      IconButton(
                        onPressed: () {
                          FocusManager.instance.primaryFocus?.unfocus();
                          clearFieldsAndFocusLogin();
                        },
                        icon: Icon(Icons.g_mobiledata, size: 50),
                      ),
                      Text(
                        "Google",
                        style: TextStyle(color: AppColors.primary1),
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

  void clearFieldsAndFocusLogin() {
    emailController.clear();
    passwordController.clear();
    isPasswordHiddenVisibile = false;
    emailFocus.unfocus();
    passwordFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
