import 'package:fpdart/fpdart.dart';
import 'package:ride_now_app/core/error/failure.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/payment/domain/repositories/payment_repository.dart';

class GetRidePaymentLink implements Usecase<String, GetRidePaymentLinkParams> {
  final PaymentRepository _paymentRepository;
  GetRidePaymentLink(this._paymentRepository);
  @override
  Future<Either<Failure, String>> call(GetRidePaymentLinkParams params) {
    return _paymentRepository.getRidePaymentLink(
      rideId: params.rideId,
      paymentAmount: params.paymentAmount,
      requiredSeats: params.requiredSeats,
      voucherId: params.voucherId,
    );
  }
}

class GetRidePaymentLinkParams {
  final int rideId;
  final double paymentAmount;
  final int requiredSeats;
  final String? voucherId;

  GetRidePaymentLinkParams({
    required this.rideId,
    required this.paymentAmount,
    required this.requiredSeats,
    this.voucherId,
  });
}
