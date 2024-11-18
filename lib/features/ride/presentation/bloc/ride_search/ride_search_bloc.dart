import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';

part 'ride_search_event.dart';
part 'ride_search_state.dart';

class RideSearchBloc extends Bloc<RideSearchEvent, RideSearchState> {
  RideSearchBloc() : super(RideSearchInitial()) {
    on<RideSearchEvent>((event, emit) {
      // TODO: implement event handler
    });
  }
}
