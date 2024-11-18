import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/auth/domain/repositories/auth_repository.dart';

class CurrentUser implements Usecase<User, NoParams> {
  final AuthRepository _authRepository;
  const CurrentUser(this._authRepository);

  @override
  Future<Either<Failure, User>> call(NoParams params) {
    return _authRepository.getCurrentUser();
  }
}
