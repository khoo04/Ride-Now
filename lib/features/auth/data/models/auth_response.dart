class AuthResponse {
  final bool? success;
  final String? message;
  final dynamic data;
  final String? accessToken;

  AuthResponse({
    required this.success,
    required this.message,
    required this.data,
    required this.accessToken,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'message': message,
      'data': data,
      'accessToken': accessToken,
    };
  }

  factory AuthResponse.fromJson(Map<String, dynamic> map) {
    return AuthResponse(
      success: map['success'] as bool?,
      message: map['message'] as String?,
      data: map['data'],
      accessToken: map['access_token'] as String?,
    );
  }
}
