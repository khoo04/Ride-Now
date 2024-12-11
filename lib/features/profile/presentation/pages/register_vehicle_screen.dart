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

class RegisterVehicleScreen extends StatefulWidget {
  static const routeName = '/register-vehicle';
  const RegisterVehicleScreen({super.key});

  @override
  State<RegisterVehicleScreen> createState() => _RegisterVehicleScreenState();
}

class _RegisterVehicleScreenState extends State<RegisterVehicleScreen> {
  final _registerVehicleFormKey = GlobalKey<FormState>();
  final _carManufacturerController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carRegistrationNumberController = TextEditingController();
  final _fuelConsumptionController = TextEditingController();
  int _vehicleType = 1;
  int _seatNumber = 1;

  /// 0 - Represent km/L
  /// 1 - Represent L/100km
  int _selectedUnit = 0;

  // Errors Text
  String? _vehicleManufacturerError;
  String? _vehicleModelError;
  String? _vehicleRegistrationNumberError;
  String? _fuelConsumptionError;
  @override
  Widget build(BuildContext context) {
    final vehicleBloc = context.read<VehicleBloc>();
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
              key: _registerVehicleFormKey,
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
                            arguments: "register")
                        .then((_) {
                      // This block is executed when the screen popped back
                      vehicleBloc.add(FetchUserVehicles());
                    });
                  }
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Register Your Vehicle",
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
                      initialSelection: 1,
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
                          value: 1,
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
                                      if (_registerVehicleFormKey.currentState!
                                          .validate()) {
                                        final manufacturer =
                                            _carManufacturerController.text
                                                .trim();
                                        final model =
                                            _carModelController.text.trim();
                                        final registrationNumber =
                                            _carRegistrationNumberController
                                                .text
                                                .trim()
                                                .replaceAll(' ', '');
                                        final vehicleType = _vehicleType;
                                        final seats = _seatNumber;
                                        late double fuelConsumption;
                                        if (_selectedUnit == 1) {
                                          fuelConsumption =
                                              convertLPer100KmToKmPerL(
                                                  double.parse(
                                                      _fuelConsumptionController
                                                          .text
                                                          .trim()));
                                        } else {
                                          fuelConsumption = double.parse(
                                              _fuelConsumptionController.text
                                                  .trim());
                                        }

                                        context.read<VehicleBloc>().add(
                                              CreateVehicleEvent(
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
                                  : const Text("Register Vehicle"),
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
