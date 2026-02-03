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
  final double width;
  final double height;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.width = 230,
    this.height = 50,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.buttonLoginSignUp, // Background color of the button
        borderRadius: BorderRadius.circular(30), // Rounded corners
        border: Border.all(color: AppColors.primary2), // Button border color
      ),
      width: width,  // Button width
      height: height, // Button height
      child: MaterialButton(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)), // Ensures ripple effect matches rounded corners
        onPressed: onPressed, // Executes the callback when tapped
        child: Text(
          text, // Displays the button text
          style: AppTextStyles.heading5.copyWith(color: AppColors.primary1), // Text style with app colors
        ),
      ),
    );
  }
}
