part of 'payment_cubit.dart';

@immutable
sealed class PaymentState {
  const PaymentState();
}

final class PaymentInitial extends PaymentState {
  const PaymentInitial();
}

final class PaymentInitSuccess extends PaymentState {
  final String paymentLink;

  const PaymentInitSuccess(this.paymentLink);
}

final class PaymentInitFailed extends PaymentState {
  final String message;
  const PaymentInitFailed(this.message);
}

final class PaymentLoading extends PaymentState {}

final class PaymentSuccess extends PaymentState {}

final class PaymentFailure extends PaymentState {}
