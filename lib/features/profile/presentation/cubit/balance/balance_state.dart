part of 'balance_cubit.dart';

@immutable
sealed class BalanceState {
  const BalanceState();
}

final class BalanceInitial extends BalanceState {}

final class BalanceDisplaySuccess extends BalanceState {
  final BalanceData data;
  const BalanceDisplaySuccess(this.data);
}

final class BalanceLoading extends BalanceState {}

final class BalanceDisplayFailure extends BalanceState {
  final String message;
  const BalanceDisplayFailure(this.message);
}
