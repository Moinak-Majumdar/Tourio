import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/common/controllers/tour_controller.dart';
import 'package:tourio/models/tour_model.dart';
import 'package:tourio/screens/tour/upsert_tour.dart';

class OngoingTourDialog extends StatelessWidget {
  const OngoingTourDialog({super.key});

  @override
  Widget build(context) {
    final scheme = Theme.of(context).colorScheme;
    final tc = Get.find<TourController>();
    final df = DateFormat('E, dd MMM');

    return Dialog(
      backgroundColor: scheme.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 24, 24, 20),
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
                    LucideIcons.mapPin,
                    color: scheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Ongoing Tour / Plan',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              'Your happpy moments..',
              style: TextStyle(fontSize: 13, color: scheme.outline),
            ),

            const SizedBox(height: 20),

            // -------- Selector --------
            Obx(() {
              if (tc.tours.isEmpty) {
                return Text(
                  'Ahh, looks like you have no tours..',
                  style: TextStyle(color: scheme.secondary, fontSize: 16),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: scheme.surfaceContainerLow,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                              width: 1.2,
                              color: scheme.outline,
                            ),
                          ),
                          child: DropdownButtonHideUnderline(
                            child: DropdownButton<TourModel>(
                              value:
                                  tc.tours.any(
                                    (t) => t.id == tc.ongoingTourId.value,
                                  )
                                  ? tc.ongoingTour
                                  : null,
                              isExpanded: true,
                              hint: Text(
                                'Choose a tour',
                                style: TextStyle(color: scheme.outline),
                              ),
                              icon: Icon(
                                LucideIcons.chevronDown,
                                size: 20,
                                color: scheme.outline,
                              ),
                              borderRadius: BorderRadius.circular(18),
                              items: tc.tours.map((tour) {
                                final title = tour.name?.isNotEmpty == true
                                    ? tour.name!
                                    : tour.destination;

                                return DropdownMenuItem<TourModel>(
                                  value: tour,
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.travel_explore_rounded,
                                        size: 18,
                                        color: scheme.outline,
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: Text(
                                          title,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              }).toList(),
                              onChanged: (tour) {
                                tc.setOngoing(tour!.id!);
                              },
                            ),
                          ),
                        ),
                      ),

                      if (tc.ongoingTour != null) ...[
                        SizedBox(width: 4),
                        IconButton(
                          onPressed: () {
                            tc.clearOngoing();
                          },
                          icon: Icon(LucideIcons.x, color: scheme.error),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (tc.ongoingTour != null)
                    Row(
                      children: [
                        SizedBox(width: 8),
                        Text(
                          df.format(tc.ongoingTour!.startDate),
                          style: TextStyle(fontSize: 12, color: scheme.outline),
                        ),
                        Text(' ~ ', style: TextStyle(color: scheme.primary)),
                        Text(
                          df.format(tc.ongoingTour!.endDate),
                          style: TextStyle(fontSize: 12, color: scheme.outline),
                        ),
                      ],
                    ),
                ],
              );
            }),

            if (tc.tours.isEmpty) ...[
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Get.to(UpsertTourScreen());
                  },
                  icon: const Icon(LucideIcons.plus),
                  label: const Text('Create Tour'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
