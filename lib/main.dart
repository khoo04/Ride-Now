import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:ride_now_app/core/common/app_wrapper.dart';
import 'package:ride_now_app/core/cubits/app_user/app_user_cubit.dart';
import 'package:ride_now_app/core/theme/theme.dart';
import 'package:ride_now_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ride_now_app/features/auth/presentation/pages/login_screen.dart';
import 'package:ride_now_app/features/auth/presentation/pages/register_screen.dart';
import 'package:ride_now_app/features/payment/presentation/pages/payment_failed_screen.dart';
import 'package:ride_now_app/features/payment/presentation/pages/payment_success_screen.dart';
import 'package:ride_now_app/features/profile/presentation/bloc/vehicle/vehicle_bloc.dart';
import 'package:ride_now_app/features/profile/presentation/bloc/voucher/voucher_bloc.dart';
import 'package:ride_now_app/features/profile/presentation/pages/manage_vehicles_screen.dart';
import 'package:ride_now_app/features/profile/presentation/pages/my_voucher_screen.dart';
import 'package:ride_now_app/features/profile/presentation/pages/register_vehicle_screen.dart';
import 'package:ride_now_app/features/profile/presentation/pages/update_profile_screen.dart';
import 'package:ride_now_app/features/profile/presentation/pages/update_vehicle_screen.dart';
import 'package:ride_now_app/features/profile/presentation/pages/vehicle_action_success_screen.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride/ride_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_create/ride_create_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_main/ride_main_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_search/ride_search_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/ride_update/ride_update_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/your_ride_list/your_ride_list_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/pages/create_ride_success_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/pick_voucher_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/update_ride_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/in_app_navigation_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/ride_detail_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/search_location_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/search_ride_result_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/search_ride_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/update_ride_success_screen.dart';
import 'package:ride_now_app/init_dependencies.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencies();
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  runApp(MultiBlocProvider(providers: [
    BlocProvider(
      create: (_) => serviceLocator<AuthBloc>(),
    ),
    BlocProvider(
      create: (_) => serviceLocator<AppUserCubit>(),
    ),
    BlocProvider(
      create: (_) => serviceLocator<VoucherBloc>(),
    ),
    BlocProvider(
      create: (_) => serviceLocator<VehicleBloc>(),
    ),
    BlocProvider(
      create: (_) => serviceLocator<RideMainBloc>(),
    ),
    BlocProvider(
      create: (_) => serviceLocator<RideSearchBloc>(),
    ),
    BlocProvider(
      create: (_) => serviceLocator<RideCreateBloc>(),
    ),
    BlocProvider(
      create: (_) => serviceLocator<RideBloc>(),
    ),
    BlocProvider(
      create: (_) => serviceLocator<RideUpdateCubit>(),
    ),
    BlocProvider(
      create: (_) => serviceLocator<YourRideListCubit>(),
    ),
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
        //Auth
        LoginScreen.routeName: (context) => const LoginScreen(),
        RegisterScreen.routeName: (context) => const RegisterScreen(),
        //Ride
        SearchRideScreen.routeName: (context) => const SearchRideScreen(),
        SearchLocationScreen.routeName: (context) =>
            const SearchLocationScreen(),
        SearchRideResultScreen.routeName: (context) =>
            const SearchRideResultScreen(),
        RideDetailScreen.routeName: (context) => const RideDetailScreen(),
        InAppNavigationScreen.routeName: (context) =>
            const InAppNavigationScreen(),
        //Profile
        RegisterVehicleScreen.routeName: (context) =>
            const RegisterVehicleScreen(),
        ManageVehiclesScreen.routeName: (context) =>
            const ManageVehiclesScreen(),
        UpdateVehicleScreen.routeName: (context) => const UpdateVehicleScreen(),
        VehicleActionSuccessScreen.routeName: (context) =>
            const VehicleActionSuccessScreen(),
        MyVoucherScreen.routeName: (context) => const MyVoucherScreen(),
        UpdateProfileScreen.routeName: (context) => const UpdateProfileScreen(),
        //Ride
        CreateRideSuccessScreen.routeName: (context) =>
            const CreateRideSuccessScreen(),
        UpdateRideScreen.routeName: (context) => const UpdateRideScreen(),
        UpdateRideSuccessScreen.routeName: (context) =>
            const UpdateRideSuccessScreen(),
        PickVoucherScreen.routeName: (context) => const PickVoucherScreen(),
        //Payment
        PaymentFailedScreen.routeName: (context) => const PaymentFailedScreen(),
        PaymentSuccessScreen.routeName : (context) => const PaymentSuccessScreen(),
      },
    );
  }
}
