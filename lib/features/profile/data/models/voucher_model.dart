import 'package:ride_now_app/features/profile/domain/entities/voucher.dart';

class VoucherModel extends Voucher {
  VoucherModel({
    required super.voucherId,
    required super.amount,
    required super.redeemed,
    required super.createdAt,
  });

  factory VoucherModel.fromJson(Map<String, dynamic> json) {
    return VoucherModel(
      voucherId: json["voucher_id"],
      amount: json["amount"],
      redeemed: json["redeemed"],
      createdAt: json["created_at"],
    );
  }

  @override
  String toString() {
    return 'VoucherModel(voucherId: $voucherId, amount:$amount, redeemed:$redeemed, created_at:$createdAt )';
  }
}
