import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

enum BudgetHealth { healthy, warning, over, none }

class BudgetSnapshotCard extends StatelessWidget {
  final double? budget;
  final double spent;
  final int totalDays;
  final VoidCallback onEditBudget;

  const BudgetSnapshotCard({
    super.key,
    required this.budget,
    required this.spent,
    required this.totalDays,
    required this.onEditBudget,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final remaining = budget != null ? (budget! - spent) : null;

    final isOverSpent = remaining != null && remaining < 0;

    final avgPerDay = totalDays > 0 ? (spent / totalDays) : 0.0;

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
                  value: budget != null ? _money(budget!) : 'Not set',
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
                  value: remaining != null ? _money(remaining) : '—',
                  color: isOverSpent ? scheme.error : scheme.primary,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ---------- Avg per day ----------
          Row(
            children: [
              Icon(LucideIcons.trendingUp, size: 20, color: scheme.secondary),
              const SizedBox(width: 8),
              Text(
                'Avg: ${_money(avgPerDay)}/day.',
                style: TextStyle(
                  color: scheme.secondary,
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
