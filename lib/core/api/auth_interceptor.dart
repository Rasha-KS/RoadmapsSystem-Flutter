import 'dart:io';

import 'package:http/http.dart' as http;

import '../auth/token_manager.dart';

class AuthInterceptor extends http.BaseClient {
  AuthInterceptor({
    required TokenManager tokenManager,
    http.Client? inner,
  })  : _tokenManager = tokenManager,
        _inner = inner ?? http.Client();

  final TokenManager _tokenManager;
  final http.Client _inner;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    try {
      final token = await _tokenManager.getToken();
      if (token != null && token.trim().isNotEmpty) {
        request.headers['Authorization'] = 'Bearer $token';
      }
    } catch (_) {
      // Ignore token errors and continue without auth header.
    }

    try {
      final response = await _inner.send(request);
      if (response.statusCode == 401 || response.statusCode == 403) {
        await _tokenManager.clearToken();
      }
      return response;
    } on SocketException {
      rethrow;
    } on http.ClientException {
      rethrow;
    } catch (e) {
      throw http.ClientException(
        'حدث خطأ غير متوقع في الشبكة',
        request.url,
      );
    }
  }

  @override
  void close() {
    _inner.close();
  }
}
