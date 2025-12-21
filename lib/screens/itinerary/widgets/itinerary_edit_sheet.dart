import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tourio/db/itinerary_db.dart';
import 'package:tourio/models/itinerary_model.dart';

class ItineraryEditSheet extends StatefulWidget {
  final int tourId;
  final int dayNumber;
  final ItineraryModel? existing;

  const ItineraryEditSheet({
    super.key,
    required this.tourId,
    required this.dayNumber,
    this.existing,
  });

  @override
  State<ItineraryEditSheet> createState() => _ItineraryEditSheetState();
}

class _ItineraryEditSheetState extends State<ItineraryEditSheet> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _titleCtrl.text = widget.existing!.title;
      _descCtrl.text = widget.existing!.description ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(16, 16, 16, bottom + 16),
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
              Text(
                'Day ${widget.dayNumber}',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 16),

              TextField(
                controller: _titleCtrl,
                decoration: const InputDecoration(labelText: 'Title'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(labelText: 'Description'),
                textCapitalization: TextCapitalization.sentences,
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _save,
                  child: const Text('Save'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _save() async {
    final title = _titleCtrl.text.trim();
    final desc = _descCtrl.text.trim();

    if (title.isEmpty && desc.isEmpty) {
      Get.back(result: false);
      return;
    }

    await ItineraryDb.upsert(
      ItineraryModel(
        id: widget.existing?.id,
        tourId: widget.tourId,
        dayNumber: widget.dayNumber,
        title: title,
        description: desc,
      ),
    );

    Get.back(result: true);
  }
}
