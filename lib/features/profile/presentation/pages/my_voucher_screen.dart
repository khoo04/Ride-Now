import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/features/profile/presentation/bloc/voucher/voucher_bloc.dart';
import 'package:ride_now_app/features/profile/presentation/widgets/voucher_card.dart';

class MyVoucherScreen extends StatefulWidget {
  static const routeName = '/my-voucher';
  const MyVoucherScreen({super.key});

  @override
  State<MyVoucherScreen> createState() => _MyVoucherScreenState();
}

class _MyVoucherScreenState extends State<MyVoucherScreen> {
  @override
  void initState() {
    super.initState();
    context.read<VoucherBloc>().add(FetchUserVouchers());
  }

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
          child: BlocConsumer<VoucherBloc, VoucherState>(
            listener: (context, state) {
              if (state is VoucherFailure) {
                showSnackBar(context, state.message);
              }
            },
            builder: (context, state) {
              if (state is VoucherLoading) {
                return const Center(
                  child: CircularProgressIndicator(
                    color: AppPallete.primaryColor,
                  ),
                );
              } else if (state is! VoucherDisplaySuccess) {
                return const SizedBox.shrink();
              }
              final numOfItem = state.vouchers.length;
              final indexOfLastItem = numOfItem - 1;
              return state.vouchers.isEmpty
                  ? const Center(
                      child: Text("No Vouchers Founded"),
                    )
                  : ListView.separated(
                      itemBuilder: (context, index) {
                        final voucher = state.vouchers[index];
                        if (index == 0) {
                          // Padding for the first element
                          return Padding(
                            padding: const EdgeInsets.only(top: 20),
                            child: VoucherCard(
                              voucher: voucher,
                            ),
                          );
                        } else if (index == indexOfLastItem) {
                          // Padding for the last element
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 20),
                            child: VoucherCard(voucher: voucher),
                          );
                        }
                        return VoucherCard(voucher: voucher);
                      },
                      separatorBuilder: (context, index) {
                        return const SizedBox(
                          height: 10,
                        );
                      },
                      itemCount: numOfItem,
                    );
            },
          ),
        ),
      ),
    );
  }
}
