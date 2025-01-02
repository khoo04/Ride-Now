import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/constants/constants.dart';
import 'package:ride_now_app/core/cubits/app_user/app_user_cubit.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/features/auth/domain/usecases/current_user.dart';
import 'package:ride_now_app/features/auth/domain/usecases/user_login.dart';
import 'package:ride_now_app/features/auth/domain/usecases/user_logout.dart';
import 'package:ride_now_app/features/auth/domain/usecases/user_register.dart';
import 'package:ride_now_app/features/auth/domain/usecases/user_remember_me_status_checked.dart';
import 'package:ride_now_app/init_dependencies.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  //Use Cases
  final UserLogin _userLogin;
  final UserRegister _userRegister;
  final CurrentUser _currentUser;
  final UserLogout _userLogout;
  final UserRememberMeStatusChecked _userRememberMeStatusChecked;
  //Cubits
  final AppUserCubit _appUserCubit;

  AuthBloc({
    required UserLogin userLogin,
    required UserRegister userRegister,
    required CurrentUser currentUser,
    required AppUserCubit appUserCubit,
    required UserLogout userLogout,
    required UserRememberMeStatusChecked userRememberMeStatusChecked,
  })  : _userLogin = userLogin,
        _userRegister = userRegister,
        _currentUser = currentUser,
        _appUserCubit = appUserCubit,
        _userLogout = userLogout,
        _userRememberMeStatusChecked = userRememberMeStatusChecked,
        super(AuthInitial()) {
    on<AuthEvent>((event, emit) {
      emit(AuthLoading());
    });
    on<AuthLogin>(_onAuthLogin);
    on<AuthIsUserLoggedIn>(_onUserIsLoggedIn);
    on<AuthLogoutUser>(_onLogoutUser);
    on<AuthRegisterUser>(_onRegisterUser);
    on<AuthRememberMeStatusChecked>(_onRememberMeStatusChecked);
    on<AuthUpdateUser>(_onAuthUpdateUser);
    on<AuthUserSessionExpired>(_onAuthUserSessionExpired);
  }

  _onAuthLogin(AuthLogin event, Emitter<AuthState> emit) async {
    final res = await _userLogin(UserLoginParams(
      email: event.email,
      password: event.password,
      isRemember: event.isRemember,
    ));

    /// Left = Failure, Right = Success
    res.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (user) {
      _emitAuthSuccess(user, emit);
    });
  }

  _onUserIsLoggedIn(AuthIsUserLoggedIn event, Emitter<AuthState> emit) async {
    final res = await _currentUser(NoParams());

    res.fold((failure) {
      emit(AuthFailure(failure.message));
    }, (user) {
      _emitAuthSuccess(user, emit);
    });
  }

  _onRememberMeStatusChecked(
      AuthRememberMeStatusChecked event, Emitter<AuthState> emit) async {
    final res = await _userRememberMeStatusChecked(NoParams());
    res.fold(
      (failure) => emit(AuthFailure(failure.message)),
      (success) => emit(AuthInitial()),
    );
  }

  _onLogoutUser(AuthLogoutUser event, Emitter<AuthState> emit) async {
    final res = await _userLogout(NoParams());
    res.fold(
      (l) => emit(AuthFailure(l.message)),
      (r) {
        emit(AuthInitial());
        _appUserCubit.updateUser(null);
      },
    );
  }

  _onRegisterUser(AuthRegisterUser event, Emitter<AuthState> emit) async {
    final res = await _userRegister(
      UserRegisterParams(
        name: event.name,
        phone: event.phone,
        email: event.email,
        password: event.password,
        confirmPassword: event.confirmPassword,
      ),
    );

    res.fold(
      (failure) {
        //Validator Error emit state with validator errors
        if (failure.validatorErrors != null) {
          emit(AuthRegisterFailure(failure.validatorErrors!));
        } else {
          emit(AuthFailure(failure.message));
        }
      },
      (r) => _emitAuthSuccess(r, emit),
    );
  }

  void _onAuthUpdateUser(AuthUpdateUser event, Emitter<AuthState> emit) {
    _emitAuthSuccess(event.user, emit);
  }

  Future<void> _onAuthUserSessionExpired(
      AuthUserSessionExpired event, Emitter<AuthState> emit) async {
    final flutterSecureStorage = serviceLocator<FlutterSecureStorage>();
    await flutterSecureStorage.write(key: "isRemember", value: null);
    await flutterSecureStorage.delete(key: "access_token");

    emit(const AuthFailure(Constants.sessionExpired));
    emit(AuthInitial());
    _appUserCubit.updateUser(null);
  }

  void _emitAuthSuccess(User user, Emitter<AuthState> emit) {
    _appUserCubit.updateUser(user);
    emit(AuthSuccess(user));
  }
}
