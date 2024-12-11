import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride/ride_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/your_ride_list/your_ride_list_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/pages/your_rides/created_rides_tab.dart';
import 'package:ride_now_app/features/ride/presentation/pages/your_rides/joined_rides_tab.dart';

class YourRideMainScreen extends StatefulWidget {
  const YourRideMainScreen({super.key});

  @override
  State<YourRideMainScreen> createState() => _YourRideMainScreenState();
}

class _YourRideMainScreenState extends State<YourRideMainScreen> {
  @override
  void initState() {
    super.initState();
    context.read<RideListCubit>().getUserCreatedNJoinedRides();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            backgroundColor: AppPallete.actionBgColor,
            foregroundColor: AppPallete.primaryColor,
            toolbarHeight: 0,
            bottom: const TabBar(
              tabs: [
                Tab(
                  text: "Joined Rides",
                ),
                Tab(
                  text: "Created Rides",
                ),
              ],
              labelColor: AppPallete.primaryColor,
              indicatorColor: AppPallete.primaryColor,
            ),
          ),
          body: TabBarView(
            children: [
              BlocBuilder<RideListCubit, RideListState>(
                builder: (context, state) {
                  if (state is RideListLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppPallete.primaryColor,
                      ),
                    );
                  }
                  return const JoinedRidesTab();
                },
              ),
              BlocBuilder<RideListCubit, RideListState>(
                builder: (context, state) {
                  if (state is RideListLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppPallete.primaryColor,
                      ),
                    );
                  }
                  return const CreatedRidesTab();
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
