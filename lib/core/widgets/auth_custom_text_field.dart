
import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

class CustomTextFormField extends StatelessWidget {
  final String label;
  final bool obscureText;
  final TextEditingController? controller;
  final String? Function(String?)? validator;
  final FocusNode? fieldFocuse;
  final Widget? suffixIcon;
  final VoidCallback? onTap;

  const CustomTextFormField({
    super.key,
    required this.label,
    this.obscureText = false,
    this.controller,
    this.validator,
    this.fieldFocuse,
    this.suffixIcon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: TextFormField(
        onTap: onTap,
        focusNode: fieldFocuse,
        controller: controller,
        obscureText: obscureText,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
       // autovalidateMode: AutovalidateMode.onUnfocus,
        validator: validator,
        decoration: InputDecoration(
          suffixIcon: suffixIcon,
          floatingLabelAlignment: FloatingLabelAlignment.start,
          labelText: label,
          floatingLabelBehavior: FloatingLabelBehavior.auto,
          labelStyle: AppTextStyles.body.copyWith(color: AppColors.text_1),

          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.secondary1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: AppColors.primary2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(20),
            borderSide: BorderSide(color: Colors.red),
          ),
        ),
      ),
    );
  }
}