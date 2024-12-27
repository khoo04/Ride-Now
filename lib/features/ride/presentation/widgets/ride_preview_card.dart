import 'package:flutter/material.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/format_date.dart';
import 'package:ride_now_app/core/utils/format_time.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';

class RidePreviewCard extends StatelessWidget {
  final Ride ride;
  final void Function()? onTap;
  const RidePreviewCard({super.key, required this.ride, required this.onTap});

  @override
  Widget build(BuildContext context) {
    Color priceColor;
    switch (ride.status) {
      case "started":
        priceColor = AppPallete.activeColor;
        break;
      case "completed":
        priceColor = Colors.red;
        break;
      case "confirmed":
      default:
        priceColor = Colors.blue;
    }
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 240,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(.5),
              blurRadius: 4.0, // soften the shadow
              spreadRadius: -4.0, //extend the shadow
            ),
          ],
        ),
        child: Card(
          color: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
          ),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                Expanded(
                  // Added Expanded here to allow the first row to take available space
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            formatTime(ride.departureTime),
                            style: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            formatDate(ride.departureTime),
                            style: const TextStyle(
                                fontSize: 12, fontWeight: FontWeight.w400),
                          ),
                        ],
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
                    ],
                  ),
                ),
                const Divider(
                  height: 20,
                ),
                Row(
                  children: [
                    // CircleAvatar(
                    //   radius: 24,
                    //   backgroundColor: Colors.grey[300],
                    //   child: const Icon(Icons.person, color: Colors.white),
                    // ),
                    Builder(builder: (context) {
                      ImageProvider<Object>? imageToDisplay;
                      final url = ride.driver.profilePicture;

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
                    }),
                    const SizedBox(width: 16),
                    Text(
                      ride.driver.name,
                      style: const TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const Divider(
                  height: 20,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildRideSeats(ride.passengers.length, ride.vehicle.seats),
                    Text(
                      "RM ${ride.baseCost.toStringAsFixed(2)}",
                      style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: priceColor),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
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
}
