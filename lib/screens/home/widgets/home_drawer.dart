import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/common/controllers/tour_controller.dart';
import 'package:tourio/screens/checklist/checklist_screen.dart';
import 'package:tourio/screens/home/widgets/tour_select_dialog.dart';
import 'package:tourio/screens/itinerary/itinerary_view_screen.dart';
import 'package:tourio/screens/settings/settings_screen.dart';
import 'package:tourio/screens/tour/upsert_tour.dart';

class HomeDrawer extends StatelessWidget {
  const HomeDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tc = Get.find<TourController>();

    return Drawer(
      backgroundColor: scheme.surface,
      child: SafeArea(
        child: Obx(
          () => Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _drawerHeader(scheme),
              const SizedBox(height: 12),

              _drawerSection('Main'),
              _drawerItem(
                icon: LucideIcons.home,
                title: 'Home',
                onTap: () => Get.back(),
              ),
              _drawerItem(
                icon: LucideIcons.plusCircle,
                title: 'Create Tour',
                onTap: () => Get.to(() => const UpsertTourScreen()),
              ),

              if (tc.tours.isNotEmpty) ...[
                _drawerItem(
                  icon: LucideIcons.clipboardCheck,
                  title: 'Checklist',
                  onTap: () {
                    final ot = tc.ongoingTour;
                    if (ot != null) {
                      Get.to(() => ChecklistScreen(tour: ot));
                    } else {
                      TourSelectDialog.open(
                        context,
                        action: TourAction.checklist,
                      );
                    }
                  },
                ),
                _drawerItem(
                  icon: LucideIcons.map,
                  title: 'Itinerary',
                  onTap: () {
                    final ot = tc.ongoingTour;
                    if (ot != null) {
                      Get.to(() => ItineraryViewScreen(tour: ot));
                    } else {
                      TourSelectDialog.open(
                        context,
                        action: TourAction.itinerary,
                      );
                    }
                  },
                ),
                _drawerItem(
                  icon: Icons.event_note_outlined,
                  title: 'Notes',
                  size: 22,
                  onTap: () => {
                    TourSelectDialog.open(context, action: TourAction.notes),
                  },
                ),
                _drawerItem(
                  icon: LucideIcons.wallet2,
                  title: 'Expenses',
                  onTap: () => {
                    TourSelectDialog.open(context, action: TourAction.expenses),
                  },
                ),
              ],
              const SizedBox(height: 16),
              _drawerSection('Preferences'),
              _drawerItem(
                icon: LucideIcons.settings,
                title: 'Settings',
                onTap: () => Get.to(() => const SettingsScreen()),
              ),

              const Spacer(),

              _drawerFooter(scheme),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Header ----------------
  Widget _drawerHeader(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: scheme.surfaceContainerHighest,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tourio',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              'Your travel planner',
              style: TextStyle(color: scheme.outline),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------- Section Label ----------------
  Widget _drawerSection(String text) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 6),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: Colors.grey,
        ),
      ),
    );
  }

  // ---------------- Item ----------------
  Widget _drawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    double size = 20,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: ListTile(
        onTap: onTap,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        leading: Icon(icon, size: size),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        horizontalTitleGap: 12,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
      ),
    );
  }

  // ---------------- Footer ----------------
  Widget _drawerFooter(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(36, 12, 24, 12),
      child: Text(
        'For a traveller, by a traveller.',
        style: TextStyle(fontSize: 14, color: scheme.outline),
      ),
    );
  }
}
