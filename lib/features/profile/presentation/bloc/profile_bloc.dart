import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:testbor/core/errors/app_exception.dart';
import 'package:testbor/features/profile/domain/usecases/get_profile_use_case.dart';
import 'package:testbor/features/profile/presentation/bloc/profile_event.dart';
import 'package:testbor/features/profile/presentation/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({required GetProfileUseCase getProfileUseCase})
    : _getProfileUseCase = getProfileUseCase,
      super(const ProfileState()) {
    on<ProfileRequested>(_onProfileRequested);
  }

  final GetProfileUseCase _getProfileUseCase;

  Future<void> _onProfileRequested(
    ProfileRequested event,
    Emitter<ProfileState> emit,
  ) async {
    emit(state.copyWith(status: ProfileStatus.loading, clearError: true));

    try {
      final profile = await _getProfileUseCase();
      emit(
        state.copyWith(
          status: ProfileStatus.loaded,
          profile: profile,
          clearError: true,
        ),
      );
    } on AppException catch (error) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: error.message,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          status: ProfileStatus.error,
          errorMessage: 'Не удалось загрузить профиль',
        ),
      );
    }
  }
}
