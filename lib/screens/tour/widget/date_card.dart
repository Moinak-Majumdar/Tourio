import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class DateRangeCard extends StatelessWidget {
  final DateTimeRange? range;
  final bool hasError;
  final ValueChanged<DateTimeRange> onSelect;

  const DateRangeCard({
    super.key,
    required this.range,
    required this.onSelect,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final df = DateFormat('dd MMM, yyyy');

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () async {
        FocusManager.instance.primaryFocus?.unfocus();
        final picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime(2099),
          initialDateRange: range,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(colorScheme: scheme),
              child: child!,
            );
          },
        );

        if (picked != null) onSelect(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: hasError ? scheme.error : scheme.outline),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // START
            _DateBlock(
              label: 'START',
              hasError: hasError,
              value: range == null ? null : df.format(range!.start),
            ),

            Icon(
              Icons.arrow_forward_rounded,
              color: hasError ? scheme.error : scheme.primary,
            ),

            // END
            _DateBlock(
              label: 'END',
              hasError: hasError,
              value: range == null ? null : df.format(range!.end),
            ),

            Container(
              padding: EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(
                LucideIcons.calendar,
                size: 24,
                color: hasError ? scheme.error : scheme.primary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DateBlock extends StatelessWidget {
  final String label;
  final String? value;
  final bool hasError;

  const _DateBlock({required this.label, this.value, this.hasError = false});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w600,
            color: hasError ? scheme.error : scheme.primary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value ?? 'Select date',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: value == null ? scheme.outline : scheme.onSurface,
          ),
        ),
      ],
    );
  }
}
