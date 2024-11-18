import 'package:flutter/material.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';

class AppTheme {
  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPallete.whiteColor,
    primaryColor: AppPallete.primaryColor,
    textTheme: ThemeData.light().textTheme.apply(
          fontFamily: 'Poppins', // Set Poppins as default fonts
        ),
  );
}
