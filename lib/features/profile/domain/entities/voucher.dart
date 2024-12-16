class Voucher {
  final String voucherId;
  final double amount;
  final bool redeemed;
  final DateTime createdAt;

  Voucher({
    required this.voucherId,
    required this.amount,
    required this.redeemed,
    required this.createdAt,
  });
}
