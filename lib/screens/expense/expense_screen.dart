import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/db/expense_db.dart';
import 'package:tourio/models/expense_model.dart';
import 'package:tourio/models/tour_model.dart';
import 'package:tourio/screens/expense/widget/budget_box.dart';
import 'package:tourio/screens/expense/widget/category_config.dart';
import 'package:tourio/screens/expense/widget/expense_upsert_sheet.dart';

class ExpenseScreen extends StatefulWidget {
  final TourModel tour;

  const ExpenseScreen({super.key, required this.tour});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<ExpenseModel> _items = [];

  double get totalSpent => _items.fold(0, (sum, e) => sum + e.amount);

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final items = await ExpenseDb.getByTour(widget.tour.id!);

    setState(() {
      _items = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.tour.name?.isNotEmpty == true
              ? widget.tour.name!
              : widget.tour.destination,
        ),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: _openFilter,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddExpense,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
        child: Column(
          children: [
            BudgetBox(
              tour: widget.tour,
              totalSpent: totalSpent,
              onBudgetUpdated: (value) {
                setState(() {
                  widget.tour.budget = value;
                });
              },
            ),
            const SizedBox(height: 16),
            Expanded(child: _expenseListBox(scheme)),
          ],
        ),
      ),
    );
  }

  // ---------------- Expense List ----------------

  Widget _expenseListBox(ColorScheme scheme) {
    if (_items.isEmpty) {
      return Container(
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
        ),
        margin: const EdgeInsets.only(bottom: 8),
        child: Center(
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.currency_exchange, size: 36, color: Colors.grey),
              SizedBox(height: 12),
              Text('No expenses added yet.', style: TextStyle(fontSize: 16)),
            ],
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(24),
      ),
      margin: EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        itemCount: _items.length,
        itemBuilder: (_, i) => _expenseTile(_items[i], scheme),
      ),
    );
  }

  // ---------------- Expense Tile ----------------

  Widget _expenseTile(ExpenseModel item, ColorScheme scheme) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _delete(item),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(LucideIcons.trash, color: scheme.onError),
      ),
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _edit(item);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surface,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Row(
            children: [
              _categoryIcon(item.category, scheme),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.title,
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.category,
                      style: TextStyle(fontSize: 12, color: scheme.outline),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    '₹${item.amount.toStringAsFixed(0)}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.edit3, size: 18),
                    onPressed: () => _edit(item),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _categoryIcon(String category, ColorScheme scheme) {
    final config = expenseCategoryMap[category] ?? expenseCategoryMap['Other']!;

    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: scheme.primaryContainer.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(config.icon, size: 20, color: scheme.onPrimaryContainer),
    );
  }

  // ---------------- Actions ----------------

  Future<void> _openAddExpense() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseUpsertSheet(tourId: widget.tour.id!),
    );

    if (created == true) {
      _loadExpenses();
    }
  }

  Future<void> _edit(ExpenseModel item) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ExpenseUpsertSheet(tourId: widget.tour.id!, existing: item),
    );

    if (updated == true) {
      _loadExpenses();
    }
  }

  Future<void> _delete(ExpenseModel item) async {
    await ExpenseDb.softDelete(item.id!);
    _loadExpenses();
  }

  void _openFilter() {}
}
