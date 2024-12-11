import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:ride_now_app/core/common/app_frame.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/cubits/app_user/app_user_cubit.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ride_now_app/features/auth/presentation/pages/splash_screen.dart';

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoading) {
          context.loaderOverlay.show();
        } else {
          context.loaderOverlay.hide();
        }
      },
      child: BlocSelector<AppUserCubit, AppUserState, User?>(selector: (state) {
        if (state is AppUserLoggedIn) {
   
          return state.user;
        }
        return null;
      }, builder: (context, user) {
        return user != null ? const AppFrame() : const SplashScreen();
      }),
    );
  }
}
