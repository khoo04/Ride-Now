import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import 'package:ride_now_app/core/usecase/usecase.dart';
import 'package:ride_now_app/features/profile/domain/entities/voucher.dart';
import 'package:ride_now_app/features/profile/domain/usecases/get_user_vouchers.dart';

part 'voucher_event.dart';
part 'voucher_state.dart';

class VoucherBloc extends Bloc<VoucherEvent, VoucherState> {
  final GetUserVouchers _getUserVouchers;
  VoucherBloc({
    required GetUserVouchers getUserVouchers,
  })  : _getUserVouchers = getUserVouchers,
        super(VoucherInitial()) {
    on<FetchUserVouchers>(_fetchUserVouchers);
  }

  Future<void> _fetchUserVouchers(
      FetchUserVouchers event, Emitter<VoucherState> emit) async {
    emit(VoucherLoading());

    final res = await _getUserVouchers(NoParams());

    res.fold(
      (l) => emit(VoucherFailure(l.message)),
      (vouchers) => emit(VoucherDisplaySuccess(vouchers)),
    );
  }
}
