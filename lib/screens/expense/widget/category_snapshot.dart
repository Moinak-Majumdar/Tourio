import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_instance/src/extension_instance.dart';
import 'package:get/get_state_manager/src/rx_flutter/rx_obx_widget.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/common/controllers/theme_controller.dart';
import 'package:tourio/models/expense_model.dart';
import 'package:tourio/screens/expense/widget/category_config.dart';

class ExpenseCategoryPie extends StatefulWidget {
  final List<ExpenseModel> expenses;
  final double totalSpent;

  const ExpenseCategoryPie({
    super.key,
    required this.expenses,
    required this.totalSpent,
  });

  @override
  State<ExpenseCategoryPie> createState() => _ExpenseCategoryPieState();
}

class _ExpenseCategoryPieState extends State<ExpenseCategoryPie> {
  int _touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final tc = Get.find<ThemeController>();

    final scheme = Theme.of(context).colorScheme;

    if (widget.expenses.isEmpty) {
      return const SizedBox();
    }

    final catAmtMap = <String, double>{};
    for (final e in widget.expenses) {
      catAmtMap[e.category] = (catAmtMap[e.category] ?? 0) + e.amount;
    }

    final entries = catAmtMap.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(LucideIcons.pieChart, size: 18, color: scheme.primary),
              const SizedBox(width: 8),
              const Text(
                'Spending by category',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Stack(
            alignment: Alignment.center,
            children: [
              if (_touchedIndex != -1)
                Column(
                  children: [
                    Text(
                      entries[_touchedIndex].key,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        color: scheme.primary,
                      ),
                    ),
                    Text(
                      entries[_touchedIndex].value.toString(),
                      style: const TextStyle(fontSize: 10),
                    ),
                  ],
                ),
              SizedBox(
                height: 260,
                child: Obx(
                  () => PieChart(
                    PieChartData(
                      startDegreeOffset: -90,
                      sectionsSpace: 4,
                      centerSpaceRadius: 50,
                      pieTouchData: PieTouchData(
                        touchCallback: (event, response) {
                          setState(() {
                            _touchedIndex =
                                response?.touchedSection?.touchedSectionIndex ??
                                -1;
                          });
                        },
                      ),
                      sections: _buildSections(
                        entries,
                        widget.totalSpent,
                        scheme,
                        tc.isDark.value,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  List<PieChartSectionData> _buildSections(
    List<MapEntry<String, double>> entries,
    double total,
    ColorScheme scheme,
    bool isDark,
  ) {
    return List.generate(entries.length, (i) {
      final e = entries[i];
      final cfg = expenseCategoryMap[e.key];
      final isTouched = i == _touchedIndex;
      final percent = (e.value / total * 100).round();

      return PieChartSectionData(
        value: e.value,
        radius: isTouched ? 60 : 52,
        title: '$percent%',
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w800,
          color: Colors.white,
        ),
        color: cfg?.color,
        badgeWidget: _badge(
          icon: cfg?.icon ?? LucideIcons.tag,
          color: scheme.primary,
          isDark: isDark,
        ),
        badgePositionPercentageOffset: 1.25,
      );
    });
  }

  Widget _badge({
    required IconData icon,
    required Color color,
    required bool isDark,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: isDark ? Colors.black : Colors.black45,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Center(child: Icon(icon, size: 20, color: color)),
    );
  }
}
