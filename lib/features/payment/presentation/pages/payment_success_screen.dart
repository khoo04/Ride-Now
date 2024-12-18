import 'package:flutter/material.dart';
import 'package:ride_now_app/core/common/widgets/app_button.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';

class PaymentSuccessScreen extends StatelessWidget {
  static const routeName = '/payment/success';
  const PaymentSuccessScreen({super.key});

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
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
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
                          color: Colors
                              .black54, // Subtle gray for less visual strain
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
                      //Pop to the details screen and let user retry payment
                      Navigator.of(context).pop();
                    },
                    child: const Text("View Your Ride"),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
