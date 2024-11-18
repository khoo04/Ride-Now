part of 'ride_main_bloc.dart';

@immutable
sealed class RideMainEvent {}

class InitFetchRide extends RideMainEvent {}

class RetrieveAvailabeRides extends RideMainEvent {}
