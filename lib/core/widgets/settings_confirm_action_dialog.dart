import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

Future<void> showSettingsConfirmActionDialog({
  required BuildContext context,
  required String title,
  required Future<void> Function() onConfirm,
  VoidCallback? onCancel,
  String cancelText = 'إلغاء',
  String confirmText = 'تأكيد',
}) async {
  final confirm = await showDialog<bool>(
    context: context,
    barrierColor: Colors.black54,
    builder: (dialogContext) {
      return Dialog(
        alignment: Alignment.topCenter,
        backgroundColor: AppColors.primary1.withValues(alpha: 0.82),
        elevation: 10,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        insetPadding: const EdgeInsets.only(
          left: 50,
          right: 50,
          top: 250,
        ),
        child: Padding(
          padding: const EdgeInsets.all(30),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                textAlign: TextAlign.center,
                style: AppTextStyles.heading4.copyWith(
                  color: AppColors.text_2,
                ),
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  MaterialButton(
                    color: AppColors.secondary4,
                    textColor: AppColors.text_1,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 6,
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(false),
                    child: Text(
                      cancelText,
                      style: AppTextStyles.boldSmallText.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  MaterialButton(
                    color: AppColors.secondary4,
                    textColor: AppColors.text_3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 30,
                      vertical: 6,
                    ),
                    onPressed: () => Navigator.of(dialogContext).pop(true),
                    child: Text(
                      confirmText,
                      style: AppTextStyles.boldSmallText.copyWith(
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    },
  );

  if (confirm == true) {
    await onConfirm();
  } else {
    onCancel?.call();
  }
}
