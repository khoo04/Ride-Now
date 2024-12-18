import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:ride_now_app/core/common/entities/user.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/cubits/app_user/app_user_cubit.dart';
import 'package:ride_now_app/core/secrets/app_secret.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/format_date.dart';
import 'package:ride_now_app/core/utils/format_time.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/core/utils/open_contact_dialog.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride/ride_bloc.dart';
import 'package:url_launcher/url_launcher.dart';

class InAppNavigationScreen extends StatefulWidget {
  static const routeName = '/navigate';
  const InAppNavigationScreen({super.key});

  @override
  State<InAppNavigationScreen> createState() => _InAppNavigationScreenState();
}

class _InAppNavigationScreenState extends State<InAppNavigationScreen> {
  final DraggableScrollableController sheetController =
      DraggableScrollableController();
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  late Future<void> _initializeMapFuture;
  late CameraPosition initPosition;
  late StreamSubscription<Position> positionStream;
  late BitmapDescriptor originIcon;
  late BitmapDescriptor destinationIcon;
  late BitmapDescriptor myLocationIcon;

  final ValueNotifier<LatLng> _userCurrentPositionNotifier =
      ValueNotifier<LatLng>(const LatLng(0, 0));
  Map<PolylineId, Polyline> polylines = {};

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
      await Geolocator.openAppSettings();
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    final currentPosition = await Geolocator.getCurrentPosition();

    return currentPosition;
  }

  Future<void> _initializeMap() async {
    try {
      final currentPosition = await getCurrentPosition();
      final latLngCurrentPos =
          LatLng(currentPosition.latitude, currentPosition.longitude);

      initPosition = CameraPosition(
        target: latLngCurrentPos,
        zoom: 18,
      );

      _userCurrentPositionNotifier.value = latLngCurrentPos;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> loadCustomMarkerIcon() async {
    BitmapDescriptor oriIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), // Adjust the size as needed
      'assets/icons/origin_icon.png',
    );

    BitmapDescriptor destIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), // Adjust the size as needed
      'assets/icons/destination_icon.png',
    );

    BitmapDescriptor myIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)), // Adjust the size as needed
      'assets/icons/my_location_icon.png',
    );

    originIcon = oriIcon;
    destinationIcon = destIcon;
    myLocationIcon = myIcon;
  }

  @override
  void initState() {
    super.initState();
    _initializeMapFuture = _initializeMap();
    getLocationUpdates();
  }

  @override
  void dispose() {
    positionStream.cancel();
    super.dispose();
  }

  void getLocationUpdates() {
    try {
      const locationSettings =
          LocationSettings(accuracy: LocationAccuracy.high, distanceFilter: 10);

      positionStream =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .handleError((error) {
        eLog("Error: $error");
      }).listen((Position? position) async {
        if (position != null) {
          _userCurrentPositionNotifier.value =
              LatLng(position.latitude, position.longitude);
        } else {
          eLog('Position is null');
        }
      });
    } catch (e) {
      eLog("Error starting position stream: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocSelector<AppUserCubit, AppUserState, AppUserLoggedIn?>(
      selector: (state) {
        return state is AppUserLoggedIn ? state : null;
      },
      builder: (context, userState) {
        if (userState == null) {
          return const Center(
            child: Text("User is not logged in"),
          );
        }
        return BlocSelector<RideBloc, RideState, RideSelected?>(
          selector: (state) {
            return state is RideSelected ? state : null;
          },
          builder: (context, state) {
            if (state == null) {
              return const Center(
                child: Text("Unable to fetch selected ride details"),
              );
            }
            final ride = state.ride;
            final isDriver = state.ride.driver.id == userState.user.id;
            return SafeArea(
              child: Scaffold(
                appBar: MyAppBar(
                  enabledBackground: true,
                  leading: NavigateBackButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  title: isDriver
                      ? const Text(
                          "Meet your passengers",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        )
                      : const Text(
                          "Meet your driver",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 20,
                          ),
                        ),
                ),
                body: Stack(
                  children: [
                    FutureBuilder(
                      future: Future.wait([
                        _initializeMapFuture,
                        generatePolyLineFromPoints(ride),
                        loadCustomMarkerIcon(),
                      ]),
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
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
                        return ValueListenableBuilder<LatLng>(
                          valueListenable: _userCurrentPositionNotifier,
                          builder: (context, currentPosition, _) {
                            return GoogleMap(
                              onMapCreated: (GoogleMapController controller) {
                                _controller.complete(controller);
                              },
                              initialCameraPosition: CameraPosition(
                                target: LatLng(ride.origin.latitude,
                                    ride.origin.longitude),
                                zoom: 15,
                              ),
                              mapToolbarEnabled: false,
                              zoomControlsEnabled: false,
                              myLocationButtonEnabled: true,
                              markers: {
                                Marker(
                                  markerId: const MarkerId("my_location"),
                                  icon: myLocationIcon,
                                  position: LatLng(currentPosition.latitude,
                                      currentPosition.longitude),
                                ),
                                Marker(
                                  markerId: const MarkerId("orgin"),
                                  icon: originIcon,
                                  position: LatLng(ride.origin.latitude,
                                      ride.origin.longitude),
                                ),
                                Marker(
                                  markerId: const MarkerId("destination"),
                                  icon: destinationIcon,
                                  position: LatLng(ride.destination.latitude,
                                      ride.destination.longitude),
                                ),
                              },
                              polylines: Set<Polyline>.of(polylines.values),
                            );
                          },
                        );
                      },
                    ),
                    Positioned(
                      top: 0,
                      right: 0,
                      child: Column(
                        children: [
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.black,
                            ),
                            icon: const Icon(Icons.my_location),
                            onPressed: () async {
                              final controller = await _controller.future;
                              await controller.animateCamera(
                                  CameraUpdate.newLatLng(LatLng(
                                      _userCurrentPositionNotifier
                                          .value.latitude,
                                      _userCurrentPositionNotifier
                                          .value.longitude)));
                            },
                          ),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppPallete.primaryColor,
                            ),
                            icon: const Icon(Icons.trip_origin),
                            onPressed: () async {
                              final controller = await _controller.future;
                              await controller.animateCamera(
                                  CameraUpdate.newLatLng(LatLng(
                                      ride.origin.latitude,
                                      ride.origin.longitude)));
                            },
                          ),
                          IconButton.filled(
                            style: IconButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: Colors.green,
                            ),
                            icon: const Icon(Icons.flag_sharp),
                            onPressed: () async {
                              final controller = await _controller.future;
                              await controller.animateCamera(
                                  CameraUpdate.newLatLng(LatLng(
                                      ride.destination.latitude,
                                      ride.destination.longitude)));
                            },
                          ),
                        ],
                      ),
                    ),
                    DraggableScrollableSheet(
                      minChildSize: 0.4,
                      initialChildSize: 0.4,
                      maxChildSize: 0.8,
                      controller: sheetController,
                      builder: (BuildContext context, scrollController) {
                        return Column(
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                        foregroundColor:
                                            AppPallete.primaryColor,
                                        backgroundColor: AppPallete.whiteColor,
                                        shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8.0))),
                                    icon: const Icon(Icons.navigation),
                                    onPressed: () async {
                                      try {
                                        await openMap(ride.destination.latitude,
                                            ride.destination.longitude);
                                      } catch (e) {
                                        if (context.mounted) {
                                          showSnackBar(context, e.toString());
                                        }
                                      }
                                    },
                                    label:
                                        const Text("Navigate on Google Maps"),
                                  ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Container(
                                clipBehavior: Clip.hardEdge,
                                decoration: const BoxDecoration(
                                  color: AppPallete.whiteColor,
                                  borderRadius: BorderRadius.only(
                                    topLeft: Radius.circular(25),
                                    topRight: Radius.circular(25),
                                  ),
                                ),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16.0),
                                child: Stack(
                                  children: [
                                    SizedBox(
                                      width: MediaQuery.of(context).size.width,
                                      child: ride.passengers.isNotEmpty
                                          ? const Center(
                                              child: Text(
                                                "No Passengers",
                                                style: TextStyle(
                                                  color: AppPallete.errorColor,
                                                ),
                                              ),
                                            )
                                          : ListView.separated(
                                              controller: scrollController,
                                              itemBuilder: (context, index) {
                                                if (index == 0) {
                                                  return const SizedBox(
                                                    height: 76,
                                                  );
                                                }
                                                // return _buildPassengersListTile(
                                                //     ride,
                                                //     context,
                                                //     ride.passengers[index - 1]);
                                                return ListTile(
                                                    title: Text((index - 1)
                                                        .toString()));
                                              },
                                              separatorBuilder:
                                                  (context, index) {
                                                if (index == 0) {
                                                  return const SizedBox
                                                      .shrink();
                                                }
                                                return const Divider();
                                              },
                                              itemCount: 11),
                                    ),
                                    IgnorePointer(
                                      child: Column(
                                        children: [
                                          Container(
                                            height: 76,
                                            color: Colors.white,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.max,
                                              children: [
                                                // Non-scrollable header that triggers scrollController
                                                Center(
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context)
                                                          .hintColor,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10)),
                                                    ),
                                                    height: 4,
                                                    width: 40,
                                                    margin: const EdgeInsets
                                                        .symmetric(
                                                        vertical: 8.0),
                                                  ),
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    const Expanded(
                                                      child: Text(
                                                        "Please wait your passengers in origin",
                                                        softWrap: true,
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight
                                                                    .w500),
                                                      ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      children: [
                                                        Text(
                                                          formatTime(ride
                                                              .departureTime),
                                                          style: const TextStyle(
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                        Text(
                                                          formatDate(ride
                                                              .departureTime),
                                                          style: const TextStyle(
                                                              color: AppPallete
                                                                  .hintColor),
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                                const Divider(thickness: 1),
                                              ],
                                            ),
                                          ),
                                          const Spacer(),
                                          Container(
                                            color: AppPallete.whiteColor,
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 8.0),
                                            child: AppButton(
                                              onPressed: ride.passengers.isEmpty
                                                  ? null
                                                  : () {},
                                              child: const Text("Start Ride"),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                    //   Column(
                    //     mainAxisAlignment: MainAxisAlignment.end,
                    //     mainAxisSize: MainAxisSize.max,
                    //     children: [
                    //       Container(
                    //         width: MediaQuery.of(context).size.width,
                    //         padding: const EdgeInsets.all(8.0),
                    //         color: AppPallete.whiteColor,
                    //         child: Column(
                    //           children: [
                    //             ElevatedButton(
                    //               onPressed: () async {
                    //                 final controller = await _controller.future;
                    //                 await controller.animateCamera(CameraUpdate.newLatLng(
                    //                     LatLng(
                    //                         _userCurrentPositionNotifier.value.latitude,
                    //                         _userCurrentPositionNotifier
                    //                             .value.longitude)));
                    //               },
                    //               child: const Text("View Current Position"),
                    //             ),
                    //             ElevatedButton(
                    //               onPressed: () async {
                    //                 final controller = await _controller.future;
                    //                 await controller.animateCamera(CameraUpdate.newLatLng(
                    //                     LatLng(ride.origin.latitude,
                    //                         ride.origin.longitude)));
                    //               },
                    //               child: const Text("View Origin"),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ],
                    //   ),
                    // ],
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  SizedBox _buildPassengersListTile(
      Ride ride, BuildContext context, User passenger) {
    return SizedBox(
      child: Column(
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundImage:
                    AssetImage("assets/images/profile_placeholder.png"),
              ),
              const SizedBox(
                width: 16,
              ),
              Expanded(
                child: Text(
                  passenger.name,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ),
              Checkbox(
                value: false,
                onChanged: (value) {},
              ),
            ],
          ),
          GestureDetector(
            onTap: () async {
              String introTemplate =
                  "Hi ${passenger.name}, I am rider on RideNow for ride on ${formatDate(ride.departureTime)}, ${formatTime(ride.departureTime)} from ${ride.origin.formattedAddress} to ${ride.destination.formattedAddress}. Please arrive the meeting point soon!";
              await showContactMethodPicker(
                  context, passenger.phone, introTemplate);

              return;
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Row(
                children: [
                  const Icon(
                    Icons.chat,
                    color: AppPallete.primaryColor,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Text(
                    "Contact ${passenger.name}",
                    style: const TextStyle(color: AppPallete.primaryColor),
                  ),
                  const Spacer(),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> openMap(double latitude, double longitude) async {
    String googleUrl =
        'https://www.google.com/maps/dir/?api=1&destination=$latitude,$longitude';

    final uri = Uri.parse(googleUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      throw 'Could not open the map.';
    }
  }

  Future<void> generatePolyLineFromPoints(Ride ride) async {
    List<LatLng> polylineCoordinates;
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      request: PolylineRequest(
        origin: PointLatLng(
          ride.origin.latitude,
          ride.origin.longitude,
        ),
        destination: PointLatLng(
          ride.destination.latitude,
          ride.destination.longitude,
        ),
        mode: TravelMode.driving,
      ),
      googleApiKey: AppSecret.mapAPIKey,
    );

    if (result.points.isNotEmpty) {
      polylineCoordinates = result.points
          .map((point) => LatLng(point.latitude, point.longitude))
          .toList();
    } else {
      eLog(result.errorMessage);
      polylineCoordinates = [];
    }

    const id = PolylineId("polyline");

    final polyline = Polyline(
        polylineId: id,
        color: AppPallete.secondaryColor,
        points: polylineCoordinates,
        width: 5);

    polylines[id] = polyline;
  }
}
