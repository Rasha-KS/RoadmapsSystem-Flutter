import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

enum SnackBarVariant {
  success,
  error,
  warning,
}

void showAppSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required SnackBarVariant variant,
  Duration duration = const Duration(seconds: 3),
}) {
  final (backgroundColor, textColor) = switch (variant) {
    SnackBarVariant.success => (AppColors.backGroundSuccess, AppColors.primary),
    SnackBarVariant.error => (AppColors.backGroundError, AppColors.text_2),
    SnackBarVariant.warning => (AppColors.warning, AppColors.text_5),
  };

  messenger.showSnackBar(
    SnackBar(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(18)),
      ),
      content: Directionality(
        textDirection: TextDirection.rtl,
        child: Text(
          message,
          textAlign: TextAlign.right,
          style: AppTextStyles.heading5.copyWith(color: textColor),
        ),
      ),
      backgroundColor: backgroundColor,
      duration: duration,
    ),
  );
}

void showActionSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required bool isSuccess,
}) {
  showAppSnackBar(
    messenger,
    message: message,
    variant: isSuccess ? SnackBarVariant.success : SnackBarVariant.error,
  );
}
