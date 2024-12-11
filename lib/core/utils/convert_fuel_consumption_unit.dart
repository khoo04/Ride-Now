double convertLPer100KmToKmPerL(double lPer100Km) {
  if (lPer100Km <= 0) {
    throw ArgumentError("Fuel consumption in L/100km must be greater than zero.");
  }
  return 100 / lPer100Km;
}