import 'package:board_datetime_picker/board_datetime_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/format_date.dart';
import 'package:ride_now_app/core/utils/format_time.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_search/ride_search_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/pages/search_location_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/search_ride_result_screen.dart';
import 'package:ride_now_app/features/ride/presentation/widgets/ride_input_field.dart';

class SearchRideScreen extends StatefulWidget {
  static const routeName = '/search-ride';
  const SearchRideScreen({super.key});

  @override
  State<SearchRideScreen> createState() => _SearchRideScreenState();
}

class _SearchRideScreenState extends State<SearchRideScreen> {
  final _searchRideFormKey = GlobalKey<FormState>();
  late final RideSearchBloc _rideSearchBloc;

  @override
  void initState() {
    _rideSearchBloc = context.read<RideSearchBloc>();
    super.initState();
  }

  @override
  void dispose() {
    //Reset the state when widget dispose
    _rideSearchBloc.add(ResetRideSearchState());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final fromLocationController = TextEditingController();
    final toLocationController = TextEditingController();
    final dateTimeController = TextEditingController();

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: MyAppBar(
          leading: NavigateBackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
          child: BlocConsumer<RideSearchBloc, RideSearchState>(
            listener: (context, state) {
              if (state is RideSearchSuccess) {
                Navigator.of(context)
                    .pushNamed(SearchRideResultScreen.routeName)
                    .then((_) {
                  _rideSearchBloc.add(ResetRideSearchState());
                });
              } else if (state is RideSearchFailure) {
                showSnackBar(context, state.message);
                _rideSearchBloc.add(ResetRideSearchState());
              }
            },
            builder: (context, state) {
              int seats = 1;
              if (state is RideSearchInitial) {
                fromLocationController.text = state.fromPlace?.name ?? "";
                toLocationController.text = state.toPlace?.name ?? "";
                seats = state.seats;

                if (state.dateTime != null) {
                  dateTimeController.text =
                      "${formatDate(state.dateTime!)} ${formatTime(state.dateTime!)}";
                }
              } else if (state is RideSearchLoading) {
                fromLocationController.text = state.fromPlace?.name ?? "";
                toLocationController.text = state.toPlace?.name ?? "";
                seats = state.seats;

                if (state.dateTime != null) {
                  dateTimeController.text =
                      "${formatDate(state.dateTime!)} ${formatTime(state.dateTime!)}";
                }
              }

              return Form(
                key: _searchRideFormKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Find a ride",
                      style:
                          TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Where are you going?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    RideInputField(
                      labelText: "From",
                      controller: fromLocationController,
                      readOnly: true,
                      validator: (fromLocation) {
                        if (fromLocation == null || fromLocation == "") {
                          return "Origin location cannot be empty";
                        }
                        return null;
                      },
                      onTap: () {
                        Navigator.of(context).pushNamed(
                            SearchLocationScreen.routeName,
                            arguments: {
                              "locationType": "from",
                              "action": "search",
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
                              "action": "search",
                            });
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "When?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    RideInputField(
                      labelText: "Date and Time",
                      controller: dateTimeController,
                      readOnly: true,
                      onTap: () async {
                        final result = await showBoardDateTimePicker(
                          context: context,
                          pickerType: DateTimePickerType.datetime,
                        );
                        if (result == null) return;
                        _rideSearchBloc.add(UpdateRideSearchDateTime(result));
                        dateTimeController.text =
                            "${formatDate(result)} ${formatTime(result)}";
                      },
                      validator: (departureDateTime) {
                        if (departureDateTime == null ||
                            departureDateTime == "") {
                          return "Departure time cannot be empty";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    const Text(
                      "Seat needed?",
                      style:
                          TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width: 150,
                      child: SpinBox(
                        readOnly: true,
                        min: 1,
                        value: seats.toDouble(),
                        onChanged: (value) {
                          _rideSearchBloc
                              .add(UpdateRideSearchSeats(value.toInt()));
                        },
                      ),
                    ),
                    const Spacer(
                      flex: 3,
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: AppButton(
                        onPressed: state is RideSearchLoading
                            ? null
                            : () {
                                if (_searchRideFormKey.currentState!
                                        .validate() &&
                                    state is RideSearchInitial) {
                                  _rideSearchBloc.add(
                                    SearchAvailableRidesEvent(
                                      fromPlace: state.fromPlace!,
                                      toPlace: state.toPlace,
                                      departureTime: state.dateTime!,
                                      seats: state.seats,
                                    ),
                                  );
                                }
                              },
                        child: state is RideSearchLoading
                            ? const CircularProgressIndicator(
                                color: AppPallete.whiteColor,
                              )
                            : const Text("Search"),
                      ),
                    ),
                    const SizedBox(
                      height: 20,
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
