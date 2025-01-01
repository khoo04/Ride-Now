import 'package:auto_size_text/auto_size_text.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:ride_now_app/core/common/widgets/my_app_bar.dart';
import 'package:ride_now_app/core/common/widgets/navigate_back_button.dart';
import 'package:ride_now_app/core/theme/app_pallete.dart';
import 'package:ride_now_app/core/utils/format_date.dart';
import 'package:ride_now_app/core/utils/logger.dart';
import 'package:ride_now_app/core/utils/show_snackbar.dart';
import 'package:ride_now_app/core/utils/string_extension.dart';
import 'package:ride_now_app/features/profile/domain/entities/balance_data.dart';
import 'package:ride_now_app/features/profile/domain/entities/balance_record.dart';
import 'package:ride_now_app/features/profile/domain/entities/graph.dart';
import 'package:ride_now_app/features/profile/presentation/cubit/balance/balance_cubit.dart';
import 'package:ride_now_app/features/profile/presentation/pages/register_vehicle_screen.dart';
import 'package:ride_now_app/features/profile/presentation/widgets/legend_list_widget.dart';

class MyBalanceScreen extends StatefulWidget {
  static const routeName = '/my_balance';
  const MyBalanceScreen({super.key});

  @override
  State<MyBalanceScreen> createState() => _MyBalanceScreenState();
}

class _MyBalanceScreenState extends State<MyBalanceScreen> {
  final creditedColor = AppPallete.secondaryColor;
  final unCreditedColor = AppPallete.errorColor;
  final betweenSpace = 0.1;
  int touchedIndex = -1;

  @override
  void initState() {
    super.initState();
    context.read<BalanceCubit>().initalizeUserBalance();
  }

  Widget bottomTitles(double value, TitleMeta meta) {
    const style = TextStyle(fontSize: 10);
    String text;
    switch (value.toInt()) {
      case 0:
        text = 'JAN';
        break;
      case 1:
        text = 'FEB';
        break;
      case 2:
        text = 'MAR';
        break;
      case 3:
        text = 'APR';
        break;
      case 4:
        text = 'MAY';
        break;
      case 5:
        text = 'JUN';
        break;
      case 6:
        text = 'JUL';
        break;
      case 7:
        text = 'AUG';
        break;
      case 8:
        text = 'SEP';
        break;
      case 9:
        text = 'OCT';
        break;
      case 10:
        text = 'NOV';
        break;
      case 11:
        text = 'DEC';
        break;
      default:
        text = '';
    }
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(text, style: style),
    );
  }

  Widget leftTitles(double value, TitleMeta meta) {
    if (value == meta.max) {
      return Container();
    }
    const style = TextStyle(
      fontSize: 10,
    );
    return SideTitleWidget(
      axisSide: meta.axisSide,
      child: Text(
        meta.formattedValue,
        style: style,
      ),
    );
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
            "My Balance",
            style: TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
        body: BlocConsumer<BalanceCubit, BalanceState>(
          listener: (context, state) {
            if (state is BalanceDisplayFailure) {
              showSnackBar(context, state.message);
            }
          },
          builder: (context, state) {
            if (state is BalanceLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: AppPallete.primaryColor,
                ),
              );
            } else if (state is! BalanceDisplaySuccess) {
              return const Center(
                child: AutoSizeText(
                  "Error occured in loading balance",
                  style: TextStyle(
                    color: AppPallete.errorColor,
                  ),
                ),
              );
            }
            final data = state.data;
            return DefaultTabController(
              length: 2,
              child: Column(
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const AutoSizeText(
                          "Your Balance",
                          style: TextStyle(
                              fontWeight: FontWeight.w400, fontSize: 18),
                        ),
                        const SizedBox(height: 8),
                        AutoSizeText(
                          "RM ${data.totalBalance.toStringAsFixed(2)}",
                          style: const TextStyle(
                              fontSize: 32, fontWeight: FontWeight.w600),
                        ),
                        const SizedBox(height: 8),
                        AutoSizeText(
                          "Uncredited balance: RM ${data.totalUncreditBalance.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                        AutoSizeText(
                          "Credited balance: RM ${data.totalCreditedBalance.toStringAsFixed(2)}",
                          style: const TextStyle(fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ),
                  const TabBar(
                    labelColor: AppPallete.primaryColor,
                    indicatorColor: Colors.blue, // Adjust to match your theme
                    tabs: [
                      Tab(text: "Earnings"),
                      Tab(text: "Refunds"),
                    ],
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      child: TabBarView(
                        children: [
                          _buildEarningsSection(
                            totalEarningsBalance: data.totalEarningsBalance,
                            currentMonthTotalEarnings:
                                data.currentMonthTotalEarnings,
                            totalEarningsGraphEntries:
                                data.totalEarningsGraphEntries,
                            earningsRecord: data.earningsRecord,
                          ),
                          _buildRefundsSection(
                            totalRefundBalance: data.totalRefundBalance,
                            refundRecord: data.refundRecord,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildGraph(
      List<GraphEntry> totalEarningsGraphEntries, DateTime yearMonth) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: 400,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Earnings Graph in ${yearMonth.year}',
              style: const TextStyle(
                color: AppPallete.primaryColor,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            LegendsListWidget(
              legends: [
                Legend('Credited Balance', creditedColor),
                Legend('Uncredited Balance', unCreditedColor),
              ],
            ),
            const SizedBox(height: 14),
            Expanded(
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceBetween,
                  titlesData: FlTitlesData(
                    leftTitles: AxisTitles(
                      drawBelowEverything: true,
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 60,
                        maxIncluded: false,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            value.toStringAsFixed(2),
                            textAlign: TextAlign.left,
                          );
                        },
                      ),
                    ),
                    rightTitles: const AxisTitles(),
                    topTitles: const AxisTitles(),
                    bottomTitles: AxisTitles(
                      axisNameWidget: const Padding(
                        padding: EdgeInsets.only(top: 2.0),
                        child: AutoSizeText(
                          "Months",
                          maxLines: 1,
                        ),
                      ),
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: bottomTitles,
                        reservedSize: 20,
                      ),
                    ),
                  ),
                  barTouchData: BarTouchData(
                    handleBuiltInTouches: false,
                    touchCallback: (FlTouchEvent event, barTouchResponse) {
                      if (!event.isInterestedForInteractions ||
                          barTouchResponse == null ||
                          barTouchResponse.spot == null) {
                        setState(() {
                          touchedIndex = -1;
                        });
                        return;
                      }

                      setState(() {
                        touchedIndex =
                            barTouchResponse.spot!.touchedBarGroupIndex;
                      });
                    },
                    touchTooltipData: BarTouchTooltipData(
                        tooltipBorder: const BorderSide(
                          color: AppPallete.primaryColor,
                        ),
                        getTooltipColor: (data) {
                          return Colors.white;
                        },
                        getTooltipItem: (
                          BarChartGroupData group,
                          int groupIndex,
                          BarChartRodData rod,
                          int rodIndex,
                        ) {
                          const color = AppPallete.secondaryColor;
                          const textStyle = TextStyle(
                            color: color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          );
                          return BarTooltipItem(
                            "RM ${rod.toY.toStringAsFixed(2)}",
                            textStyle,
                          );
                        }),
                  ),
                  borderData: FlBorderData(show: false),
                  gridData: const FlGridData(show: true),
                  barGroups:
                      List.generate(totalEarningsGraphEntries.length, (index) {
                    final graphData = totalEarningsGraphEntries[index].data;
                    return generateGroupData(
                        index, graphData.credited, graphData.uncredited);
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  BarChartGroupData generateGroupData(
    int x,
    double credited,
    double unCredited,
  ) {
    final isTop = credited > 0;
    final isTouched = touchedIndex == x;
    final sum = credited + unCredited;
    return BarChartGroupData(
      x: x,
      groupVertically: true,
      showingTooltipIndicators: isTouched ? [0] : [],
      barRods: [
        BarChartRodData(
            toY: sum,
            width: 5,
            borderRadius: isTop
                ? const BorderRadius.only(
                    topLeft: Radius.circular(6),
                    topRight: Radius.circular(6),
                  )
                : const BorderRadius.only(
                    bottomLeft: Radius.circular(6),
                    bottomRight: Radius.circular(6),
                  ),
            rodStackItems: [
              BarChartRodStackItem(
                0,
                credited,
                creditedColor,
                BorderSide(
                  color: Colors.white,
                  width: isTouched ? 2 : 0,
                ),
              ),
              BarChartRodStackItem(
                credited,
                credited + unCredited,
                unCreditedColor,
                BorderSide(
                  color: Colors.white,
                  width: isTouched ? 2 : 0,
                ),
              ),
            ]),
      ],
    );
  }

  Widget _buildEarningsSection({
    required double totalEarningsBalance,
    required CurrentMonthTotalEarnings currentMonthTotalEarnings,
    required List<GraphEntry> totalEarningsGraphEntries,
    required List<BalanceRecord> earningsRecord,
  }) {
    return SingleChildScrollView(
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0),
            child: Card(
              color: Colors.white,
              surfaceTintColor: AppPallete.secondaryColor,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const AutoSizeText(
                      "Total Earnings Balance",
                      style:
                          TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    AutoSizeText(
                      "RM ${totalEarningsBalance.toStringAsFixed(2)}",
                      style: const TextStyle(
                          fontSize: 32, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 8),
                    AutoSizeText(
                      "Total earnings balance in ${formatDateWithMonth(currentMonthTotalEarnings.yearMonth)}:\nRM ${currentMonthTotalEarnings.earnings.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.w400),
                    ),
                  ],
                ),
              ),
            ),
          ),
          _buildGraph(
              totalEarningsGraphEntries, currentMonthTotalEarnings.yearMonth),
          Card(
            color: Colors.white,
            surfaceTintColor: AppPallete.secondaryColor,
            child: SizedBox(
              height: 300,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: AutoSizeText(
                      "Earnings Record",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Expanded(
                    child: earningsRecord.isEmpty
                        ? const Center(
                            child: AutoSizeText("No record founded"),
                          )
                        : ListView.builder(
                            itemCount: earningsRecord.length,
                            itemBuilder: (context, index) {
                              final record = earningsRecord[index];
                              Color statusColor = AppPallete.errorColor;
                              if (record.status == "credited") {
                                statusColor = AppPallete.primaryColor;
                              }
                              return ListTile(
                                title: Text(
                                    "Earning on ${formatDate(record.createdDateTime)}"),
                                subtitle: Text.rich(
                                  TextSpan(
                                    text: "Status: ",
                                    children: [
                                      TextSpan(
                                        text: record.status.capitalize(),
                                        style: TextStyle(color: statusColor),
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: Text(
                                    "RM ${record.amount.toStringAsFixed(2)}"),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRefundsSection({
    required double totalRefundBalance,
    required List<BalanceRecord> refundRecord,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: Card(
            color: Colors.white,
            surfaceTintColor: AppPallete.secondaryColor,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const AutoSizeText(
                    "Total Refund Balance",
                    style: TextStyle(fontWeight: FontWeight.w400, fontSize: 18),
                  ),
                  const SizedBox(height: 8),
                  AutoSizeText(
                    "RM ${totalRefundBalance.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 32, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
            ),
          ),
        ),
        Expanded(
          child: Card(
            color: Colors.white,
            surfaceTintColor: AppPallete.secondaryColor,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                  child: AutoSizeText(
                    "Refund Record",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Expanded(
                  child: refundRecord.isEmpty
                      ? const Center(
                          child: AutoSizeText("No record founded"),
                        )
                      : ListView.builder(
                          itemCount: refundRecord.length,
                          itemBuilder: (context, index) {
                            final record = refundRecord[index];
                            Color statusColor = AppPallete.errorColor;
                            if (record.status == "credited") {
                              statusColor = AppPallete.primaryColor;
                            }
                            return ListTile(
                              title: Text(
                                  "Refund on ${formatDate(record.createdDateTime)}"),
                              subtitle: Text.rich(
                                TextSpan(
                                  text: "Status: ",
                                  children: [
                                    TextSpan(
                                      text: record.status.capitalize(),
                                      style: TextStyle(color: statusColor),
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Text(
                                  "RM ${record.amount.toStringAsFixed(2)}"),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
