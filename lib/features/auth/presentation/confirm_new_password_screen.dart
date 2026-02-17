import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/auth_custom_button.dart';
import 'package:roadmaps/core/widgets/auth_custom_text_field.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/main_screen.dart';

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
//    â€¢ Go back to SplashScreen.
//    â€¢ Go to LoginScreen.
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

class ConfirmNewPasswordScreen extends StatefulWidget {
  const ConfirmNewPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() {
    return _MyAppState();
  }
}

class _MyAppState extends State<ConfirmNewPasswordScreen> {
  GlobalKey<FormState> formStateKey = GlobalKey();

  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmNewPasswordController =
      TextEditingController();

  final newPasswordFocus = FocusNode();
  final confirmNewPasswordFocus = FocusNode();

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  bool isPasswordHiddenVisibile = false;
  bool isconfirmPasswordHiddenVisibile = false;
  bool _suppressPasswordError = false;
  bool _suppressConfirmPasswordError = false;

  @override
  void dispose() {
    newPasswordController.dispose();
    confirmNewPasswordController.dispose();
    newPasswordFocus.dispose();
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
                  clearFieldsAndFocusConfirmPass();
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
          body: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(minHeight: constraints.maxHeight),
                  child: Center(
                    child: Container(
                      width: screenWidth * 0.9, // ÙŠÙ…Ù„Ø£ ØªÙ‚Ø±ÙŠØ¨Ø§Ù‹ 90% Ù…Ù† Ø¹Ø±Ø¶ Ø§Ù„Ø´Ø§Ø´Ø©
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.02),
                      child: Column(
                  children: [
                    SizedBox(height: screenHeight * 0.05),
                    Text(
                      "ØªØºÙŠÙŠØ± ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.heading3.copyWith(
                        color: AppColors.primary,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.03),
                    Text(
                      "Ø³ÙŠØªÙ… Ø§Ø³ØªØ¨Ø¯Ø§Ù„ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± Ø§Ù„Ù‚Ø¯ÙŠÙ…Ø© Ø¨Ø§Ù„Ø¬Ø¯ÙŠØ¯Ø©",
                      textAlign: TextAlign.center,
                      style: AppTextStyles.body.copyWith(
                        fontSize: 17,
                        color: AppColors.text_4,
                      ),
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
                                    isPasswordHiddenVisibile = true;
                                    isconfirmPasswordHiddenVisibile = false;
                                  });
                                },
                                fieldFocuse: newPasswordFocus,
                                label: "ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±",
                                controller: newPasswordController,
                                obscureText: isPasswordHidden,
                                onChanged: (_) {
                                  if (!_suppressPasswordError) {
                                    setState(() => _suppressPasswordError = true);
                                  }
                                },
                                validator: (value) {
                                  if (_suppressPasswordError) return null;
                                  if (value == null || value.isEmpty) {
                                    return 'Ø§Ù„Ø±Ø¬Ø§Ø¡ Ø¥Ø¯Ø®Ø§Ù„ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±';
                                  }
                                  return null;
                                },
                                suffixIcon: isPasswordHiddenVisibile
                                    ? IconButton(
                                        padding: EdgeInsets.all(
                                          screenWidth * 0.02,
                                        ),
                                        icon: Icon(
                                          isPasswordHidden
                                              ? Icons.visibility_off_outlined
                                              : Icons.visibility_outlined,
                                          color: AppColors.primary1,
                                          size: 22,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            isPasswordHidden =
                                                !isPasswordHidden;
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
                                fieldFocuse: confirmNewPasswordFocus,
                                label: "ØªØ£ÙƒÙŠØ¯ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±",
                                controller: confirmNewPasswordController,
                                obscureText: isConfirmPasswordHidden,
                                onChanged: (_) {
                                  if (!_suppressConfirmPasswordError) {
                                    setState(() => _suppressConfirmPasswordError = true);
                                  }
                                },
                                validator: (value) {
                                  if (_suppressConfirmPasswordError) return null;
                                  if (value == null || value.isEmpty) {
                                    return 'Ø§Ù„Ø±Ø¬Ø§Ø¡ Ø¥Ø¯Ø®Ø§Ù„ ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ±';
                                  }
                                  if (value != newPasswordController.text) {
                                    return 'ÙƒÙ„Ù…Ø© Ø§Ù„Ù…Ø±ÙˆØ± ØºÙŠØ± Ù…ØªØ·Ø§Ø¨Ù‚Ø©';
                                  }
                                  return null;
                                },
                                suffixIcon: isconfirmPasswordHiddenVisibile
                                    ? IconButton(
                                        padding: EdgeInsets.all(
                                          screenWidth * 0.02,
                                        ),
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
                      height: 45,
                      width: 187,
                      onPressed: () {
                        setState(() {
                          _suppressPasswordError = false;
                          _suppressConfirmPasswordError = false;
                        });
                        if (formStateKey.currentState?.validate() ?? false) {
                          FocusScope.of(context).unfocus();
                          clearFieldsAndFocusConfirmPass();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainScreen(),
                          ),
                        );
                          
                        }
                        newPasswordFocus.unfocus();
                        confirmNewPasswordFocus.unfocus();
                       
                      },
                      //    height: screenHeight * 0.07,
                      //    width: screenWidth * 0.6,
                      text: "ØªØ£ÙƒÙŠØ¯ ",
                      fontsize: 17, // Ø§Ù„Ø®Ø· Ø«Ø§Ø¨Øª
                    ),
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

  void clearFieldsAndFocusConfirmPass() {
    newPasswordController.clear();
    confirmNewPasswordController.clear();
    newPasswordFocus.unfocus();
    isconfirmPasswordHiddenVisibile = false;
    isPasswordHiddenVisibile = false;
    FocusManager.instance.primaryFocus?.unfocus();
  }
}

