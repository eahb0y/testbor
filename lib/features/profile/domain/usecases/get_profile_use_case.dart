import 'package:testbor/features/profile/domain/entities/profile.dart';
import 'package:testbor/features/profile/domain/repositories/profile_repository.dart';

class GetProfileUseCase {
  GetProfileUseCase(this._repository);

  final ProfileRepository _repository;

  Future<Profile> call() {
    return _repository.getProfile();
  }
}
