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
  late final Uri _expectedCallbackUri = Uri.parse(
    ApiConstants.url(ApiConstants.githubCallback),
  );

  Uri get _authorizeUri => Uri.https(
        'github.com',
        '/login/oauth/authorize',
        {
          'client_id': 'Ov23liIjYNGNi3P2m2DK',
          'redirect_uri': ApiConstants.url(ApiConstants.githubCallback),
          'scope': 'user:email',
        },
      );

  @override
  void initState() {
    super.initState();

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _setLoading(true),
          onPageFinished: (_) async {
            _setLoading(false);
            final currentUrl = await _controller.currentUrl();
            _maybeHandleRedirect(currentUrl);
          },
          onNavigationRequest: (request) {
            if (_handledRedirect) {
              return NavigationDecision.prevent;
            }
            final uri = Uri.tryParse(request.url);
            if (uri == null) {
              return NavigationDecision.navigate;
            }
            if (_isGithubCallback(uri)) {
              _handledRedirect = true;
              _handleAuthCode(
                uri.queryParameters['code'],
                uri.queryParameters['state'],
              );
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(_authorizeUri);
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

  Future<void> _handleAuthCode(String? code, String? state) async {
    if (code == null || code.trim().isEmpty) {
      _showErrorAndGoBack('تعذر الحصول على رمز GitHub. حاول مرة أخرى.');
      return;
    }

    _setLoading(true);
    final provider = context.read<AuthProvider>();
    final user = await provider.loginWithGithub(
      code: code.trim(),
      state: state,
    );

    if (!mounted) return;

    if (user == null) {
      _setLoading(false);
      _showErrorAndGoBack(provider.error ?? 'تعذر تسجيل الدخول عبر GitHub.');
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

  void _showErrorAndGoBack(String message) {
    final messenger = ScaffoldMessenger.of(context);
    showActionSnackBar(messenger, message: message, isSuccess: false);
    Navigator.pop(context);
  }

  void _maybeHandleRedirect(String? url) {
    if (url == null || _handledRedirect) return;
    final uri = Uri.tryParse(url);
    if (uri == null) return;
    if (!_isGithubCallback(uri)) return;
    _handledRedirect = true;
    _handleAuthCode(uri.queryParameters['code'], uri.queryParameters['state']);
  }

  bool _isGithubCallback(Uri uri) {
    return uri.scheme == _expectedCallbackUri.scheme &&
        uri.host == _expectedCallbackUri.host &&
        uri.port == _expectedCallbackUri.port &&
        uri.path == _expectedCallbackUri.path;
  }

  void _setLoading(bool value) {
    if (!mounted) return;
    setState(() => _isLoading = value);
  }
}
