import 'package:flutter/material.dart';
import 'package:flutter_spinbox/flutter_spinbox.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/features/ride/domain/entities/auto_complete_prediction.dart';
import 'package:ride_now_app/features/ride/presentation/pages/search_location_screen.dart';
import 'package:ride_now_app/features/ride/presentation/widgets/ride_auto_complete_search_field.dart';
import 'package:ride_now_app/features/ride/presentation/widgets/ride_input_field.dart';

class SearchRideScreen extends StatefulWidget {
  static const routeName = '/search-ride';
  const SearchRideScreen({super.key});

  @override
  State<SearchRideScreen> createState() => _SearchRideScreenState();
}

class _SearchRideScreenState extends State<SearchRideScreen> {
  final _fromLocationController = TextEditingController();
  final _toLocationController = TextEditingController();
  final _dateTimeController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Find a ride",
              style: TextStyle(fontSize: 32, fontWeight: FontWeight.w500),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Where are you going?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 20,
            ),
            RideAutoCompleteSearchField(
              labelText: "From",
              controller: _fromLocationController,
            ),
            const SizedBox(
              height: 20,
            ),
            RideAutoCompleteSearchField(
              labelText: "To",
              controller: _toLocationController,
            ),
            const SizedBox(
              height: 20,
            ),
            //TODO: SHOW DATE TIME PICKER
            const Text(
              "When?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 20,
            ),
            RideInputField(
              labelText: "Date and Time",
              controller: _dateTimeController,
              focusNode: FocusNode(),
            ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Seat needed?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: 200,
              child: SpinBox(
                readOnly: true,
              ),
            ),
            const Spacer(
              flex: 3,
            ),
            Align(
              alignment: Alignment.center,
              child: AppButton(
                onPressed: () {
                  Navigator.of(context)
                      .pushNamed(SearchLocationScreen.routeName);
                },
                child: const Text("Search"),
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
