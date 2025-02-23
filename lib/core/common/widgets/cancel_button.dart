import 'package:flutter/material.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';

class CancelButton extends StatelessWidget {
  final void Function()? onPressed;
  final Widget? child;
  const CancelButton({super.key, required this.onPressed, required this.child});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: Size(MediaQuery.sizeOf(context).width * 0.8, 54),
        foregroundColor: AppPallete.whiteColor,
        backgroundColor: AppPallete.errorColor,
      ),
      child: child,
    );
  }
}
