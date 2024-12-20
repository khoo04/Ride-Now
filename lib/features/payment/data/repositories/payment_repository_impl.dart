import 'package:fpdart/src/either.dart';
import 'package:ride_now_app/core/constants/constants.dart';
import 'package:ride_now_app/core/error/exception.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/network/connection_checker.dart';
import 'package:ride_now_app/features/payment/data/datasources/payment_remote_data_source.dart';
import 'package:ride_now_app/features/payment/domain/repositories/payment_repository.dart';

class PaymentRepositoryImpl implements PaymentRepository {
  final PaymentRemoteDataSource _paymentRemoteDataSource;
  final ConnectionChecker _connectionChecker;

  PaymentRepositoryImpl(this._paymentRemoteDataSource, this._connectionChecker);

  @override
  Future<Either<Failure, String>> getRidePaymentLink({
    required int rideId,
    required double paymentAmount,
    required int requiredSeats,
  }) async {
    try {
      if (!await (_connectionChecker.isConnected)) {
        return left(Failure(Constants.noConnectionErrorMessage));
      }
      final paymentLink = await _paymentRemoteDataSource.getRidePaymentLink(
          rideId: rideId,
          paymentAmount: paymentAmount,
          requiredSeats: requiredSeats);

      return right(paymentLink);
    } on ServerException catch (e) {
      return left(Failure(e.message));
    }
  }
}
