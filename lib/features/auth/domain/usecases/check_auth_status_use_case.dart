import 'package:testbor/features/auth/domain/repositories/auth_repository.dart';

class CheckAuthStatusUseCase {
  CheckAuthStatusUseCase(this._repository);

  final AuthRepository _repository;

  Future<bool> call() {
    return _repository.hasUserSession();
  }
}
