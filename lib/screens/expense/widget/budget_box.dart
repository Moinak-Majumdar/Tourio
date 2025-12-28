import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/db/tour_db.dart';
import 'package:tourio/models/tour_model.dart';

enum BudgetState { none, safe, warning, over }

class BudgetBox extends StatefulWidget {
  final TourModel tour;
  final double totalSpent;

  /// Final callback – parent decides what to do
  final ValueChanged<double?> onBudgetUpdated;

  const BudgetBox({
    super.key,
    required this.tour,
    required this.totalSpent,
    required this.onBudgetUpdated,
  });

  @override
  State<BudgetBox> createState() => _BudgetBoxState();
}

class _BudgetBoxState extends State<BudgetBox> {
  double? _budgetOverride;

  double? get _budget => _budgetOverride ?? widget.tour.budget;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final budget = _budget;
    final spent = widget.totalSpent;

    BudgetState state = BudgetState.none;
    double progress = 0;

    if (budget != null && budget > 0) {
      progress = (spent / budget).clamp(0.0, 1.5);
      if (progress < 0.7) {
        state = BudgetState.safe;
      } else if (progress <= 1.0) {
        state = BudgetState.warning;
      } else {
        state = BudgetState.over;
      }
    }

    final ui = _mapState(state, scheme, budget, spent);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: ui.color),
        color: scheme.surface,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: ui.color.withAlpha(120),
            blurRadius: 12,
            offset: const Offset(-2, -2),
          ),
        ],
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(ui.icon, color: ui.accent),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  ui.title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  budget == null ? LucideIcons.edit2 : LucideIcons.edit3,
                  color: ui.accent,
                ),
                onPressed: _openBudgetDialog,
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(ui.subtitle, style: TextStyle(color: scheme.outline)),
          const SizedBox(height: 12),
          if (budget != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress.clamp(0.0, 1.0),
                minHeight: 8,
                backgroundColor: scheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation(ui.color),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
        ],
      ),
    );
  }

  // ---------------- UI Mapping ----------------

  _BudgetUI _mapState(
    BudgetState state,
    ColorScheme scheme,
    double? budget,
    double spent,
  ) {
    switch (state) {
      case BudgetState.safe:
        return _BudgetUI(
          color: scheme.primaryContainer,
          accent: scheme.primary,
          icon: LucideIcons.checkCircle,
          title: 'You’re on track',
          subtitle:
              '₹${spent.toStringAsFixed(0)} of ₹${budget!.toStringAsFixed(0)} spent',
        );

      case BudgetState.warning:
        return _BudgetUI(
          color: scheme.tertiaryContainer,
          accent: scheme.tertiary,
          icon: LucideIcons.alertTriangle,
          title: 'Approaching budget',
          subtitle:
              '₹${spent.toStringAsFixed(0)} of ₹${budget!.toStringAsFixed(0)} spent',
        );

      case BudgetState.over:
        return _BudgetUI(
          color: scheme.errorContainer,
          accent: scheme.error,
          icon: LucideIcons.alertOctagon,
          title: 'Budget exceeded',
          subtitle: '₹${spent.toStringAsFixed(0)} spent',
        );

      case BudgetState.none:
        return _BudgetUI(
          color: scheme.surfaceContainerLow,
          accent: scheme.outline,
          icon: LucideIcons.wallet,
          title: 'No budget set',
          subtitle: 'Add a budget to track expenses',
        );
    }
  }

  // ---------------- Budget Edit ----------------
  Future<void> _openBudgetDialog() async {
    final result = await showDialog<double>(
      context: context,
      barrierDismissible: true,
      builder: (_) => _BudgetEditDialog(initial: _budget),
    );

    if (result != null) {
      setState(() {
        _budgetOverride = result;
      });

      await TourDb.upsertBudget(widget.tour.id!, result);
      widget.onBudgetUpdated(result);
    }
  }
}

class _BudgetUI {
  final Color color;
  final Color accent;
  final IconData icon;
  final String title;
  final String subtitle;

  _BudgetUI({
    required this.color,
    required this.accent,
    required this.icon,
    required this.title,
    required this.subtitle,
  });
}

class _BudgetEditDialog extends StatefulWidget {
  final double? initial;

  const _BudgetEditDialog({required this.initial});

  @override
  State<_BudgetEditDialog> createState() => _BudgetEditDialogState();
}

class _BudgetEditDialogState extends State<_BudgetEditDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initial?.toStringAsFixed(0));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState!.validate()) {
      final val = double.parse(_ctrl.text.trim());
      Navigator.pop(context, val);
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- Header --------
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(
                      LucideIcons.wallet,
                      color: scheme.onPrimaryContainer,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Text(
                    'Set tour budget',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // -------- Input --------
              TextFormField(
                controller: _ctrl,
                autofocus: true,
                keyboardType: TextInputType.number,
                textInputAction: TextInputAction.done,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Budget is required';
                  }

                  final num? parsed = double.tryParse(value.trim());
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount';
                  }

                  return null;
                },
                onFieldSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  hintText: 'Enter budget amount',
                  filled: true,
                  fillColor: scheme.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // -------- Actions --------
              Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                  const Spacer(),
                  FilledButton.icon(
                    onPressed: _submit,
                    icon: const Icon(LucideIcons.check),
                    label: const Text('Save'),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
