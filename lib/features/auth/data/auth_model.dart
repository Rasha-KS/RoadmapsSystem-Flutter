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
    final success = json['success'] == true;
    if (!success) {
      final message = json['message'];
      throw ApiException(
        message is String && message.trim().isNotEmpty
            ? message.trim()
            : 'تعذر إتمام العملية.',
      );
    }

    final data = json['data'];
    if (data is! Map<String, dynamic>) {
      throw ParsingException();
    }

    final userJson = data['user'];
    if (userJson is! Map<String, dynamic>) {
      throw ParsingException();
    }

    final token = data['token'];
    if (token is! String || token.trim().isEmpty) {
      throw ParsingException();
    }

    return AuthModel(
      user: UserModel.fromJson(userJson),
      token: token.trim(),
      tokenType: (data['token_type'] as String?) ?? 'Bearer',
    );
  }
}
