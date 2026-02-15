import 'package:testbor/core/constants/api_endpoints.dart';
import 'package:testbor/core/errors/app_exception.dart';
import 'package:testbor/core/network/graphql_http_client.dart';
import 'package:testbor/features/auth/data/models/auth_tokens_model.dart';
import 'package:testbor/features/auth/data/models/user_session_model.dart';

class AuthRemoteDataSource {
  AuthRemoteDataSource({required GraphqlHttpClient graphqlHttpClient})
    : _graphqlHttpClient = graphqlHttpClient;

  final GraphqlHttpClient _graphqlHttpClient;

  Future<AuthTokensModel> fetchAnonymousToken() async {
    const query = '''
      query AnonymousToken {
        anonymousToken {
          token
          refreshToken
        }
      }
    ''';

    final data = await _graphqlHttpClient.request(
      endpoint: ApiEndpoints.authGraphql,
      document: query,
    );

    final tokenJson = data['anonymousToken'] as Map<String, dynamic>?;
    if (tokenJson == null) {
      throw NetworkException('anonymousToken payload is missing');
    }

    final tokens = AuthTokensModel.fromJson(tokenJson);
    if (!tokens.isValid) {
      throw NetworkException('anonymousToken payload is invalid');
    }

    return tokens;
  }

  Future<bool> createOtpForPhone({
    required String phone,
    required String bearerToken,
  }) async {
    const mutation = '''
      mutation RequestOtp(\$phone: String!) {
        otp {
          createForPhone(phone: \$phone)
        }
      }
    ''';

    final data = await _graphqlHttpClient.request(
      endpoint: ApiEndpoints.authGraphql,
      document: mutation,
      variables: {'phone': phone},
      bearerToken: bearerToken,
    );

    final otpJson = data['otp'] as Map<String, dynamic>?;
    return otpJson?['createForPhone'] as bool? ?? false;
  }

  Future<UserSessionModel> loginOrSignup({
    required String phone,
    required String pinCode,
    required String bearerToken,
  }) async {
    const mutation = '''
      mutation LoginOrSignup(\$phone: String!, \$pinCode: String!) {
        loginOrSignup(phone: \$phone, pinCode: \$pinCode) {
          id
          firstName
          lastName
          phone
          email
          roles
          token
          refreshToken
        }
      }
    ''';

    final data = await _graphqlHttpClient.request(
      endpoint: ApiEndpoints.authGraphql,
      document: mutation,
      variables: {'phone': phone, 'pinCode': pinCode},
      bearerToken: bearerToken,
    );

    final sessionJson = data['loginOrSignup'] as Map<String, dynamic>?;
    if (sessionJson == null) {
      throw NetworkException('loginOrSignup payload is missing');
    }

    final session = UserSessionModel.fromJson(sessionJson);
    final tokens = session.tokens;
    if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
      throw NetworkException('loginOrSignup payload is invalid');
    }

    return session;
  }

  Future<AuthTokensModel> refreshToken({required String refreshToken}) async {
    const query = '''
      query RefreshToken {
        refreshToken {
          token
          refreshToken
        }
      }
    ''';

    final data = await _graphqlHttpClient.request(
      endpoint: ApiEndpoints.authGraphql,
      document: query,
      bearerToken: refreshToken,
    );

    final tokenJson = data['refreshToken'] as Map<String, dynamic>?;
    if (tokenJson == null) {
      throw NetworkException('refreshToken payload is missing');
    }

    final tokens = AuthTokensModel.fromJson(tokenJson);
    if (!tokens.isValid) {
      throw NetworkException('refreshToken payload is invalid');
    }

    return tokens;
  }
}
