part of 'profile_cubit.dart';

@immutable
sealed class ProfileState {
  const ProfileState();
}

final class ProfileInitial extends ProfileState {}

final class ProfileUpdateSuccess extends ProfileState {
  final User user;
  const ProfileUpdateSuccess(this.user);
}

final class ProfileUpdateLoading extends ProfileState {}

final class ProfileUpdateFailure extends ProfileState {
  final Map<String, String>? validationErrors;
  final String? message;
  const ProfileUpdateFailure({this.message, this.validationErrors});
}
