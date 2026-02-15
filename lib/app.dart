import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testbor/features/auth/domain/repositories/auth_repository.dart';
import 'package:testbor/features/auth/domain/usecases/check_auth_status_use_case.dart';
import 'package:testbor/features/auth/domain/usecases/login_or_signup_use_case.dart';
import 'package:testbor/features/auth/domain/usecases/logout_use_case.dart';
import 'package:testbor/features/auth/domain/usecases/request_otp_use_case.dart';
import 'package:testbor/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:testbor/features/auth/presentation/bloc/auth_event.dart';
import 'package:testbor/features/auth/presentation/bloc/auth_state.dart';
import 'package:testbor/features/auth/presentation/pages/auth_page.dart';
import 'package:testbor/features/profile/domain/repositories/profile_repository.dart';
import 'package:testbor/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:testbor/features/profile/presentation/bloc/profile_bloc.dart';
import 'package:testbor/features/profile/presentation/pages/home_page.dart';

class TestBorApp extends StatelessWidget {
  const TestBorApp({
    super.key,
    required this.authRepository,
    required this.profileRepository,
  });

  final AuthRepository authRepository;
  final ProfileRepository profileRepository;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (_) => AuthBloc(
            checkAuthStatusUseCase: CheckAuthStatusUseCase(authRepository),
            requestOtpUseCase: RequestOtpUseCase(authRepository),
            loginOrSignupUseCase: LoginOrSignupUseCase(authRepository),
            logoutUseCase: LogoutUseCase(authRepository),
          )..add(const AuthStarted()),
        ),
        BlocProvider<ProfileBloc>(
          create: (_) => ProfileBloc(
            getProfileUseCase: GetProfileUseCase(profileRepository),
          ),
        ),
      ],
      child: MaterialApp(
        title: 'TestBor',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        ),
        home: const _RootPage(),
      ),
    );
  }
}

class _RootPage extends StatelessWidget {
  const _RootPage();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.checking:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.unauthenticated:
            return const AuthPage();
          case AuthStatus.authenticated:
            return const HomePage();
        }
      },
    );
  }
}
