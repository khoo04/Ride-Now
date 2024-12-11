import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/features/profile/presentation/bloc/vehicle/vehicle_bloc.dart';
import 'package:ride_now_app/features/profile/presentation/pages/manage_vehicles_screen.dart';
import 'package:ride_now_app/features/profile/presentation/pages/register_vehicle_screen.dart';
import 'package:ride_now_app/features/profile/presentation/pages/update_vehicle_screen.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';

class ManageVehicleCard extends StatelessWidget {
  final Vehicle vehicle;
  const ManageVehicleCard({super.key, required this.vehicle});

  @override
  Widget build(BuildContext context) {
    return Container(
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
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                  child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.vehicleRegistrationNumber,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "${vehicle.manufacturer} ${vehicle.model}",
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Seats: ${vehicle.seats}",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(
                    "Average Fuel Consumption: ${vehicle.averageFuelConsumption.toStringAsFixed(2)}km/L",
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              )),
              Column(
                children: [
                  IconButton(
                    onPressed: () {
                      Navigator.pushNamed(
                          context, UpdateVehicleScreen.routeName,
                          arguments: vehicle);
                    },
                    icon: const Icon(
                      Icons.edit,
                      color: AppPallete.primaryColor,
                    ),
                  ),
                  IconButton(
                    onPressed: () {
                      context.read<VehicleBloc>().add(
                          DeleteVehicleEvent(vehicleId: vehicle.vehicleId));
                    },
                    icon: const Icon(
                      Icons.delete,
                      color: AppPallete.errorColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
