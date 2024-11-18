import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/cubits/app_user/app_user_cubit.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_main/ride_main_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/pages/search_ride_screen.dart';
import 'package:ride_now_app/features/ride/presentation/widgets/ride_preview_card.dart';

class RideMainScreen extends StatefulWidget {
  const RideMainScreen({super.key});

  @override
  State<RideMainScreen> createState() => _RideMainScreenState();
}

class _RideMainScreenState extends State<RideMainScreen> {
  final scrollController = ScrollController();
  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      final rideState = context.read<RideMainBloc>().state;

      if (scrollController.position.maxScrollExtent ==
              scrollController.offset &&
          rideState is! FetchRideLoading &&
          rideState is FetchRideSuccess &&
          !rideState.isEnd) {
        context.read<RideMainBloc>().add(RetrieveAvailabeRides());
      }
    });
  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              BlocBuilder<AppUserCubit, AppUserState>(
                builder: (context, state) {
                  return RichText(
                    text: TextSpan(
                      text: "Welcome! ",
                      children: [
                        TextSpan(
                          text: state is AppUserLoggedIn
                              ? state.user.name
                              : 'username',
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                      style: const TextStyle(
                        fontWeight: FontWeight.normal,
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () {
                  Navigator.of(context).pushNamed(SearchRideScreen.routeName);
                },
                child: const AbsorbPointer(
                  child: TextField(
                    readOnly: true,
                    decoration: InputDecoration(
                      label: Row(
                        children: [
                          Icon(Icons.search),
                          SizedBox(
                            width: 12,
                          ),
                          Text("Search Rides"),
                        ],
                      ),
                      errorMaxLines: 5,
                      floatingLabelStyle:
                          TextStyle(color: AppPallete.primaryColor),
                      filled: true,
                      fillColor: AppPallete.actionBgColor,
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: AppPallete.borderColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: AppPallete.primaryColor),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Current Available Rides",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: BlocConsumer<RideMainBloc, FetchRideState>(
                    builder: (context, state) {
                  if (state is FetchRideSuccess) {
                    return RefreshIndicator(
                      color: AppPallete.primaryColor,
                      onRefresh: () async {
                        context.read<RideMainBloc>().add(InitFetchRide());
                      },
                      child: ListView.separated(
                        key: const PageStorageKey("rides_scroll_position"),
                        controller: scrollController,
                        itemBuilder: (context, index) {
                          if (index < state.rides.length) {
                            return RidePreviewCard(ride: state.rides[index]);
                          } else {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 32),
                              child: Center(
                                child: state.isEnd
                                    ? const Text("No more rides to load")
                                    : const CircularProgressIndicator(
                                        color: AppPallete.primaryColor,
                                      ),
                              ),
                            );
                          }
                        },
                        separatorBuilder: (context, index) {
                          return const SizedBox(height: 8);
                        },
                        itemCount: state.rides.length + 1,
                      ),
                    );
                  }
                  return const Center(child: CircularProgressIndicator());
                }, listener: (context, state) {
                  //TODO: Show Snackbar
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
