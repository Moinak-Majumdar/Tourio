import 'package:flutter/material.dart';
import 'package:flutter_expandable_fab/flutter_expandable_fab.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/common/controllers/tour_controller.dart';
import 'package:tourio/common/theme/glass_card.dart';
import 'package:tourio/screens/home/widgets/home_drawer.dart';
import 'package:tourio/screens/home/widgets/ongoing_tour_dialog.dart';
import 'package:tourio/screens/home/widgets/tour_list.dart';
import 'package:tourio/screens/tour/upsert_tour.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _key = GlobalKey<ExpandableFabState>();

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final tc = Get.find<TourController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tourio'),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
      ),
      drawer: const HomeDrawer(),
      floatingActionButtonLocation: ExpandableFab.location,
      floatingActionButton: ExpandableFab(
        key: _key,
        overlayStyle: ExpandableFabOverlayStyle(blur: 4),
        children: [
          FloatingActionButton.extended(
            heroTag: 'create_tour',
            onPressed: () {
              final state = _key.currentState;
              if (state != null) {
                state.close();
                Get.to(() => const UpsertTourScreen());
              }
            },
            icon: const Icon(LucideIcons.plus),
            label: const Text('Create Tour'),
          ),
          FloatingActionButton.extended(
            heroTag: 'ongoing_tour',
            onPressed: () {
              final state = _key.currentState;
              if (state != null) {
                showDialog(
                  context: context,
                  builder: (context) => const OngoingTourDialog(),
                );
                state.close();
              }
            },
            icon: const Icon(LucideIcons.mapPin),
            label: const Text('Ongoing Tour'),
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _heroHeader(),
              const SizedBox(height: 20),
              Obx(() {
                return Row(
                  children: [
                    Expanded(
                      child: _statCard(
                        scheme,
                        icon: LucideIcons.map,
                        title: 'Tours',
                        value: tc.tourCount.value.toString(),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _statCard(
                        scheme,
                        icon: LucideIcons.wallet,
                        title: 'Expenses',
                        value: '₹${tc.expenseCount.value.toStringAsFixed(2)}',
                      ),
                    ),
                  ],
                );
              }),
              const SizedBox(height: 28),
              _sectionTitle('Your Tours'),
              const SizedBox(height: 12),
              Expanded(child: const TourList()),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Hero Header ----------------
  Widget _heroHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome back',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Plan your next journey',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
        ),
      ],
    );
  }

  // ---------------- Stats ----------------
  Widget _statCard(
    ColorScheme scheme, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    return GlassCard(
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22, color: scheme.primary),
          const SizedBox(height: 14),
          Text(
            title,
            style: TextStyle(
              fontSize: 13,
              color: scheme.outline,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }

  // ---------------- Section Title ----------------
  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
      ),
    );
  }
}
