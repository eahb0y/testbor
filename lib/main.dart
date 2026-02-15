import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testbor/app.dart';
import 'package:testbor/core/network/graphql_http_client.dart';
import 'package:testbor/core/storage/token_storage.dart';
import 'package:testbor/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:testbor/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:testbor/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:testbor/features/profile/data/repositories/profile_repository_impl.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();
  final httpClient = http.Client();
  final graphqlHttpClient = GraphqlHttpClient(httpClient: httpClient);
  final tokenStorage = TokenStorage(sharedPreferences: sharedPreferences);

  final authRemoteDataSource = AuthRemoteDataSource(
    graphqlHttpClient: graphqlHttpClient,
  );
  final authRepository = AuthRepositoryImpl(
    remoteDataSource: authRemoteDataSource,
    tokenStorage: tokenStorage,
  );

  final profileRemoteDataSource = ProfileRemoteDataSource(
    graphqlHttpClient: graphqlHttpClient,
  );
  final profileRepository = ProfileRepositoryImpl(
    remoteDataSource: profileRemoteDataSource,
    authRepository: authRepository,
  );

  runApp(
    TestBorApp(
      authRepository: authRepository,
      profileRepository: profileRepository,
    ),
  );
}
