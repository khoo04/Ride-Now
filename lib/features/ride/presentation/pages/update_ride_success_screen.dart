import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/utils/format_date.dart';
import 'package:ride_now_app/core/utils/format_time.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride/ride_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_main/ride_main_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/ride_update/ride_update_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/pages/ride_detail_screen.dart';

class UpdateRideSuccessScreen extends StatelessWidget {
  static const routeName = '/update-ride/success';
  const UpdateRideSuccessScreen({super.key});

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
        ),
        body: BlocBuilder<RideUpdateCubit, RideUpdateState>(
          builder: (context, state) {
            if (state is! RideUpdateSuccess) {
              return const SizedBox.shrink();
            }
            final ride = state.ride;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(
                            height: 32,
                          ),
                          Image.asset(
                            "assets/images/car_sharing.png",
                            width: MediaQuery.of(context).size.width * 0.3,
                          ),
                          const SizedBox(
                            height: 24,
                          ),
                          const Text(
                            "Success! Your ride has been updated!",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          Text(
                            "Please wait for your passengers at ${ride.origin.formattedAddress} at ${formatDate(ride.departureTime)} and be there 5 minutes before ${formatTime(ride.departureTime)}.",
                            style: const TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: AppButton(
                        onPressed: () {
                          //Navigate to ride details
                          context.read<RideBloc>().add(
                                SelectRideEvent(
                                  ride: ride,
                                ),
                              );
                          // context
                          //     .read<RideMainBloc>()
                          //     .add(const InitFetchRide());
                          //Pop to details screen
                          Navigator.of(context).pop();
                        },
                        child: const Text("View Ride"),
                      ),
                    ),
                  )
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
