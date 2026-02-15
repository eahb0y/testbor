import 'package:testbor/core/errors/app_exception.dart';
import 'package:testbor/core/storage/token_storage.dart';
import 'package:testbor/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:testbor/features/auth/data/models/auth_tokens_model.dart';
import 'package:testbor/features/auth/domain/entities/user_session.dart';
import 'package:testbor/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required AuthRemoteDataSource remoteDataSource,
    required TokenStorage tokenStorage,
  }) : _remoteDataSource = remoteDataSource,
       _tokenStorage = tokenStorage;

  final AuthRemoteDataSource _remoteDataSource;
  final TokenStorage _tokenStorage;

  AuthTokensModel? _anonymousTokens;

  @override
  Future<bool> hasUserSession() async {
    final accessToken = _tokenStorage.getAccessToken();
    final refreshToken = _tokenStorage.getRefreshToken();
    return accessToken != null && refreshToken != null;
  }

  @override
  Future<void> requestOtp(String phone) async {
    await _ensureAnonymousToken();

    bool ok;
    try {
      ok = await _remoteDataSource.createOtpForPhone(
        phone: phone,
        bearerToken: _anonymousTokens!.accessToken,
      );
    } on GraphqlException catch (error) {
      throw AppException(_mapGraphqlError(error));
    }

    if (!ok) {
      throw AppException('Не удалось отправить код подтверждения');
    }
  }

  @override
  Future<UserSession> loginOrSignup({
    required String phone,
    required String pinCode,
  }) async {
    await _ensureAnonymousToken();

    late final UserSession session;
    try {
      session = await _remoteDataSource.loginOrSignup(
        phone: phone,
        pinCode: pinCode,
        bearerToken: _anonymousTokens!.accessToken,
      );
    } on GraphqlException catch (error) {
      throw AppException(_mapGraphqlError(error));
    }

    await _tokenStorage.saveUserTokens(
      accessToken: session.tokens.accessToken,
      refreshToken: session.tokens.refreshToken,
    );

    return session;
  }

  @override
  Future<void> refreshUserToken() async {
    final refreshToken = _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw AppException('Сессия истекла. Войдите заново.');
    }

    late final AuthTokensModel refreshed;
    try {
      refreshed = await _remoteDataSource.refreshToken(
        refreshToken: refreshToken,
      );
    } on GraphqlException catch (error) {
      throw AppException(_mapGraphqlError(error));
    }

    await _tokenStorage.saveUserTokens(
      accessToken: refreshed.accessToken,
      refreshToken: refreshed.refreshToken,
    );
  }

  @override
  Future<String?> getAccessToken() async {
    return _tokenStorage.getAccessToken();
  }

  @override
  Future<void> logout() async {
    await _tokenStorage.clearUserTokens();
    _anonymousTokens = null;
  }

  Future<void> _ensureAnonymousToken() async {
    final currentToken = _anonymousTokens;
    if (currentToken != null && currentToken.isValid) {
      return;
    }

    _anonymousTokens = await _remoteDataSource.fetchAnonymousToken();
  }

  String _mapGraphqlError(GraphqlException error) {
    if (error.hasCode('invalid-phone-or-pin-code')) {
      return 'Неверный телефон или код подтверждения';
    }
    if (error.hasCode('access-denied')) {
      return 'Доступ запрещён. Повторите авторизацию.';
    }
    return error.message;
  }
}
