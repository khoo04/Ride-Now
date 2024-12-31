import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/features/profile/presentation/bloc/vehicle/vehicle_bloc.dart';
import 'package:ride_now_app/features/profile/presentation/pages/register_vehicle_screen.dart';
import 'package:ride_now_app/features/profile/presentation/widgets/manage_vehicle_card.dart';

class ManageVehiclesScreen extends StatefulWidget {
  static const routeName = '/manage-vehicle';
  const ManageVehiclesScreen({super.key});

  @override
  State<ManageVehiclesScreen> createState() => _ManageVehiclesScreenState();
}

class _ManageVehiclesScreenState extends State<ManageVehiclesScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VehicleBloc>().add(FetchUserVehicles());
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          leading: NavigateBackButton(onPressed: () {
            Navigator.of(context).pop();
          }),
          enabledBackground: true,
          title: const Text(
            "Manage Vehicles",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18.0,
          ),
          child: BlocConsumer<VehicleBloc, VehicleState>(
            listener: (context, state) {
              if (state is VehicleFailure) {
                showSnackBar(context, state.message);
                context.read<VehicleBloc>().add(FetchUserVehicles());
              } else if (state is VehicleDeleteSuccess) {
                showSnackBar(context, "Vehicle deleted successfully");
                context.read<VehicleBloc>().add(FetchUserVehicles());
              }
            },
            builder: (context, state) {
              if (state is VehicleLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppPallete.primaryColor,
                  ),
                );
              }
              if (state is VehicleDisplaySuccess) {
                final numOfItem = state.vehicles.length;
                final indexOfLastItem = numOfItem - 1;
                return state.vehicles.isEmpty
                    ? const Center(
                        child: Text("No Vehicles Founded"),
                      )
                    : ListView.separated(
                        itemBuilder: (context, index) {
                          final vehicle = state.vehicles[index];
                          if (index == 0) {
                            // Padding for the first element
                            return Padding(
                              padding: const EdgeInsets.only(top: 20),
                              child: ManageVehicleCard(
                                vehicle: vehicle,
                              ),
                            );
                          } else if (index == indexOfLastItem) {
                            // Padding for the last element
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 20),
                              child: ManageVehicleCard(vehicle: vehicle),
                            );
                          }
                          return ManageVehicleCard(vehicle: vehicle);
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(
                            height: 10,
                          );
                        },
                        itemCount: numOfItem,
                      );
              }
              return const SizedBox.shrink();
            },
          ),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.of(context).pushNamed(RegisterVehicleScreen.routeName);
          },
          label: const Text("New Vehicles"),
          icon: const Icon(Icons.add),
          backgroundColor: AppPallete.actionBgColor,
          foregroundColor: AppPallete.primaryColor,
        ),
      ),
    );
  }
}
