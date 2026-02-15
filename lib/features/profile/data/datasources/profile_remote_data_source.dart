import 'package:testbor/core/constants/api_endpoints.dart';
import 'package:testbor/core/errors/app_exception.dart';
import 'package:testbor/core/network/graphql_http_client.dart';
import 'package:testbor/features/profile/data/models/profile_model.dart';

class ProfileRemoteDataSource {
  ProfileRemoteDataSource({required GraphqlHttpClient graphqlHttpClient})
    : _graphqlHttpClient = graphqlHttpClient;

  final GraphqlHttpClient _graphqlHttpClient;

  Future<ProfileModel> fetchProfile({required String accessToken}) async {
    const query = '''
      query Profile {
        profile {
          id
          username
          firstName
          lastName
          phone
          email
          imageUrl
          roles
          language
        }
      }
    ''';

    final data = await _graphqlHttpClient.request(
      endpoint: ApiEndpoints.profileGraphql,
      document: query,
      bearerToken: accessToken,
    );

    final profileJson = data['profile'] as Map<String, dynamic>?;
    if (profileJson == null) {
      throw NetworkException('profile payload is missing');
    }

    final profile = ProfileModel.fromJson(profileJson);
    if (profile.username.isEmpty) {
      throw NetworkException('profile payload is invalid');
    }

    return profile;
  }
}
