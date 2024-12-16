import 'package:flutter/material.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/format_date.dart';
import 'package:ride_now_app/features/profile/domain/entities/voucher.dart';

class VoucherCard extends StatelessWidget {
  final Voucher voucher;
  const VoucherCard({super.key, required this.voucher});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(.5),
            blurRadius: 4.0, // soften the shadow
            spreadRadius: -4.0, //extend the shadow
          ),
        ],
      ),
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        child: Container(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Text(
                  "RM ${voucher.amount}",
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Text(
                "Voucher ID: ${voucher.voucherId}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: AppPallete.hintColor,
                ),
              ),
              const SizedBox(
                height: 6,
              ),
              Text(
                "Received on: ${formatDate(voucher.createdAt)}",
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w300,
                  color: AppPallete.hintColor,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
