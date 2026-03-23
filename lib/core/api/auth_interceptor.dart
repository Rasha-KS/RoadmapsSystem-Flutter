import 'dart:convert';
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
      if (response.statusCode == 401) {
        return _handleUnauthorizedResponse(request, response);
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

  Future<http.StreamedResponse> _handleUnauthorizedResponse(
    http.BaseRequest request,
    http.StreamedResponse response,
  ) async {
    final bytes = await response.stream.toBytes();
    final body = utf8.decode(bytes, allowMalformed: true);

    if (_shouldClearTokenOnUnauthorized(request.url, body)) {
      await _tokenManager.clearToken();
    }

    return http.StreamedResponse(
      Stream<List<int>>.value(bytes),
      response.statusCode,
      contentLength: bytes.length,
      request: response.request,
      headers: response.headers,
      isRedirect: response.isRedirect,
      persistentConnection: response.persistentConnection,
      reasonPhrase: response.reasonPhrase,
    );
  }

  bool _shouldClearTokenOnUnauthorized(Uri url, String responseBody) {
    if (url.path.endsWith('/update-account')) {
      return false;
    }

    final lower = responseBody.toLowerCase();

    final mentionsCurrentPassword =
        lower.contains('current password') ||
        lower.contains('current_password') ||
        lower.contains('كلمة المرور الحالية');
    final mentionsPasswordConfirmation =
        lower.contains('password confirmation') ||
        lower.contains('password_confirmation') ||
        lower.contains('confirmed') ||
        lower.contains('تأكيد كلمة المرور');
    final mentionsPasswordValidation =
        lower.contains('password') || lower.contains('كلمة المرور');

    final isValidationFailure =
        (mentionsCurrentPassword &&
            (lower.contains('incorrect') ||
                lower.contains('invalid') ||
                lower.contains('wrong') ||
                lower.contains('does not match') ||
                lower.contains('required') ||
                lower.contains('غير صحيحة') ||
                lower.contains('خاطئة') ||
                lower.contains('مطلوبة'))) ||
        (mentionsPasswordConfirmation &&
            (lower.contains('match') ||
                lower.contains('required') ||
                lower.contains('غير مطابق') ||
                lower.contains('مطلوبة'))) ||
        (mentionsPasswordValidation &&
            (lower.contains('required') || lower.contains('مطلوبة')));

    return !isValidationFailure;
  }
}
