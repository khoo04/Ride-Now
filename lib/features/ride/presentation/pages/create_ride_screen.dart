import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/loading_button.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/format_date.dart';
import 'package:ride_now_app/core/utils/format_time.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/core/utils/simple_alert_dialog.dart';
import 'package:ride_now_app/features/profile/presentation/pages/register_vehicle_screen.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_create/ride_create_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_main/ride_main_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/pages/create_ride_success_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/search_location_screen.dart';
import 'package:ride_now_app/features/ride/presentation/widgets/ride_input_field.dart';

class CreateRideScreen extends StatefulWidget {
  const CreateRideScreen({super.key});

  @override
  State<CreateRideScreen> createState() => _CreateRideScreenState();
}

class _CreateRideScreenState extends State<CreateRideScreen> {
  final _createRideFormKey = GlobalKey<FormState>();
  final dateTimeController = TextEditingController();
  final fromLocationController = TextEditingController();
  final toLocationController = TextEditingController();
  final baseCostController = TextEditingController();
  late final RideCreateBloc _rideCreateBloc;
  Vehicle? selectedVehicle;
  DateTime? selectedDepartureTime;

  @override
  void initState() {
    _rideCreateBloc = context.read<RideCreateBloc>();
    _rideCreateBloc.add(InitializeCreateRideEvent());
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
        resizeToAvoidBottomInset: true,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0),
          child: BlocConsumer<RideCreateBloc, RideCreateState>(
            listener: (context, state) {
              if (state is RideCreateInitial) {
                if (state.vehicles.isEmpty) {
                  showSimpleAlertDialog(
                    context,
                    "No Vehicles Registered",
                    "You need to register a vehicle before creating a ride.",
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
              } else if (state is RideCreateSuccess) {
                Navigator.pushNamed(context, CreateRideSuccessScreen.routeName)
                    .then((_) {
                  _rideCreateBloc.add(InitializeCreateRideEvent());
                  //Refresh Main Screen
                  if (context.mounted) {
                    context
                        .read<RideMainBloc>()
                        .add(const RetrieveAvailabeRides());
                  }
                });
              } else if (state is RideCreateFailure) {
                showSnackBar(context, state.message);
                _rideCreateBloc.add(InitializeCreateRideEvent());
              }
            },
            builder: (context, state) {
              List<Vehicle> userVehicles = [];
              Map<String, String>? errors;

              if (state is RideCreateInitial) {
                errors = state.validationErrors;
                userVehicles = state.vehicles;
                dateTimeController.text = state.departureDateTime != null
                    ? "${formatDate(state.departureDateTime!)} ${formatTime(state.departureDateTime!)}"
                    : '';
                fromLocationController.text = state.fromPlace?.name ?? '';
                toLocationController.text = state.toPlace?.name ?? '';
                baseCostController.text =
                    state.priceSuggstion?.toStringAsFixed(2) ?? '';
                if (userVehicles.isNotEmpty && state.selectedVehicle == null) {
                  selectedVehicle = userVehicles.first;
                  _rideCreateBloc.add(
                    UpdateCreateRideParams(selectedVehicle: selectedVehicle),
                  );
                }
              } else if (state is RideCreateLoading) {
                userVehicles = state.vehicles;
                fromLocationController.text = state.fromPlace?.name ?? '';
                toLocationController.text = state.toPlace?.name ?? '';
                baseCostController.text =
                    state.priceSuggstion?.toStringAsFixed(2) ?? '';
                if (userVehicles.isNotEmpty && state.selectedVehicle == null) {
                  selectedVehicle = userVehicles.first;
                  _rideCreateBloc.add(
                    UpdateCreateRideParams(selectedVehicle: selectedVehicle),
                  );
                }
              }

              return Form(
                key: _createRideFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      "Create a ride",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    Expanded(
                      child: SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
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
                                  return "Origin location cannot be empty";
                                }
                                return null;
                              },
                              onTap: () {
                                Navigator.of(context).pushNamed(
                                    SearchLocationScreen.routeName,
                                    arguments: {
                                      "locationType": "from",
                                      "action": "create",
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
                                      "action": "create",
                                    });
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
                                //TODO: Iff the date time is picked, start with the picked date time
                                final result = await showBoardDateTimePicker(
                                  context: context,
                                  pickerType: DateTimePickerType.datetime,
                                  initialDate: selectedDepartureTime,
                                );
                                if (result == null) return;
                                dateTimeController.text =
                                    "${formatDate(result)} ${formatTime(result)}";
                                selectedDepartureTime = result;
                                _rideCreateBloc.add(
                                  UpdateCreateRideParams(
                                      departureTime: selectedDepartureTime),
                                );
                              },
                              validator: (departureDateTime) {
                                if (departureDateTime == null ||
                                    departureDateTime == "") {
                                  return "Departure time cannot be empty";
                                } else if (selectedDepartureTime!
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
                              initialSelection: userVehicles.isEmpty ||
                                      selectedVehicle == null
                                  ? -1
                                  : selectedVehicle!.vehicleId,
                              expandedInsets: EdgeInsets.zero,
                              dropdownMenuEntries: userVehicles.isEmpty ||
                                      selectedVehicle == null
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

                                _rideCreateBloc.add(
                                  UpdateCreateRideParams(
                                      selectedVehicle: vehicle),
                                );
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
                                  return "Base cost cannot be empty";
                                }
                                return null;
                              },
                              keyboardType: TextInputType.number,
                              onChanged: (price) {
                                //TODO: Change the logic
                                // Extract only digits and the decimal point from the input
                                String extractedNumber =
                                    price.replaceAll(RegExp('[^0-9]'), '');

                                if (extractedNumber.length >= 2) {
                                  //If number length is have more than 2 places, add the '.'
                                  extractedNumber =
                                      "${extractedNumber.substring(0, extractedNumber.length - 2)}.${extractedNumber.substring(extractedNumber.length - 2)}";
                                } else {
                                  extractedNumber =
                                      "0.${extractedNumber.padLeft(2, '0')}";
                                }
                                //Replace 0 for start of line
                                extractedNumber = extractedNumber.replaceFirst(
                                    RegExp('0'), '');

                                if (extractedNumber.startsWith(".")) {
                                  extractedNumber = '0$extractedNumber';
                                }
                                // Ensure a valid double value
                                final userInputPrice =
                                    double.tryParse(extractedNumber) ?? 0.0;
                                baseCostController.text = extractedNumber;

                                // Use the parsed price in your function
                                _rideCreateBloc.add(UpdateCreateRideParams(
                                    price: userInputPrice));
                              },
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
                                      _rideCreateBloc.add(
                                        const GetRidePriceSuggestion(),
                                      );
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
                        child: state is RideCreateLoading
                            ? const LoadingButton()
                            : AppButton(
                                onPressed: userVehicles.isEmpty
                                    ? null
                                    : () {
                                        if (_createRideFormKey.currentState!
                                            .validate()) {
                                          _rideCreateBloc
                                              .add(const CreateRideEvent());
                                        }
                                      },
                                child: const Text("Create New Ride"),
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
