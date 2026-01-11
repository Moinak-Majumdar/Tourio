import 'package:flutter/material.dart';
import 'package:tourio/screens/expense/widget/category_config.dart';

enum ExpenseSort { amountHighToLow, amountLowToHigh, dateNewest, dateOldest }

class ExpenseFilterState {
  final ExpenseSort? sort;
  final Set<String> categories;
  final double minAmount;
  final double maxAmount;

  const ExpenseFilterState({
    this.sort,
    this.categories = const {},
    this.minAmount = 0,
    this.maxAmount = 2000,
  });

  ExpenseFilterState copyWith({
    ExpenseSort? sort,
    Set<String>? categories,
    double? minAmount,
    double? maxAmount,
  }) {
    return ExpenseFilterState(
      sort: sort ?? this.sort,
      categories: categories ?? this.categories,
      minAmount: minAmount ?? this.minAmount,
      maxAmount: maxAmount ?? this.maxAmount,
    );
  }
}

class ExpenseFilterSheet extends StatefulWidget {
  final ExpenseFilterState initial;
  final double maxAmtSpent;
  final Function() onReset;

  const ExpenseFilterSheet({
    super.key,
    required this.initial,
    required this.onReset,
    required this.maxAmtSpent,
  });

  @override
  State<ExpenseFilterSheet> createState() => _ExpenseFilterSheetState();
}

class _ExpenseFilterSheetState extends State<ExpenseFilterSheet> {
  late ExpenseFilterState _state;

  @override
  void initState() {
    super.initState();
    _state = widget.initial;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(left: 16, right: 16, bottom: 24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _header(scheme),
            const SizedBox(height: 20),
            _sortSection(),
            const SizedBox(height: 24),
            _categorySection(),
            const SizedBox(height: 24),
            _amountRangeSection(),
            const SizedBox(height: 16),
            _applyButton(),
          ],
        ),
      ),
    );
  }

  Widget _sortSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Sort by', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _sortChip('Amt: High to Low', ExpenseSort.amountHighToLow),
            _sortChip('Amt: Low to High', ExpenseSort.amountLowToHigh),
            _sortChip('Date: Newest', ExpenseSort.dateNewest),
            _sortChip('Date: Oldest', ExpenseSort.dateOldest),
          ],
        ),
      ],
    );
  }

  Widget _sortChip(String label, ExpenseSort value) {
    final scheme = Theme.of(context).colorScheme;
    final selected = _state.sort == value;

    return InkWell(
      borderRadius: BorderRadius.circular(24),
      onTap: () => setState(() {
        _state = _state.copyWith(sort: value);
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? scheme.primary.withAlpha(25)
              : scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: selected ? scheme.primary : Colors.transparent,
            width: 1.6,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: selected ? scheme.primary : scheme.outline,
          ),
        ),
      ),
    );
  }

  Widget _categorySection() {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Categories', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: expenseCategoryMap.entries.map((entry) {
            final cat = entry.key;
            final config = entry.value;
            final selected = _state.categories.contains(cat);

            return InkWell(
              borderRadius: BorderRadius.circular(24),
              onTap: () {
                final next = {..._state.categories};
                selected ? next.remove(cat) : next.add(cat);
                setState(() => _state = _state.copyWith(categories: next));
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? config.color!.withAlpha(25)
                      : scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    width: 1.4,
                    color: selected
                        ? config.color!
                        : scheme.outline.withAlpha(25),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      config.icon,
                      size: 18,
                      color: selected ? config.color : scheme.outline,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      cat,
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: selected ? config.color : scheme.outline,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _amountRangeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Amount range',
          style: TextStyle(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 8),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            showValueIndicator: ShowValueIndicator.onDrag,
            valueIndicatorTextStyle: TextStyle(
              color: Theme.of(context).colorScheme.onPrimary,
              fontWeight: FontWeight.w600,
            ),
            valueIndicatorColor: Theme.of(context).colorScheme.primary,
            rangeValueIndicatorShape:
                const PaddleRangeSliderValueIndicatorShape(),
          ),
          child: RangeSlider(
            min: 0,
            max: widget.maxAmtSpent,
            values: RangeValues(_state.minAmount, _state.maxAmount),
            labels: RangeLabels(
              '₹${_state.minAmount.toInt()}',
              '₹${_state.maxAmount.toInt()}',
            ),
            onChanged: (v) {
              setState(() {
                _state = _state.copyWith(minAmount: v.start, maxAmount: v.end);
              });
            },
          ),
        ),
      ],
    );
  }

  Widget _header(ColorScheme scheme) {
    return Row(
      children: [
        const Text(
          'Advanced filter',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
        ),
        const Spacer(),
        TextButton(
          onPressed: () {
            widget.onReset();
            Navigator.pop(context);
          },
          child: const Text('Clear all'),
        ),
      ],
    );
  }

  Widget _applyButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: () => Navigator.pop(context, _state),
        child: const Text('Apply filters'),
      ),
    );
  }
}
