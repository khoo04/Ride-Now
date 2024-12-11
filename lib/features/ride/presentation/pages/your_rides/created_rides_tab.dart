import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/features/ride/domain/entities/ride.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride/ride_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/cubit/your_ride_list/your_ride_list_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/pages/ride_detail_screen.dart';
import 'package:ride_now_app/features/ride/presentation/widgets/ride_preview_card.dart';

class CreatedRidesTab extends StatefulWidget {
  const CreatedRidesTab({super.key});

  @override
  State<CreatedRidesTab> createState() => _CreatedRidesTabState();
}

class _CreatedRidesTabState extends State<CreatedRidesTab>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  bool _isNavigating = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        TabBar.secondary(
          controller: _tabController,
          tabs: const <Widget>[
            Tab(
              icon: Icon(
                Icons.event_available,
                color: AppPallete.activeColor,
              ),
              child: Text(
                "Active",
                style: TextStyle(color: AppPallete.activeColor),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.check_circle_outline_outlined,
                color: AppPallete.completedColor,
              ),
              child: Text(
                "Completed",
                style: TextStyle(color: AppPallete.completedColor),
              ),
            ),
            Tab(
              icon: Icon(
                Icons.block,
                color: AppPallete.errorColor,
              ),
              child: Text(
                "Canceled",
                style: TextStyle(color: AppPallete.errorColor),
              ),
            ),
            // CustomTabItem(
            //   color: AppPallete.activeColor,
            //   icon: Icons.event_available,
            //   label: "Active",
            // ),
          ],
          indicatorColor: AppPallete.secondaryColor,
        ),
        Expanded(
          child: BlocConsumer<RideListCubit, RideListState>(
            listener: (context, state) {
              if (state is RideListFailure) {
                showSnackBar(context, state.message);
              }
            },
            builder: (context, state) {
              if (state is! RidesDisplaySuccess) {
                return const Center(
                  child: Text(
                    "Error in getting rides",
                    style: TextStyle(
                      color: AppPallete.errorColor,
                    ),
                  ),
                );
              }
              final createdRides = state.createdRides;
              final activeRides = createdRides
                  .where((ride) => ride.status == "confirmed")
                  .toList();
              final completedRides = createdRides
                  .where((ride) => ride.status == "completed ")
                  .toList();
              final canceledRides = createdRides
                  .where((ride) => ride.status == 'canceled')
                  .toList();
              return TabBarView(
                controller: _tabController,
                children: <Widget>[
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: _buildRidesList(activeRides, "active"),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: _buildRidesList(completedRides, "completed"),
                  ),
                  Container(
                    margin: const EdgeInsets.all(16.0),
                    child: _buildRidesList(canceledRides, "canceled"),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRidesList(List<Ride> ridesList, String rideListType) {
    return ridesList.isEmpty
        ? const Center(
            child: Text("No record founded"),
          )
        : ListView.separated(
            physics: const AlwaysScrollableScrollPhysics(),
            key: PageStorageKey("user_created_${rideListType}_rides"),
            itemBuilder: (context, index) {
              final ride = ridesList[index];
              return RidePreviewCard(
                  ride: ride,
                  onTap: () {
                    if (!_isNavigating) {
                      _isNavigating = true;

                      context.read<RideBloc>().add(
                            SelectRideEvent(
                              ride: ride,
                            ),
                          );
                      Navigator.of(context)
                          .pushNamed(RideDetailScreen.routeName)
                          .then((_) {
                        _isNavigating = false;
                      });
                    }
                  });
            },
            separatorBuilder: (BuildContext context, int index) {
              return const SizedBox(
                height: 8,
              );
            },
            itemCount: ridesList.length,
          );
  }
}
