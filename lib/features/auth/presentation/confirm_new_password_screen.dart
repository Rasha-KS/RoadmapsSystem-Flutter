import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';
import 'package:roadmaps/core/widgets/auth_custom_button.dart';
import 'package:roadmaps/core/widgets/auth_custom_text_field.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/main_screen.dart';

class ConfirmNewPasswordScreen extends StatefulWidget {
  const ConfirmNewPasswordScreen({super.key});

  @override
  State<StatefulWidget> createState() => _ConfirmNewPasswordScreenState();
}

class _ConfirmNewPasswordScreenState extends State<ConfirmNewPasswordScreen> {
  final GlobalKey<FormState> formStateKey = GlobalKey<FormState>();
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
    confirmNewPasswordFocus.dispose();
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
            actionsPadding: const EdgeInsets.all(8),
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
                          SizedBox(height: screenHeight * 0.05),
                          Text(
                            "تغيير كلمة المرور",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.primary,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Text(
                            "سيتم استبدال كلمة المرور القديمة بالجديدة",
                            textAlign: TextAlign.center,
                            style: AppTextStyles.body.copyWith(
                              fontSize: 17,
                              color: AppColors.text_4,
                            ),
                          ),
                          SizedBox(height: screenHeight * 0.03),
                          Form(
                            key: formStateKey,
                            child: Column(
                              children: [
                                Directionality(
                                  textDirection: TextDirection.rtl,
                                  child: Padding(
                                    padding:
                                        EdgeInsets.all(screenWidth * 0.02),
                                    child: CustomTextFormField(
                                      onTap: () {
                                        setState(() {
                                          isPasswordHiddenVisibile = true;
                                          isconfirmPasswordHiddenVisibile =
                                              false;
                                        });
                                      },
                                      fieldFocuse: newPasswordFocus,
                                      label: "كلمة المرور",
                                      controller: newPasswordController,
                                      obscureText: isPasswordHidden,
                                      onChanged: (_) {
                                        if (!_suppressPasswordError) {
                                          setState(
                                            () =>
                                                _suppressPasswordError = true,
                                          );
                                        }
                                      },
                                      validator: (value) {
                                        if (_suppressPasswordError) return null;
                                        if (value == null || value.isEmpty) {
                                          return 'الرجاء إدخال كلمة المرور';
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
                                                    ? Icons
                                                        .visibility_off_outlined
                                                    : Icons
                                                        .visibility_outlined,
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
                                    padding:
                                        EdgeInsets.all(screenWidth * 0.02),
                                    child: CustomTextFormField(
                                      onTap: () {
                                        setState(() {
                                          isPasswordHiddenVisibile = false;
                                          isconfirmPasswordHiddenVisibile =
                                              true;
                                        });
                                      },
                                      fieldFocuse: confirmNewPasswordFocus,
                                      label: "تأكيد كلمة المرور",
                                      controller: confirmNewPasswordController,
                                      obscureText: isConfirmPasswordHidden,
                                      onChanged: (_) {
                                        if (!_suppressConfirmPasswordError) {
                                          setState(
                                            () =>
                                                _suppressConfirmPasswordError =
                                                    true,
                                          );
                                        }
                                      },
                                      validator: (value) {
                                        if (_suppressConfirmPasswordError) {
                                          return null;
                                        }
                                        if (value == null || value.isEmpty) {
                                          return 'الرجاء إدخال كلمة المرور';
                                        }
                                        if (value !=
                                            newPasswordController.text) {
                                          return 'كلمة المرور غير متطابقة';
                                        }
                                        return null;
                                      },
                                      suffixIcon:
                                          isconfirmPasswordHiddenVisibile
                                              ? IconButton(
                                                  padding: EdgeInsets.all(
                                                    screenWidth * 0.02,
                                                  ),
                                                  icon: Icon(
                                                    isConfirmPasswordHidden
                                                        ? Icons
                                                            .visibility_off_outlined
                                                        : Icons
                                                            .visibility_outlined,
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
                          CustomButton(
                            height: 45,
                            width: screenWidth > 420 ? 240 : screenWidth * 0.6,
                            onPressed: () {
                              setState(() {
                                _suppressPasswordError = false;
                                _suppressConfirmPasswordError = false;
                              });
                              if (formStateKey.currentState?.validate() ??
                                  false) {
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
                            text: "تأكيد",
                            fontsize: 17,
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
    confirmNewPasswordFocus.unfocus();
    isconfirmPasswordHiddenVisibile = false;
    isPasswordHiddenVisibile = false;
    FocusManager.instance.primaryFocus?.unfocus();
  }
}
