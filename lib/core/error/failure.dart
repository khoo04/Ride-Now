class Failure {
  final String message;
  final Map<String, String>? validatorErrors;
  Failure(
      [this.message = 'An unexpected error occurred', this.validatorErrors]);
}
