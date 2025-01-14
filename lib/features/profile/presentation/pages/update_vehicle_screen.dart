import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:ride_now_app/core/common/enums/vehicle_type.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/convert_fuel_consumption_unit.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/core/utils/string_extension.dart';
import 'package:ride_now_app/features/profile/presentation/bloc/vehicle/vehicle_bloc.dart';
import 'package:ride_now_app/features/profile/presentation/pages/vehicle_action_success_screen.dart';
import 'package:ride_now_app/features/profile/presentation/widgets/vehicle_input_field.dart';
import 'package:ride_now_app/features/ride/domain/entities/vehicle.dart';

class UpdateVehicleScreen extends StatefulWidget {
  static const routeName = '/manage-vehicle/update';
  const UpdateVehicleScreen({super.key});

  @override
  State<UpdateVehicleScreen> createState() => _UpdateVehicleScreenState();
}

class _UpdateVehicleScreenState extends State<UpdateVehicleScreen> {
  late final _vehicleBloc;
  final _updateVehicleFormKey = GlobalKey<FormState>();
  final _carManufacturerController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carRegistrationNumberController = TextEditingController();
  final _fuelConsumptionController = TextEditingController();
  int _vehicleType = 1;
  int _seatNumber = 1;

  /// 0 - Represent km/L
  /// 1 - Represent L/100km
  int _selectedUnit = 0;
  bool isInitialized = false;

  // Errors Text
  String? _vehicleManufacturerError;
  String? _vehicleModelError;
  String? _vehicleRegistrationNumberError;
  String? _fuelConsumptionError;

  @override
  void initState() {
    _vehicleBloc = context.read<VehicleBloc>();
    super.initState();
  }

  @override
  void dispose() {
    if (_vehicleBloc.state is VehicleRegisterFailure) {
      _vehicleBloc.add(FetchUserVehicles());
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vehicleToUpdate =
        ModalRoute.of(context)!.settings.arguments as Vehicle;

    if (!isInitialized) {
      _carManufacturerController.text = vehicleToUpdate.manufacturer;
      _carModelController.text = vehicleToUpdate.model;
      _carRegistrationNumberController.text =
          vehicleToUpdate.vehicleRegistrationNumber;
      _fuelConsumptionController.text =
          vehicleToUpdate.averageFuelConsumption.toStringAsFixed(2);
      _vehicleType = vehicleToUpdate.vehicleType.index + 1;
      _seatNumber = vehicleToUpdate.seats;

      isInitialized = true;
    }

    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          leading: NavigateBackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
            ),
            child: Form(
              key: _updateVehicleFormKey,
              child: BlocListener<VehicleBloc, VehicleState>(
                listener: (context, state) {
                  setState(() {
                    _vehicleManufacturerError = _vehicleModelError =
                        _vehicleRegistrationNumberError =
                            _fuelConsumptionError = null;
                  });

                  if (state is VehicleRegisterFailure) {
                    _showErrosHint(state.registrationErrors);
                  } else if (state is VehicleRegisterSuccess) {
                    Navigator.of(context)
                        .popAndPushNamed(VehicleActionSuccessScreen.routeName,
                            arguments: "update")
                        .then((_) {
                      // This block is executed when the screen popped back
                      _vehicleBloc.add(FetchUserVehicles());
                    });
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Update Your Vehicle",
                      style: TextStyle(
                          fontSize: 24.0, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 40,
                    ),
                    const Text(
                      "Vehicle Type",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 8,
                    ),
                    DropdownMenu(
                      inputDecorationTheme: const InputDecorationTheme(
                        errorMaxLines: 5,
                        floatingLabelStyle:
                            TextStyle(color: AppPallete.primaryColor),
                        filled: true,
                        fillColor: AppPallete.actionBgColor,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppPallete.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppPallete.primaryColor),
                        ),
                      ),
                      initialSelection: vehicleToUpdate.vehicleType.index + 1,
                      onSelected: (value) {
                        _vehicleType = value!;
                      },
                      expandedInsets: EdgeInsets.zero,
                      dropdownMenuEntries: VehicleType.values
                          .map(
                            (e) => DropdownMenuEntry(
                              value: e.index + 1,
                              label: e.name.capitalize(),
                            ),
                          )
                          .toList(),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Vehicle Details",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: VehicleInputField(
                        labelText: "Vehicle Manufacturer",
                        controller: _carManufacturerController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vehicle manufacturer is required";
                          } else if (!RegExp(r'^[a-zA-Z0-9 ]+$')
                              .hasMatch(value)) {
                            return "Only alphabets, numbers and spaces are allowed";
                          }
                          return null;
                        },
                        errorText: _vehicleManufacturerError,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: VehicleInputField(
                        labelText: "Vehicle Model",
                        controller: _carModelController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vehicle model is required";
                          } else if (!RegExp(r'^[a-zA-Z0-9 ]+$')
                              .hasMatch(value)) {
                            return "Only alphabets, numbers and spaces are allowed";
                          }
                          return null;
                        },
                        errorText: _vehicleModelError,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: VehicleInputField(
                        labelText: "Vehicle Registration Number",
                        controller: _carRegistrationNumberController,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vehicle registration number is required";
                          } else if (!RegExp(r'^[a-zA-Z0-9 ]+$')
                              .hasMatch(value)) {
                            return "Only alphabets, numbers and spaces are allowed";
                          }
                          return null;
                        },
                        errorText: _vehicleRegistrationNumberError,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: SizedBox(
                        width: 150,
                        child: SpinBox(
                          decoration: const InputDecoration(
                            errorMaxLines: 5,
                            floatingLabelStyle:
                                TextStyle(color: AppPallete.primaryColor),
                            labelText: 'Number of seats',
                            filled: true,
                            fillColor: AppPallete.actionBgColor,
                            border: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppPallete.borderColor),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  BorderSide(color: AppPallete.primaryColor),
                            ),
                          ),
                          readOnly: true,
                          min: 1,
                          value: _seatNumber.toDouble(),
                          onChanged: (value) {
                            _seatNumber = value.toInt();
                          },
                        ),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 20.0),
                      child: Text(
                        "Average Fuel Consumptions",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.w600),
                      ),
                    ),
                    DropdownMenu(
                      inputDecorationTheme: const InputDecorationTheme(
                        errorMaxLines: 5,
                        floatingLabelStyle:
                            TextStyle(color: AppPallete.primaryColor),
                        filled: true,
                        fillColor: AppPallete.actionBgColor,
                        border: OutlineInputBorder(
                          borderSide: BorderSide(color: AppPallete.borderColor),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: AppPallete.primaryColor),
                        ),
                      ),
                      label: const Text("Unit"),
                      initialSelection: 0,
                      expandedInsets: EdgeInsets.zero,
                      dropdownMenuEntries: const [
                        DropdownMenuEntry(value: 0, label: "km/L"),
                        DropdownMenuEntry(value: 1, label: "L/100km"),
                      ],
                      onSelected: (value) {
                        _selectedUnit = value!;
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20),
                      child: VehicleInputField(
                        labelText: "Fuel Consumption",
                        controller: _fuelConsumptionController,
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Vehicle average fuel consumptions is required";
                          } else if (!RegExp(r'^[0-9.]+$').hasMatch(value)) {
                            return "Only numbers are allowed";
                          }
                          return null;
                        },
                        errorText: _fuelConsumptionError,
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0, bottom: 30.0),
                      child: Align(
                        alignment: Alignment.center,
                        child: BlocBuilder<VehicleBloc, VehicleState>(
                          builder: (context, state) {
                            return AppButton(
                              onPressed: state is VehicleLoading
                                  ? null
                                  : () {
                                      if (_updateVehicleFormKey.currentState!
                                          .validate()) {
                                        String? manufacturer =
                                            (_carManufacturerController.text
                                                        .trim() !=
                                                    vehicleToUpdate
                                                        .manufacturer)
                                                ? _carManufacturerController
                                                    .text
                                                    .trim()
                                                : null;

                                        String? model = (_carModelController
                                                    .text
                                                    .trim() !=
                                                vehicleToUpdate.model)
                                            ? _carModelController.text.trim()
                                            : null;

                                        String? registrationNumber =
                                            (_carRegistrationNumberController
                                                        .text
                                                        .trim() !=
                                                    vehicleToUpdate
                                                        .vehicleRegistrationNumber)
                                                ? _carRegistrationNumberController
                                                    .text
                                                    .trim()
                                                    .replaceAll(' ', '')
                                                : null;

                                        int? vehicleType = (_vehicleType !=
                                                vehicleToUpdate
                                                        .vehicleType.index +
                                                    1)
                                            ? _vehicleType
                                            : null;

                                        int? seats = (_seatNumber !=
                                                vehicleToUpdate.seats)
                                            ? _seatNumber
                                            : null;

                                        double? fuelConsumption =
                                            (_fuelConsumptionController.text
                                                            .trim() !=
                                                        vehicleToUpdate
                                                            .averageFuelConsumption
                                                            .toStringAsFixed(
                                                                2) ||
                                                    _selectedUnit == 1)
                                                ? double.parse(
                                                    _fuelConsumptionController
                                                        .text
                                                        .trim())
                                                : null;

                                        if (fuelConsumption != null) {
                                          fuelConsumption =
                                              convertLPer100KmToKmPerL(
                                                  fuelConsumption);
                                        }

                                        context.read<VehicleBloc>().add(
                                              UpdateVehicleEvent(
                                                vehicleId:
                                                    vehicleToUpdate.vehicleId,
                                                vehicleRegistrationNumber:
                                                    registrationNumber,
                                                manufacturer: manufacturer,
                                                model: model,
                                                seats: seats,
                                                averageFuelConsumptions:
                                                    fuelConsumption,
                                                vehicleTypeId: vehicleType,
                                              ),
                                            );
                                      }
                                    },
                              child: state is VehicleLoading
                                  ? const CircularProgressIndicator(
                                      color: AppPallete.primaryColor,
                                    )
                                  : const Text("Update Vehicle"),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showErrosHint(Map<String, String> errors) {
    setState(() {
      _vehicleManufacturerError = errors["manufacturer"];
      _vehicleModelError = errors["model"];
      _vehicleRegistrationNumberError = errors["vehicle_registration_number"];
      _fuelConsumptionError = errors["average_fuel_consumptions"];
    });
  }
}
