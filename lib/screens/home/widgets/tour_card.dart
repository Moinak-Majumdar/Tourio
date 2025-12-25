import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/models/tour_model.dart';

class TourCard extends StatelessWidget {
  final TourModel tour;
  final VoidCallback onEdit;
  final VoidCallback onExpenses;
  final VoidCallback onItinerary;
  final VoidCallback onNotes;
  final VoidCallback onChecklist;

  const TourCard({
    super.key,
    required this.tour,
    required this.onEdit,
    required this.onExpenses,
    required this.onItinerary,
    required this.onNotes,
    required this.onChecklist,
  });

  static const _defaultImages = [
    'assets/images/tour_1.jpg',
    'assets/images/tour_2.jpg',
    'assets/images/tour_3.jpg',
    'assets/images/tour_4.jpg',
  ];

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final dateFmt = DateFormat('dd MMM');

    final String titleText = tour.name != null && tour.name!.trim().isNotEmpty
        ? tour.name!
        : tour.destination;

    final fallbackImage = _defaultImages[tour.id! % _defaultImages.length];

    return Container(
      height: 220,
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: Stack(
          fit: StackFit.expand,
          children: [
            _imageLayer(fallbackImage),
            _gradientOverlay(),
            _contentLayer(scheme, titleText, dateFmt),
          ],
        ),
      ),
    );
  }

  // ---------------- Layers ----------------

  Widget _imageLayer(String fallbackAsset) {
    return tour.coverImagePath != null
        ? Image.file(File(tour.coverImagePath!), fit: BoxFit.cover)
        : Image.asset(fallbackAsset, fit: BoxFit.cover);
  }

  Widget _gradientOverlay() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.transparent, Color(0x99000000)],
        ),
      ),
    );
  }

  Widget _contentLayer(ColorScheme scheme, String title, DateFormat dateFmt) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // -------- Title --------
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 6),

          // -------- Date Row --------
          Row(
            children: [
              const Icon(LucideIcons.calendar, size: 14, color: Colors.white70),
              const SizedBox(width: 6),
              Text(
                '${tour.totalDays} days · '
                '${dateFmt.format(tour.startDate)} - ${dateFmt.format(tour.endDate)}',
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // -------- Actions --------
          _actionRow(),
        ],
      ),
    );
  }

  // ---------------- Actions ----------------

  Widget _actionRow() {
    return Row(
      children: [
        _glassIcon(LucideIcons.edit3, onEdit),
        _glassIcon(LucideIcons.clipboardCheck, onChecklist),
        _glassIcon(LucideIcons.map, onItinerary),
        _glassIcon(LucideIcons.wallet, onExpenses),
        _glassIcon(LucideIcons.fileText, onNotes),
      ],
    );
  }

  Widget _glassIcon(IconData icon, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          height: 42,
          width: 42,
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: 0.18),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.white.withValues(alpha: 0.25)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      ),
    );
  }
}
