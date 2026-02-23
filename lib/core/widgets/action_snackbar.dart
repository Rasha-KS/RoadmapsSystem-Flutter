import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

void showActionSnackBar(
  ScaffoldMessengerState messenger, {
  required String message,
  required bool isSuccess,
}) {
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
          style: AppTextStyles.heading5.copyWith(
            color: isSuccess ? AppColors.primary : AppColors.text_2,
          ),
        ),
      ),
      backgroundColor: isSuccess
          ? AppColors.backGroundSuccess
          : AppColors.backGroundError,
      duration: const Duration(seconds: 3),
    ),
  );
}
