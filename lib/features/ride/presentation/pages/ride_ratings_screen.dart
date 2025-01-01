import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/features/ride/domain/usecases/rate_ride.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride/ride_bloc.dart';
import 'package:ride_now_app/init_dependencies.dart';

class RideRatingsScreen extends StatefulWidget {
  static const routeName = '/ride/ratings';
  const RideRatingsScreen({super.key});

  @override
  State<RideRatingsScreen> createState() => _RideRatingsScreenState();
}

class _RideRatingsScreenState extends State<RideRatingsScreen> {
  double currentRating = 0;

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
            "Rate Your Driver",
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 20,
            ),
          ),
        ),
        body: BlocBuilder<RideBloc, RideState>(
          builder: (context, state) {
            if (state is! RideSelected) {
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
                            height: 24,
                          ),
                          const Text(
                            "Thanks for using RideNow",
                            style: TextStyle(
                                fontSize: 24, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 8,
                          ),
                          const Text(
                            "We hope you enjoyed your ride",
                            style: TextStyle(
                                fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          SizedBox(
                            height: 100,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        ride.origin.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        ride.origin.formattedAddress,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w400,
                                          fontSize: 12,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Spacer(),
                                      Text(
                                        ride.destination.name,
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        ride.destination.formattedAddress,
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
                          const Padding(
                            padding: EdgeInsets.symmetric(vertical: 12.0),
                            child: Divider(),
                          ),
                          Row(
                            children: [
                              Builder(
                                builder: (context) {
                                  ImageProvider<Object>? imageToDisplay;
                                  final url = state.ride.driver.profilePicture;

                                  if (url != null) {
                                    imageToDisplay = NetworkImage(url);
                                  } else {
                                    imageToDisplay = null;
                                  }
                                  return CircleAvatar(
                                    backgroundColor: Colors.grey[300],
                                    radius: 24,
                                    foregroundImage: imageToDisplay,
                                    child: imageToDisplay == null
                                        ? const Icon(
                                            Icons.person,
                                            color: Colors.white,
                                          )
                                        : null,
                                  );
                                },
                              ),
                              const SizedBox(width: 16),
                              Text(
                                ride.driver.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                          RatingBar.builder(
                            initialRating: 0,
                            minRating: 1,
                            direction: Axis.horizontal,
                            allowHalfRating: false,
                            itemCount: 5,
                            itemPadding:
                                const EdgeInsets.symmetric(horizontal: 4.0),
                            itemBuilder: (context, _) => const Icon(
                              Icons.star,
                              color: Colors.amber,
                            ),
                            onRatingUpdate: (rating) {
                              currentRating = rating;
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 24.0),
                    child: Center(
                      child: AppButton(
                        onPressed: () async {
                          //Rating

                          final rateRide = serviceLocator<RateRide>();
                          final res = await rateRide(RateRideParams(
                              rideId: ride.rideId, rating: currentRating));

                          res.fold(
                              (failure) =>
                                  showSnackBar(context, failure.message), (r) {
                            if (r) {
                              showSnackBar(
                                  context, "Ride was rated successfully");
                              Navigator.of(context).pop();
                            }
                          });
                        },
                        child: const Text("Rate Driver"),
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
