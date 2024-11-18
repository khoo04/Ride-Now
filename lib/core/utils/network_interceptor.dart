import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';

//TODO: Plan to implement it
class NetworkInterceptor implements Interceptor {
  @override
  void onRequest(
      RequestOptions options, RequestInterceptorHandler handler) async {
    if (options.headers['requires-token'] == true) {
      final storage = GetIt.instance<FlutterSecureStorage>();
      final accessToken = await storage.read(key: "access_token");
      options.headers.addAll({"Authorization": "$accessToken"});
    }

    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // navigate to the authentication screen
      return handler.reject(
        DioException(
          requestOptions: err.requestOptions,
          error: 'The user has been deleted or the session is expired',
        ),
      );
    }
    return handler.next(err);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
// check if the response is in standard format
/* 
The format we want our response might be
{
"success": true/false,
"data":{} or [] or null,
"message": "There is data" or "The data couldnot be found"
}  
Let us validate 
*/
    final responseData = response.data;
    if (responseData is Map &&
        (responseData.keys.every(
          (e) => ['success', 'data', 'message'].contains(e),
        ))) {
      return handler.next(response);
    }
    return handler.reject(
      DioException(
        requestOptions: response.requestOptions,
        error: 'The response is not in valid format',
      ),
    );
  }
}
