import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:tourio/models/expense_model.dart';
import 'package:tourio/screens/expense/widget/category_config.dart';

class DayWiseSnapshot extends StatefulWidget {
  const DayWiseSnapshot({
    super.key,
    required this.data,
    required this.maxSpentDay,
  });

  final List<DailyExpenseSummary> data;
  final int maxSpentDay;

  @override
  State<DayWiseSnapshot> createState() => _DayWiseSnapshotState();
}

class _DayWiseSnapshotState extends State<DayWiseSnapshot> {
  final Color gradientColor1 = Color(0xffecdec4);
  final Color gradientColor2 = Color(0xff62f4f9);
  final Color gradientColor3 = Color(0xfff49fda);
  final Color indicatorStrokeColor = Colors.white;

  int? selectedDay;

  late final List<FlSpot> allSpots;

  @override
  void initState() {
    super.initState();
    final List<FlSpot> temp = [];
    for (var i = 0; i < widget.data.length; i++) {
      temp.add(FlSpot(i.toDouble(), widget.data[i].totalAmount));
    }
    allSpots = temp;
    selectedDay = widget.maxSpentDay;
  }

  Widget bottomTitleWidgets(double value, TitleMeta meta, ColorScheme scheme) {
    String text = 'D${value.toInt() + 1}';

    if (text.isEmpty) {
      return const SizedBox.shrink();
    }
    return SideTitleWidget(
      meta: meta,
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w800,
          color: scheme.secondary,
          fontSize: 12,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final lineBarsData = [
      LineChartBarData(
        showingIndicators: selectedDay != null ? [selectedDay!] : [],
        spots: allSpots,
        isCurved: false,
        barWidth: 4,
        belowBarData: BarAreaData(
          show: true,
          gradient: LinearGradient(
            colors: [
              gradientColor1.withValues(alpha: 0.4),
              gradientColor2.withValues(alpha: 0.4),
              gradientColor3.withValues(alpha: 0.4),
            ],
          ),
        ),
        dotData: FlDotData(
          show: true,
          getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
            radius: 6,
            color: _lerpGradient(
              barData.gradient!.colors,
              barData.gradient!.stops!,
              percent / 100,
            ),
            strokeWidth: 3,
            strokeColor: indicatorStrokeColor,
          ),
        ),
        gradient: LinearGradient(
          colors: [gradientColor1, gradientColor2, gradientColor3],
          stops: const [0.1, 0.4, 0.9],
        ),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.bar_chart_outlined, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Day wise spend',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Container(
              width: MediaQuery.of(context).size.width,
              padding: EdgeInsets.fromLTRB(0, 8, 8, 0),
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return LineChart(
                      LineChartData(
                        lineTouchData: LineTouchData(
                          enabled: true,
                          handleBuiltInTouches: false,
                          touchCallback:
                              (
                                FlTouchEvent event,
                                LineTouchResponse? response,
                              ) {
                                if (response == null ||
                                    response.lineBarSpots == null) {
                                  return;
                                }
                                if (event is FlTapUpEvent) {
                                  final spotIndex =
                                      response.lineBarSpots!.first.spotIndex;

                                  showModalBottomSheet(
                                    context: context,
                                    backgroundColor: Colors.transparent,
                                    builder: (_) => _DayDetails(
                                      day: widget.data[spotIndex],
                                    ),
                                  );
                                  setState(() {
                                    selectedDay = spotIndex;
                                  });
                                }
                              },
                          mouseCursorResolver:
                              (
                                FlTouchEvent event,
                                LineTouchResponse? response,
                              ) {
                                if (response == null ||
                                    response.lineBarSpots == null) {
                                  return SystemMouseCursors.basic;
                                }
                                return SystemMouseCursors.click;
                              },
                          getTouchedSpotIndicator:
                              (
                                LineChartBarData barData,
                                List<int> spotIndexes,
                              ) {
                                return spotIndexes.map((index) {
                                  return TouchedSpotIndicatorData(
                                    FlLine(
                                      color: Color(0xff6ef195),
                                      strokeWidth: 4,
                                    ),
                                    FlDotData(
                                      show: true,
                                      getDotPainter:
                                          (spot, percent, barData, index) =>
                                              FlDotCirclePainter(
                                                radius: 8,
                                                color: _lerpGradient(
                                                  barData.gradient!.colors,
                                                  barData.gradient!.stops!,
                                                  percent / 100,
                                                ),
                                                strokeWidth: 2,
                                                strokeColor: Colors.red,
                                              ),
                                    ),
                                  );
                                }).toList();
                              },
                        ),
                        lineBarsData: lineBarsData,
                        minY: 0,
                        maxY: widget.data[widget.maxSpentDay].totalAmount + 10,
                        titlesData: FlTitlesData(
                          leftTitles: AxisTitles(
                            axisNameWidget: Text(
                              'Amount',
                              style: TextStyle(color: scheme.secondary),
                            ),
                            axisNameSize: 24,
                            sideTitles: SideTitles(
                              showTitles: false,
                              reservedSize: 0,
                            ),
                          ),
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return bottomTitleWidgets(value, meta, scheme);
                              },
                              reservedSize: 30,
                            ),
                          ),
                          // rightTitles: const AxisTitles(
                          //   sideTitles: SideTitles(
                          //     showTitles: true,
                          //     reservedSize: 0,
                          //   ),
                          // ),
                          topTitles: const AxisTitles(
                            axisNameSize: 24,
                            sideTitles: SideTitles(
                              showTitles: false,
                              reservedSize: 0,
                            ),
                          ),
                        ),
                        gridData: const FlGridData(show: true),
                        borderData: FlBorderData(
                          show: true,
                          border: Border.all(color: scheme.outline),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Lerps between a [LinearGradient] colors, based on [t]
Color _lerpGradient(List<Color> colors, List<double> stops, double t) {
  if (colors.isEmpty) {
    throw ArgumentError('"colors" is empty.');
  } else if (colors.length == 1) {
    return colors[0];
  }

  if (stops.length != colors.length) {
    stops = [];

    /// provided gradientColorStops is invalid and we calculate it here
    colors.asMap().forEach((index, color) {
      final percent = 1.0 / (colors.length - 1);
      stops.add(percent * index);
    });
  }

  for (var s = 0; s < stops.length - 1; s++) {
    final leftStop = stops[s];
    final rightStop = stops[s + 1];
    final leftColor = colors[s];
    final rightColor = colors[s + 1];
    if (t <= leftStop) {
      return leftColor;
    } else if (t < rightStop) {
      final sectionT = (t - leftStop) / (rightStop - leftStop);
      return Color.lerp(leftColor, rightColor, sectionT)!;
    }
  }
  return colors.last;
}

class _DayDetails extends StatelessWidget {
  final DailyExpenseSummary day;

  const _DayDetails({required this.day});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- Header --------
              _header(scheme),

              const SizedBox(height: 20),

              // -------- Items --------
              ...day.items.map((e) => _expenseRow(context, e)),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  Widget _header(ColorScheme scheme) {
    return Row(
      children: [
        Text(
          DateFormat('EEE, dd MMM yyyy').format(day.date),
          style: const TextStyle(fontSize: 14),
        ),
        const Spacer(),
        Icon(Icons.currency_rupee, size: 18, color: scheme.primary),
        const SizedBox(width: 4),
        Text(
          day.totalAmount.toStringAsFixed(2),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  Widget _expenseRow(BuildContext context, ExpenseModel e) {
    final scheme = Theme.of(context).colorScheme;
    final config = expenseCategoryMap[e.category];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: scheme.surfaceContainer,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // -------- Category Icon --------
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: config?.color,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(config?.icon ?? Icons.receipt_long, size: 20),
          ),

          const SizedBox(width: 14),

          // -------- Title + Category --------
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  e.title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 2),
                Text(
                  e.category,
                  style: TextStyle(fontSize: 12, color: scheme.outline),
                ),
              ],
            ),
          ),

          // -------- Amount --------
          Text(
            '₹${e.amount.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
          ),
        ],
      ),
    );
  }
}
