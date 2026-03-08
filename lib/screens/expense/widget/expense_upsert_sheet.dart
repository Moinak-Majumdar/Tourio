import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/db/expense_db.dart';
import 'package:tourio/models/expense_model.dart';
import 'package:tourio/models/taveler_model.dart';
import 'package:tourio/models/tour_model.dart';
import 'package:tourio/screens/expense/widget/category_config.dart';

class ExpenseUpsertSheet extends StatefulWidget {
  final TourModel tour;
  final ExpenseModel? existing;
  final List<TavelerModel> travelers;

  const ExpenseUpsertSheet({
    super.key,
    required this.tour,
    required this.travelers,
    this.existing,
  });

  @override
  State<ExpenseUpsertSheet> createState() => _ExpenseUpsertSheetState();
}

class _ExpenseUpsertSheetState extends State<ExpenseUpsertSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  late final TextEditingController _travelerNameCtrl;
  late TavelerModel _selectedTraveler;
  final FocusNode _titleFocus = FocusNode();

  String _category = 'Other';
  DateTime _expenseDate = DateTime.now();

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();

    _titleCtrl = TextEditingController(text: widget.existing?.title);
    _travelerNameCtrl = TextEditingController();
    _amountCtrl = TextEditingController(
      text: widget.existing?.amount.toStringAsFixed(0),
    );

    if (widget.existing != null) {
      _category = widget.existing!.category;
      _expenseDate = widget.existing!.expenseDate;
      _selectedTraveler = widget.travelers.firstWhere(
        (t) => t.id == widget.existing!.paidBy,
      );
    } else {
      _selectedTraveler = widget.travelers.firstWhere((t) => t.isSelf == true);
    }

    // 🔑 Autofocus fix for modal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocus.requestFocus();
    });

    final now = DateTime.now();
    if (now.isBefore(widget.tour.startDate)) {
      _expenseDate = widget.tour.startDate;
    } else if (now.isAfter(widget.tour.endDate)) {
      _expenseDate = widget.tour.endDate;
    } else {
      _expenseDate = now;
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _titleFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Form(
          key: _formKey,
          child: Scrollbar(
            child: SingleChildScrollView(
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
                          isEdit ? LucideIcons.edit3 : LucideIcons.plus,
                          color: scheme.onPrimaryContainer,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        isEdit ? 'Edit expense' : 'Add expense',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 18),

                  // -------- Date --------
                  Row(
                    children: [
                      Icon(
                        LucideIcons.calendar,
                        size: 18,
                        color: scheme.outline,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        DateFormat('EEE, d MMM yyyy').format(_expenseDate),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      const Spacer(),
                      TextButton(
                        onPressed: _pickDate,
                        child: const Text('Change'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  // -------- Title --------
                  TextFormField(
                    controller: _titleCtrl,
                    focusNode: _titleFocus,
                    textCapitalization: TextCapitalization.sentences,
                    validator: (v) =>
                        v == null || v.trim().isEmpty ? 'Title required' : null,
                    decoration: InputDecoration(
                      hintText: 'Expense title',
                      filled: true,
                      fillColor: scheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  // -------- Amount --------
                  TextFormField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    validator: (v) {
                      final val = double.tryParse(v ?? '');
                      if (val == null || val <= 0) {
                        return 'Enter valid amount';
                      }
                      return null;
                    },
                    decoration: InputDecoration(
                      hintText: 'Amount',
                      filled: true,
                      fillColor: scheme.surfaceContainerLow,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // -------- Category --------
                  SizedBox(
                    height: 40,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: expenseCategoryList.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 8),
                      itemBuilder: (context, i) {
                        final c = expenseCategoryList[i];
                        final selected = c == _category;

                        return ChoiceChip(
                          label: Text(c),
                          selected: selected,
                          onSelected: (_) => setState(() => _category = c),
                          selectedColor: scheme.primaryContainer,
                          backgroundColor: scheme.surfaceContainerLow,
                          labelStyle: TextStyle(
                            color: selected
                                ? scheme.onPrimaryContainer
                                : scheme.onSurface,
                          ),
                        );
                      },
                    ),
                  ),

                  const SizedBox(height: 16),
                  _travelerSelector(scheme),

                  // select payer
                  const SizedBox(height: 24),

                  // -------- Action --------
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton.icon(
                      icon: const Icon(LucideIcons.check),
                      label: Text(isEdit ? 'Update expense' : 'Add expense'),
                      style: FilledButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      onPressed: _save,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // traveler selector

  Widget _travelerSelector(ColorScheme scheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Paid by', style: TextStyle(fontWeight: FontWeight.w700)),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: widget.travelers.map((t) {
              final selected = t.id == _selectedTraveler.id;

              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  selected: selected,
                  onSelected: (_) {
                    setState(() {
                      _selectedTraveler = t;
                      _travelerNameCtrl.clear();
                    });
                  },
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(t.name),
                      if (t.isSelf) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          LucideIcons.crown,
                          size: 16,
                          color: Colors.amber,
                        ),
                      ],
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _travelerNameCtrl,
          textCapitalization: TextCapitalization.words,
          decoration: InputDecoration(
            hintText: 'Or new person ...',
            filled: true,
            fillColor: scheme.surfaceContainerLow,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
          ),
          onChanged: _createTraveler,
        ),
      ],
    );
  }

  void _createTraveler(String val) {
    final name = val.trim();
    if (name.isEmpty) return;

    final exists = widget.travelers.any(
      (t) => t.name.toLowerCase() == name.toLowerCase(),
    );

    TavelerModel t;

    if (exists) {
      t = widget.travelers.firstWhere(
        (t) => t.name.toLowerCase() == name.toLowerCase(),
      );
    } else {
      t = TavelerModel(tourId: widget.tour.id!, isSelf: false, name: name);
    }

    setState(() {
      _selectedTraveler = t;
    });
  }

  // ---------------- Date Picker ----------------

  Future<void> _pickDate() async {
    FocusManager.instance.primaryFocus?.unfocus();

    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: widget.tour.startDate,
      lastDate: widget.tour.endDate,
    );

    if (picked != null) {
      setState(() => _expenseDate = picked);
    }
  }

  // ---------------- Save ----------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final expense = ExpenseModel(
      id: widget.existing?.id,
      tourId: widget.tour.id!,
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      category: _category,
      expenseDate: _expenseDate,
    );

    await ExpenseDb.upsert(expense, _selectedTraveler);

    Navigator.pop(context, true);
  }
}
