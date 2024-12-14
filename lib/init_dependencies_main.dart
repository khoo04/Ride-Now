part of 'init_dependencies.dart';

final serviceLocator = GetIt.instance;

Future<void> initDependencies() async {
  _initUtils();
  _initAuth();
  _initRide();
  _initProfile();

  serviceLocator.registerLazySingleton(() => AppUserCubit());
}

void _initUtils() {
  Dio dio = Dio();

  dio.options = BaseOptions(
    connectTimeout: const Duration(seconds: 10),
    headers: {
      "Accept": "application/json",
    },
  );

  //Debugging use
  dio.interceptors.add(
    PrettyDioLogger(
      requestBody: true,
      error: true,
      request: true,
      compact: true,
      maxWidth: 90,
      requestHeader: true,
      responseBody: true,
      responseHeader: false,
    ),
  );

  serviceLocator
    ..registerSingleton<NetworkClient>(
      NetworkClient(dio),
    )
    ..registerSingleton<FlutterSecureStorage>(
      const FlutterSecureStorage(
        aOptions: AndroidOptions(
          encryptedSharedPreferences: true,
        ),
      ),
    )
    ..registerFactory<InternetConnection>(
      () => InternetConnection(),
    )
    ..registerFactory<ConnectionChecker>(
        () => ConnectionCheckerImpl(serviceLocator<InternetConnection>()));
}

void _initAuth() {
  serviceLocator
    ..registerFactory<AuthRemoteDataSource>(
      () => AuthRemoteDataSourceImpl(
        serviceLocator<NetworkClient>(),
        serviceLocator<FlutterSecureStorage>(),
      ),
    )
    ..registerFactory<AuthRepository>(
      () => AuthRepositoryImpl(
        serviceLocator<AuthRemoteDataSource>(),
        serviceLocator<ConnectionChecker>(),
        serviceLocator<FlutterSecureStorage>(),
      ),
    )
    //Use Case

    ..registerFactory(
      () => UserLogin(
        serviceLocator<AuthRepository>(),
      ),
    )
    ..registerFactory(
      () => CurrentUser(
        serviceLocator<AuthRepository>(),
      ),
    )
    ..registerFactory(
      () => UserLogout(
        serviceLocator<AuthRepository>(),
      ),
    )
    ..registerFactory(
      () => UserRememberMeStatusChecked(
        serviceLocator<AuthRepository>(),
      ),
    )
    ..registerFactory(
      () => UserRegister(
        serviceLocator<AuthRepository>(),
      ),
    )
    .. //Bloc use Lazy Singleton, so that the state will not lose
        registerLazySingleton(
      () => AuthBloc(
        appUserCubit: serviceLocator<AppUserCubit>(),
        currentUser: serviceLocator<CurrentUser>(),
        userLogin: serviceLocator<UserLogin>(),
        userRegister: serviceLocator<UserRegister>(),
        userRememberMeStatusChecked:
            serviceLocator<UserRememberMeStatusChecked>(),
        userLogout: serviceLocator<UserLogout>(),
      ),
    );
}

void _initRide() {
  serviceLocator
    ..registerFactory<RideRemoteDataSource>(
      () => RideRemoteDataSourceImpl(
        serviceLocator<NetworkClient>(),
        serviceLocator<FlutterSecureStorage>(),
      ),
    )
    ..registerFactory<RideRepository>(
      () => RideRepositoryImpl(
        serviceLocator<RideRemoteDataSource>(),
        serviceLocator<ConnectionChecker>(),
      ),
    )
    //Use Case
    ..registerFactory(
      () => FetchAvailableRides(
        serviceLocator<RideRepository>(),
      ),
    )
    ..registerFactory(
      () => FetchLocationAutoCompleteSuggestion(
        serviceLocator<RideRepository>(),
      ),
    )
    ..registerFactory(
      () => FetchPlaceDetails(
        serviceLocator<RideRepository>(),
      ),
    )
    ..registerFactory(
      () => GeocodingFetchPlaceDetails(
        serviceLocator<RideRepository>(),
      ),
    )
    ..registerFactory(
      () => SearchAvailableRides(
        serviceLocator<RideRepository>(),
      ),
    )
    ..registerFactory(
      () => FetchRideById(
        serviceLocator<RideRepository>(),
      ),
    )
    ..registerFactory(
      () => GetRideCostSuggestion(
        serviceLocator<RideRepository>(),
      ),
    )
    ..registerFactory(
      () => CreateRide(
        serviceLocator<RideRepository>(),
      ),
    )
    ..registerFactory(
      () => UpdateRide(
        serviceLocator<RideRepository>(),
      ),
    )
    ..registerFactory(
      () => GetUserCreatedRides(
        serviceLocator<RideRepository>(),
      ),
    )
    ..registerFactory(
      () => GetUserJoinedRides(
        serviceLocator<RideRepository>(),
      ),
    )
    ..registerFactory(
      () => CancelRide(
        serviceLocator<RideRepository>(),
      ),
    )
    //Bloc
    ..registerLazySingleton(
      () => RideMainBloc(
        fetchAvailableRides: serviceLocator<FetchAvailableRides>(),
      ),
    )
    ..registerLazySingleton(
      () => RideSearchBloc(
        searchAvailableRides: serviceLocator<SearchAvailableRides>(),
      ),
    )
    ..registerLazySingleton(
      () => RideBloc(
        fetchRideById: serviceLocator<FetchRideById>(),
        cancelRide: serviceLocator<CancelRide>(),
      ),
    )
    ..registerLazySingleton(
      () => RideCreateBloc(
        getUserVehicles: serviceLocator<GetUserVehicles>(),
        getRideCostSuggestion: serviceLocator<GetRideCostSuggestion>(),
        createRide: serviceLocator<CreateRide>(),
      ),
    )
    ..registerLazySingleton(
      () => RideUpdateCubit(
        getUserVehicles: serviceLocator<GetUserVehicles>(),
        updateRide: serviceLocator<UpdateRide>(),
        getRideCostSuggestion: serviceLocator<GetRideCostSuggestion>(),
      ),
    )
    ..registerLazySingleton(
      () => RideListCubit(
        getUserCreatedRides: serviceLocator<GetUserCreatedRides>(),
        getUserJoinedRides: serviceLocator<GetUserJoinedRides>(),
      ),
    );
}

void _initProfile() {
  serviceLocator
    ..registerFactory<ProfileRemoteDataSource>(
      () => ProfileRemoteDataSourceImpl(
        serviceLocator<NetworkClient>(),
        serviceLocator<FlutterSecureStorage>(),
      ),
    )
    ..registerFactory<ProfileRepository>(
      () => ProfileRepositoryImpl(
        serviceLocator<ProfileRemoteDataSource>(),
        serviceLocator<ConnectionChecker>(),
      ),
    )
    //Use Case
    ..registerFactory(
      () => GetUserVehicles(
        serviceLocator<ProfileRepository>(),
      ),
    )
    ..registerFactory(
      () => CreateVehicle(
        serviceLocator<ProfileRepository>(),
      ),
    )
    ..registerFactory(
      () => UpdateVehicle(
        serviceLocator<ProfileRepository>(),
      ),
    )
    ..registerFactory(
      () => DeleteVehicle(
        serviceLocator<ProfileRepository>(),
      ),
    )
    ..registerLazySingleton(
      () => VehicleBloc(
        getUserVehicles: serviceLocator<GetUserVehicles>(),
        createVehicle: serviceLocator<CreateVehicle>(),
        updateVehicle: serviceLocator<UpdateVehicle>(),
        deleteVehicle: serviceLocator<DeleteVehicle>(),
      ),
    );
}
