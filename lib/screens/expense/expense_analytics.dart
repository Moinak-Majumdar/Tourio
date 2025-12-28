import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/models/expense_model.dart';
import 'package:tourio/models/tour_model.dart';
import 'package:tourio/screens/expense/widget/budget_snapshot_card.dart';
import 'package:tourio/screens/expense/widget/category_snapshot.dart';
import 'package:tourio/screens/expense/widget/daily_snapshot.dart';
import 'package:tourio/screens/expense/widget/daywise_snapshot.dart';

class ExpenseAnalyticsScreen extends StatefulWidget {
  final TourModel tour;
  final List<ExpenseModel> expenses;

  const ExpenseAnalyticsScreen({
    super.key,
    required this.tour,
    required this.expenses,
  });

  @override
  State<ExpenseAnalyticsScreen> createState() => _ExpenseAnalyticsScreenState();
}

class _ExpenseAnalyticsScreenState extends State<ExpenseAnalyticsScreen> {
  double _totalSpent = 0;

  List<DailyExpenseSummary>? _dailyData;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    _dailyData = _buildDailySummary(widget.tour, widget.expenses);

    setState(() {
      _totalSpent = widget.expenses.fold<double>(0, (sum, e) => sum + e.amount);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    if (_dailyData == null) {
      return const Center(child: CircularProgressIndicator());
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tour.tourName),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        actions: [
          IconButton(icon: const Icon(LucideIcons.info), onPressed: _showInfo),
        ],
      ),
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            // -------- Budget Snapshot Hero --------
            BudgetSnapshotCard(
              budget: widget.tour.budget,
              spent: _totalSpent,
              totalDays: widget.tour.totalDays,
              onEditBudget: _openBudgetSheet,
            ),
            const SizedBox(height: 16),

            DailySnapshotCard(summaries: _dailyData!, tour: widget.tour),

            // -------- Timeline (next) --------
            const SizedBox(height: 16),
            DayWiseSnapshot(
              data: _dailyData!,
              maxSpentDay: _maxSpentDay(_dailyData!),
            ),

            // -------- Category Donut (next) --------
            const SizedBox(height: 16),
            ExpenseCategoryPie(expenses: widget.expenses),

            // const SizedBox(height: 16),

            // -------- Insights (next) --------

            // _sectionTitle('Insights'),
            // const SizedBox(height: 12),
            // _placeholderCard(
            //   scheme,
            //   icon: LucideIcons.lightbulb,
            //   text: 'Smart insights go here',
            // ),
          ],
        ),
      ),
    );
  }

  // ---------------- Actions ----------------

  void _openBudgetSheet() {
    // you already have this implemented
    // reuse the same modal here
  }

  void _showInfo() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Analytics'),
        content: const Text(
          'This screen shows how your expenses relate to your tour budget.',
        ),
      ),
    );
  }
}

int _maxSpentDay(List<DailyExpenseSummary> data) {
  int maxSpentDay = 0;
  for (int i = 0; i < data.length; i++) {
    if (data[i].totalAmount > data[maxSpentDay].totalAmount) {
      maxSpentDay = i;
    }
  }
  return maxSpentDay;
}

List<DailyExpenseSummary> _buildDailySummary(
  TourModel tour,
  List<ExpenseModel> expenses,
) {
  final Map<DateTime, List<ExpenseModel>> grouped = {};

  for (final e in expenses) {
    final key = DateTime(
      e.expenseDate.year,
      e.expenseDate.month,
      e.expenseDate.day,
    );
    grouped.putIfAbsent(key, () => []).add(e);
  }

  final List<DailyExpenseSummary> result = [];

  for (int i = 0; i < tour.totalDays; i++) {
    final date = tour.startDate.add(Duration(days: i));
    final key = DateTime(date.year, date.month, date.day);
    final items = grouped[key] ?? [];

    result.add(
      DailyExpenseSummary(
        date: date,
        items: items,
        totalAmount: items.fold(0, (s, e) => s + e.amount),
      ),
    );
  }

  return result;
}
