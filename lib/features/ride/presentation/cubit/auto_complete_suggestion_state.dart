part of 'auto_complete_suggestion_cubit.dart';

@immutable
sealed class AutoCompleteSuggestionState {
  final List<AutoCompletePrediction> predictions;

  const AutoCompleteSuggestionState(this.predictions);
}

final class AutoCompleteSuggestionInitial extends AutoCompleteSuggestionState {
  const AutoCompleteSuggestionInitial(super.predictions);
}

final class AutoCompleteSuggestionSuccess extends AutoCompleteSuggestionState {
  const AutoCompleteSuggestionSuccess(super.predictions);
}

final class AutoCompleteSuggestionLoading extends AutoCompleteSuggestionState {
  const AutoCompleteSuggestionLoading(super.predictions);
}

final class AutoCompleteSuggestionFailure extends AutoCompleteSuggestionState {
  final String message;
  AutoCompleteSuggestionFailure(this.message) : super([]);
}
