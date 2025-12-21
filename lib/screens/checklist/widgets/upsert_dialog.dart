import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/db/checklist_db.dart';
import 'package:tourio/models/checklist_item_model.dart';

class UpsertDialog extends StatelessWidget {
  const UpsertDialog({
    super.key,
    required this.existing,
    required this.tourId,
    required this.isEdit,
    required this.ctrl,
    required this.nonDeletedList,
    required this.onSuccess,
  });
  final TextEditingController ctrl;
  final bool isEdit;
  final List<ChecklistItemModel> nonDeletedList;
  final ChecklistItemModel? existing;
  final int tourId;
  final VoidCallback onSuccess;

  @override
  Widget build(context) {
    final scheme = Theme.of(context).colorScheme;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: Padding(
        padding: const EdgeInsets.all(20),
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
                    isEdit ? LucideIcons.edit3 : LucideIcons.plus,
                    color: scheme.onPrimaryContainer,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  isEdit ? 'Edit checklist item' : 'Add checklist item',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // -------- Input --------
            TextField(
              controller: ctrl,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: InputDecoration(
                hintText: 'e.g. Sunglasses, Socks, Water Bottle',
                filled: true,
                fillColor: scheme.surfaceContainerLow,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide: BorderSide.none,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // -------- Action --------
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                icon: Icon(isEdit ? LucideIcons.check : LucideIcons.plus),
                label: Text(isEdit ? 'Save changes' : 'Add item'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () async {
                  final title = ctrl.text.trim();
                  if (title.isEmpty) return;

                  // ---- Duplicate check (ignore self when editing)
                  final exists = nonDeletedList.any(
                    (e) =>
                        e.title.toLowerCase() == title.toLowerCase() &&
                        e.id != existing?.id,
                  );
                  if (exists) return;

                  if (isEdit) {
                    await ChecklistDb.upsert(
                      ChecklistItemModel(
                        id: existing!.id,
                        tourId: tourId,
                        title: title,
                      ),
                    );
                  } else {
                    await ChecklistDb.upsert(
                      ChecklistItemModel(tourId: tourId, title: title),
                    );
                  }

                  onSuccess();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
