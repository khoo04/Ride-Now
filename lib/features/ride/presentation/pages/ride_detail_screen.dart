import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/cancel_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/cubits/app_user/app_user_cubit.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/format_date.dart';
import 'package:ride_now_app/core/utils/format_time.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/core/utils/open_contact_dialog.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/core/utils/string_extension.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride/ride_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/ride_update_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/pages/update_ride_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/in_app_navigation_screen.dart';

class RideDetailScreen extends StatefulWidget {
  static const routeName = "/ride-details";
  const RideDetailScreen({super.key});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen> {
  late RideBloc _rideBloc;
  @override
  void initState() {
    super.initState();
    _rideBloc = context.read<RideBloc>();
    if (_rideBloc.state is RideSelected) {
      _rideBloc.add(FetchRideDetails(rideId: _rideBloc.state.rideId!));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: MyAppBar(
          leading: NavigateBackButton(
            onPressed: () {
              Navigator.of(context).popUntil((route) {
                context.read<RideBloc>().add(ResetRideStateEvent());
                return true;
              });
            },
          ),
        ),
        body: BlocConsumer<RideBloc, RideState>(
          listener: (context, state) {
            if (state is RideFailure) {
              showSnackBar(context, state.message);
            } else if (state is! RideSelected) {
              Navigator.of(context).pop();
            }
          },
          builder: (context, state) {
            if (state is! RideSelected) {
              return const SizedBox.shrink();
            }
            return BlocSelector<AppUserCubit, AppUserState, User?>(
              selector: (state) {
                if (state is AppUserLoggedIn) {
                  return state.user;
                }
                return null;
              },
              builder: (context, user) {
                if (user == null) return const SizedBox.shrink();

                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0),
                  child: user.id == state.ride.driver.id
                      ? _driverView(state, context, user)
                      : _passengersView(state, context, user),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Column _driverView(RideSelected state, BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatDateWithWeekDay(state.ride.departureTime),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Ride Base Cost",
                style: TextStyle(
                  fontSize: 16,
                  color: AppPallete.hintColor,
                ),
              ),
              Column(
                children: [
                  Text(
                    "RM ${state.ride.baseCost.toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppPallete.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTime(state.ride.departureTime),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 2.0),
                          Container(
                            width: 14.0,
                            height: 14.0,
                            decoration: const BoxDecoration(
                              color: AppPallete.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 8.0,
                            ),
                          ),
                          Expanded(
                            // Added Expanded for the vertical line
                            child: Container(
                              color: AppPallete.primaryColor,
                              width: 4,
                            ),
                          ),
                          Container(
                            width: 14.0,
                            height: 14.0,
                            decoration: const BoxDecoration(
                              color: AppPallete.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 8.0,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.ride.origin.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              state.ride.origin.formattedAddress,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            _buildRideSeats(state.ride.passengers.length,
                                state.ride.vehicle.seats),
                            const Spacer(),
                            Text(
                              state.ride.destination.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              state.ride.destination.formattedAddress,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "${state.ride.driver.name} (You)",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.star,
                        size: 12,
                      ),
                      Text(
                        " ${state.ride.driver.ratings} / 5.0",
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppPallete.hintColor,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(),
        ),
        const Text(
          "Vehicle Details",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          state.ride.vehicle.vehicleRegistrationNumber,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${state.ride.vehicle.manufacturer} ${state.ride.vehicle.model} (${state.ride.vehicle.vehicleType.name.capitalize()})",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(),
        ),
        const Spacer(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Builder(
            builder: (context) {
              if (state.ride.status != "confirmed") {
                return const SizedBox.shrink();
              }
              final isBefore5Minutes = DateTime.now().isBefore(state
                  .ride.departureTime
                  .subtract(const Duration(minutes: 5)));
              if (isBefore5Minutes) {
                return Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: state.ride.passengers.isEmpty
                          ? () async {
                              context
                                  .read<RideUpdateCubit>()
                                  .initializeUpdateRide(state.ride);
                              Navigator.pushNamed(
                                  context, UpdateRideScreen.routeName);
                            }
                          : () {
                              showSnackBar(context,
                                  "Unable to edit ride once passengers have joined");
                            },
                      icon: const Icon(Icons.edit),
                      iconSize: 32,
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: AppButton(
                        onPressed: () {
                          Navigator.pushNamed(
                              context, InAppNavigationScreen.routeName,
                              arguments: state.ride);
                        },
                        child: const Text("View Route"),
                      ),
                    ),
                    const SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      child: CancelButton(
                          onPressed: () {
                            //Cancel Ride
                          },
                          child: const Text("Cancel Ride")),
                    ),
                  ],
                );
              } else {
                return Center(
                  child: state.ride.passengers.isEmpty
                      ?
                      //If not passengers join after 5 minutes for the departure time, user can cancel ride
                      CancelButton(
                          onPressed: () {
                            //Cancel Ride
                          },
                          child: const Text("Cancel Ride"))
                      : AppButton(
                          onPressed: () {}, child: const Text("Start Ride")),
                );
              }
            },
          ),
        ),
      ],
    );
  }

  Column _passengersView(RideSelected state, BuildContext context, User user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          formatDateWithWeekDay(state.ride.departureTime),
          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 24),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Total price for ${state.seats} passenger",
                style: const TextStyle(
                  fontSize: 16,
                  color: AppPallete.hintColor,
                ),
              ),
              //TODO Calculate based on passengers
              Column(
                children: [
                  Text(
                    "RM ${_calculateTotalPrice(state.ride.baseCost, state.seats, 0.8).toStringAsFixed(2)}",
                    style: const TextStyle(
                      fontSize: 16,
                      color: AppPallete.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: SizedBox(
            height: 120,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  formatTime(state.ride.departureTime),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(width: 12.0),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        children: [
                          const SizedBox(height: 2.0),
                          Container(
                            width: 14.0,
                            height: 14.0,
                            decoration: const BoxDecoration(
                              color: AppPallete.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 8.0,
                            ),
                          ),
                          Expanded(
                            // Added Expanded for the vertical line
                            child: Container(
                              color: AppPallete.primaryColor,
                              width: 4,
                            ),
                          ),
                          Container(
                            width: 14.0,
                            height: 14.0,
                            decoration: const BoxDecoration(
                              color: AppPallete.primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.circle,
                              color: Colors.white,
                              size: 8.0,
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              state.ride.origin.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              state.ride.origin.formattedAddress,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            _buildRideSeats(state.ride.passengers.length,
                                state.ride.vehicle.seats),
                            const Spacer(),
                            Text(
                              state.ride.destination.name,
                              style:
                                  const TextStyle(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              state.ride.destination.formattedAddress,
                              style: const TextStyle(
                                fontWeight: FontWeight.w400,
                                fontSize: 12,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        const Divider(),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.ride.driver.name,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.star,
                        size: 12,
                      ),
                      //TODO Ratings
                      Text(
                        " ${state.ride.driver.ratings} / 5.0",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                          color: AppPallete.hintColor,
                        ),
                      ),
                    ],
                  )
                ],
              ),
              CircleAvatar(
                radius: 24,
                backgroundColor: Colors.grey[300],
                child: const Icon(Icons.person, color: Colors.white),
              ),
            ],
          ),
        ),
        InkWell(
          onTap: () async {
            String introTemplate =
                "Hi ${state.ride.driver.name}, I saw your ride on RideNow for ${formatDate(state.ride.departureTime)}, ${formatTime(state.ride.departureTime)} from ${state.ride.origin.formattedAddress} to ${state.ride.destination.formattedAddress}. Is it still available? Let me know, thanks!";
            showContactMethodPicker(
                context, state.ride.driver.phone, introTemplate);
            return;
          },
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              children: [
                const Icon(
                  Icons.chat,
                  color: AppPallete.primaryColor,
                ),
                const SizedBox(
                  width: 8,
                ),
                Text(
                  "Contact ${state.ride.driver.name}",
                  style: const TextStyle(color: AppPallete.primaryColor),
                ),
                const Spacer(),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(),
        ),
        const Text(
          "Vehicle Details",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          state.ride.vehicle.vehicleRegistrationNumber,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          "${state.ride.vehicle.manufacturer} ${state.ride.vehicle.model} (${state.ride.vehicle.vehicleType.name.capitalize()})",
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w400,
          ),
        ),
        const Padding(
          padding: EdgeInsets.symmetric(vertical: 8.0),
          child: Divider(),
        ),
        const Spacer(),
        const Text(
          "Note: \nYou will get cashback voucher after this ride completed, if you become the first person who join the ride ",
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppPallete.errorColor,
          ),
        ),
        const SizedBox(
          height: 8,
        ),
        InkWell(
          onTap: () {},
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  Icons.redeem,
                  color: AppPallete.primaryColor,
                ),
                SizedBox(
                  width: 10,
                ),
                Text(
                  "Apply Voucher",
                  style: TextStyle(color: AppPallete.primaryColor),
                ),
                Spacer(),
                Icon(Icons.chevron_right),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Center(
            child: BlocSelector<AppUserCubit, AppUserState, User?>(
                selector: (state) {
              if (state is AppUserLoggedIn) {
                return state.user;
              }
              return null;
            }, builder: (context, user) {
              if (user == null) return const SizedBox.shrink();
              //If current time is before 5 minutes compare to ride departure time, driver cannot cancel
              final isBefore5Minutes = DateTime.now().isBefore(state
                  .ride.departureTime
                  .subtract(const Duration(minutes: 5)));

              if (state.ride.passengers
                  .any((passenger) => passenger.id == user.id)) {
                return AppButton(
                  onPressed: () {
                    //View the ride (navigation and maps)
                  },
                  child:
                      const Text("Your have joined this ride, Click to view"),
                );
              } else {
                return AppButton(
                  onPressed: () {
                    //Join ride
                  },
                  child: const Text("Join ride"),
                );
              }
            }),
          ),
        ),
      ],
    );
  }

  Row _buildRideSeats(int numOfPassengers, int vehicleSeats) {
    return Row(
      children: List.generate(vehicleSeats, (index) {
        return Icon(
          Icons.airline_seat_recline_normal_outlined,
          size: 22,
          color: index < numOfPassengers
              ? AppPallete.primaryColor // Occupied seats in primary color
              : Colors.grey, // Remaining seats in grey
        );
      }),
    );
  }

  //TODO Calculate Price Based On Num Of Passengers
  double _calculateTotalPrice(
      double basePrice, int numOfPassengers, double discountFactor) {
    List<double> prices = [];

    for (int passenger = 1; passenger <= numOfPassengers; passenger++) {
      double price = basePrice * pow(discountFactor, passenger - 1);
      prices.add(price);
    }

    // Sum all prices
    double totalPrice = prices.fold(0, (sum, price) => sum + price);

    return totalPrice;
  }
}
