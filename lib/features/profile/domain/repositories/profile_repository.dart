import 'package:testbor/features/profile/domain/entities/profile.dart';

abstract interface class ProfileRepository {
  Future<Profile> getProfile();
}
