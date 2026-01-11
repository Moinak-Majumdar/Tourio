import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/db/expense_db.dart';
import 'package:tourio/models/expense_model.dart';
import 'package:tourio/screens/expense/widget/category_config.dart';

class ExpenseUpsertSheet extends StatefulWidget {
  final int tourId;
  final ExpenseModel? existing;

  const ExpenseUpsertSheet({super.key, required this.tourId, this.existing});

  @override
  State<ExpenseUpsertSheet> createState() => _ExpenseUpsertSheetState();
}

class _ExpenseUpsertSheetState extends State<ExpenseUpsertSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _titleCtrl;
  late final TextEditingController _amountCtrl;
  final FocusNode _titleFocus = FocusNode();

  String _category = 'Other';
  DateTime _expenseDate = DateTime.now();

  bool get isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();

    _titleCtrl = TextEditingController(text: widget.existing?.title);
    _amountCtrl = TextEditingController(
      text: widget.existing?.amount.toStringAsFixed(0),
    );

    if (widget.existing != null) {
      _category = widget.existing!.category;
      _expenseDate = widget.existing!.expenseDate;
    }

    // 🔑 Autofocus fix for modal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _titleFocus.requestFocus();
    });
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
                  Wrap(
                    spacing: 8,
                    runSpacing: 0,
                    children: expenseCategoryList.map((c) {
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
                    }).toList(),
                  ),

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

  // ---------------- Date Picker ----------------

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _expenseDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
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
      tourId: widget.tourId,
      title: _titleCtrl.text.trim(),
      amount: double.parse(_amountCtrl.text.trim()),
      category: _category,
      expenseDate: _expenseDate,
    );

    await ExpenseDb.upsert(expense);

    Navigator.pop(context, true);
  }
}
