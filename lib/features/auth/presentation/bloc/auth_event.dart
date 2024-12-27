part of 'auth_bloc.dart';

@immutable
sealed class AuthEvent {}

class AuthLogin extends AuthEvent {
  final String email;
  final String password;
  final bool isRemember;

  AuthLogin({
    required this.email,
    required this.password,
    required this.isRemember,
  });
}

class AuthRegisterUser extends AuthEvent {
  final String name;
  final String phone;
  final String email;
  final String password;
  final String confirmPassword;

  AuthRegisterUser({
    required this.name,
    required this.phone,
    required this.email,
    required this.password,
    required this.confirmPassword,
  });
}

class AuthIsUserLoggedIn extends AuthEvent {}

class AuthRememberMeStatusChecked extends AuthEvent {}

class AuthUpdateUser extends AuthEvent {
  final User user;
  AuthUpdateUser(this.user);
}

class AuthLogoutUser extends AuthEvent {}
