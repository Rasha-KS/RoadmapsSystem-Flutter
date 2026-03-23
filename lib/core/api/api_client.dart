import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import 'api_exceptions.dart';

class ApiClient {
  ApiClient({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<Map<String, dynamic>> get(
    String url, {
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      final response = await _client
          .get(Uri.parse(url), headers: _mergeHeaders(headers))
          .timeout(timeout);
      return _handleResponse(url, response);
    } on TimeoutException {
      throw _timeoutException();
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> post(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      final response = await _client
          .post(
            Uri.parse(url),
            headers: _mergeHeaders(headers),
            body: jsonEncode(body ?? const <String, dynamic>{}),
          )
          .timeout(timeout);
      return _handleResponse(url, response);
    } on TimeoutException {
      throw _timeoutException();
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> patch(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      final response = await _client
          .patch(
            Uri.parse(url),
            headers: _mergeHeaders(headers),
            body: jsonEncode(body ?? const <String, dynamic>{}),
          )
          .timeout(timeout);
      return _handleResponse(url, response);
    } on TimeoutException {
      throw _timeoutException();
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> put(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      final response = await _client
          .put(
            Uri.parse(url),
            headers: _mergeHeaders(headers),
            body: jsonEncode(body ?? const <String, dynamic>{}),
          )
          .timeout(timeout);
      return _handleResponse(url, response);
    } on TimeoutException {
      throw _timeoutException();
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> postMultipart(
    String url, {
    required String fileField,
    required String filePath,
    Map<String, String>? fields,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      final request = http.MultipartRequest('POST', Uri.parse(url));
      request.headers.addAll({
        'Accept': 'application/json',
        if (headers != null) ...headers,
      });
      if (fields != null) {
        request.fields.addAll(fields);
      }
      request.files.add(await http.MultipartFile.fromPath(fileField, filePath));

      final streamedResponse = await _client.send(request).timeout(timeout);
      final response = await http.Response.fromStream(streamedResponse);
      return _handleResponse(url, response);
    } on TimeoutException {
      throw _timeoutException();
    } on FileSystemException {
      throw const ApiException(
        'تعذر قراءة الصورة المحددة. حاول اختيار صورة أخرى.',
      );
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Future<Map<String, dynamic>> delete(
    String url, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Duration timeout = const Duration(seconds: 20),
  }) async {
    try {
      final response = await _client
          .delete(
            Uri.parse(url),
            headers: _mergeHeaders(headers),
            body: body == null ? null : jsonEncode(body),
          )
          .timeout(timeout);
      return _handleResponse(url, response);
    } on TimeoutException {
      throw _timeoutException();
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }
  }

  Map<String, String> _mergeHeaders(Map<String, String>? headers) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (headers != null) ...headers,
    };
  }

  Map<String, dynamic> _handleResponse(String url, http.Response response) {
    final statusCode = response.statusCode;
    final dynamic payload = _decodeBody(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      if (payload == null) {
        return const <String, dynamic>{'success': true};
      }
      throw const ParsingException();
    }

    debugPrint(
      'خطأ API: $url | statusCode=$statusCode | body=${response.body}',
    );
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
        return _normalizeMessage(message);
      }

      final error = payload['error'];
      if (error is String && error.trim().isNotEmpty) {
        return _normalizeMessage(error);
      }

      final validationErrors = payload['errors'];
      if (validationErrors is Map<String, dynamic>) {
        final messages = <String>[];
        for (final entry in validationErrors.entries) {
          final value = entry.value;
          if (value is Iterable) {
            for (final item in value) {
              if (item is String && item.trim().isNotEmpty) {
                messages.add(_normalizeMessage(item));
              }
            }
          } else if (value is String && value.trim().isNotEmpty) {
            messages.add(_normalizeMessage(value));
          }
        }
        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
      }
    }
    return null;
  }

  String _normalizeMessage(String message) {
    final text = message.trim();
    if (text.isEmpty) return text;

    final lower = text.toLowerCase();

    if ((lower.contains('patch method is not supported') ||
            lower.contains('supported methods: put')) &&
        lower.contains('update-account')) {
      return 'الخادم لا يدعم PATCH لهذا الطلب. استخدم PUT لتعديل الحساب.';
    }
    if (lower.contains('notifications enabled field is required') ||
        lower.contains('is notifications enabled field is required')) {
      return 'حقل تفعيل الإشعارات مطلوب.';
    }
    if (lower.contains('username') && lower.contains('required')) {
      return 'اسم المستخدم مطلوب.';
    }
    if (lower.contains('unauthorized') || lower.contains('unauthenticated')) {
      return 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.';
    }
    if (lower.contains('forbidden')) {
      return 'لا تملك صلاحية تنفيذ هذا الطلب.';
    }
    if (lower.contains('not found')) {
      return 'المورد المطلوب غير موجود.';
    }
    if (lower.contains('too many requests')) {
      return 'تم إرسال طلبات كثيرة. حاول مرة أخرى بعد قليل.';
    }
    if (lower.contains('server error')) {
      return 'حدث خطأ في الخادم. حاول لاحقاً.';
    }

    return text;
  }

  ApiException _timeoutException() {
    return const NetworkException('انتهت مهلة الاتصال. حاول مرة أخرى.');
  }

  String _defaultMessage(int statusCode) {
    if (statusCode >= 500) {
      return 'حدث خطأ في الخادم. حاول لاحقاً.';
    }
    if (statusCode == 404) {
      return 'المورد المطلوب غير موجود.';
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
