String formatPhoneNumber(String phoneNumber) {
  // Ensure the phone number starts with "+60" and has the correct length
  if (phoneNumber.startsWith('+60') && phoneNumber.length == 12) {
    // Extract parts of the phone number using substring
    String countryCode = phoneNumber.substring(0, 3); // "+60"
    String part1 = phoneNumber.substring(3, 5); // "12"
    String part2 = phoneNumber.substring(5, 8); // "345"
    String part3 = phoneNumber.substring(8); // "6766"

    // Format and return the phone number
    return '$countryCode $part1-$part2 $part3';
  } else {
    // Return the original phone number if format doesn't match
    return phoneNumber;
  }
}

String formatPhoneNumberToBackend(String phoneNumber) {
  String formattedNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'),
      ''); // Remove existing spaces and non-numeric characters except '+'

  return formattedNumber;
}
