import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/core/utils/string_extension.dart';
import 'package:ride_now_app/features/ride/domain/entities/auto_complete_prediction.dart';
import 'package:ride_now_app/features/ride/domain/entities/place_details.dart';
import 'package:ride_now_app/features/ride/domain/usecases/fetch_location_auto_complete_suggestion.dart';
import 'package:ride_now_app/features/ride/domain/usecases/fetch_place_details.dart';
import 'package:ride_now_app/features/ride/domain/usecases/geocoding_fetch_place_details.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_create/ride_create_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_search/ride_search_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/ride_update_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/pages/search_ride_screen.dart';
import 'package:ride_now_app/features/ride/presentation/widgets/ride_input_field.dart';
import 'package:ride_now_app/init_dependencies.dart';

class SearchLocationScreen extends StatefulWidget {
  static const routeName = '/search-location';
  const SearchLocationScreen({super.key});

  @override
  State<SearchLocationScreen> createState() => _SearchLocationScreenState();
}

class _SearchLocationScreenState extends State<SearchLocationScreen> {
  bool isSelectedViaSearch = false;
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  CameraPosition? initCameraPosition;
  late Future<void> _locationFuture;
  final ValueNotifier<LatLng> _cameraPositionNotifier = ValueNotifier<LatLng>(
    const LatLng(0, 0),
  );
  Timer? _debounceTimer;
  PlaceDetails? currentSelectedPlaces;

  @override
  void initState() {
    super.initState();
    _locationFuture = _determinePosition();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  Future<Position> getCurrentPosition() async {
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

    final currentPosition = await Geolocator.getCurrentPosition();

    return currentPosition;
  }

  Future<void> _determinePosition() async {
    try {
      final currentPosition = await getCurrentPosition();
      final newPosition =
          LatLng(currentPosition.latitude, currentPosition.longitude);

      initCameraPosition = CameraPosition(
        target: newPosition,
        zoom: 18,
      );

      _cameraPositionNotifier.value = newPosition;
    } catch (e) {
      rethrow;
    }
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
      if (mounted) {
        completeCallback(predictions);
      }
    });
  }

  Future<PlaceDetails?> _getSelectedPlaceDetailsById(String placeId) async {
    final fetchPlaceDetails = serviceLocator<FetchPlaceDetails>();

    final res = await fetchPlaceDetails(FetchPlaceDetailsParams(placeId));

    return res.fold((failure) {
      showSnackBar(context, failure.message);
      return null;
    }, (placeDetails) {
      return placeDetails;
    });
  }

  @override
  Widget build(BuildContext context) {
    //Retrieve Argument From Route
    final routeArgs =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>;
    final locationType =
        routeArgs["locationType"] as String; // Access "location type"
    final action = routeArgs["action"] as String; // Access "action"
    return SafeArea(
      child: Scaffold(
        body: Stack(
          clipBehavior: Clip.hardEdge,
          children: [
            FutureBuilder<void>(
              future: _locationFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: CircularProgressIndicator(
                    color: AppPallete.primaryColor,
                  ));
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      'Error: ${snapshot.error}',
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                // Map rebuilds only when _cameraPositionNotifier changes.
                return Listener(
                  onPointerDown: (e) {
                    isSelectedViaSearch = false;
                  },
                  child: ValueListenableBuilder<LatLng>(
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
                        onCameraIdle: () async {
                          if (isSelectedViaSearch) return;
                          final geocodingFetchPlaceDetails =
                              serviceLocator<GeocodingFetchPlaceDetails>();

                          final res = await geocodingFetchPlaceDetails(
                              GeocodingFetchPlaceDetailsParams(
                                  cameraPosition.latitude,
                                  cameraPosition.longitude));

                          return res.fold((failure) {
                            showSnackBar(context, failure.message);
                            return;
                          }, (placeDetails) async {
                            if (!mounted) return;
                            setState(() {
                              currentSelectedPlaces = placeDetails;
                            });
                          });
                        },
                        markers: {
                          Marker(
                            markerId: const MarkerId("map_center_location"),
                            position: cameraPosition,
                          ),
                        },
                      );
                    },
                  ),
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
                              suffixIcon: controller.text.isEmpty
                                  ? null
                                  : IconButton(
                                      onPressed: () {
                                        // Clear the text and reset the controller
                                        controller.clear();
                                        // Unfocus the text field
                                        focusNode.unfocus();
                                        setState(() {});
                                      },
                                      icon: const Icon(Icons.cancel),
                                    ),
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
                    onSelected: (selectedOption) async {
                      final selectedPlaceDetails =
                          await _getSelectedPlaceDetailsById(
                              selectedOption.placeId!);
                      if (selectedPlaceDetails == null || !mounted) return;
                      setState(() {
                        isSelectedViaSearch = true;
                        currentSelectedPlaces = selectedPlaceDetails;
                      });
                      final GoogleMapController controller =
                          await _controller.future;

                      await controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              selectedPlaceDetails.latitude,
                              selectedPlaceDetails.longitude,
                            ),
                            zoom: 18,
                          ),
                        ),
                      );
                    },
                    displayStringForOption: (option) =>
                        option.description ?? "Unknown Address",
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: IconButton.outlined(
                    padding: const EdgeInsets.all(8.0),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.white,
                    ),
                    onPressed: () async {
                      final currentPosition = await getCurrentPosition();
                      final GoogleMapController controller =
                          await _controller.future;
                      await controller.animateCamera(
                        CameraUpdate.newCameraPosition(
                          CameraPosition(
                            target: LatLng(
                              currentPosition.latitude,
                              currentPosition.longitude,
                            ),
                            zoom: 18,
                          ),
                        ),
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
                      Align(
                        alignment: Alignment.topLeft,
                        child: Text(
                          locationType.capitalize(),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      ListTile(
                        leading: const Icon(Icons.location_pin),
                        title: Text(
                          currentSelectedPlaces?.name ?? "Unknown place",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          currentSelectedPlaces?.formattedAddress ??
                              "Unknown address",
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        tileColor: Colors.white,
                      ),
                      const Spacer(),
                      AppButton(
                        onPressed: currentSelectedPlaces == null
                            ? null
                            : () {
                                if (currentSelectedPlaces == null) {
                                  showSnackBar(
                                      context, "Location does not selected");
                                  return;
                                }
                                if (locationType == "from") {
                                  if (action == "search") {
                                    context.read<RideSearchBloc>().add(
                                          UpdateRideSearchOrigin(
                                            currentSelectedPlaces!,
                                          ),
                                        );
                                    Navigator.of(context).popUntil(
                                        ModalRoute.withName(
                                            SearchRideScreen.routeName));
                                  } else if (action == "create") {
                                    //Create Action
                                    context.read<RideCreateBloc>().add(
                                        UpdateCreateRideParams(
                                            origin: currentSelectedPlaces));
                                    Navigator.pop(context);
                                  } else if (action == "update") {
                                    //Update Action
                                    context
                                        .read<RideUpdateCubit>()
                                        .onChangeRideDetails(
                                            origin: currentSelectedPlaces!);
                                    Navigator.pop(context);
                                  }
                                } else if (locationType == "to") {
                                  if (action == "search") {
                                    context.read<RideSearchBloc>().add(
                                          UpdateRideSearchDestination(
                                            currentSelectedPlaces!,
                                          ),
                                        );
                                    Navigator.of(context).popUntil(
                                        ModalRoute.withName(
                                            SearchRideScreen.routeName));
                                  } else if (action == "create") {
                                    //Create Action
                                    context.read<RideCreateBloc>().add(
                                        UpdateCreateRideParams(
                                            destination:
                                                currentSelectedPlaces));
                                    Navigator.pop(context);
                                  } else if (action == "update") {
                                    //Update Action
                                    context
                                        .read<RideUpdateCubit>()
                                        .onChangeRideDetails(
                                            destination:
                                                currentSelectedPlaces!);
                                    Navigator.pop(context);
                                  }
                                } else {
                                  Navigator.of(context).pop();
                                }
                              },
                        child: const Text("Confirm Location"),
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
