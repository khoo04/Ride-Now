import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:pusher_channels_flutter/pusher_channels_flutter.dart';
import 'package:ride_now_app/core/cubits/app_user/app_user_cubit.dart';
import 'package:ride_now_app/core/network/app_response.dart';
import 'package:ride_now_app/core/secrets/app_secret.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:ride_now_app/features/payment/presentation/pages/payment_failed_screen.dart';
import 'package:ride_now_app/features/payment/presentation/pages/payment_success_screen.dart';
import 'package:ride_now_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:ride_now_app/features/ride/data/models/ride_model.dart';
import 'package:ride_now_app/features/auth/domain/usecases/get_broadcasting_auth_token.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride/ride_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_main/ride_main_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/your_ride_list/your_ride_list_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/pages/create_ride_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/ride_main_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/ride_ratings_screen.dart';

import 'package:ride_now_app/features/ride/presentation/pages/your_rides/your_ride_main_screen.dart';
import 'package:ride_now_app/init_dependencies.dart';

class AppFrame extends StatefulWidget {
  const AppFrame({super.key});

  @override
  State<AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends State<AppFrame> {
  final PusherChannelsFlutter pusher = PusherChannelsFlutter.getInstance();
  int currentIndex = 0;
  final List<Widget> pages = const [
    RideMainScreen(),
    CreateRideScreen(),
    YourRideMainScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    _initPusher();
    context.read<RideMainBloc>().add(const RetrieveAvailabeRides());
  }

  @override
  void dispose() {
    pusher.disconnect();
    super.dispose();
  }

  Future<void> _initPusher() async {
    if (!mounted) return;

    await pusher.init(
        apiKey: AppSecret.pusherAPIKey,
        cluster: AppSecret.pusherCluster,
        useTLS: false,
        logToConsole: true,
        onError: (String message, int? code, dynamic e) {
          eLog("onError: $message code: $code exception: $e");
        },
        onConnectionStateChange: (dynamic currentState, dynamic previousState) {
          vLog("Current State :$currentState , Previous State: $previousState");
        },
        onEvent: (PusherEvent event) {
          final Map<String, dynamic> decodedData = json.decode(event.data);

          if (event.eventName == 'joinedRide.status.started') {
            final appResponse = AppResponse.fromJson(decodedData);

            if (appResponse.success) {
              final updatedRide = RideModel.fromJson(appResponse.data);
              context.read<YourRideListCubit>().updateRideInList(updatedRide);
              context
                  .read<RideMainBloc>()
                  .add(UpdateSpecificRideInList(ride: updatedRide));
              context.read<RideBloc>().add(UpdateSelectedRide(updatedRide));
            }
          } else if (event.eventName == 'joinedRide.status.completed') {
            //Complete ride
            final appResponse = AppResponse.fromJson(decodedData);

            if (appResponse.success) {
              final updatedRide = RideModel.fromJson(appResponse.data);
              context.read<YourRideListCubit>().updateRideInList(updatedRide);
              context
                  .read<RideMainBloc>()
                  .add(UpdateSpecificRideInList(ride: updatedRide));

              //Select this ride
              context.read<RideBloc>().add(SelectRideEvent(ride: updatedRide));
              Navigator.of(context).pushNamed(RideRatingsScreen.routeName);
            }
          } else if (event.eventName == 'ride.status.changed') {
            final appResponse = AppResponse.fromJson(decodedData);

            if (appResponse.success) {
              final updatedRide = RideModel.fromJson(appResponse.data);
              context.read<YourRideListCubit>().updateRideInList(updatedRide);
              context
                  .read<RideMainBloc>()
                  .add(UpdateSpecificRideInList(ride: updatedRide));
              context.read<RideBloc>().add(UpdateSelectedRide(updatedRide));
            }
          }
          if (event.eventName == 'payment.status.changed') {
            final appResponse = AppResponse.fromJson(decodedData);
            if (appResponse.success) {
              final updatedRide = RideModel.fromJson(appResponse.data["ride"]);
              context.read<YourRideListCubit>().updateRideInList(updatedRide);
              context
                  .read<RideMainBloc>()
                  .add(UpdateSpecificRideInList(ride: updatedRide));
              context.read<RideBloc>().add(UpdateSelectedRide(updatedRide));
              context.read<PaymentCubit>().setPaymentSuccess();
            } else {
              context.read<PaymentCubit>().setPaymentFailed();
            }
          }
        },
        onSubscriptionError: (String message, dynamic e) {
          eLog("onSubscriptionError: $e");
        },
        onDecryptionFailure: (String event, String reason) {
          vLog("onDecryptionFailure: $event reason: $reason");
        },
        onAuthorizer:
            (String channelName, String socketId, dynamic options) async {
          final getRideBroadcastingAuthToken =
              serviceLocator<GetBroadcastingAuthToken>();

          final res = await getRideBroadcastingAuthToken(
            GetBroadcastingAuthTokenParams(
              channelName: channelName,
              socketId: socketId,
            ),
          );

          final result = res.fold((failure) {
            return null;
          }, (authToken) {
            return {"auth": authToken};
          });

          return result;
        });

    await pusher.connect();

    if (mounted) {
      final state = context.read<AppUserCubit>().state;
      if (state is AppUserLoggedIn) {
        await pusher.subscribe(channelName: "ride");

        await pusher.subscribe(channelName: "private-user.${state.user.id}");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: pages[currentIndex]),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.search), label: "Search Ride"),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: "New Ride"),
          BottomNavigationBarItem(
              icon: Icon(Icons.format_list_bulleted), label: "Your Rides"),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_outline), label: "Profile"),
        ],
        currentIndex: currentIndex,
        unselectedItemColor: AppPallete.inactiveColor,
        selectedItemColor: AppPallete.primaryColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: (index) => setState(() {
          currentIndex = index;
        }),
        selectedFontSize: 12,
        unselectedFontSize: 12,
      ),
    );
  }
}
