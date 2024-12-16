import 'package:ride_now_app/core/utils/round_cost.dart';

double calculateRidePrice({
  required double baseCost,
  required int currentPassengersCount,
  required int requiredSeats,
  double? voucherAmount,
}) {
  // Step 1: Calculate discounted cost 20% discount for next passengers
  double discountedCost = roundToNearestFiveCents(baseCost * 0.8);

  // Step 2: Determine amount to pay before charges
  double subtotal;
  if (currentPassengersCount > 1) {
    // Case: Ride already has one or more passengers
    subtotal = discountedCost * requiredSeats;
  } else {
    // Case: Ride has no passengers
    subtotal = baseCost + discountedCost * (requiredSeats - 1);
  }

  // Step 3: Apply voucher (if available)
  if (voucherAmount != null) {
    subtotal = (subtotal - voucherAmount).clamp(0, double.infinity);
  }
  double amountShouldPay;
  // Step 4: Apply platform charge (5%)
  final double platformCharge = roundToNearestFiveCents(subtotal * 0.05);

  amountShouldPay = subtotal + platformCharge;

  // Step 5: Add bank service charge
  amountShouldPay += 0.70;

  // Step 6: Round to nearest 5 cents
  amountShouldPay = roundToNearestFiveCents(amountShouldPay);

  return amountShouldPay;
}
