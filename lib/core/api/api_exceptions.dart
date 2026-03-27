class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() {
    if (statusCode == null) {
      return 'ApiException: $message';
    }
    return 'ApiException($statusCode): $message';
  }
}

class NetworkException extends ApiException {
  const NetworkException([
    super.message = 'تعذر الاتصال حالياً. تحقق من الشبكة وحاول مرة أخرى.',
  ]);
}

class TimeoutApiException extends ApiException {
  const TimeoutApiException([
    super.message = 'استغرق الطلب وقتًا أطول من المعتاد. حاول مرة أخرى.',
  ]);
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    super.message = 'انتهت صلاحية الجلسة. يرجى تسجيل الدخول مرة أخرى.',
  ]) : super(statusCode: 401);
}

class ParsingException extends ApiException {
  const ParsingException([
    super.message = 'استجابة غير متوقعة من الخادم. حاول مرة أخرى.',
  ]);
}
