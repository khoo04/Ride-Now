import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/utils/format_phone_number.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ride_now_app/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:ride_now_app/features/auth/presentation/widgets/auth_password_field.dart';

class RegisterScreen extends StatefulWidget {
  static const routeName = "/register";

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _registerFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumController = TextEditingController(text: "+60 ");
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  //Errors Text
  String? _nameError;
  String? _emailError;
  String? _phoneNumError;
  String? _passwordError;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: MyAppBar(
          leading: NavigateBackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            setState(() {
              _nameError = null;
              _emailError = null;
              _passwordError = null;
              _phoneNumError = null;
            });
            if (state is AuthRegisterFailure) {
              _showErrosHint(state.registrationErrors);
            } else if (state is AuthSuccess) {
              showSnackBar(context, "User registered successfuly");
              Navigator.of(context).pop();
            }
          },
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    child: Form(
                      key: _registerFormKey,
                      child: Column(
                        children: [
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Register New Account",
                              style: TextStyle(
                                  fontSize: 24.0, fontWeight: FontWeight.w500),
                            ),
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AuthInputField(
                            labelText: "Full Name",
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Username is required";
                              } else if (!RegExp(r'^[a-zA-Z0-9 ]+$')
                                  .hasMatch(value)) {
                                return "Only alphabets, numbers and spaces are allowed";
                              }
                              return null;
                            },
                            errorText: _nameError,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AuthInputField(
                            labelText: "Phone Number",
                            controller: _phoneNumController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Phone number is required";
                              } else if (!RegExp(
                                      r'^\+60\s\d{2}\s(?:\d{3}|\d{4})\s\d{4}$')
                                  .hasMatch(_phoneNumController.text.trim())) {
                                return "The phone number format is invalid";
                              }
                              return null;
                            },
                            errorText: _phoneNumError,
                            onChanged: (value) {
                              String currentValue = value.replaceAll(
                                  RegExp(r'[^0-9+]'),
                                  ''); // Remove existing spaces and non-numeric characters except '+'

                              if (currentValue.length <= 3) {
                                _phoneNumController.text = "+60 ";
                              } else if (currentValue.length <= 5) {
                                _phoneNumController.text =
                                    '${currentValue.substring(0, 3)} ${currentValue.substring(3)}';
                              } else if (currentValue.length <= 8) {
                                _phoneNumController.text =
                                    '${currentValue.substring(0, 3)} ${currentValue.substring(3, 5)} ${currentValue.substring(5)}';
                              } else if (currentValue.length <= 12) {
                                _phoneNumController.text =
                                    '${currentValue.substring(0, 3)} ${currentValue.substring(3, 5)} ${currentValue.substring(5, 8)} ${currentValue.substring(8)}';
                              } else {
                                _phoneNumController.text =
                                    '${currentValue.substring(0, 3)} ${currentValue.substring(3, 5)} ${currentValue.substring(5, 9)} ${currentValue.substring(9, 13)}';
                              }
                            },
                            keyboardType: TextInputType.number,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AuthInputField(
                            labelText: "Email",
                            controller: _emailController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Email is required";
                              } else if (!RegExp(
                                      r"^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$")
                                  .hasMatch(value)) {
                                return "The email format is not valid";
                              }
                              return null;
                            },
                            errorText: _emailError,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AuthPasswordField(
                            labelText: "Password",
                            controller: _passwordController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return "Password is required";
                              } else if (!RegExp(
                                      r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@!$#%^&*()])[A-Za-z\d@!$#%^&*()]{8,}$')
                                  .hasMatch(value)) {
                                return "Password must contain at least 1 number, 1 uppercase letter, and 1 special character";
                              }
                              return null;
                            },
                            errorText: _passwordError,
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          AuthPasswordField(
                            labelText: "Confirm Password",
                            controller: _confirmPasswordController,
                            validator: (value) {
                              if (value != _passwordController.text.trim()) {
                                return "Confirmation password does not match";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return AppButton(
                        onPressed: state is AuthLoading
                            ? null
                            : () {
                                if (_registerFormKey.currentState!.validate()) {
                                  String phoneNumber =
                                      formatPhoneNumberToBackend(
                                          _phoneNumController.text.trim());
                                  context.read<AuthBloc>().add(
                                        AuthRegisterUser(
                                          name: _nameController.text.trim(),
                                          phone: phoneNumber,
                                          email: _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                          confirmPassword:
                                              _confirmPasswordController.text
                                                  .trim(),
                                        ),
                                      );
                                }
                              },
                        child: state is AuthLoading
                            ? const CircularProgressIndicator(
                                color: Colors.white,
                              )
                            : const Text("Register"),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showErrosHint(Map<String, String> errors) {
    setState(() {
      _nameError = errors["name"];
      _emailError = errors["email"];
      _passwordError = errors["password"];
      _phoneNumError = errors["phone_number"];
    });
  }
}
