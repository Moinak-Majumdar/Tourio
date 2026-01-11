import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:get/get_navigation/src/extension_navigation.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/db/expense_db.dart';
import 'package:tourio/models/expense_model.dart';
import 'package:tourio/models/tour_model.dart';
import 'package:tourio/screens/expense/expense_analytics.dart';
import 'package:tourio/screens/expense/widget/category_config.dart';
import 'package:tourio/screens/expense/widget/expense_filter.dart';
import 'package:tourio/screens/expense/widget/expense_overview.dart';
import 'package:tourio/screens/expense/widget/expense_upsert_sheet.dart';

class ExpenseScreen extends StatefulWidget {
  final TourModel tour;

  const ExpenseScreen({super.key, required this.tour});

  @override
  State<ExpenseScreen> createState() => _ExpenseScreenState();
}

class _ExpenseScreenState extends State<ExpenseScreen> {
  List<ExpenseModel> _items = [];
  List<ExpenseModel> _filteredItems = [];
  ExpenseFilterState? _filter;

  double get totalSpent => _items.fold(0, (sum, e) => sum + e.amount);

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  Future<void> _loadExpenses() async {
    final items = await ExpenseDb.getByTour(widget.tour.id!);
    final minAmount = _minExpenseAmount(items);
    final maxAmount = _maxExpenseAmount(items);

    setState(() {
      _filter = ExpenseFilterState(minAmount: minAmount, maxAmount: maxAmount);
      _items = items;
      _filteredItems = items;
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tour.tourName),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.trending_up),
            onPressed: () => {
              Get.to(
                () =>
                    ExpenseAnalyticsScreen(tour: widget.tour, expenses: _items),
              ),
            },
          ),
        ],
      ),
      resizeToAvoidBottomInset: false,
      floatingActionButton: FloatingActionButton(
        onPressed: _onAddExpense,

        child: const Icon(LucideIcons.plus),
      ),
      body: Column(
        children: [
          ExpenseOverview(used: totalSpent, limit: widget.tour.budget!),
          Padding(
            padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
            child: SizedBox(height: 48, child: filterMenu()),
          ),
          Expanded(child: _expenseListBox(scheme)),
        ],
      ),
    );
  }

  // ---------------- Expense List ----------------

  Widget _expenseListBox(ColorScheme scheme) {
    if (_filteredItems.isEmpty) {
      return Container(
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      margin: EdgeInsets.only(bottom: 8),
      child: ListView.builder(
        itemCount: _filteredItems.length,
        itemBuilder: (_, i) => _expenseTile(_filteredItems[i], scheme),
      ),
    );
  }

  // ---------------- Expense Tile ----------------

  Widget _expenseTile(ExpenseModel item, ColorScheme scheme) {
    final amount = item.amount.toStringAsFixed(2);

    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => _onDeleteExpense(item),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: scheme.error,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Icon(LucideIcons.trash, color: scheme.onError),
      ),
      child: GestureDetector(
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _onEditExpense(item);
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: scheme.surfaceContainer,
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
                      DateFormat('EEE, d MMM yyyy').format(item.expenseDate),
                      style: TextStyle(fontSize: 12, color: scheme.outline),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        '₹${amount.split('.').first}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      if (amount.split('.').last != '00') ...[
                        Text('.', style: TextStyle(color: scheme.outline)),
                        Text(
                          amount.split('.').last,
                          style: TextStyle(
                            color: scheme.outline,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                  IconButton(
                    icon: const Icon(LucideIcons.edit3, size: 18),
                    onPressed: () => _onEditExpense(item),
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
        color: config.color,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(config.icon, size: 20),
    );
  }

  // ---------------- Actions ----------------

  Future<void> _onAddExpense() async {
    final created = await showModalBottomSheet<bool>(
      context: context,
      useSafeArea: true,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ExpenseUpsertSheet(tourId: widget.tour.id!),
    );

    if (created == true) {
      _loadExpenses();
    }
  }

  Future<void> _onEditExpense(ExpenseModel item) async {
    final updated = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          ExpenseUpsertSheet(tourId: widget.tour.id!, existing: item),
    );

    if (updated == true) {
      _loadExpenses();
    }
  }

  Future<void> _onDeleteExpense(ExpenseModel item) async {
    await ExpenseDb.softDelete(item.id!);
    _loadExpenses();
  }

  // ---------------- Filter ----------------
  double _minExpenseAmount(List<ExpenseModel> items) => items.isEmpty
      ? 0
      : items.map((e) => e.amount).reduce((a, b) => a < b ? a : b);

  double _maxExpenseAmount(List<ExpenseModel> items) => items.isEmpty
      ? 0
      : items.map((e) => e.amount).reduce((a, b) => a > b ? a : b);

  Widget filterMenu() {
    return ListView(
      scrollDirection: Axis.horizontal,
      children: [
        FilledButton.icon(
          label: Text('Amt: High to Low'),
          icon: const Icon(Icons.sort),
          onPressed: () {
            final t = _items;
            t.sort((a, b) => b.amount.compareTo(a.amount));
            setState(() {
              _filteredItems = t;
            });
          },
        ),
        const SizedBox(width: 8),
        FilledButton.icon(
          label: Text('Date: Newest'),
          icon: const Icon(LucideIcons.calendar),
          onPressed: () {
            final t = _items;
            t.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
            setState(() {
              _filteredItems = t;
            });
          },
        ),
        const SizedBox(width: 8),
        if (_filter != null)
          FilledButton.icon(
            label: Text('Others'),
            icon: const Icon(Icons.tune),
            onPressed: () async {
              final result = await showModalBottomSheet<ExpenseFilterState>(
                context: context,
                isScrollControlled: true,
                useSafeArea: true,
                backgroundColor: Colors.transparent,
                builder: (_) => ExpenseFilterSheet(
                  initial: _filter!,
                  maxAmtSpent: _maxExpenseAmount(_items),
                  onReset: () => {
                    setState(() {
                      _filter = ExpenseFilterState(
                        maxAmount: _maxExpenseAmount(_items),
                        minAmount: _minExpenseAmount(_items),
                      );
                      _filteredItems = _items;
                    }),
                  },
                ),
              );
              if (result != null) {
                setState(() {
                  _filter = result;
                  _filteredItems = _applyExpenseFilter(_items, result);
                });
              }
            },
          ),
      ],
    );
  }
}

List<ExpenseModel> _applyExpenseFilter(
  List<ExpenseModel> items,
  ExpenseFilterState filter,
) {
  var list = items.where((e) {
    if (e.amount < filter.minAmount || e.amount > filter.maxAmount) {
      return false;
    }
    if (filter.categories.isNotEmpty &&
        !filter.categories.contains(e.category)) {
      return false;
    }
    return true;
  }).toList();

  switch (filter.sort) {
    case ExpenseSort.amountHighToLow:
      list.sort((a, b) => b.amount.compareTo(a.amount));
      break;
    case ExpenseSort.amountLowToHigh:
      list.sort((a, b) => a.amount.compareTo(b.amount));
      break;
    case ExpenseSort.dateNewest:
      list.sort((a, b) => b.expenseDate.compareTo(a.expenseDate));
      break;
    case ExpenseSort.dateOldest:
      list.sort((a, b) => a.expenseDate.compareTo(b.expenseDate));
      break;
    case null:
      break;
  }

  return list;
}
