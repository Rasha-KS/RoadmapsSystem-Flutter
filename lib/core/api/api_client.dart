import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import 'api_exceptions.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: _mergeHeaders(headers))
          .timeout(const Duration(seconds: 20));
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException('انتهت مهلة الاتصال. حاول مرة أخرى.');
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    }
  }

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _mergeHeaders(headers),
            body: jsonEncode(body ?? const <String, dynamic>{}),
          )
          .timeout(const Duration(seconds: 20));
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException('انتهت مهلة الاتصال. حاول مرة أخرى.');
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    }
  }

  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: _mergeHeaders(headers),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(const Duration(seconds: 20));
      return _handleResponse(response);
    } on TimeoutException {
      throw NetworkException('انتهت مهلة الاتصال. حاول مرة أخرى.');
    } on SocketException {
      throw NetworkException();
    } on http.ClientException {
      throw NetworkException();
    }
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;
    final dynamic payload = _decodeBody(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      throw ParsingException();
    }

    final message = _extractMessage(payload) ?? _defaultMessage(statusCode);
    if (statusCode == 401) {
      throw UnauthorizedException(message);
    }
    throw ApiException(message, statusCode: statusCode);
  }

  dynamic _decodeBody(String body) {
    if (body.isEmpty) return null;
    try {
      return jsonDecode(body);
    } catch (_) {
      return null;
    }
  }

  String? _extractMessage(dynamic payload) {
    if (payload is Map<String, dynamic>) {
      final message = payload['message'];
      if (message is String && message.trim().isNotEmpty) {
        return message.trim();
      }
    }
    return null;
  }

  String _defaultMessage(int statusCode) {
    if (statusCode >= 500) {
      return 'حدث خطأ في الخادم. حاول لاحقاً.';
    }
    if (statusCode == 404) {
      return 'المورد غير موجود.';
    }
    if (statusCode == 403) {
      return 'لا تملك صلاحية تنفيذ هذا الطلب.';
    }
    if (statusCode == 400) {
      return 'البيانات المرسلة غير صحيحة.';
    }
    return 'حدث خطأ غير متوقع. حاول مرة أخرى.';
  }
}
