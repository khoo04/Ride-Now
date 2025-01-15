import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';

abstract interface class PaymentRepository {
  Future<Either<Failure, String>> getRidePaymentLink({
    required int rideId,
    required double paymentAmount,
    required int requiredSeats,
    required String? voucherId,
  });
}
