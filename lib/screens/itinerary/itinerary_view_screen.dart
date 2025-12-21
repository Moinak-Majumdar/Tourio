import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

import '../../db/itinerary_db.dart';
import '../../models/itinerary_model.dart';
import '../../models/tour_model.dart';
import 'widgets/itinerary_edit_sheet.dart';

class ItineraryViewScreen extends StatefulWidget {
  final TourModel tour;

  const ItineraryViewScreen({super.key, required this.tour});

  @override
  State<ItineraryViewScreen> createState() => _ItineraryViewScreenState();
}

class _ItineraryViewScreenState extends State<ItineraryViewScreen> {
  final Map<int, ItineraryModel> _dayPlans = {};
  late final PageController _pageController;
  int _currentDay = 1;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    _loadItinerary();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadItinerary() async {
    final items = await ItineraryDb.getByTour(widget.tour.id!);
    setState(() {
      _dayPlans
        ..clear()
        ..addEntries(items.map((e) => MapEntry(e.dayNumber, e)));
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final totalDays = widget.tour.totalDays;
    final plannedDays = _dayPlans.length;
    final selectedPlan = _dayPlans[_currentDay];

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tour.tourName),
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(_currentDay, _dayPlans[_currentDay]),
        label: Text(selectedPlan == null ? 'Add Plan' : 'Edit Plan'),
        icon: const Icon(Icons.edit),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _progressHeader(scheme, plannedDays, totalDays),
          Expanded(
            child: PageView.builder(
              controller: _pageController,
              itemCount: totalDays,
              onPageChanged: (index) {
                setState(() {
                  _currentDay = index + 1;
                });
              },
              itemBuilder: (context, index) {
                final dayNumber = index + 1;
                final plan = _dayPlans[dayNumber];
                final date = widget.tour.startDate.add(Duration(days: index));

                return _dayContent(scheme, dayNumber, plan, date);
              },
            ),
          ),
        ],
      ),
    );
  }

  // ---------------- PROGRESS HEADER ----------------

  Widget _progressHeader(ColorScheme scheme, int planned, int total) {
    final planProgress = total == 0 ? 0.0 : planned / total;
    final dayProgress = _currentDay / total;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.map),
                SizedBox(width: 8),
                Text(
                  'Itinerary',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                SizedBox(
                  width: 50,
                  height: 50,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // ---- Background ring ----
                      CircularProgressIndicator(
                        value: 1,
                        strokeWidth: 6,
                        valueColor: AlwaysStoppedAnimation(
                          scheme.surfaceContainerHighest,
                        ),
                      ),
                      // ---- Progress ring ----
                      CircularProgressIndicator(
                        value: dayProgress.clamp(0.0, 1.0),
                        strokeWidth: 6,
                        strokeCap: StrokeCap.round,
                        valueColor: AlwaysStoppedAnimation(scheme.primary),
                        backgroundColor: Colors.transparent,
                      ),

                      // ---- Center text ----
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _currentDay.toString(),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              '$planned of $total days planned',
              style: TextStyle(color: scheme.outline),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: LinearProgressIndicator(
                value: planProgress,
                minHeight: 8,
                backgroundColor: scheme.surface,
                color: scheme.secondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- DAY CONTENT ----------------

  Widget _dayContent(
    ColorScheme scheme,
    int dayNumber,
    ItineraryModel? plan,
    DateTime date,
  ) {
    final dateFmt = DateFormat('EEEE, dd MMM yyyy');

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: scheme.surfaceContainer,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // -------- Day Header --------
            Row(
              children: [
                Icon(LucideIcons.calendar, size: 18, color: scheme.secondary),
                const SizedBox(width: 8),
                Text(
                  dateFmt.format(date),
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // -------- Content --------
            if (plan == null) ...[
              const Text(
                'Nothing planned yet',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                'Swipe or tap Add Plan to organize this day',
                style: TextStyle(color: scheme.outline),
              ),
            ] else ...[
              Text(
                plan.title,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                ),
              ),
              if (plan.description?.isNotEmpty == true) ...[
                const SizedBox(height: 12),
                Text(plan.description!, style: const TextStyle(fontSize: 15)),
              ],
            ],
          ],
        ),
      ),
    );
  }

  // ---------------- EDIT ----------------

  Future<void> _openEditor(int day, ItineraryModel? plan) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ItineraryEditSheet(
        tourId: widget.tour.id!,
        dayNumber: day,
        existing: plan,
      ),
    );

    if (result == true) {
      _loadItinerary();
    }
  }
}
