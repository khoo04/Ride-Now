import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:ride_now_app/core/common/app_wrapper.dart';
import 'package:ride_now_app/core/cubits/app_user/app_user_cubit.dart';
import 'package:ride_now_app/core/theme/theme.dart';
import 'package:ride_now_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ride_now_app/features/auth/presentation/pages/login_screen.dart';
import 'package:ride_now_app/features/auth/presentation/pages/register_screen.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_main/ride_main_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/auto_complete_suggestion_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/pages/search_location_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/search_ride_screen.dart';
import 'package:ride_now_app/init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  runApp(MultiBlocProvider(providers: [
    BlocProvider(
      create: (_) => serviceLocator<AuthBloc>(),
    ),
    BlocProvider(
      create: (_) => serviceLocator<AppUserCubit>(),
    ),
    BlocProvider(
      create: (_) => serviceLocator<RideMainBloc>(),
    ),
    BlocProvider(
      create: (_) => serviceLocator<AutoCompleteSuggestionCubit>(),
    )
  ], child: const MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(AuthIsUserLoggedIn());
  }

  @override
  void dispose() {
    context.read<AuthBloc>().add(AuthRememberMeStatusChecked());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Ride Now',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightThemeMode,
      home: const LoaderOverlay(child: AppWrapper()),
      routes: {
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        SearchRideScreen.routeName: (context) => const SearchRideScreen(),
        SearchLocationScreen.routeName: (context) =>
            const SearchLocationScreen(),
      },
    );
  }
}
