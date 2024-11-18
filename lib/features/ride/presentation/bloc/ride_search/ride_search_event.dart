part of 'ride_search_bloc.dart';

@immutable
sealed class RideSearchEvent {}

class LocationAutoCompleteSuggestion extends RideSearchEvent {
  final String query;
  LocationAutoCompleteSuggestion(this.query);
}
