import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

class AppPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final double width;
  final double height;
  final double borderRadius;
  final Color backgroundColor;
  final Color foregroundColor;
  final TextStyle? textStyle;

  const AppPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.width = 241,
    this.height = 50,
    this.borderRadius = 30,
    this.backgroundColor = AppColors.primary2,
    this.foregroundColor = AppColors.text_5,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    final VoidCallback? effectiveOnPressed = isLoading ? null : onPressed;

    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: backgroundColor,
          foregroundColor: foregroundColor,
          minimumSize: Size.fromHeight(height),
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        onPressed: effectiveOnPressed,
        child: isLoading
            ? SizedBox(
                width: 18,
                height: 18,
                child: CircularProgressIndicator(
                  strokeWidth: 2.2,
                  valueColor: AlwaysStoppedAnimation<Color>(foregroundColor),
                ),
              )
            : Text(
                text,
                style: (textStyle ?? AppTextStyles.heading5).copyWith(
                  color: foregroundColor,
                ),
              ),
      ),
    );
  }
}
