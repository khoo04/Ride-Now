import 'package:flutter/material.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';

class AppIconButton extends StatelessWidget {
  final void Function()? onPressed;
  final IconData icon;
  final String label;
  const AppIconButton({
    super.key,
    this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(label),
        style: ElevatedButton.styleFrom(
          iconColor: AppPallete.primaryColor,
          foregroundColor: AppPallete.primaryColor,
          backgroundColor: AppPallete.actionBgColor,
          elevation: 4,
        ));
  }
}
