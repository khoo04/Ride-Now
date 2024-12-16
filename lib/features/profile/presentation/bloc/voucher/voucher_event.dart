part of 'voucher_bloc.dart';

@immutable
sealed class VoucherEvent {}

class FetchUserVouchers extends VoucherEvent {}
