import 'package:flutter/material.dart';
import 'package:roadmaps/core/theme/app_colors.dart';

/// Builds a reusable AppBar for the application.
///
/// This AppBar includes:
/// - A notifications icon button displayed on the left.
/// - A settings icon button displayed on the right.
///
/// Parameters:
/// - [onNotificationsTap] (required): Callback triggered when the notifications button is pressed.
/// - [onSettingsTap] (optional): Callback triggered when the settings button is pressed.
///
/// Returns:
/// - An [AppBar] widget with left and right aligned action buttons.
/// 
/// Notes on required vs optional callbacks:
/// - [onNotificationsTap] is marked as required because the notifications
///   action is considered a core feature of the AppBar and is expected
///   to be available and functional on all screens.
///
/// - [onSettingsTap] is optional because the settings action may not be
///   needed on every screen. Making it optional allows the AppBar to be
///   reused in different contexts without forcing a settings behavior.
AppBar buildAppBar({
  required VoidCallback onNotificationsTap,
  VoidCallback? onSettingsTap,
  required BuildContext context,
}) {

     final screenWidth = MediaQuery.of(context).size.width;
     final screenHeight = MediaQuery.of(context).size.height;
     final double iconSize = ((screenWidth + screenHeight) / 2) * 0.05;
     final double rightPadding = screenWidth * 0.03;


  return AppBar(
    // Left side: Notifications
    leading: IconButton(
      icon:  Icon(
        Icons.notifications_none_outlined, 
        color: AppColors.primary,
        size: iconSize,

      ),
      onPressed: onNotificationsTap,
    ),

    // Right side: Settings (outline)
    actions: [
      if (onSettingsTap != null)
      Padding(
          padding: EdgeInsets.only(right: rightPadding , top:1),
          child: IconButton(
          icon:  Icon(
          Icons.settings_outlined, 
          color: AppColors.primary,
          size: iconSize,
        ),
        onPressed: onSettingsTap,
      ),
     ),
    ],
  );
}
