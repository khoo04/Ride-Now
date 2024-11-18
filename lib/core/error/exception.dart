class ServerException implements Exception {
  final String message;
  const ServerException(this.message);
}

class ServerValidatorException implements Exception {
  final bool success;
  final String message;
  final Map<String, String> errors;

  const ServerValidatorException(this.success, this.message, this.errors);

  factory ServerValidatorException.fromJson(Map<String, dynamic> json) {
    return ServerValidatorException(
      json['success'] as bool,
      json['message'] as String,
      (json['errors'] as Map<String, dynamic>).map(
        (key, value) => MapEntry(key, (value as List).first as String),
      ),
    );
  }

  @override
  String toString() =>
      'ServerValidatorException(success: $success, message: $message, errors: $errors)';
}
