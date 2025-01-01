import 'package:ride_now_app/features/profile/domain/entities/balance_record.dart';
import 'package:ride_now_app/features/profile/domain/entities/graph.dart';

class BalanceData {
  final double totalBalance;
  final double totalUncreditBalance;
  final double totalCreditedBalance;
  final double totalEarningsBalance;
  final CurrentMonthTotalEarnings currentMonthTotalEarnings;
  //Current year data
  final List<GraphEntry> totalEarningsGraphEntries;
  final List<BalanceRecord> earningsRecord;
  final double totalRefundBalance;
  final List<BalanceRecord> refundRecord;

  BalanceData({
    required this.totalBalance,
    required this.totalUncreditBalance,
    required this.totalCreditedBalance,
    required this.totalEarningsBalance,
    required this.currentMonthTotalEarnings,
    required this.totalEarningsGraphEntries,
    required this.earningsRecord,
    required this.totalRefundBalance,
    required this.refundRecord,
  });
}

class CurrentMonthTotalEarnings {
  final DateTime yearMonth;
  final double earnings;

  CurrentMonthTotalEarnings({
    required this.yearMonth,
    required this.earnings,
  });
}
