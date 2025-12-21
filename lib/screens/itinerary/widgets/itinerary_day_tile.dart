import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/models/itinerary_model.dart';

class ItineraryDayTile extends StatelessWidget {
  final int dayNumber;
  final DateTime date;
  final ItineraryModel? plan;
  final bool isLast;
  final VoidCallback onEdit;

  const ItineraryDayTile({
    super.key,
    required this.dayNumber,
    required this.date,
    required this.plan,
    required this.isLast,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('dd MMM');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // -------- Timeline --------
        Column(
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: plan != null ? scheme.primary : scheme.outline,
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 80,
                color: scheme.outline.withValues(alpha: 0.3),
              ),
          ],
        ),
        const SizedBox(width: 12),

        // -------- Content --------
        Expanded(
          child: Container(
            margin: const EdgeInsets.only(bottom: 24),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Day $dayNumber • ${dateFmt.format(date)}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: scheme.outline,
                  ),
                ),
                const SizedBox(height: 8),

                if (plan == null) ...[
                  const Text(
                    'Nothing planned yet',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to add plan for this day',
                    style: TextStyle(color: scheme.outline),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(LucideIcons.plus),
                    label: const Text('Add plan'),
                  ),
                ] else ...[
                  Text(
                    plan!.title,
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  if (plan!.description?.isNotEmpty == true) ...[
                    const SizedBox(height: 4),
                    Text(plan!.description!),
                  ],
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(LucideIcons.edit3, size: 18),
                    label: const Text('Edit'),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}
