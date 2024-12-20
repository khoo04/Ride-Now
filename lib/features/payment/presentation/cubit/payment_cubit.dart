import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ride_now_app/features/payment/domain/usecases/get_ride_payment_link.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';

part 'payment_state.dart';

class PaymentCubit extends Cubit<PaymentState> {
  final GetRidePaymentLink _getRidePaymentLink;
  PaymentCubit({
    required GetRidePaymentLink getRidePaymentLink,
  })  : _getRidePaymentLink = getRidePaymentLink,
        super(const PaymentInitial());

  Future<PaymentState> initializePayment({
    required int rideId,
    required double paymentAmount,
    required int requiredSeats,
  }) async {
    final res = await _getRidePaymentLink(
      GetRidePaymentLinkParams(
        rideId: rideId,
        paymentAmount: paymentAmount,
        requiredSeats: requiredSeats,
      ),
    );

    res.fold(
      (l) => emit(PaymentInitFailed(l.message)),
      (paymentLink) => emit(PaymentInitSuccess(paymentLink)),
    );

    return state;
  }

  void setRequestProcessing() {
    emit(PaymentLoading());
  }

  void setPaymentSuccess() {
    emit(PaymentSuccess());
  }

  void setPaymentFailed() {
    emit(PaymentFailure());
  }
}
