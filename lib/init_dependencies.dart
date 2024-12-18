import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:ride_now_app/core/cubits/app_user/app_user_cubit.dart';
import 'package:ride_now_app/core/network/connection_checker.dart';
import 'package:ride_now_app/core/network/network_client.dart';
import 'package:ride_now_app/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:ride_now_app/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:ride_now_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:ride_now_app/features/auth/domain/usecases/current_user.dart';
import 'package:ride_now_app/features/auth/domain/usecases/user_login.dart';
import 'package:ride_now_app/features/auth/domain/usecases/user_logout.dart';
import 'package:ride_now_app/features/auth/domain/usecases/user_register.dart';
import 'package:ride_now_app/features/auth/domain/usecases/user_remember_me_status_checked.dart';
import 'package:ride_now_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ride_now_app/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:ride_now_app/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:ride_now_app/features/profile/domain/repositories/profile_repository.dart';
import 'package:ride_now_app/features/profile/domain/usecases/create_vehicle.dart';
import 'package:ride_now_app/features/profile/domain/usecases/delete_vehicle.dart';
import 'package:ride_now_app/features/profile/domain/usecases/get_user_vehicles.dart';
import 'package:ride_now_app/features/profile/domain/usecases/get_user_vouchers.dart';
import 'package:ride_now_app/features/profile/domain/usecases/update_vehicle.dart';
import 'package:ride_now_app/features/profile/presentation/bloc/vehicle/vehicle_bloc.dart';
import 'package:ride_now_app/features/profile/presentation/bloc/voucher/voucher_bloc.dart';
import 'package:ride_now_app/features/ride/data/datasources/ride_remote_data_source.dart';
import 'package:ride_now_app/features/ride/data/repositories/ride_repository_impl.dart';
import 'package:ride_now_app/features/ride/domain/repositories/ride_repository.dart';
import 'package:ride_now_app/features/ride/domain/usecases/cancel_ride.dart';
import 'package:ride_now_app/features/ride/domain/usecases/create_ride.dart';
import 'package:ride_now_app/features/ride/domain/usecases/fetch_available_rides.dart';
import 'package:ride_now_app/features/ride/domain/usecases/fetch_location_auto_complete_suggestion.dart';
import 'package:ride_now_app/features/ride/domain/usecases/fetch_place_details.dart';
import 'package:ride_now_app/features/ride/domain/usecases/fetch_ride_by_id.dart';
import 'package:ride_now_app/features/ride/domain/usecases/geocoding_fetch_place_details.dart';
import 'package:ride_now_app/features/auth/domain/usecases/get_broadcasting_auth_token.dart';
import 'package:ride_now_app/features/ride/domain/usecases/get_ride_cost_suggestion.dart';
import 'package:ride_now_app/features/ride/domain/usecases/get_user_created_rides.dart';
import 'package:ride_now_app/features/ride/domain/usecases/get_user_joined_rides.dart';
import 'package:ride_now_app/features/ride/domain/usecases/search_available_rides.dart';
import 'package:ride_now_app/features/ride/domain/usecases/update_ride.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride/ride_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_create/ride_create_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_main/ride_main_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_search/ride_search_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/ride_update/ride_update_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/your_ride_list/your_ride_list_cubit.dart';

part 'init_dependencies_main.dart';
