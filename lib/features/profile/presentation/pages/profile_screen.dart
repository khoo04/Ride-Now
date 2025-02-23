import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/cubits/app_user/app_user_cubit.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/format_phone_number.dart';
import 'package:ride_now_app/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:ride_now_app/features/profile/presentation/pages/balance/my_balance_screen.dart';
import 'package:ride_now_app/features/profile/presentation/pages/manage_vehicles_screen.dart';
import 'package:ride_now_app/features/profile/presentation/pages/my_voucher_screen.dart';
import 'package:ride_now_app/features/profile/presentation/pages/update_profile_screen.dart';
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
                  Builder(
                    builder: (context) {
                      final url = state is AppUserLoggedIn
                          ? state.user.profilePicture
                          : null;
                      ImageProvider<Object>? imageToDisplay;

                      if (url != null) {
                        imageToDisplay = NetworkImage(url);
                      } else {
                        imageToDisplay = null;
                      }
                      return CircleAvatar(
                        backgroundColor: Colors.grey[300],
                        radius: 45,
                        foregroundImage: imageToDisplay,
                        child: imageToDisplay == null
                            ? const Icon(
                                Icons.person,
                                color: Colors.white,
                                size: 64,
                              )
                            : null,
                      );
                    },
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
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: ProfileActionTile(
                      icon: Icons.person,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(UpdateProfileScreen.routeName);
                      },
                      title: "My Profile",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: ProfileActionTile(
                      icon: Icons.account_balance_wallet,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(MyBalanceScreen.routeName);
                      },
                      title: "My Balance",
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 25),
                    child: ProfileActionTile(
                      icon: Icons.redeem,
                      onTap: () {
                        Navigator.of(context)
                            .pushNamed(MyVoucherScreen.routeName);
                      },
                      title: "My Voucher",
                    ),
                  ),
                  ProfileActionTile(
                    icon: Icons.directions_car,
                    onTap: () {
                      Navigator.of(context)
                          .pushNamed(ManageVehiclesScreen.routeName);
                    },
                    title: "Manage Vehicles",
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
