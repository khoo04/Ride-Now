import 'package:flutter/material.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/features/profile/presentation/widgets/voucher_card.dart';

class MyVoucherScreen extends StatelessWidget {
  static const routeName = '/my-voucher';
  const MyVoucherScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: MyAppBar(
          leading: NavigateBackButton(onPressed: () {
            Navigator.of(context).pop();
          }),
          enabledBackground: true,
          title: const Text(
            "My Voucher",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 18.0,
          ),
          child: ListView.separated(
            itemBuilder: (context, index) {
              if (index == 0) {
                // Padding for the first element
                return Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: VoucherCard(),
                );
              } else if (index == 9) {
                // Padding for the last element
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: VoucherCard(),
                );
              }
              return VoucherCard();
            },
            separatorBuilder: (context, index) {
              return const SizedBox(
                height: 10,
              );
            },
            itemCount: 10,
          ),
        ),
      ),
    );
  }
}
