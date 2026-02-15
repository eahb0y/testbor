import 'package:testbor/features/auth/domain/entities/user_session.dart';

abstract interface class AuthRepository {
  Future<bool> hasUserSession();

  Future<void> requestOtp(String phone);

  Future<UserSession> loginOrSignup({
    required String phone,
    required String pinCode,
  });

  Future<void> refreshUserToken();

  Future<String?> getAccessToken();

  Future<void> logout();
}
