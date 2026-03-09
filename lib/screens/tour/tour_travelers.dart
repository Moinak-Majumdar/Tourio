import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/common/controllers/tour_controller.dart';

import '../../db/traveler_db.dart';
import '../../helper/delete_ack_dialog.dart';
import '../../models/taveler_model.dart';
import '../../models/tour_model.dart';

class TourTravelers extends StatefulWidget {
  const TourTravelers({super.key, required this.tour});

  final TourModel tour;

  @override
  State<TourTravelers> createState() => _TourTravelersState();
}

class _TourTravelersState extends State<TourTravelers> {
  List<TavelerModel> _travelers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final travelers = await TravelerDb.getAllByTour(widget.tour.id!);
    await Get.find<TourController>().refreshTours();
    setState(() {
      _travelers = travelers;
      _isLoading = false;
    });
  }

  String _getInitials(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(RegExp(r'\s+'));
    if (parts.length > 1) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }

  Future<void> _showAddUpdateDialog([TavelerModel? traveler]) async {
    final isUpdate = traveler != null;
    final nameCtrl = TextEditingController(text: isUpdate ? traveler.name : '');
    final scheme = Theme.of(context).colorScheme;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(isUpdate ? 'Update Traveler' : 'Add Traveler'),
          content: TextField(
            controller: nameCtrl,
            decoration: InputDecoration(
              hintText: 'Or new person ...',
              filled: true,
              fillColor: scheme.surfaceContainerLow,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none,
              ),
            ),
            autofocus: true,
            textCapitalization: TextCapitalization.words,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    if (result == true && nameCtrl.text.trim().isNotEmpty) {
      final newModel = TavelerModel(
        id: traveler?.id,
        tourId: widget.tour.id!,
        name: nameCtrl.text.trim(),
        isSelf: traveler?.isSelf ?? false,
      );
      await TravelerDb.upsertTraveler(newModel);
      _loadData(); // refresh list
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    if (_isLoading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.primary),
        ),
      );
    }

    final tourName = widget.tour.tourName;
    final count = _travelers.length.toString();

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(tourName),
        actions: [
          IconButton(
            onPressed: _showAddUpdateDialog,
            icon: const Icon(LucideIcons.userPlus),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  count,
                  style: textTheme.displayMedium?.copyWith(
                    color: colorScheme.onSurface,
                    fontWeight: FontWeight.bold,
                    height: 1.0,
                  ),
                ),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6.0),
                  child: Text(
                    'Participants',
                    style: textTheme.titleMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'CONFIRMED LIST',
              style: textTheme.labelMedium?.copyWith(
                color: colorScheme.outline,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ListView.separated(
                itemCount: _travelers.length,
                separatorBuilder: (context, index) => Divider(
                  color: colorScheme.surfaceContainerHighest,
                  height: 1,
                ),
                itemBuilder: (context, index) {
                  final t = _travelers[index];
                  final initials = _getInitials(t.name);
                  final date = t.createdAt != null
                      ? DateFormat('MMM dd, yyyy').format(t.createdAt!)
                      : '';
                  final deletable = t.totalSpend == 0 && !t.isSelf;

                  Widget tile = InkWell(
                    onTap: () => _showAddUpdateDialog(t),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor:
                                colorScheme.surfaceContainerHighest,
                            child: Text(
                              initials,
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.onSurface,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      t.name,
                                      style: textTheme.titleMedium?.copyWith(
                                        color: colorScheme.onSurface,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                    if (t.isSelf) ...[
                                      const SizedBox(width: 4),
                                      Icon(
                                        LucideIcons.crown,
                                        color: colorScheme.primary,
                                      ),
                                    ],
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  date,
                                  style: textTheme.bodyMedium?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (deletable)
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: Icon(
                                Icons.swipe_left,
                                color: colorScheme.onSurfaceVariant,
                              ),
                            ),
                          if (!deletable)
                            Text(
                              NumberFormat.currency(
                                symbol: '₹',
                                decimalDigits: 0,
                              ).format(t.totalSpend),
                              style: textTheme.titleMedium?.copyWith(
                                color: colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                        ],
                      ),
                    ),
                  );

                  if (deletable) {
                    return Dismissible(
                      key: ValueKey(t.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20.0),
                        color: colorScheme.error,
                        child: Icon(Icons.delete, color: colorScheme.onError),
                      ),
                      confirmDismiss: (direction) async {
                        return await showDialog<bool>(
                          context: context,
                          builder: (context) => DeleteAckDialog(
                            title: 'Delete Traveler',
                            message:
                                'Are you sure you want to delete ${t.name} from this tour?',
                            btnText: 'Delete',
                            onConfirm: () => Navigator.pop(context, true),
                            onCancel: () => Navigator.pop(context, false),
                          ),
                        );
                      },
                      onDismissed: (direction) async {
                        await TravelerDb.deleteTraveler(t.id!);
                        _loadData();
                      },
                      child: tile,
                    );
                  }

                  return tile;
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
