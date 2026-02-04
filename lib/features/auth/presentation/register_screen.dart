
import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/auth_custom_button.dart';
import 'package:roadmaps/core/widgets/auth_custom_text_field.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/auth/presentation/splash_screen.dart';

// RegisterScreen - New Account Creation Page
//
// This screen allows the user to create a new account in the app.
// It includes the following fields:
// 1. Username
// 2. Email
// 3. Password
// 4. Confirm Password
//
// Features:
// - Field validation for all input fields.
// - Show/Hide password functionality.
// - Clear fields and unfocus text inputs when tapping outside.
// - Navigation buttons:
//    • Go back to SplashScreen.
//    • Go to LoginScreen.
// - Create account button after validation.
// - Option to sign in using Google.
//
// General Structure:
// - SafeArea: prevents content from overlapping with the status bar.
// - Scaffold: contains AppBar and Body.
// - AppBar: back button and no automatic leading elements.
// - Body: Column with SizedBox for spacing, Form for input fields, and buttons.
// - FittedBox + Container: ensures responsive sizing across devices.
// - Form + CustomTextFormField: validates user input.
// - CustomButton: handles account creation logic.
// - SizedBox: manages vertical spacing between elements.
//
// Technical Notes:
// - MediaQuery is used for relative sizing and spacing based on screen dimensions.
// - TextEditingController manages the values of input fields.
// - FocusNode manages input focus.
// - dispose() is used to free resources when the screen is destroyed.
//


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<RegisterScreen> {
  GlobalKey<FormState> formStateKey = GlobalKey();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
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
    emailController.dispose();
    passwordController.dispose();
    userNameController.dispose();
    confirmPasswordController.dispose();
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
                    MaterialPageRoute(builder: (context) => const SplashScreen()),
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
                width: screenWidth * 0.9, // يملأ تقريباً 90% من عرض الشاشة
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      "إنشاء حساب",
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
                              padding: EdgeInsets.all(screenWidth * 0.02),
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
                              padding: EdgeInsets.all(screenWidth * 0.02),
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
                          Directionality(
                            textDirection: TextDirection.rtl,
                            child: Padding(
                              padding: EdgeInsets.all(screenWidth * 0.02),
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
                                obscureText: isConfirmPasswordHidden,
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
                                        padding: EdgeInsets.all(screenWidth * 0.02),
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

                    SizedBox(height: screenHeight * 0.03),

                    // Buttons
                    CustomButton(
                      onPressed: () {
                        if (formStateKey.currentState?.validate() ?? false) {
                          FocusScope.of(context).unfocus();
                          clearFieldsAndFocusSignUp();
                        }
                      },
                      height: screenHeight * 0.07,
                      width: screenWidth * 0.6,
                      text: "إنشاء حساب",
                      fontsize: 17, // الخط ثابت
                    ),
                    SizedBox(height: screenHeight * 0.02),
                    TextButton(
                      onPressed: () {
                        FocusManager.instance.primaryFocus?.unfocus();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const LoginScreen()),
                        );
                        clearFieldsAndFocusSignUp();
                      },
                      child: Text(
                        " تسجيل الدخول ",
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
                            "او إنشاء حساب بـ",
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
                            clearFieldsAndFocusSignUp();
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
