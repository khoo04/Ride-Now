import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/format_date.dart';
import 'package:ride_now_app/core/utils/format_time.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride/ride_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_search/ride_search_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/pages/ride_detail_screen.dart';
import 'package:ride_now_app/features/ride/presentation/widgets/ride_preview_card.dart';

class SearchRideResultScreen extends StatelessWidget {
  static const routeName = '/search-result';
  const SearchRideResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.read<RideSearchBloc>().state;

    if (state is! RideSearchSuccess) {
      // Redirect back if the state is not RideSearchSuccess
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return const SizedBox(); // Return an empty widget while redirecting
    }

    final rideSearchState = state;

    final now = DateTime.now();
    final isToday = rideSearchState.departureTime.year == now.year &&
        rideSearchState.departureTime.month == now.month &&
        rideSearchState.departureTime.day == now.day;

    final dateText =
        isToday ? "Today" : formatDate(rideSearchState.departureTime);
    bool isNavigating = false;

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 150,
          backgroundColor: AppPallete.borderColor,
          shape: const RoundedRectangleBorder(
              side: BorderSide(width: 10, color: AppPallete.borderColor)),
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new,
              color: AppPallete.primaryColor,
            ),
          ),
          title: BlocBuilder<RideSearchBloc, RideSearchState>(
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Location and Direction Section
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rideSearchState.fromPlace.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black, // Adjust color as needed
                        ),
                      ),
                      Text(
                        rideSearchState.fromPlace.formattedAddress,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                          color: Colors.black54, // Adjust color as needed
                        ),
                      ),
                    ],
                  ),
                  const Icon(
                    Icons.arrow_downward,
                    size: 24,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rideSearchState.toPlace.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.black, // Adjust color as needed
                        ),
                      ),
                      Text(
                        rideSearchState.toPlace.formattedAddress,
                        style: const TextStyle(
                          fontWeight: FontWeight.w300,
                          fontSize: 12,
                          color: Colors.black54, // Adjust color as needed
                        ),
                      ),
                    ],
                  ),

                  // Divider
                  const Row(
                    children: [
                      Expanded(
                        child: Divider(
                          indent: 4,
                        ),
                      ),
                    ],
                  ),

                  // Date and Passenger Information
                  Row(
                    children: [
                      Text(
                        "$dateText ${formatTime(rideSearchState.departureTime)}, ${rideSearchState.seats} Passengers",
                        style: const TextStyle(
                          fontWeight: FontWeight.w400,
                          fontSize: 12,
                          color: Colors.black54, // Adjust color as needed
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 18),
          child: state.searchRides.isEmpty
              ? const Center(
                  child: Text("No rides found"),
                )
              : ListView.separated(
                  itemBuilder: (context, index) {
                    final ride = state.searchRides[index];
                    return RidePreviewCard(
                      ride: ride,
                      onTap: () {
                        if (!isNavigating) {
                          isNavigating = true;
                          context.read<RideBloc>().add(
                              SelectRideEvent(ride: ride, seats: state.seats));
                          Navigator.of(context)
                              .pushNamed(RideDetailScreen.routeName)
                              .then((_) {
                            isNavigating = false;
                          });
                        }
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const SizedBox(height: 8);
                  },
                  itemCount: state.searchRides.length,
                ),
        ),
      ),
    );
  }
}
