import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/db/checklist_db.dart';
import 'package:tourio/models/checklist_item_model.dart';

class DeletedItemsSheet extends StatefulWidget {
  final List<ChecklistItemModel> initialItems;
  final VoidCallback onSuccess;

  const DeletedItemsSheet({
    super.key,
    required this.initialItems,
    required this.onSuccess,
  });

  @override
  State<DeletedItemsSheet> createState() => _DeletedItemsSheetState();
}

class _DeletedItemsSheetState extends State<DeletedItemsSheet> {
  late List<ChecklistItemModel> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.initialItems);
  }

  @override
  Widget build(BuildContext context) {
    final df = DateFormat('EEE, MMM d, yy • hh:mm a');
    final scheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // -------- Header --------
              Row(
                children: [
                  Icon(LucideIcons.trash2, color: scheme.primary),
                  const SizedBox(width: 8),
                  const Text(
                    'Recently Deleted',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              if (_items.isEmpty)
                _emptyState(scheme)
              else
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height * 0.7,
                  ),
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: _items.length,
                    separatorBuilder: (c, i) => const Divider(height: 1),
                    itemBuilder: (_, index) {
                      final item = _items[index];

                      return Dismissible(
                        key: ValueKey(item.id),
                        direction: DismissDirection.endToStart,
                        onDismissed: (_) {
                          _hardDeleteItem(item, index);
                        },
                        background: Container(
                          padding: const EdgeInsets.only(right: 20),
                          alignment: Alignment.centerRight,
                          decoration: BoxDecoration(
                            color: Colors.red,
                            // borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            'Delete',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                        child: ListTile(
                          title: Text(item.title),
                          subtitle: item.lastUpdatedAt != null
                              ? Text(df.format(item.lastUpdatedAt!))
                              : null,
                          subtitleTextStyle: TextStyle(
                            color: scheme.outline,
                            fontSize: 11,
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              LucideIcons.undo2,
                              color: scheme.primary,
                              size: 18,
                            ),
                            onPressed: () => _restoreItem(item, index),
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- Actions ----------------

  Future<void> _restoreItem(ChecklistItemModel item, int index) async {
    await ChecklistDb.restore(item.id!);

    setState(() {
      _items.removeAt(index);
    });

    widget.onSuccess();
  }

  Future<void> _hardDeleteItem(ChecklistItemModel item, int index) async {
    await ChecklistDb.hardDelete(item.id!);

    setState(() {
      _items.removeAt(index);
    });

    widget.onSuccess();
  }

  // ---------------- Empty ----------------

  Widget _emptyState(ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(LucideIcons.inbox, size: 36, color: scheme.outline),
            const SizedBox(height: 12),
            const Text(
              'No deleted items',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text('Everything is safe', style: TextStyle(color: scheme.outline)),
          ],
        ),
      ),
    );
  }
}
