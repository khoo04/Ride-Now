import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/cubits/app_user/app_user_cubit.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/format_phone_number.dart';
import 'package:ride_now_app/core/utils/image_helper.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ride_now_app/features/auth/presentation/widgets/auth_input_field.dart';
import 'package:ride_now_app/features/auth/presentation/widgets/auth_password_field.dart';
import 'package:ride_now_app/features/profile/presentation/cubit/profile_cubit.dart';
import 'package:ride_now_app/init_dependencies.dart';

class UpdateProfileScreen extends StatefulWidget {
  static const routeName = '/profile/update';
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final _updateProfileFormKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneNumController = TextEditingController(text: "+60 ");
  final _emailController = TextEditingController();
  final _oldPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();

  //Errors Text
  String? _nameError;
  String? _emailError;
  String? _phoneNumError;
  String? _oldPasswordError;
  String? _newPasswordError;

  //Image
  File? _selectedImage;

  @override
  void initState() {
    context.read<ProfileCubit>().initializeCubit();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          leading: NavigateBackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          title: const Text(
            "Edit Profile",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        body: BlocSelector<AppUserCubit, AppUserState, User?>(
          selector: (AppUserState state) {
            if (state is AppUserLoggedIn) {
              return state.user;
            }
            return null;
          },
          builder: (BuildContext context, user) {
            return BlocConsumer<ProfileCubit, ProfileState>(
                listener: (context, state) {
              if (state is ProfileUpdateFailure &&
                  state.validationErrors == null &&
                  state.message != null) {
                showSnackBar(context, state.message!);
              } else if (state is ProfileUpdateSuccess) {
                _oldPasswordController.text = '';
                _newPasswordController.text = '';
                context.read<AuthBloc>().add(AuthIsUserLoggedIn());
                showSnackBar(context, "User profile was updated successfully");
              }
            }, builder: (context, state) {
              if (user == null) {
                return const Center(
                  child: Text("User details not founded"),
                );
              }
              if (state is! ProfileUpdateLoading) {
                _nameController.text = user.name;
                String userPhone = user.phone;
                if (userPhone.length <= 12) {
                  _phoneNumController.text =
                      '${userPhone.substring(0, 3)} ${userPhone.substring(3, 5)} ${userPhone.substring(5, 8)} ${userPhone.substring(8)}';
                } else {
                  _phoneNumController.text =
                      '${userPhone.substring(0, 3)} ${userPhone.substring(3, 5)} ${userPhone.substring(5, 9)} ${userPhone.substring(9, 13)}';
                }
                _emailController.text = user.email;
              }
              if (state is ProfileUpdateFailure &&
                  state.validationErrors != null) {
                final errors = state.validationErrors!;
                _nameError = errors["name"];
                _newPasswordError = errors["new_password"];
                _oldPasswordError = errors["old_password"];
                _emailError = errors["email"];
                _phoneNumError = errors["phone_number"];
              } else {
                _nameError = null;
                _emailError = null;
                _phoneNumError = null;
                _oldPasswordError = null;
                _newPasswordError = null;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final imageHelper = serviceLocator<ImageHelper>();
                          final files = await imageHelper.pickImage();
                          if (files.isNotEmpty) {
                            final croppedFile =
                                await imageHelper.crop(file: files.first);

                            if (croppedFile != null) {
                              setState(() =>
                                  _selectedImage = File(croppedFile.path));
                            }
                          }
                        },
                        child: Stack(children: [
                          Builder(builder: (context) {
                            ImageProvider<Object>? imageToDisplay;
                            if (_selectedImage != null) {
                              imageToDisplay = FileImage(_selectedImage!);
                            } else if (user.profilePicture != null) {
                              imageToDisplay =
                                  NetworkImage(user.profilePicture!);
                            } else {
                              imageToDisplay = null;
                            }
                            return CircleAvatar(
                              backgroundColor: Colors.grey[300],
                              radius: 48,
                              foregroundImage: imageToDisplay,
                              child: imageToDisplay == null
                                  ? const Icon(
                                      Icons.person,
                                      color: Colors.white,
                                      size: 64,
                                    )
                                  : null,
                            );
                          }),
                          const Positioned(
                            bottom: 0,
                            right: 0,
                            child: CircleAvatar(
                              radius: 14,
                              backgroundColor: AppPallete.secondaryColor,
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: 14,
                              ),
                            ),
                          ),
                        ]),
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      Form(
                        key: _updateProfileFormKey,
                        child: Column(
                          children: [
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
                                    .hasMatch(
                                        _phoneNumController.text.trim())) {
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
                              labelText: "Old Password",
                              controller: _oldPasswordController,
                              errorText: _oldPasswordError,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                } else if (_newPasswordController
                                    .text.isEmpty) {
                                  return "New password is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            AuthPasswordField(
                              labelText: "New Password",
                              controller: _newPasswordController,
                              errorText: _newPasswordError,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return null;
                                } else if (!RegExp(
                                        r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[@!$#%^&*()])[A-Za-z\d@!$#%^&*()]{8,}$')
                                    .hasMatch(value)) {
                                  return "Password must contain at least 1 number, 1 uppercase letter, and 1 special character";
                                } else if (_oldPasswordController
                                    .text.isEmpty) {
                                  return "Old password is required";
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
                      const SizedBox(
                        height: 24,
                      ),
                      Builder(builder: (context) {
                        if (state is ProfileUpdateLoading) {
                          return const AppButton(
                            onPressed: null,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                            ),
                          );
                        }
                        return AppButton(
                          onPressed: () {
                            if (_updateProfileFormKey.currentState!
                                .validate()) {
                              // Unfocus all input fields
                              FocusScope.of(context).unfocus();

                              String? updatedName =
                                  (_nameController.text.trim() != user.name)
                                      ? _nameController.text.trim()
                                      : null;

                              String? updatedEmail =
                                  (_emailController.text.trim() != user.email)
                                      ? _emailController.text.trim()
                                      : null;

                              String? updatedPhone =
                                  (formatPhoneNumberToBackend(
                                              _phoneNumController.text
                                                  .trim()) !=
                                          user.phone)
                                      ? formatPhoneNumberToBackend(
                                          _phoneNumController.text.trim())
                                      : null;

                              String? oldPassword = (_oldPasswordController.text
                                          .trim()
                                          .isNotEmpty &&
                                      _newPasswordController.text
                                          .trim()
                                          .isNotEmpty)
                                  ? _oldPasswordController.text.trim()
                                  : null;

                              String? newPassword = (_newPasswordController.text
                                          .trim()
                                          .isNotEmpty &&
                                      _newPasswordController.text
                                          .trim()
                                          .isNotEmpty)
                                  ? _newPasswordController.text.trim()
                                  : null;

                              if (updatedName == null &&
                                  updatedEmail == null &&
                                  updatedPhone == null &&
                                  oldPassword == null &&
                                  newPassword == null &&
                                  _selectedImage == null) {
                                showSnackBar(context, "Nothings to update...");
                                return;
                              }

                              context.read<ProfileCubit>().updateUserProfile(
                                    name: updatedName,
                                    email: updatedEmail,
                                    phone: updatedPhone,
                                    oldPassword: oldPassword,
                                    newPassword: newPassword,
                                    profileImage: _selectedImage,
                                  );
                            }
                          },
                          child: const Text(
                            "Update Profile",
                          ),
                        );
                      })
                    ],
                  ),
                ),
              );
            });
          },
        ),
      ),
    );
  }
}
