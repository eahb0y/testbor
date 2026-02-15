import 'package:equatable/equatable.dart';

sealed class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthStarted extends AuthEvent {
  const AuthStarted();
}

class OtpRequested extends AuthEvent {
  const OtpRequested(this.phone);

  final String phone;

  @override
  List<Object?> get props => [phone];
}

class LoginSubmitted extends AuthEvent {
  const LoginSubmitted({required this.phone, required this.pinCode});

  final String phone;
  final String pinCode;

  @override
  List<Object?> get props => [phone, pinCode];
}

class LoggedOut extends AuthEvent {
  const LoggedOut();
}

class AuthFeedbackCleared extends AuthEvent {
  const AuthFeedbackCleared();
}
