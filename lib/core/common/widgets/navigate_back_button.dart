import 'package:flutter/material.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';

class NavigateBackButton extends StatelessWidget {
  final void Function()? onPressed;
  const NavigateBackButton({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      onPressed: onPressed,
      icon: const Icon(Icons.arrow_back_ios_new),
      style: IconButton.styleFrom(
        fixedSize: const Size(44, 44),
        backgroundColor: AppPallete.actionBgColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      color: AppPallete.primaryColor, // Icon color
    );
  }
}
