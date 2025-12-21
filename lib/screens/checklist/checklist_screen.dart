import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/models/checklist_filter.dart';
import 'package:tourio/screens/checklist/widgets/filter_dialog.dart';
import 'package:tourio/screens/checklist/widgets/upsert_dialog.dart';

import '../../db/checklist_db.dart';
import '../../models/checklist_item_model.dart';
import '../../models/tour_model.dart';
import 'widgets/deleted_items_sheet.dart';

class ChecklistScreen extends StatefulWidget {
  final TourModel tour;

  const ChecklistScreen({super.key, required this.tour});

  @override
  State<ChecklistScreen> createState() => _ChecklistScreenState();
}

class _ChecklistScreenState extends State<ChecklistScreen> {
  final List<ChecklistItemModel> _items = [];
  final List<ChecklistItemModel> _deletedItems = [];

  final List<String> _essentials = const [
    'Passport / ID',
    'Tickets',
    'Phone charger',
    'Power bank',
    'Camera',
    'Headphones',
    'Towel',
    'Toiletries',
    'Medicines',
    'Slippers',
  ];

  ChecklistFilter _filter = ChecklistFilter.reset;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final active = await ChecklistDb.getAllNonDeleted(widget.tour.id!);
    final deleted = await ChecklistDb.getAllDeleted(widget.tour.id!);

    setState(() {
      _items
        ..clear()
        ..addAll(active);
      _deletedItems
        ..clear()
        ..addAll(deleted);
    });
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    final completed = _items.where((e) => e.isCompleted).length;
    final progress = _items.isEmpty ? 0.0 : completed / _items.length;

    final existingTitles = _items.map((e) => e.title.toLowerCase()).toSet();

    final remainingEssentials = _essentials
        .where((e) => !existingTitles.contains(e.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
        title: Text(widget.tour.tourName),
        actions: [
          IconButton(
            icon: const Icon(LucideIcons.filter),
            onPressed: _openFilterDialog,
          ),
          if (_deletedItems.isNotEmpty)
            IconButton(
              icon: const Icon(LucideIcons.trash2),
              onPressed: _openDeletedItems,
            ),
        ],
      ),

      // ---------------- BODY ----------------
      body: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        child: Column(
          children: [
            _progressCard(scheme, completed, _items.length, progress),

            const SizedBox(height: 12),

            if (remainingEssentials.isNotEmpty)
              _essentialsBox(scheme, remainingEssentials),

            const SizedBox(height: 12),

            // -------- Checklist Box --------
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: scheme.surfaceContainer,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: _filteredItems.isEmpty
                    ? _emptyState(scheme)
                    : ListView.builder(
                        itemCount: _filteredItems.length,
                        itemBuilder: (_, i) =>
                            _itemTile(_filteredItems[i], scheme),
                      ),
              ),
            ),
          ],
        ),
      ),

      // ---------------- ADD ITEM FAB ----------------
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _upsertModal,
        icon: const Icon(LucideIcons.plus),
        label: const Text('Add'),
      ),
    );
  }

  // ================= UI SECTIONS =================

  Widget _progressCard(
    ColorScheme scheme,
    int completed,
    int total,
    double progress,
  ) {
    return Container(
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
              Icon(LucideIcons.backpack, color: scheme.primary, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Packing progress',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            total == 0
                ? 'Start preparing for your journey'
                : '$completed of $total items packed',
            style: TextStyle(color: scheme.outline),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: scheme.surface,
            ),
          ),
        ],
      ),
    );
  }

  Widget _essentialsBox(ColorScheme scheme, List<String> essentials) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(20)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(LucideIcons.star, size: 18, color: scheme.primary),
              const SizedBox(width: 6),
              const Text(
                'Suggested essentials',
                style: TextStyle(fontWeight: FontWeight.w600),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // -------- Horizontal chips --------
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: essentials.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final title = essentials[i];

                return ActionChip(
                  label: Text(title),
                  backgroundColor: scheme.surfaceContainerLow,
                  onPressed: () => _addEssential(title),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _itemTile(ChecklistItemModel item, ColorScheme scheme) {
    return Dismissible(
      key: ValueKey(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) async {
        await ChecklistDb.softDelete(item.id!);
        _load();
      },

      background: Container(
        padding: const EdgeInsets.only(right: 20),
        alignment: Alignment.centerRight,
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Text(
          'Delete',
          style: TextStyle(
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(18),
        ),
        child: ListTile(
          trailing: Checkbox(
            value: item.isCompleted,
            onChanged: (v) async {
              await ChecklistDb.toggleCompleted(item.id!, v ?? false);
              _load();
            },
          ),
          onTap: () async {
            await ChecklistDb.toggleCompleted(item.id!, !item.isCompleted);
            _load();
          },
          onLongPress: () => _upsertModal(existing: item),
          title: Text(
            item.title,
            style: TextStyle(
              decoration: item.isCompleted ? TextDecoration.lineThrough : null,
            ),
          ),
        ),
      ),
    );
  }

  Widget _emptyState(ColorScheme scheme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(LucideIcons.listChecks, size: 48, color: scheme.outline),
          const SizedBox(height: 12),
          const Text(
            'No items yet',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(
            'Use suggestions or add your own',
            style: TextStyle(color: scheme.outline),
          ),
        ],
      ),
    );
  }

  // ================= ACTIONS =================

  Future<void> _addEssential(String title) async {
    await ChecklistDb.upsert(
      ChecklistItemModel(
        tourId: widget.tour.id!,
        title: title,
        createdAt: DateTime.now(),
        lastUpdatedAt: DateTime.now(),
      ),
    );
    _load();
  }

  void _openDeletedItems() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          DeletedItemsSheet(initialItems: _deletedItems, onSuccess: _load),
    );
  }

  Future<void> _upsertModal({ChecklistItemModel? existing}) async {
    final ctrl = TextEditingController(text: existing?.title ?? '');

    await showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) {
        return UpsertDialog(
          existing: existing,
          tourId: widget.tour.id!,
          isEdit: existing != null,
          ctrl: ctrl,
          nonDeletedList: _items,
          onSuccess: () {
            Navigator.pop(context);
            _load();
          },
        );
      },
    );
  }

  // Filter dialog
  Future<void> _openFilterDialog() async {
    final result = await showDialog<ChecklistFilter>(
      context: context,
      builder: (_) => ChecklistFilterDialog(initial: _filter),
    );

    if (result != null) {
      setState(() {
        _filter = result;
      });
    }
  }

  List<ChecklistItemModel> get _filteredItems {
    List<ChecklistItemModel> list = List.from(_items);
    // _items is already in created_at ASC from DB

    // ---- Status filter ----
    switch (_filter.status) {
      case ChecklistStatusFilter.checked:
        list = list.where((e) => e.isCompleted).toList();
        break;
      case ChecklistStatusFilter.unchecked:
        list = list.where((e) => !e.isCompleted).toList();
        break;
      case ChecklistStatusFilter.all:
        break;
    }

    // ---- Sort ONLY if user selected one ----
    if (_filter.order != ChecklistSortOrder.none) {
      list.sort(
        (a, b) => a.title.toLowerCase().compareTo(b.title.toLowerCase()),
      );

      if (_filter.order == ChecklistSortOrder.za) {
        list = list.reversed.toList();
      }
    }

    return list;
  }
}
