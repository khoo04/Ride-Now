double roundToNearestFiveCents(double totalAmount) {
  final cents =
      (totalAmount * 100).round() % 10; // Extract the last digit of cents

  if (cents == 1 || cents == 2 || cents == 6 || cents == 7) {
    // Round down
    return (totalAmount * 20).floor() / 20; // Round down to the nearest 0.05
  } else if (cents == 3 || cents == 4 || cents == 8 || cents == 9) {
    // Round up
    return (totalAmount * 20).ceil() / 20; // Round up to the nearest 0.05
  }
  // If already a multiple of 5 cents (0 or 5), return as is
  return double.parse(totalAmount.toStringAsFixed(2));
}
