import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/entities/balance_data.dart';
import 'package:ride_now_app/features/profile/domain/repositories/profile_repository.dart';

class GetUserBalance implements Usecase<BalanceData, NoParams> {
  final ProfileRepository _profileRepository;
  const GetUserBalance(this._profileRepository);
  @override
  Future<Either<Failure, BalanceData>> call(NoParams params) {
    return _profileRepository.getUserBalance();
  }
}
