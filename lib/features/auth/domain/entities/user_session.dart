import 'package:equatable/equatable.dart';
import 'package:testbor/features/auth/domain/entities/auth_tokens.dart';

class UserSession extends Equatable {
  const UserSession({
    required this.tokens,
    required this.roles,
    this.id,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
  });

  final AuthTokens tokens;
  final List<String> roles;
  final String? id;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;

  @override
  List<Object?> get props => [
    tokens,
    roles,
    id,
    firstName,
    lastName,
    phone,
    email,
  ];
}
