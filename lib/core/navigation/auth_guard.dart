import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../auth/token_manager.dart';

class AuthGuard extends StatefulWidget {
  final Widget child;
  final WidgetBuilder unauthenticatedBuilder;

  const AuthGuard({
    super.key,
    required this.child,
    required this.unauthenticatedBuilder,
  });

  @override
  State<AuthGuard> createState() => _AuthGuardState();
}

class _AuthGuardState extends State<AuthGuard> {
  bool _checking = true;
  bool _authenticated = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final tokenManager = context.read<TokenManager>();
    final token = await tokenManager.getToken();
    if (!mounted) return;
    setState(() {
      _authenticated = token != null && token.trim().isNotEmpty;
      _checking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_checking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (_authenticated) {
      return widget.child;
    }

    return widget.unauthenticatedBuilder(context);
  }
}
