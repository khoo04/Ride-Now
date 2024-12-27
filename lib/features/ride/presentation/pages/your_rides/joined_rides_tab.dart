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

class JoinedRidesTab extends StatefulWidget {
  const JoinedRidesTab({super.key});

  @override
  State<JoinedRidesTab> createState() => _JoinedRidesTabState();
}

class _JoinedRidesTabState extends State<JoinedRidesTab> {
  bool _isNavigating = false;
  int _selectedTabIndex = 0;

  final List<Map<String, dynamic>> _tabs = [
    {
      'label': 'Confirmed',
      'icon': Icons.event_available,
      'color': AppPallete.primaryColor,
    },
    {
      'label': 'Active',
      'icon': Icons.event_available,
      'color': AppPallete.activeColor,
    },
    {
      'label': 'Completed',
      'icon': Icons.check_circle_outline_outlined,
      'color': AppPallete.completedColor,
    },
    {
      'label': 'Canceled',
      'icon': Icons.block,
      'color': AppPallete.errorColor,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(8.0),
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 columns
              crossAxisSpacing: 8.0,
              mainAxisSpacing: 8.0,
              childAspectRatio: 3.0, // Adjust to control item height
            ),
            itemCount: _tabs.length,
            itemBuilder: (context, index) {
              final tab = _tabs[index];
              final isSelected = _selectedTabIndex == index;
              return GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedTabIndex = index;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppPallete.secondaryColor.withOpacity(0.2)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(8.0),
                    border: Border.all(
                      color: isSelected
                          ? AppPallete.secondaryColor
                          : Colors.grey.shade300,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(tab['icon'], color: tab['color']),
                      const SizedBox(height: 4.0),
                      Text(
                        tab['label'],
                        style: TextStyle(
                          color: tab['color'],
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        Expanded(
          // Content for selected tab
          child: BlocConsumer<YourRideListCubit, RideListState>(
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
              final joinRides = state.joinedRides;
              final confirmedRides = joinRides
                  .where((ride) => ride.status == "confirmed")
                  .toList();
              final startedRides =
                  joinRides.where((ride) => ride.status == "started").toList();
              final completedRides = joinRides
                  .where((ride) => ride.status == "completed")
                  .toList();
              final canceledRides =
                  joinRides.where((ride) => ride.status == 'canceled').toList();

              return IndexedStack(
                index: _selectedTabIndex,
                children: [
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: _buildRidesList(confirmedRides, "confirmed"),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: _buildRidesList(startedRides, "started"),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: _buildRidesList(completedRides, "completed"),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
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
            key: PageStorageKey("user_joined_${rideListType}_rides"),
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
