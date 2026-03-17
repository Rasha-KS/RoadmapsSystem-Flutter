import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:webview_flutter/webview_flutter.dart';

import 'package:roadmaps/core/constants/api_constants.dart';
import 'package:roadmaps/core/navigation/auth_guard.dart';
import 'package:roadmaps/core/widgets/action_snackbar.dart';
import 'package:roadmaps/features/auth/presentation/auth_provider.dart';
import 'package:roadmaps/features/auth/presentation/login_screen.dart';
import 'package:roadmaps/features/main_screen.dart';

class GithubLoginScreen extends StatefulWidget {
  const GithubLoginScreen({super.key});

  @override
  State<GithubLoginScreen> createState() => _GithubLoginScreenState();
}

class _GithubLoginScreenState extends State<GithubLoginScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _handledRedirect = false;

  static const String _authorizeUrl =
      'https://github.com/login/oauth/authorize'
      '?client_id=Ov23liIjYNGNi3P2m2DK'
      '&redirect_uri=${ApiConstants.baseUrl}${ApiConstants.githubCallback}'
      '&scope=user:email';

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _setLoading(true),
          onPageFinished: (_) => _setLoading(false),
          onNavigationRequest: (request) {
            if (_handledRedirect) {
              return NavigationDecision.prevent;
            }
            final uri = Uri.tryParse(request.url);
            if (uri == null) {
              return NavigationDecision.navigate;
            }

            if (uri.toString().startsWith(
                  ApiConstants.url(ApiConstants.githubCallback),
                )) {
              final code = uri.queryParameters['code'];
              _handledRedirect = true;
              _handleAuthCode(code);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_authorizeUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GitHub'),
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Align(
              alignment: Alignment.topCenter,
              child: LinearProgressIndicator(),
            ),
        ],
      ),
    );
  }

  Future<void> _handleAuthCode(String? code) async {
    if (code == null || code.trim().isEmpty) {
      _showError('تعذر الحصول على رمز GitHub. حاول مرة أخرى.');
      if (mounted) Navigator.pop(context);
      return;
    }

    _setLoading(true);
    final provider = context.read<AuthProvider>();
    final user = await provider.loginWithGithub(code: code.trim());

    if (!mounted) return;

    if (user == null) {
      _setLoading(false);
      _showError(provider.error ?? 'تعذر تسجيل الدخول عبر GitHub.');
      Navigator.pop(context);
      return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => AuthGuard(
          child: const MainScreen(),
          unauthenticatedBuilder: (_) => const LoginScreen(),
        ),
      ),
      (route) => false,
    );
  }

  void _showError(String message) {
    final messenger = ScaffoldMessenger.of(context);
    showActionSnackBar(messenger, message: message, isSuccess: false);
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => _isLoading = value);
  }
}
