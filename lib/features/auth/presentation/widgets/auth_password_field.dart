import 'package:flutter/material.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';

class AuthPasswordField extends StatefulWidget {
  final String labelText;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final String? errorText;
  final void Function()? onEditingComplete;
  const AuthPasswordField({
    super.key,
    required this.controller,
    required this.labelText,
    this.validator,
    this.errorText,
    this.onEditingComplete,
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool isObscureText = true;
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      focusNode: _focusNode,
      controller: widget.controller,
      obscureText: isObscureText,
      onEditingComplete: widget.onEditingComplete,
      decoration: InputDecoration(
        errorMaxLines: 5,
        errorText: widget.errorText,
        floatingLabelStyle: const TextStyle(color: AppPallete.primaryColor),
        filled: true,
        fillColor: AppPallete.actionBgColor,
        border: const OutlineInputBorder(
          borderSide: BorderSide(color: AppPallete.borderColor),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: AppPallete.primaryColor),
        ),
        labelText: widget.labelText,
        suffixIcon: _focusNode.hasFocus
            ? IconButton(
                onPressed: () {
                  setState(() {
                    isObscureText = !isObscureText;
                  });
                },
                icon: Icon(
                  isObscureText ? Icons.visibility_off : Icons.visibility,
                ),
              )
            : null,
      ),
      validator: widget.validator,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.done,
    );
  }
}
