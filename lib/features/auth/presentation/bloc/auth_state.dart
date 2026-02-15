import 'package:equatable/equatable.dart';

enum AuthStatus { checking, unauthenticated, authenticated }

class AuthState extends Equatable {
  const AuthState({
    required this.status,
    this.otpInProgress = false,
    this.loginInProgress = false,
    this.infoMessage,
    this.errorMessage,
  });

  const AuthState.initial() : this(status: AuthStatus.checking);

  final AuthStatus status;
  final bool otpInProgress;
  final bool loginInProgress;
  final String? infoMessage;
  final String? errorMessage;

  AuthState copyWith({
    AuthStatus? status,
    bool? otpInProgress,
    bool? loginInProgress,
    String? infoMessage,
    String? errorMessage,
    bool clearInfoMessage = false,
    bool clearErrorMessage = false,
  }) {
    return AuthState(
      status: status ?? this.status,
      otpInProgress: otpInProgress ?? this.otpInProgress,
      loginInProgress: loginInProgress ?? this.loginInProgress,
      infoMessage: clearInfoMessage ? null : infoMessage ?? this.infoMessage,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    status,
    otpInProgress,
    loginInProgress,
    infoMessage,
    errorMessage,
  ];
}
