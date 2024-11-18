import 'package:flutter/material.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';

class AuthInputField extends StatelessWidget {
  final String labelText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final String? errorText;
  final TextInputType? keyboardType;
  const AuthInputField({
    super.key,
    required this.labelText,
    required this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      decoration: InputDecoration(
        errorMaxLines: 5,
        floatingLabelStyle: const TextStyle(color: AppPallete.primaryColor),
        labelText: labelText,
        filled: true,
        fillColor: AppPallete.actionBgColor,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppPallete.borderColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppPallete.primaryColor),
        ),
        errorText: errorText,
      ),
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
    );
  }
}
