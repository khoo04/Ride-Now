import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/entities/voucher.dart';
import 'package:ride_now_app/features/profile/domain/repositories/profile_repository.dart';

class GetUserVouchers implements Usecase<List<Voucher>, NoParams> {
  final ProfileRepository _profileRepository;
  const GetUserVouchers(this._profileRepository);
  @override
  Future<Either<Failure, List<Voucher>>> call(NoParams params) {
    return _profileRepository.getUserVouchers();
  }
}
