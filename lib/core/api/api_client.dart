import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';

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

  Map<String, dynamic> _handleResponse(String url, http.Response response) {
    final statusCode = response.statusCode;
    final dynamic payload = _decodeBody(response.body);

    if (statusCode >= 200 && statusCode < 300) {
      if (payload is Map<String, dynamic>) {
        return payload;
      }
      throw ParsingException();
    }

    debugPrint(
      'API error: $url | statusCode=$statusCode | body=${response.body}',
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
        return message.trim();
      }

      final validationErrors = payload['errors'];
      if (validationErrors is Map<String, dynamic>) {
        final messages = <String>[];
        for (final entry in validationErrors.entries) {
          final value = entry.value;
          if (value is Iterable) {
            for (final item in value) {
              if (item is String && item.trim().isNotEmpty) {
                messages.add(item.trim());
              }
            }
          } else if (value is String && value.trim().isNotEmpty) {
            messages.add(value.trim());
          }
        }
        if (messages.isNotEmpty) {
          return messages.join('\n');
        }
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
