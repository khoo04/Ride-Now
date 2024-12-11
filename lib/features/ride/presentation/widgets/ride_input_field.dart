import 'package:flutter/material.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';

class RideInputField extends StatelessWidget {
  final Widget? suffixIcon;
  final String labelText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function()? onTap;
  final String? errorText;
  final TextInputType? keyboardType;
  final FocusNode? focusNode;
  final void Function(String)? onFieldSubmitted;
  final bool isDense;
  final bool readOnly;
  const RideInputField({
    super.key,
    required this.labelText,
    required this.controller,
    this.validator,
    this.onChanged,
    this.errorText,
    this.keyboardType,
    this.focusNode,
    this.onFieldSubmitted,
    this.isDense = false,
    this.readOnly = false,
    this.onTap,
    this.suffixIcon,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTap: onTap,
      readOnly: readOnly,
      onFieldSubmitted: onFieldSubmitted,
      focusNode: focusNode,
      controller: controller,
      decoration: InputDecoration(
        isDense: isDense,
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
        suffixIcon: suffixIcon,
      ),
      validator: validator,
      onChanged: onChanged,
      keyboardType: keyboardType,
    );
  }
}
