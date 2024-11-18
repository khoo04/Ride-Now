import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/auth/domain/repositories/auth_repository.dart';

class UserRememberMeStatusChecked implements Usecase<String, NoParams> {
  final AuthRepository _authRepository;
  const UserRememberMeStatusChecked(this._authRepository);
  @override
  Future<Either<Failure, String>> call(NoParams params) {
    return _authRepository.rememberMeStatusChecked();
  }
}
