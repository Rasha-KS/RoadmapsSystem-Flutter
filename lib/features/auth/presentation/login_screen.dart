import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/auth_custom_button.dart';
import 'package:roadmaps/core/widgets/auth_custom_text_field.dart';
import 'package:roadmaps/features/auth/presentation/forget_password_screen.dart';
import 'package:roadmaps/features/auth/presentation/register_screen.dart';
import 'package:roadmaps/features/auth/presentation/splash_screen.dart';

// LoginScreen - User Login Page
//
// This screen allows the user to log in to the app using email/password or Google.
//
// Features:
// - Email and password input fields with validation.
// - Show/Hide password functionality.
// - "Forgot Password?" button navigates to ForgetPasswordScreen.
// - "Create New Account" button navigates to RegisterScreen.
// - Clear input fields and unfocus text inputs when tapping outside.
//
// General Structure:
// - SafeArea: prevents content from overlapping with the status bar.
// - Scaffold: contains AppBar and Body.
// - AppBar: custom back button leading to SplashScreen.
// - Body: Center > FittedBox > Container ensures responsive layout across devices.
// - Column: organizes the screen vertically with spacing using SizedBox.
// - Form + CustomTextFormField: handles input fields and validation.
// - CustomButton: triggers login action after validation.
// - TextButton: navigates to other screens (register or forgot password).
// - Row + Divider: separates the "or login with" section.
// - IconButton: represents login via Google.
//
// Technical Notes:
// - MediaQuery is used to calculate dynamic widths, heights, and padding based on screen size.
// - TextEditingController manages the text input for email and password fields.
// - FocusNode manages input focus, allowing dismissal of keyboard on tap outside.
// - dispose() is used to free resources when the screen is destroyed.
//


class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<StatefulWidget> createState() => _MyAppState();
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
    emailController.dispose();
    passwordController.dispose();
    emailFocus.dispose();
    passwordFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

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
          body: Center(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Container(
                width: screenWidth * 0.9,
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      "تسجيل دخول",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading3.copyWith(color: AppColors.primary),
                    ),
                    SizedBox(height: screenHeight * 0.03),

                    // Form Fields
                    Form(
                      key: formStateKey,
                      child: Column(
                        children: [
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.02),
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
                              padding: EdgeInsets.all(screenWidth * 0.02),
                              child: CustomTextFormField(
                                onTap: () {
                                  setState(() {
                                    isPasswordHiddenVisibile = true;
                                  });
                                },
                                fieldFocuse: passwordFocus,
                                label: "كلمة المرور",
                                controller: passwordController,
                                obscureText: isPasswordHidden,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'الرجاء إدخال كلمة المرور';
                                  }
                                  return null;
                                },
                                suffixIcon: isPasswordHiddenVisibile
                                    ? IconButton(
                                        padding: EdgeInsets.all(screenWidth * 0.02),
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
                                    builder: (context) => const ForgetPasswordScreen(),
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

                    SizedBox(height: screenHeight * 0.03),

                    // Buttons
                    CustomButton(
                      height: 45,
                        width: 187,
                      onPressed: () {
                        if (formStateKey.currentState?.validate() ?? false) {
                          FocusScope.of(context).unfocus();
                          clearFieldsAndFocusLogin();
                        }
                      },
                      // height: screenHeight * 0.07,
                      // width: screenWidth * 0.6,
                      text: "تسجيل",
                      fontsize: 17,
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        clearFieldsAndFocusLogin();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterScreen()),
                        );
                      },
                      child: Text(
                        "إنشاء حساب جديد",
                        style: AppTextStyles.smallText.copyWith(
                          color: AppColors.text_4,
                        ),
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.02),

                    Row(
                      children: [
                        Expanded(child: Divider()),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
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
                    SizedBox(height: screenHeight * 0.02),

                    Column(
                      children: [
                        IconButton(
                          onPressed: () {
                            clearFieldsAndFocusLogin();
                          },
                          icon: Icon(Icons.g_mobiledata, size: screenWidth * 0.12),
                        ),
                        Text(
                          "Google",
                          style: TextStyle(color: AppColors.primary1),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.05),
                  ],
                ),
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
