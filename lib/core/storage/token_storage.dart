import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  TokenStorage({required SharedPreferences sharedPreferences})
    : _sharedPreferences = sharedPreferences;

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  final SharedPreferences _sharedPreferences;

  Future<void> saveUserTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _sharedPreferences.setString(_accessTokenKey, accessToken);
    await _sharedPreferences.setString(_refreshTokenKey, refreshToken);
  }

  String? getAccessToken() => _sharedPreferences.getString(_accessTokenKey);

  String? getRefreshToken() => _sharedPreferences.getString(_refreshTokenKey);

  Future<void> clearUserTokens() async {
    await _sharedPreferences.remove(_accessTokenKey);
    await _sharedPreferences.remove(_refreshTokenKey);
  }
}
