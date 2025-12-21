import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/common/controllers/tour_controller.dart';
import 'package:tourio/screens/home/widgets/tour_card.dart';
import 'package:tourio/screens/itinerary/itinerary_view_screen.dart';
import 'package:tourio/screens/tour/upsert_tour.dart';

class TourList extends StatelessWidget {
  const TourList({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tc = Get.find<TourController>();

    return Obx(() {
      final tours = tc.tours;

      if (tours.isEmpty) {
        return _emptyState(scheme);
      }

      return ListView.builder(
        physics: const BouncingScrollPhysics(),
        itemCount: tours.length,
        itemBuilder: (context, index) {
          final tour = tc.tours[index];
          return TourCard(
            tour: tour,
            onEdit: () => Get.to(() => UpsertTourScreen(tourId: tour.id!)),
            onExpenses: () {
              // Navigate to expenses page with tourId
            },
            onItinerary: () => Get.to(() => ItineraryViewScreen(tour: tour)),
            onNotes: () {
              // Navigate to notes page with tourId
            },
          );
        },
      );
    });
  }

  Widget _emptyState(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.mapPin, size: 48, color: scheme.outline),
          const SizedBox(height: 12),
          const Text('No tours yet', style: TextStyle(fontSize: 16)),
          const SizedBox(height: 4),
          Text(
            'Create your first tour',
            style: TextStyle(color: scheme.outline),
          ),
        ],
      ),
    );
  }
}
