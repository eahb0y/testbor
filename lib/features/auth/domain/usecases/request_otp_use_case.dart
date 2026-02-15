import 'package:testbor/features/auth/domain/repositories/auth_repository.dart';

class RequestOtpUseCase {
  RequestOtpUseCase(this._repository);

  final AuthRepository _repository;

  Future<void> call(String phone) {
    return _repository.requestOtp(phone);
  }
}
