import 'package:flutter/material.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';

class LoadingButton extends StatelessWidget {
  const LoadingButton({super.key});

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(
        fixedSize: Size(MediaQuery.sizeOf(context).width * 0.8, 54),
        foregroundColor: AppPallete.whiteColor,
        backgroundColor: AppPallete.primaryColor,
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: AppPallete.whiteColor,
        ),
      ),
    );
  }
}
