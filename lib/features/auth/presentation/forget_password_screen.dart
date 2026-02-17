import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/auth_custom_button.dart';
import 'package:roadmaps/core/widgets/auth_custom_text_field.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/auth/presentation/verify_message_screen.dart';

// ForgetPasswordScreen - User Password Recovery Screen
//
// This screen allows the user to request a password reset
// by entering their email address.
//
// Features:
// - Includes a single TextFormField for the user's email input.
// - Validates that the email field is not empty and contains '@'.
// - Right-to-left text alignment for Arabic content.
// - Uses a CustomTextFormField for consistent styling.
// - "Continue" button navigates to the VerifyMessageScreen
//   with the entered email after validation.
//
// Layout & Styling:
// - Responsive padding and spacing using screen width/height.
// - FittedBox ensures the content scales properly on small screens.
// - AppBar has a back button that clears input and navigates
//   back to the LoginScreen.
// - Background color and text styles are pulled from AppColors
//   and AppTextStyles for a consistent theme.
//
// Behavior:
// - Dismisses the keyboard when tapping outside of input fields.
// - Clears input fields and unfocuses when navigating away.
// - Ensures email input is trimmed before use.
//

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final GlobalKey<FormState> formStateKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final emailFocus = FocusNode();
  bool _suppressEmailError = false;

  @override
  void dispose() {
    emailController.dispose();
    emailFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            actionsPadding: const EdgeInsets.all(8),
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
                icon: const Icon(
                  Icons.arrow_right_alt_rounded,
                  size: 35,
                  color: AppColors.text_3,
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.background,
          body: LayoutBuilder(
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
                    child: Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            "ادخل البريد الإلكتروني هنا",
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.text_1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            "سنرسل لك رسالة عبر البريد الإلكتروني",
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.text_4,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Form(
                            key: formStateKey,
                            child: Directionality(
                              textDirection: TextDirection.rtl,
                              child: Padding(
                                padding: EdgeInsets.all(screenWidth * 0.02),
                                child: CustomTextFormField(
                                  label: "البريد الإلكتروني",
                                  controller: emailController,
                                  fieldFocuse: emailFocus,
                                  onChanged: (_) {
                                    if (!_suppressEmailError) {
                                      setState(
                                        () => _suppressEmailError = true,
                                      );
                                    }
                                  },
                                  validator: (value) {
                                    if (_suppressEmailError) return null;
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
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          CustomButton(
                            height: 45,
                            width: screenWidth > 420 ? 240 : screenWidth * 0.6,
                            onPressed: () {
                              setState(() => _suppressEmailError = false);
                              if (formStateKey.currentState?.validate() ??
                                  false) {
                                FocusScope.of(context).unfocus();
                                final email = emailController.text.trim();
                                if (email.isEmpty) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        VerifyMessageScreen(email: email),
                                  ),
                                );
                                clearFieldsAndFocusForget();
                              }
                              emailFocus.unfocus();
                            },
                            text: "متابعة",
                            fontsize: 17,
                          ),
                          SizedBox(height: screenHeight * 0.05),
                        ],
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

  void clearFieldsAndFocusForget() {
    emailController.clear();
    emailFocus.unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
