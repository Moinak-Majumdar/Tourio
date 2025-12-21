import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/common/controllers/tour_controller.dart';
import 'package:tourio/models/tour_model.dart';
import 'package:tourio/screens/checklist/checklist_screen.dart';
import 'package:tourio/screens/itinerary/itinerary_view_screen.dart';

enum TourAction { itinerary, notes, expenses, checklist }

class TourSelectDialog {
  static Future<void> open(
    BuildContext context, {
    required TourAction action,
  }) async {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (_) => _TourSelectDialogContent(action: action),
    );
  }
}

class _TourSelectDialogContent extends StatefulWidget {
  final TourAction action;

  const _TourSelectDialogContent({required this.action});

  @override
  State<_TourSelectDialogContent> createState() =>
      _TourSelectDialogContentState();
}

class _TourSelectDialogContentState extends State<_TourSelectDialogContent> {
  TourModel? _selectedTour;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tc = Get.find<TourController>();

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
                  'Select tour',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              'Choose a tour to continue',
              style: TextStyle(fontSize: 13, color: scheme.outline),
            ),

            const SizedBox(height: 20),

            // -------- Selector --------
            GestureDetector(
              onTap: () {},
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainerLow,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: _selectedTour == null
                        ? Colors.transparent
                        : scheme.primary.withValues(alpha: 0.4),
                    width: 1.2,
                  ),
                ),
                child: Obx(
                  () => DropdownButtonHideUnderline(
                    child: DropdownButton<TourModel>(
                      isExpanded: true,
                      value: _selectedTour,
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
                        setState(() {
                          _selectedTour = tour;
                        });
                      },
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 28),

            // -------- Action --------
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _selectedTour == null
                    ? null
                    : () {
                        Navigator.of(context).pop();
                        _navigate();
                      },
                icon: const Icon(LucideIcons.arrowRight),
                label: const Text('Continue'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Navigation ----------------

  void _navigate() {
    switch (widget.action) {
      case TourAction.itinerary:
        Get.to(() => ItineraryViewScreen(tour: _selectedTour!));
        break;

      case TourAction.checklist:
        Get.to(() => ChecklistScreen(tour: _selectedTour!));
        break;

      case TourAction.notes:
        // Get.to(() => NotesScreen(tour: tour));
        break;

      case TourAction.expenses:
        // Get.to(() => ExpensesScreen(tour: tour));
        break;
    }
  }
}
