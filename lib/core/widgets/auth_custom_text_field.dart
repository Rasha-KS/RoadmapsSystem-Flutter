import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';
import 'package:roadmaps/core/theme/app_text_styles.dart';

// CustomTextFormField - Reusable Text Input Widget
//
// This widget is a reusable wrapper around Flutter's TextFormField,
// designed for consistent styling and behavior across the app's forms.
//
// Features:
// - Right-to-left text alignment (TextAlign.right) for Arabic content.
// - Optional controller for managing input text.
// - Optional validator for form validation logic.
// - Optional focus node for programmatic focus handling.
// - Optional suffixIcon for toggling password visibility or other actions.
// - Optional onTap callback to handle taps on the field.
//
// Styling:
// - Padding is responsive, based on screen width.
// - Rounded borders with 20px radius.
// - Colors are pulled from AppColors for enabled, focused, and error states.
// - Label styling uses AppTextStyles.body with text color from AppColors.
//
// Behavior:
// - Supports obscured text for password fields via obscureText property.
// - Floating label aligns to start and automatically floats when the field is focused or has content.
// - RTL text direction is enforced for Arabic language support.
//



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
    final screenWidth = MediaQuery.of(context).size.width;

    return Padding(
      padding: EdgeInsets.all(screenWidth * 0.02),
      child: TextFormField(
        onTap: onTap,
        focusNode: fieldFocuse,
        controller: controller,
        obscureText: obscureText,
        textAlign: TextAlign.right,
        textDirection: TextDirection.rtl,
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
