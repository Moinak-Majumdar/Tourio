import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/models/checklist_filter.dart';

class ChecklistFilterDialog extends StatefulWidget {
  final ChecklistFilter initial;

  const ChecklistFilterDialog({super.key, required this.initial});

  @override
  State<ChecklistFilterDialog> createState() => _ChecklistFilterDialogState();
}

class _ChecklistFilterDialogState extends State<ChecklistFilterDialog> {
  late ChecklistStatusFilter _status;
  late ChecklistSortOrder _order;

  @override
  void initState() {
    super.initState();
    _status = widget.initial.status;
    _order = widget.initial.order;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------- Header --------
            Row(
              children: [
                Icon(LucideIcons.filter, color: scheme.primary),
                const SizedBox(width: 8),
                const Text(
                  'Filter checklist',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // -------- STATUS --------
            _sectionTitle('Filter items', scheme),
            RadioGroup<ChecklistStatusFilter>(
              groupValue: _status,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _status = value);
                }
              },
              child: Column(
                children: [
                  _radioRow(label: 'All', value: ChecklistStatusFilter.all),
                  _radioRow(
                    label: 'Checked',
                    value: ChecklistStatusFilter.checked,
                  ),
                  _radioRow(
                    label: 'Unchecked',
                    value: ChecklistStatusFilter.unchecked,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // -------- SORT --------
            _sectionTitle('Sort items', scheme),
            const SizedBox(height: 6),
            RadioGroup<ChecklistSortOrder>(
              groupValue: _order,
              onChanged: (value) {
                if (value != null) {
                  setState(() => _order = value);
                }
              },
              child: Column(
                children: [
                  _radioRow(label: 'A → Z', value: ChecklistSortOrder.az),
                  _radioRow(label: 'Z → A', value: ChecklistSortOrder.za),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // -------- Actions --------
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, ChecklistFilter.reset);
                  },
                  child: const Text('Reset'),
                ),
                const Spacer(),
                FilledButton(
                  onPressed: () {
                    Navigator.pop(
                      context,
                      ChecklistFilter(status: _status, order: _order),
                    );
                  },
                  child: const Text('Apply'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Helpers ----------------

  Widget _sectionTitle(String text, ColorScheme scheme) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.w600, color: scheme.secondary),
    );
  }

  Widget _radioRow<T>({required String label, required T value}) {
    return RadioListTile<T>(
      value: value,
      title: Text(label),
      dense: true,
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
    );
  }
}
