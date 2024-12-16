part of 'ride_main_bloc.dart';

@immutable
sealed class FetchRideState {
  const FetchRideState();
}

final class FetchRideInitial extends FetchRideState {}

final class FetchRideLoading extends FetchRideState {}

final class FetchRideSuccess extends FetchRideState {
  final int currentPage;
  final List<Ride> rides;
  final bool isEnd;

  const FetchRideSuccess({
    required this.rides,
    required this.isEnd,
    required this.currentPage,
  });

  FetchRideSuccess copyWith({
    List<Ride>? rides,
    bool? isEnd,
    int? currentPage,
  }) {
    return FetchRideSuccess(
      rides: rides ?? this.rides,
      isEnd: isEnd ?? this.isEnd,
      currentPage: currentPage ?? this.currentPage,
    );
  }
}

final class FetchRideFailure extends FetchRideState {
  final String message;
  const FetchRideFailure(this.message);
}
