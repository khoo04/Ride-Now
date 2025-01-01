import 'package:ride_now_app/features/profile/domain/entities/balance_record.dart';

class BalanceRecordModel extends BalanceRecord {
  BalanceRecordModel({
    required super.createdDateTime,
    required super.status,
    required super.amount,
  });

  factory BalanceRecordModel.fromJson(Map<String, dynamic> json) {
    return BalanceRecordModel(
      createdDateTime: DateTime.parse(json["created_date_time"]),
      status: json["status"],
      amount: (json['amount'] as num).toDouble(),
    );
  }
}
