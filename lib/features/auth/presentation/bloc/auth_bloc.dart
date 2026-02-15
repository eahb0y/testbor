import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testbor/core/errors/app_exception.dart';
import 'package:testbor/features/auth/domain/usecases/check_auth_status_use_case.dart';
import 'package:testbor/features/auth/domain/usecases/login_or_signup_use_case.dart';
import 'package:testbor/features/auth/domain/usecases/logout_use_case.dart';
import 'package:testbor/features/auth/domain/usecases/request_otp_use_case.dart';
import 'package:testbor/features/auth/presentation/bloc/auth_event.dart';
import 'package:testbor/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc({
    required CheckAuthStatusUseCase checkAuthStatusUseCase,
    required RequestOtpUseCase requestOtpUseCase,
    required LoginOrSignupUseCase loginOrSignupUseCase,
    required LogoutUseCase logoutUseCase,
  }) : _checkAuthStatusUseCase = checkAuthStatusUseCase,
       _requestOtpUseCase = requestOtpUseCase,
       _loginOrSignupUseCase = loginOrSignupUseCase,
       _logoutUseCase = logoutUseCase,
       super(const AuthState.initial()) {
    on<AuthStarted>(_onStarted);
    on<OtpRequested>(_onOtpRequested);
    on<LoginSubmitted>(_onLoginSubmitted);
    on<LoggedOut>(_onLoggedOut);
    on<AuthFeedbackCleared>(_onFeedbackCleared);
  }

  final CheckAuthStatusUseCase _checkAuthStatusUseCase;
  final RequestOtpUseCase _requestOtpUseCase;
  final LoginOrSignupUseCase _loginOrSignupUseCase;
  final LogoutUseCase _logoutUseCase;

  Future<void> _onStarted(AuthStarted event, Emitter<AuthState> emit) async {
    final hasSession = await _checkAuthStatusUseCase();
    emit(
      state.copyWith(
        status: hasSession
            ? AuthStatus.authenticated
            : AuthStatus.unauthenticated,
        clearInfoMessage: true,
        clearErrorMessage: true,
      ),
    );
  }

  Future<void> _onOtpRequested(
    OtpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        otpInProgress: true,
        clearInfoMessage: true,
        clearErrorMessage: true,
      ),
    );

    try {
      await _requestOtpUseCase(event.phone);
      emit(
        state.copyWith(
          otpInProgress: false,
          infoMessage: 'Код отправлен',
          clearErrorMessage: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          otpInProgress: false,
          errorMessage: error.message,
          clearInfoMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          otpInProgress: false,
          errorMessage: 'Не удалось отправить код',
          clearInfoMessage: true,
        ),
      );
    }
  }

  Future<void> _onLoginSubmitted(
    LoginSubmitted event,
    Emitter<AuthState> emit,
  ) async {
    emit(
      state.copyWith(
        loginInProgress: true,
        clearInfoMessage: true,
        clearErrorMessage: true,
      ),
    );

    try {
      await _loginOrSignupUseCase(phone: event.phone, pinCode: event.pinCode);
      emit(
        state.copyWith(
          loginInProgress: false,
          status: AuthStatus.authenticated,
          clearInfoMessage: true,
          clearErrorMessage: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          loginInProgress: false,
          errorMessage: error.message,
          clearInfoMessage: true,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          loginInProgress: false,
          errorMessage: 'Не удалось выполнить вход',
          clearInfoMessage: true,
        ),
      );
    }
  }

  Future<void> _onLoggedOut(LoggedOut event, Emitter<AuthState> emit) async {
    await _logoutUseCase();
    emit(
      state.copyWith(
        status: AuthStatus.unauthenticated,
        clearInfoMessage: true,
        clearErrorMessage: true,
      ),
    );
  }

  void _onFeedbackCleared(AuthFeedbackCleared event, Emitter<AuthState> emit) {
    emit(state.copyWith(clearInfoMessage: true, clearErrorMessage: true));
  }
}
