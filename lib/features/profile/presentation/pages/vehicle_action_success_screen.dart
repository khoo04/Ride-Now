import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/features/profile/presentation/bloc/vehicle/vehicle_bloc.dart';

class VehicleActionSuccessScreen extends StatelessWidget {
  static const routeName = "/manage-vehicle/success";
  const VehicleActionSuccessScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final arguments = ModalRoute.of(context)!.settings.arguments as String;
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          leading: NavigateBackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: arguments == "register "
            ? _registerSuccessView()
            : _updateSuccessView(),
      ),
    );
  }

  BlocBuilder<VehicleBloc, VehicleState> _updateSuccessView() {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        if (state is! VehicleRegisterSuccess) {
          return const SizedBox.shrink();
        }
        final vehicle = state.vehicle;
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
                        "assets/images/vehicle_success.png",
                        width: MediaQuery.of(context).size.width * 0.3,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const Text(
                        "Success! Your vehicle has been updated!",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Vehicle ${vehicle.manufacturer} ${vehicle.model} with ${vehicle.seats} seats has been updated.",
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
                      Navigator.of(context).pop();
                    },
                    child: const Text("Back"),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }

  BlocBuilder<VehicleBloc, VehicleState> _registerSuccessView() {
    return BlocBuilder<VehicleBloc, VehicleState>(
      builder: (context, state) {
        if (state is! VehicleRegisterSuccess) {
          return const SizedBox.shrink();
        }
        final vehicle = state.vehicle;
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
                        "assets/images/vehicle_success.png",
                        width: MediaQuery.of(context).size.width * 0.3,
                      ),
                      const SizedBox(
                        height: 24,
                      ),
                      const Text(
                        "Success! Your vehicle has been registered!",
                        style: TextStyle(
                            fontSize: 24, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Text(
                        "Vehicle ${vehicle.manufacturer} ${vehicle.model} with ${vehicle.seats} seats has been registered.",
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
                      Navigator.of(context).pop();
                    },
                    child: const Text("Back"),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}
