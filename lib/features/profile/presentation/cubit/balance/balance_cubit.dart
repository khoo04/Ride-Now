import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/entities/balance_data.dart';
import 'package:ride_now_app/features/profile/domain/usecases/get_user_balance.dart';

part 'balance_state.dart';

class BalanceCubit extends Cubit<BalanceState> {
  final GetUserBalance _getUserBalance;
  BalanceCubit({required GetUserBalance getUserBalance})
      : _getUserBalance = getUserBalance,
        super(BalanceInitial());

  Future<void> initalizeUserBalance() async {
    emit(BalanceLoading());

    final res = await _getUserBalance(NoParams());

    res.fold(
      (failure) => emit(BalanceDisplayFailure(failure.message)),
      (data) => emit(BalanceDisplaySuccess(data)),
    );
  }
}
