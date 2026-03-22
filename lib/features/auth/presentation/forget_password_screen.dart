import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/action_snackbar.dart';
import 'package:roadmaps/core/widgets/auth_custom_button.dart';
import 'package:roadmaps/core/widgets/auth_custom_text_field.dart';
import 'package:roadmaps/features/auth/presentation/auth_provider.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/auth/presentation/verify_message_screen.dart';

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
    final authProvider = context.watch<AuthProvider>();
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
                    child: Container(
                      width: screenWidth * 0.9,
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.02,
                      ),
                      child: Column(
                        children: [
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'أدخل البريد الإلكتروني هنا',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.text_1,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: screenHeight * 0.01),
                          Text(
                            'سنرسل لك رسالة عبر البريد الإلكتروني',
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
                                  label: 'البريد الإلكتروني',
                                  controller: emailController,
                                  fieldFocuse: emailFocus,
                                  onChanged: (_) {
                                    if (!_suppressEmailError) {
                                      setState(() => _suppressEmailError = true);
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
                            onPressed: () async {
                              if (authProvider.isLoading) return;
                              setState(() => _suppressEmailError = false);
                              if (formStateKey.currentState?.validate() ?? false) {
                                FocusScope.of(context).unfocus();
                                final email = emailController.text.trim();
                                if (email.isEmpty) return;
                                final success = await authProvider.forgotPassword(
                                  email: email,
                                );
                                if (!context.mounted) return;
                                if (success) {
                                  showActionSnackBar(
                                    ScaffoldMessenger.of(context),
                                    message: 'Check your email for reset link',
                                    isSuccess: true,
                                  );
                                  clearFieldsAndFocusForget();
                                  Navigator.pushReplacement(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) =>
                                          VerifyMessageScreen(email: email),
                                    ),
                                  );
                                } else {
                                  showActionSnackBar(
                                    ScaffoldMessenger.of(context),
                                    message: authProvider.error ??
                                        'Unable to send reset link.',
                                    isSuccess: false,
                                  );
                                }
                              }
                              emailFocus.unfocus();
                            },
                            text: authProvider.isLoading
                                ? 'جارٍ الإرسال...'
                                : 'متابعة',
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
