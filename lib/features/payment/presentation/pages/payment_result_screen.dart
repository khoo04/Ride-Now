import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/features/payment/presentation/cubit/payment_cubit.dart';
import 'package:ride_now_app/features/ride/presentation/pages/ride_detail_screen.dart';

class PaymentResultScreen extends StatelessWidget {
  static const routeName = 'payment/result';
  const PaymentResultScreen({super.key});

  //TODO: Peridoic Check Payment Result if after 5 seconds is still loading, since real time update maybe not working properly when the connection is unstable

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          leading: NavigateBackButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
        ),
        body: BlocBuilder<PaymentCubit, PaymentState>(
          builder: (context, state) {
            if (state is PaymentLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppPallete.primaryColor,
                ),
              );
            } else if (state is PaymentSuccess || state is PaymentFailure) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Builder(
                  builder: (context) {
                    if (state is PaymentSuccess) {
                      return _buildSuccessScreen(context);
                    } else {
                      return _buildFailureScreen(context);
                    }
                  },
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          },
        ),
      ),
    );
  }

  Column _buildFailureScreen(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 32,
                ),
                Image.asset(
                  "assets/images/transaction-failed.png",
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
                const SizedBox(
                  height: 24,
                ),
                const Text(
                  "Payment Failed!",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppPallete.errorColor),
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  "We couldn’t process your payment, please try again..",
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.w300),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Center(
            child: AppButton(
              onPressed: () {
                //Pop to the details screen and let user retry payment
                Navigator.of(context).pop();
              },
              child: const Text("Go Back and Retry"),
            ),
          ),
        )
      ],
    );
  }

  Column _buildSuccessScreen(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(
                  height: 32,
                ),
                Image.asset(
                  "assets/images/transaction-success.png",
                  width: MediaQuery.of(context).size.width * 0.3,
                ),
                const SizedBox(
                  height: 24,
                ),
                const Text(
                  "Payment Success!",
                  style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w500,
                      color: AppPallete.primaryColor),
                ),
                const SizedBox(
                  height: 8,
                ),
                const Text(
                  "Your ride has been confirmed. Thank you for choosing Ride Now for your journey!",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w400,
                    color: Colors.black54, // Subtle gray for less visual strain
                  ),
                ),
              ],
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Center(
            child: AppButton(
              onPressed: () {
                Navigator.of(context).popUntil((route) =>
                    route.settings.name == RideDetailScreen.routeName);
              },
              child: const Text("View Your Ride"),
            ),
          ),
        )
      ],
    );
  }
}
