import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

/// A reusable custom button widget with configurable text, size, and behavior.
///
/// This button is designed for login/sign-up screens but can be reused elsewhere.
/// It has a rounded design, customizable width and height, and uses the app's theme colors.
///
/// Parameters:
/// - [text] (required): The label displayed on the button.
/// - [onPressed] (required): The callback function triggered when the button is pressed.
/// - [width] (optional, default 230): The width of the button.
/// - [height] (optional, default 50): The height of the button.
class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final double? fontsize;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width,
    this.height, 
    this.fontsize,
  });

  @override
  Widget build(BuildContext context) {
    return MaterialButton(
      height: height,
      minWidth: width,
      onPressed: onPressed,
      color: AppColors.buttonLoginSignUp,
      disabledColor: AppColors.accent_3,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: AppColors.primary2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: AppTextStyles.heading5.copyWith(
          fontSize: fontsize,
          color: AppColors.text_3,
        ),
      ),
    );
  }
}
