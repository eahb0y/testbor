import 'package:testbor/features/auth/data/models/auth_tokens_model.dart';
import 'package:testbor/features/auth/domain/entities/user_session.dart';

class UserSessionModel extends UserSession {
  const UserSessionModel({
    required super.tokens,
    required super.roles,
    super.id,
    super.firstName,
    super.lastName,
    super.phone,
    super.email,
  });

  factory UserSessionModel.fromJson(Map<String, dynamic> json) {
    final token = json['token'] as String? ?? '';
    final refreshToken = json['refreshToken'] as String? ?? '';

    return UserSessionModel(
      tokens: AuthTokensModel(accessToken: token, refreshToken: refreshToken),
      roles: (json['roles'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      id: json['id']?.toString(),
      firstName: json['firstName'] as String?,
      lastName: json['lastName'] as String?,
      phone: json['phone'] as String?,
      email: json['email'] as String?,
    );
  }
}
