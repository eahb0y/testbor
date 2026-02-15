import 'package:testbor/features/auth/domain/entities/user_session.dart';
import 'package:testbor/features/auth/domain/repositories/auth_repository.dart';

class LoginOrSignupUseCase {
  LoginOrSignupUseCase(this._repository);

  final AuthRepository _repository;

  Future<UserSession> call({required String phone, required String pinCode}) {
    return _repository.loginOrSignup(phone: phone, pinCode: pinCode);
  }
}
