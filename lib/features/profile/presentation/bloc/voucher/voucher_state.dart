part of 'voucher_bloc.dart';

@immutable
sealed class VoucherState {
  const VoucherState();
}

final class VoucherInitial extends VoucherState {}

final class VoucherLoading extends VoucherState {}

final class VoucherFailure extends VoucherState {
  final String message;
  const VoucherFailure(this.message);
}

final class VoucherDisplaySuccess extends VoucherState {
  final List<Voucher> vouchers;
  const VoucherDisplaySuccess(this.vouchers);
}
