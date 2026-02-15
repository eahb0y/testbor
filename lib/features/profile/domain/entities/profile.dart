import 'package:equatable/equatable.dart';

class Profile extends Equatable {
  const Profile({
    required this.id,
    required this.username,
    required this.roles,
    required this.language,
    this.firstName,
    this.lastName,
    this.phone,
    this.email,
    this.imageUrl,
  });

  final String? id;
  final String username;
  final List<String> roles;
  final String language;
  final String? firstName;
  final String? lastName;
  final String? phone;
  final String? email;
  final String? imageUrl;

  String get fullName {
    final parts = [firstName, lastName]
        .whereType<String>()
        .where((value) => value.trim().isNotEmpty)
        .toList(growable: false);
    return parts.join(' ');
  }

  @override
  List<Object?> get props => [
    id,
    username,
    roles,
    language,
    firstName,
    lastName,
    phone,
    email,
    imageUrl,
  ];
}
