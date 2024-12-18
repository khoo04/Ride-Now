import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/auth/domain/repositories/auth_repository.dart';

class GetBroadcastingAuthToken
    implements Usecase<String, GetBroadcastingAuthTokenParams> {
  final AuthRepository _authRepository;
  GetBroadcastingAuthToken(this._authRepository);
  @override
  Future<Either<Failure, String>> call(GetBroadcastingAuthTokenParams params) {
    return _authRepository.getBroadcastingAuthToken(
      channelName: params.channelName,
      socketId: params.socketId,
    );
  }
}

class GetBroadcastingAuthTokenParams {
  final String channelName;
  final String socketId;

  GetBroadcastingAuthTokenParams({
    required this.channelName,
    required this.socketId,
  });
}
