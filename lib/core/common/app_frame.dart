import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/features/profile/presentation/pages/profile_screen.dart';
import 'package:ride_now_app/features/ride/presentation/bloc/ride_main/ride_main_bloc.dart';
import 'package:ride_now_app/features/ride/presentation/pages/ride_main_screen.dart';
import 'package:ride_now_app/features/ride/presentation/pages/search_ride_screen.dart';

class AppFrame extends StatefulWidget {
  const AppFrame({super.key});

  @override
  State<AppFrame> createState() => _AppFrameState();
}

class _AppFrameState extends State<AppFrame> {
  int currentIndex = 0;
  final List<Widget> pages = const [
    RideMainScreen(),
    Text("New Ride Page"),
    Text("Your Rides Page"),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    context.read<RideMainBloc>().add(RetrieveAvailabeRides());
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
