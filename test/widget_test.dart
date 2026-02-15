import 'package:flutter_test/flutter_test.dart';
import 'package:testbor/app.dart';
import 'package:testbor/features/auth/domain/entities/user_session.dart';
import 'package:testbor/features/auth/domain/repositories/auth_repository.dart';
import 'package:testbor/features/profile/domain/entities/profile.dart';
import 'package:testbor/features/profile/domain/repositories/profile_repository.dart';

void main() {
  testWidgets('renders auth screen for anonymous user', (tester) async {
    await tester.pumpWidget(
      TestBorApp(
        authRepository: _FakeAuthRepository(),
        profileRepository: _FakeProfileRepository(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Авторизация по телефону'), findsOneWidget);
  });
}

class _FakeAuthRepository implements AuthRepository {
  @override
  Future<String?> getAccessToken() async => null;

  @override
  Future<bool> hasUserSession() async => false;

  @override
  Future<UserSession> loginOrSignup({
    required String phone,
    required String pinCode,
  }) {
    throw UnimplementedError();
  }

  @override
  Future<void> logout() async {}

  @override
  Future<void> refreshUserToken() async {}

  @override
  Future<void> requestOtp(String phone) async {}
}

class _FakeProfileRepository implements ProfileRepository {
  @override
  Future<Profile> getProfile() {
    throw UnimplementedError();
  }
}
