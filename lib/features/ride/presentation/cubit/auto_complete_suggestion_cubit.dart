import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ride_now_app/features/ride/domain/entities/auto_complete_prediction.dart';
import 'package:ride_now_app/features/ride/domain/usecases/fetch_location_auto_complete_suggestion.dart';

part 'auto_complete_suggestion_state.dart';

class AutoCompleteSuggestionCubit extends Cubit<AutoCompleteSuggestionState> {
  final FetchLocationAutoCompleteSuggestion
      _fetchLocationAutoCompleteSuggestion;
  AutoCompleteSuggestionCubit(
      FetchLocationAutoCompleteSuggestion fetchLocationAutoCompleteSuggestion)
      : _fetchLocationAutoCompleteSuggestion =
            fetchLocationAutoCompleteSuggestion,
        super(const AutoCompleteSuggestionInitial([]));

  Future<void> searchLocation(String query) async {
    emit(const AutoCompleteSuggestionLoading([]));
    if (query.isEmpty) {
      emit(const AutoCompleteSuggestionSuccess([]));
    }

    final res = await _fetchLocationAutoCompleteSuggestion(
        FetchLocationAutoCompleteSuggestionParams(query: query));

    res.fold((failure) {
      emit(AutoCompleteSuggestionFailure(failure.message));
    }, (searchedResult) {
      emit(AutoCompleteSuggestionSuccess(searchedResult ?? []));
    });
  }

  void resetPredictionResult() {
    emit(const AutoCompleteSuggestionInitial([]));
  }
}
