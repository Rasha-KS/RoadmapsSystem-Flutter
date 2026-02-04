import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/auth_custom_button.dart';
import 'package:roadmaps/core/widgets/auth_custom_text_field.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/auth/presentation/splash_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  // ignore: no_logic_in_create_state
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<RegisterScreen> {
  GlobalKey<FormState> formStateKey = GlobalKey();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController userNameController = TextEditingController();
  final emailFocus = FocusNode();
  final passwordFocus = FocusNode();
  final confirmPasswordFocus = FocusNode();
  final userNameFocus = FocusNode();
  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  bool isPasswordHiddenVisibile = false;
  bool isconfirmPasswordHiddenVisibile = false;

  @override
  void dispose() {
    super.dispose();
    emailController.dispose();
    passwordController.dispose();
    userNameController.dispose();
    confirmPasswordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        isconfirmPasswordHiddenVisibile = false;
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
                  clearFieldsAndFocusSignUp();
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
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Container(
                    padding: EdgeInsets.only(top: 50, bottom: 15),
                    child: Text(
                      "إنشاء حساب",
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
                                  isconfirmPasswordHiddenVisibile = false;
                                  isPasswordHiddenVisibile = false;
                                });
                              },
                              fieldFocuse: userNameFocus,
                              label: "اسم المستخدم",
                              controller: userNameController,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال اسم المستخدم';
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
                                  isconfirmPasswordHiddenVisibile = false;
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
                                  isconfirmPasswordHiddenVisibile = false;
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
                        Directionality(
                          textDirection: TextDirection.rtl,
                          child: Padding(
                            padding: const EdgeInsets.all(5),
                            child: CustomTextFormField(
                              onTap: () {
                                setState(() {
                                  isPasswordHiddenVisibile = false;
                                  isconfirmPasswordHiddenVisibile = true;
                                });
                              },
                              fieldFocuse: confirmPasswordFocus,
                              label: "تأكيد كلمة المرور",
                              controller: confirmPasswordController,
                              obscureText: isConfirmPasswordHidden
                                  ? true
                                  : false,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'الرجاء إدخال كلمة المرور';
                                }
                                if (value != passwordController.text) {
                                  return 'كلمة المرور غير متطابقة';
                                }
                                return null;
                              },
                              suffixIcon: isconfirmPasswordHiddenVisibile
                                  ? IconButton(
                                      padding: const EdgeInsets.all(10),
                                      icon: Icon(
                                        isConfirmPasswordHidden
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AppColors.primary1,
                                        size: 22,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          isConfirmPasswordHidden =
                                              !isConfirmPasswordHidden;
                                        });
                                      },
                                    )
                                  : null,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: CustomButton(
                      onPressed: () {
                        if (formStateKey.currentState?.validate() ?? false) {
                          // Proceed with login logic here
                          FocusScope.of(context).unfocus();
                          clearFieldsAndFocusSignUp();
                        }
                      },
                      height: 45,
                      width: 187,
                      text: "إنشاء حساب",
                      fontsize: 17,
                    ),
                  ),

                  /// إنشاء حساب جديد
                  TextButton(
                    onPressed: () {
                      FocusManager.instance.primaryFocus?.unfocus();
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const LoginScreen(),
                        ),
                      );
                      clearFieldsAndFocusSignUp();
                    },
                    child: Text(
                      " تسجيل الدخول ",
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
                          "او إنشاء حساب بـ",
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
                          clearFieldsAndFocusSignUp();
                         
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

  void clearFieldsAndFocusSignUp() {
    emailController.clear();
    passwordController.clear();
    confirmPasswordController.clear();
    userNameController.clear();
    emailFocus.unfocus();
    passwordFocus.unfocus();
    isconfirmPasswordHiddenVisibile = false;
    isPasswordHiddenVisibile = false;
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
