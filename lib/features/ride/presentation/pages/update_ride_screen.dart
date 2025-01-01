import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/format_date.dart';
import 'package:ride_now_app/core/utils/format_time.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/core/utils/simple_alert_dialog.dart';
import 'package:ride_now_app/features/profile/presentation/pages/register_vehicle_screen.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_main/ride_main_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/ride_update/ride_update_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/your_ride_list/your_ride_list_cubit.dart';

import 'package:ride_now_app/features/ride/presentation/pages/search_location_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/update_ride_success_screen.dart';
import 'package:ride_now_app/features/ride/presentation/widgets/ride_input_field.dart';

class UpdateRideScreen extends StatefulWidget {
  static const routeName = '/edit-ride';
  const UpdateRideScreen({super.key});

  @override
  State<UpdateRideScreen> createState() => _UpdateRideScreenState();
}

class _UpdateRideScreenState extends State<UpdateRideScreen> {
  final _updateRideFormKey = GlobalKey<FormState>();
  final dateTimeController = TextEditingController();
  final fromLocationController = TextEditingController();
  final toLocationController = TextEditingController();
  final baseCostController = TextEditingController();
  late final RideUpdateCubit _rideUpdateCubit;

  @override
  void initState() {
    _rideUpdateCubit = context.read<RideUpdateCubit>();
    super.initState();
  }

  @override
  void dispose() {
    dateTimeController.dispose();
    fromLocationController.dispose();
    toLocationController.dispose();
    baseCostController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          leading: NavigateBackButton(onPressed: () {
            Navigator.pop(context);
          }),
        ),
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: BlocConsumer<RideUpdateCubit, RideUpdateState>(
            listener: (context, state) {
              if (state is RideUpdateInitial) {
                if (state.userVehicles!.isEmpty) {
                  showSimpleAlertDialog(
                    context,
                    "No Vehicles Registered",
                    "You need to register a vehicle before updating a ride.",
                    [
                      TextButton(
                        onPressed: () {
                          Navigator.of(context).pop(); // Close the dialog
                          Navigator.of(context)
                              .pushNamed(RegisterVehicleScreen.routeName);
                        },
                        child: const Text(
                          'Register Now',
                          style: TextStyle(
                            color: AppPallete.primaryColor,
                          ),
                        ),
                      ),
                    ],
                  );
                }
              } else if (state is RideUpdateFailure) {
                showSnackBar(context, state.message);
              } else if (state is RideUpdateSuccess) {
                //Update the ride in ride list
                context
                    .read<RideMainBloc>()
                    .add(UpdateSpecificRideInList(ride: state.ride));
                context.read<YourRideListCubit>().updateRideInList(state.ride);
                Navigator.popAndPushNamed(
                    context, UpdateRideSuccessScreen.routeName);
              }
            },
            builder: (context, state) {
              if (state is RideUpdatePageLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppPallete.primaryColor,
                  ),
                );
              } else if (state is! RideUpdateInitial) {
                return const SizedBox.shrink();
              }

              List<Vehicle> userVehicles = [];
              late DateTime departureTime;
              late Vehicle selectedVehicle;
              Map<String, String>? errors;

              final ride = state.rideToUpdate!;

              errors = state.validationErrors;

              userVehicles = state.userVehicles!;
              departureTime = state.departureTime == null
                  ? ride.departureTime
                  : state.departureTime!;

              fromLocationController.text =
                  state.origin == null ? ride.origin.name : state.origin!.name;

              toLocationController.text = state.destination == null
                  ? ride.destination.name
                  : state.destination!.name;

              dateTimeController.text = state.departureTime == null
                  ? "${formatDate(ride.departureTime)} ${formatTime(ride.departureTime)}"
                  : "${formatDate(state.departureTime!)} ${formatTime(state.departureTime!)}";

              baseCostController.text = state.price == null
                  ? ride.baseCost.toStringAsFixed(2)
                  : state.price!.toStringAsFixed(2);

              selectedVehicle = state.selectedVehicle == null
                  ? ride.vehicle
                  : state.selectedVehicle!;

              return Form(
                key: _updateRideFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Update Ride",
                              style: TextStyle(
                                  fontSize: 32, fontWeight: FontWeight.w500),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              "Where are you going?",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            RideInputField(
                              labelText: "From",
                              controller: fromLocationController,
                              readOnly: true,
                              validator: (fromLocation) {
                                if (fromLocation == null ||
                                    fromLocation == "") {
                                  return "Origin location is required";
                                }
                                return null;
                              },
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    SearchLocationScreen.routeName,
                                    arguments: {
                                      "locationType": "from",
                                      "action": "update",
                                    });
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            RideInputField(
                              labelText: "To",
                              controller: toLocationController,
                              readOnly: true,
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    SearchLocationScreen.routeName,
                                    arguments: {
                                      "locationType": "to",
                                      "action": "update",
                                    });
                              },
                              validator: (toLocation) {
                                if (toLocation == null || toLocation == "") {
                                  return "Destination location is required";
                                }
                                return null;
                              },
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            const Text(
                              "When?",
                              style: TextStyle(
                                  fontSize: 18, fontWeight: FontWeight.w600),
                            ),
                            const SizedBox(
                              height: 20,
                            ),
                            RideInputField(
                              errorText: errors?["departure_time"],
                              labelText: "Date and Time",
                              controller: dateTimeController,
                              readOnly: true,
                              onTap: () async {
                                final result = await showBoardDateTimePicker(
                                  context: context,
                                  pickerType: DateTimePickerType.datetime,
                                  initialDate: departureTime,
                                );
                                if (result == null) return;
                                departureTime = result;
                                dateTimeController.text =
                                    "${formatDate(result)} ${formatTime(result)}";
                                _rideUpdateCubit.onChangeRideDetails(
                                    departureTime: result);
                              },
                              validator: (departureDateTime) {
                                if (departureDateTime == null ||
                                    departureDateTime == "") {
                                  return "Departure time is required";
                                } else if (departureTime
                                    .isBefore(DateTime.now())) {
                                  return "Departure time cannot be before current date and time";
                                }
                                return null;
                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                "Vehicle",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                            DropdownMenu(
                              enabled: userVehicles.isNotEmpty,
                              inputDecorationTheme: const InputDecorationTheme(
                                errorMaxLines: 5,
                                floatingLabelStyle:
                                    TextStyle(color: AppPallete.primaryColor),
                                filled: true,
                                fillColor: AppPallete.actionBgColor,
                                border: OutlineInputBorder(
                                  borderSide:
                                      BorderSide(color: AppPallete.borderColor),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                      color: AppPallete.primaryColor),
                                ),
                              ),
                              initialSelection: userVehicles.isEmpty
                                  ? -1
                                  : selectedVehicle.vehicleId,
                              expandedInsets: EdgeInsets.zero,
                              dropdownMenuEntries: userVehicles.isEmpty
                                  ? const [
                                      DropdownMenuEntry(
                                          value: -1,
                                          label: "No vehicles founded")
                                    ]
                                  : userVehicles
                                      .map((v) => DropdownMenuEntry(
                                          value: v.vehicleId,
                                          label:
                                              "${v.manufacturer} ${v.model} (${v.vehicleRegistrationNumber}) - ${v.seats} seats"))
                                      .toList(),
                              onSelected: (selectedVehicleId) {
                                final vehicle = userVehicles.firstWhere(
                                    (v) => v.vehicleId == selectedVehicleId!);
                                selectedVehicle = vehicle;

                                _rideUpdateCubit.onChangeRideDetails(
                                    selectedVehicle: vehicle);
                              },
                            ),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 20.0),
                              child: Text(
                                "Ride's Base Cost (RM)",
                                style: TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w600),
                              ),
                            ),
                            RideInputField(
                              labelText: "",
                              controller: baseCostController,
                              validator: (baseCost) {
                                if (baseCost == null || baseCost.isEmpty) {
                                  return "Base cost is required";
                                }
                                return null;
                              },
                              onChanged: (price) {
                                String extractedNumber =
                                    price.replaceAll(RegExp('[^0-9]'), '');

                                if (extractedNumber.isEmpty) {
                                  extractedNumber =
                                      '0.00'; // Default for empty input
                                } else if (extractedNumber.length == 1) {
                                  extractedNumber =
                                      '0.0$extractedNumber'; // Single digit input
                                } else if (extractedNumber.length == 2) {
                                  extractedNumber =
                                      '0.$extractedNumber'; // Two digits input
                                } else {
                                  extractedNumber =
                                      "${extractedNumber.substring(0, extractedNumber.length - 2)}.${extractedNumber.substring(extractedNumber.length - 2)}";
                                }
                                // Ensure a valid double value
                                final userInputPrice =
                                    double.tryParse(extractedNumber) ?? 0.0;
                                baseCostController.text = extractedNumber;

                                // Use the parsed price in your function
                                _rideUpdateCubit.onChangeRideDetails(
                                    price: userInputPrice);
                              },
                              keyboardType: TextInputType.number,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () {
                                    //Show Dialog if From and To Place is not set
                                    if (fromLocationController.text.isEmpty ||
                                        toLocationController.text.isEmpty) {
                                      String content = '';
                                      if (fromLocationController.text.isEmpty) {
                                        content += "Origin is not set!\n";
                                      }
                                      if (toLocationController.text.isEmpty) {
                                        content += "Destination is not set!\n";
                                      }

                                      showSimpleAlertDialog(
                                          context, "Error!", content, [
                                        TextButton(
                                            onPressed: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text("Noted"))
                                      ]);
                                    } else {
                                      _rideUpdateCubit
                                          .getLatestPriceSuggstion();
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppPallete.whiteColor,
                                    foregroundColor: AppPallete.primaryColor,
                                    elevation: 1,
                                    shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        side: const BorderSide(
                                          color: AppPallete.borderColor,
                                        )),
                                  ),
                                  icon: const Icon(Icons.lightbulb),
                                  label: const Text("Price Suggestion"),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 20.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: AppButton(
                          onPressed: userVehicles.isEmpty
                              ? null
                              : () {
                                  if (_updateRideFormKey.currentState!
                                      .validate()) {
                                    _rideUpdateCubit.onUpdateRide();
                                  }
                                },
                          child: const Text("Edit Ride"),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
