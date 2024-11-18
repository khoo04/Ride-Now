import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/cubits/app_user/app_user_cubit.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/format_phone_number.dart';
import 'package:ride_now_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ride_now_app/features/profile/presentation/widgets/profile_action_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          BlocBuilder<AppUserCubit, AppUserState>(
            builder: (context, state) {
              return Column(
                children: [
                  const Spacer(
                    flex: 1,
                  ),
                  const Text(
                    "Profile",
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  //TODO: User Profile Picture
                  const CircleAvatar(
                    radius: 45,
                    backgroundImage:
                        AssetImage("assets/images/profile_placeholder.png"),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  Text(state is AppUserLoggedIn ? state.user.name : "Username",
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600)),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                      state is AppUserLoggedIn
                          ? formatPhoneNumber(state.user.phone)
                          : "Phone Number",
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: AppPallete.hintColor)),
                  const SizedBox(
                    height: 24,
                  ),
                  ProfileActionTile(
                    icon: Icons.person,
                    onTap: () {},
                    title: "My Profile",
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ProfileActionTile(
                    icon: Icons.redeem,
                    onTap: () {},
                    title: "My Voucher",
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ProfileActionTile(
                    icon: Icons.directions_car,
                    onTap: () {},
                    title: "Manage Vehicles",
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  ProfileActionTile(
                    icon: Icons.settings,
                    onTap: () {},
                    title: "Settings",
                  ),
                  const SizedBox(
                    height: 25,
                  ),
                  const Spacer(flex: 2),
                ],
              );
            },
          ),
          // Floating Logout Button
          Positioned(
            bottom: 16.0,
            right: 16.0,
            child: FloatingActionButton(
              onPressed: () {
                // Add logout functionality here
                context.read<AuthBloc>().add(AuthLogoutUser());
              },
              shape: const CircleBorder(),
              backgroundColor: const Color.fromARGB(255, 248, 190, 190),
              child: const Icon(
                Icons.logout,
                color: AppPallete.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
