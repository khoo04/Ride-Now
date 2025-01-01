import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/features/profile/data/models/balance_record_model.dart';
import 'package:ride_now_app/features/profile/data/models/graph_model.dart';
import 'package:ride_now_app/features/profile/domain/entities/balance_data.dart';

class BalanceDataModel extends BalanceData {
  BalanceDataModel({
    required super.totalBalance,
    required super.totalUncreditBalance,
    required super.totalCreditedBalance,
    required super.totalEarningsBalance,
    required super.currentMonthTotalEarnings,
    required super.totalEarningsGraphEntries,
    required super.earningsRecord,
    required super.totalRefundBalance,
    required super.refundRecord,
  });

  factory BalanceDataModel.fromJson(Map<String, dynamic> json) {
    return BalanceDataModel(
      totalBalance: (json["total_balance"] as num).toDouble(),
      totalUncreditBalance:
          (json["total_uncredited_balance"] as num).toDouble(),
      totalCreditedBalance: (json["total_credited_balance"] as num).toDouble(),
      totalEarningsBalance: (json["total_earnings_balance"] as num).toDouble(),
      currentMonthTotalEarnings: CurrentMonthTotalEarningsModel.fromJson(
          json["current_month_total_earnings"]),
      totalEarningsGraphEntries: (json['total_earnings_graph_data'] as List)
          .map((item) => GraphEntryModel.fromJson(item))
          .toList(),
      earningsRecord: (json['earnings_records'] as List)
          .map((item) => BalanceRecordModel.fromJson(item))
          .toList(),
      totalRefundBalance: (json['total_refund_balance'] as num).toDouble(),
      refundRecord: (json['refunds_records'] as List)
          .map((item) => BalanceRecordModel.fromJson(item))
          .toList(),
    );
  }
}

class CurrentMonthTotalEarningsModel extends CurrentMonthTotalEarnings {
  CurrentMonthTotalEarningsModel({
    required super.yearMonth,
    required super.earnings,
  });

  factory CurrentMonthTotalEarningsModel.fromJson(Map<String, dynamic> json) {
    return CurrentMonthTotalEarningsModel(
      yearMonth: DateTime.parse(json["year_month"]),
      earnings: (json["earnings"] as num).toDouble(),
    );
  }
}
