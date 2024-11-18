import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/features/ride/domain/entities/auto_complete_prediction.dart';
import 'package:ride_now_app/features/ride/domain/usecases/fetch_location_auto_complete_suggestion.dart';
import 'package:ride_now_app/features/ride/presentation/widgets/ride_input_field.dart';
import 'package:ride_now_app/init_dependencies.dart';

class SearchLocationScreen extends StatefulWidget {
  static const routeName = '/search-location';
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  CameraPosition? initCameraPosition;
  late Future<void> _locationFuture;
  final ValueNotifier<LatLng> _cameraPositionNotifier = ValueNotifier<LatLng>(
    const LatLng(0, 0),
  );
  Timer? _debounceTimer;
  AutoCompletePrediction? userSelectedPlace;

  @override
  void initState() {
    super.initState();
    _locationFuture = _determinePosition();
  }

  Future<void> _determinePosition() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final initPosition = await Geolocator.getCurrentPosition();

    final newPosition = LatLng(initPosition.latitude, initPosition.longitude);

    initCameraPosition = CameraPosition(
      target: newPosition,
      zoom: 18,
    );

    _cameraPositionNotifier.value = newPosition;
  }

  Future<List<AutoCompletePrediction>> _predictionsFromGoogleAPI(
      String query) async {
    final fetchLocationAutoCompleteSuggestion =
        serviceLocator<FetchLocationAutoCompleteSuggestion>();

    final res = await fetchLocationAutoCompleteSuggestion(
        FetchLocationAutoCompleteSuggestionParams(query: query));

    return res.fold((failure) {
      showSnackBar(context, failure.message);
      return List.empty();
    }, (predictions) {
      return predictions ?? List.empty();
    });
  }

  void _onSearchQueryChanged(String query,
      void Function(List<AutoCompletePrediction>) completeCallback) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration(seconds: 2), () async {
      final predictions = await _predictionsFromGoogleAPI(query);
      completeCallback(predictions);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            FutureBuilder<void>(
              future: _locationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // Map rebuilds only when _cameraPositionNotifier changes.
                return ValueListenableBuilder<LatLng>(
                  valueListenable: _cameraPositionNotifier,
                  builder: (context, cameraPosition, _) {
                    return GoogleMap(
                      mapType: MapType.normal,
                      initialCameraPosition: initCameraPosition!,
                      onMapCreated: (GoogleMapController controller) {
                        _controller.complete(controller);
                      },
                      zoomControlsEnabled: false,
                      mapToolbarEnabled: false,
                      myLocationButtonEnabled: false,
                      onCameraMove: (cameraPosition) {
                        _cameraPositionNotifier.value = cameraPosition.target;
                      },
                      markers: {
                        Marker(
                          markerId: const MarkerId("map_center_location"),
                          position: cameraPosition,
                        ),
                      },
                    );
                  },
                );
              },
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding:
                      const EdgeInsets.only(left: 18, right: 18, top: 24.0),
                  child: Autocomplete<AutoCompletePrediction>(
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      if (textEditingValue.text.isEmpty) {
                        return List.empty();
                      } else {
                        final completer =
                            Completer<List<AutoCompletePrediction>>();
                        _onSearchQueryChanged(
                            textEditingValue.text, completer.complete);
                        return completer.future;
                      }
                    },
                    fieldViewBuilder: (BuildContext context,
                        TextEditingController controller,
                        FocusNode focusNode,
                        VoidCallback onFieldSubmitted) {
                      return Row(
                        children: [
                          CupertinoNavigationBarBackButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: RideInputField(
                              labelText: "Enter an address",
                              focusNode: focusNode,
                              controller: controller,
                              onFieldSubmitted: (String value) {
                                onFieldSubmitted();
                              },
                              isDense: true,
                            ),
                          ),
                        ],
                      );
                    },
                    optionsViewBuilder: (BuildContext context,
                        AutocompleteOnSelected<AutoCompletePrediction>
                            onSelected,
                        Iterable<AutoCompletePrediction> options) {
                      return Align(
                        alignment: AlignmentDirectional.topStart,
                        child: Material(
                          elevation: 4.0,
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                                maxHeight: 200,
                                maxWidth: MediaQuery.of(context).size.width -
                                    (18 * 2)),
                            child: ListView.builder(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              itemBuilder: (BuildContext context, int index) {
                                final AutoCompletePrediction option =
                                    options.elementAt(index);
                                final bool highlight =
                                    AutocompleteHighlightedOption.of(context) ==
                                        index;
                                return ListTile(
                                  leading: const Icon(Icons.location_pin),
                                  tileColor: highlight
                                      ? Theme.of(context).focusColor
                                      : null,
                                  title: Text(
                                      option.structuredFormatting?.mainText ??
                                          "Unknown place"),
                                  subtitle: Text(option.structuredFormatting
                                          ?.secondaryText ??
                                      "Unknown address"),
                                  onTap: () {
                                    onSelected(option);
                                  },
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                    onSelected: (selectedOption) {
                      vLog(selectedOption.toString());
                      setState(() {
                        userSelectedPlace = selectedOption;
                      });
                    },
                    displayStringForOption: (option) =>
                        option.description ?? "Unknown Address",
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton.outlined(
                    padding: const EdgeInsets.all(8.0),
                    onPressed: () async {
                      vLog("Do something");
                      return;
                      await _determinePosition();
                      final GoogleMapController controller =
                          await _controller.future;
                      await controller.animateCamera(
                        CameraUpdate.newCameraPosition(initCameraPosition!),
                      );
                    },
                    icon: const Icon(Icons.my_location),
                  ),
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 200,
                  padding: const EdgeInsets.all(18.0),
                  decoration: const BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey,
                        spreadRadius: 2.0,
                        blurRadius: 8.0,
                        offset: Offset(0, 1),
                      ),
                    ],
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(12.0),
                      topRight: Radius.circular(12.0),
                    ),
                  ),
                  child: Column(
                    children: [
                      const Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          "From",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: Icon(Icons.location_pin),
                        title: Text(
                          userSelectedPlace?.structuredFormatting?.mainText ??
                              "Unknown place",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          userSelectedPlace
                                  ?.structuredFormatting?.secondaryText ??
                              "Unknown address",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        tileColor: Colors.white,
                      ),
                      const Spacer(),
                      AppButton(
                        onPressed: () {},
                        child: Text("Confirm Location"),
                      )
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
