import 'package:testbor/core/errors/app_exception.dart';
import 'package:testbor/features/auth/domain/repositories/auth_repository.dart';
import 'package:testbor/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:testbor/features/profile/domain/entities/profile.dart';
import 'package:testbor/features/profile/domain/repositories/profile_repository.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
    required AuthRepository authRepository,
  }) : _remoteDataSource = remoteDataSource,
       _authRepository = authRepository;

  final ProfileRemoteDataSource _remoteDataSource;
  final AuthRepository _authRepository;

  @override
  Future<Profile> getProfile() async {
    var accessToken = await _authRepository.getAccessToken();
    if (accessToken == null || accessToken.isEmpty) {
      throw AppException('Пользователь не авторизован');
    }

    try {
      return await _remoteDataSource.fetchProfile(accessToken: accessToken);
    } on GraphqlException catch (error) {
      if (!_shouldRefreshToken(error)) {
        rethrow;
      }

      await _authRepository.refreshUserToken();
      accessToken = await _authRepository.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        throw AppException('Сессия истекла. Войдите заново.');
      }

      return _remoteDataSource.fetchProfile(accessToken: accessToken);
    }
  }

  bool _shouldRefreshToken(GraphqlException error) {
    return error.hasCode('access-denied') ||
        error.hasCode('invalid-token') ||
        error.hasCode('invalid-jwt') ||
        error.hasCode('token-expired');
  }
}
