import 'package:roadmaps/core/api/api_exceptions.dart';
import 'package:roadmaps/core/data/user/user_model.dart';
import 'package:roadmaps/core/entities/user_entity.dart';

class AuthModel {
  final UserEntity user;
  final String token;
  final String tokenType;

  const AuthModel({
    required this.user,
    required this.token,
    required this.tokenType,
  });

  factory AuthModel.fromResponse(Map<String, dynamic> json) {
    final success = json['success'] == true || json['status'] == 'success';
    if (!success) {
      final message = json['message'];
      throw ApiException(
        message is String && message.trim().isNotEmpty
            ? message.trim()
            : 'تعذر إتمام العملية.',
      );
    }

    final data = json['data'];
    final Map<String, dynamic> payload = data is Map<String, dynamic>
        ? data
        : json;

    final userJson = payload['user'];
    if (userJson is! Map<String, dynamic>) {
      throw ParsingException();
    }

    final token = payload['token'];
    if (token is! String || token.trim().isEmpty) {
      throw ParsingException();
    }

    return AuthModel(
      user: UserModel.fromJson(userJson),
      token: token.trim(),
      tokenType: (payload['token_type'] as String?) ?? 'Bearer',
    );
  }
}
