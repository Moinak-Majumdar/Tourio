import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/models/tour_model.dart';

enum BudgetHealth { healthy, warning, over, none }

class BudgetSnapshotCard extends StatelessWidget {
  final double spent;
  final TourModel tour;
  final int spentDays;
  final VoidCallback onEditBudget;

  const BudgetSnapshotCard({
    super.key,
    required this.spent,
    required this.tour,
    required this.spentDays,
    required this.onEditBudget,
  });

  @override
  Widget build(BuildContext context) {
    final double budget = tour.budget ?? 0.0;
    final int totalDays = tour.totalDays;
    final scheme = Theme.of(context).colorScheme;

    final allocationPerDay = totalDays > 0 ? (budget / totalDays) : 0.0;
    final spentPerDay = spentDays > 0 ? (spent / spentDays) : 0.0;
    final remaining = (allocationPerDay - spentPerDay);
    final isOverSpent = remaining < 0;

    final health = _health(budget, spent);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ---------- Header ----------
          _statusRow(health, scheme),

          const SizedBox(height: 18),

          // ---------- Numbers ----------
          Row(
            children: [
              Expanded(
                child: _metric(
                  label: 'Budget',
                  value: _money(budget),
                  color: scheme.primary,
                ),
              ),
              Expanded(
                child: _metric(
                  label: 'Spent',
                  value: _money(spent),
                  color: isOverSpent ? scheme.error : scheme.primary,
                ),
              ),
              Expanded(
                child: _metric(
                  label: isOverSpent ? 'Over Spent' : 'Remaining',
                  value: _money(budget - spent),
                  color: isOverSpent ? scheme.error : scheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ---------- Avg per day ----------
          Row(
            children: [
              Text(
                'Limit: ${_money(allocationPerDay)}/day.',
                style: TextStyle(
                  fontSize: 12,
                  color: scheme.secondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                'Avg spent: ',
                style: TextStyle(fontSize: 12, color: scheme.secondary),
              ),
              Text(
                '₹${spentPerDay.toStringAsFixed(2)}/day',
                style: TextStyle(
                  fontSize: 12,
                  color: isOverSpent ? Colors.red : Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ---------------- Helpers ----------------

  Widget _metric({
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 12, color: color)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  Widget _statusRow(BudgetHealth health, ColorScheme scheme) {
    late IconData icon;
    late String text;
    late Color fg;

    switch (health) {
      case BudgetHealth.healthy:
        icon = Icons.done_all_outlined;
        text = 'Spending healthy';
        fg = Colors.green[400]!;
        break;

      case BudgetHealth.warning:
        icon = LucideIcons.alertTriangle;
        text = 'Approaching budget';
        fg = Colors.orange;
        break;

      case BudgetHealth.over:
        icon = Icons.dangerous_outlined;
        text = 'Over budget !!';
        fg = scheme.error;
        break;

      case BudgetHealth.none:
        icon = LucideIcons.info;
        text = 'Set a budget to track spending';
        fg = scheme.outline;
        break;
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 24, color: fg),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: fg,
          ),
        ),
      ],
    );
  }

  BudgetHealth _health(double? budget, double spent) {
    if (budget == null || budget <= 0) {
      return BudgetHealth.none;
    }

    final ratio = spent / budget;

    if (ratio < 0.7) return BudgetHealth.healthy;
    if (ratio <= 1.0) return BudgetHealth.warning;
    return BudgetHealth.over;
  }

  String _money(double v) {
    return '₹${v.abs().toStringAsFixed(0)}';
  }
}
