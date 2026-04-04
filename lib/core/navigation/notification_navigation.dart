import 'package:flutter/material.dart';
import 'package:roadmaps/core/navigation/app_navigator.dart';
import 'package:roadmaps/core/navigation/auth_guard.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/notifications/presentation/notifications_screen.dart';

void openNotificationsPage() {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    _pushNotificationsPage();
  });
}

void _pushNotificationsPage() {
  final navigator = appNavigatorKey.currentState;
  if (navigator == null) return;

  navigator.push(
    MaterialPageRoute(
      builder: (_) => AuthGuard(
        child: const NotificationsScreen(),
        unauthenticatedBuilder: (_) => const LoginScreen(),
      ),
    ),
  );
}
