class AppResponse {
  final bool success;
  final String message;
  final dynamic data;

  AppResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      'success': success,
      'message': message,
      'data': data,
    };
  }

  factory AppResponse.fromJson(Map<String, dynamic> map) {
    return AppResponse(
      success: map['success'] as bool,
      message: map['message'] as String,
      data: map['data'],
    );
  }
}
