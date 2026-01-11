import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:tourio/common/controllers/tour_controller.dart';
import 'package:tourio/db/tour_db.dart';
import 'package:tourio/helper/move_img.dart';
import 'package:tourio/models/tour_model.dart';

class UpsertTourScreen extends StatefulWidget {
  final int? tourId;

  const UpsertTourScreen({super.key, this.tourId});

  bool get isEdit => tourId != null;

  @override
  State<UpsertTourScreen> createState() => _UpsertTourScreenState();
}

class _UpsertTourScreenState extends State<UpsertTourScreen> {
  final _nameCtrl = TextEditingController();
  final _destinationCtrl = TextEditingController();
  final _budgetCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.isEdit) {
      _loadTour();
    }
  }

  DateTime? _startDate;
  DateTime? _endDate;

  File? _coverImage;
  final _formKey = GlobalKey<FormState>();

  bool _startDateError = false;
  bool _endDateError = false;

  final ImagePicker _picker = ImagePicker();

  int get totalDays {
    if (_startDate == null || _endDate == null) return 0;
    if (_endDate!.isBefore(_startDate!)) return 0;

    return _endDate!.difference(_startDate!).inDays + 1;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isEdit ? 'Edit Tour' : 'Create Tour'),
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: scheme.surface,
      ),

      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveTour,
        icon: const Icon(LucideIcons.check),
        label: Text(widget.isEdit ? 'Update' : 'Save'),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _coverPicker(scheme),
              const SizedBox(height: 20),

              const SizedBox(height: 24),
              _section('Tour Details'),
              _input(
                _destinationCtrl,
                'Destination',
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '';
                  }
                  return null;
                },
              ),
              _input(
                _nameCtrl,
                'Display name',
                onChanged: (_) => setState(() {}),
              ),
              _input(
                _budgetCtrl,
                keyboardType: TextInputType.number,
                'Budget',
                onChanged: (_) => setState(() {}),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return '';
                  }
                  return null;
                },
              ),

              const SizedBox(height: 24),
              _section('Dates'),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: _dateButton(
                          label: 'Start date',
                          date: _startDate,
                          onSelect: (d) {
                            setState(() {
                              _startDate = d;
                              _startDateError = false;
                            });
                          },
                          hasError: _startDateError,
                        ),
                      ),
                      const SizedBox(width: 12),
                      if (_startDate != null) ...[
                        Expanded(
                          child: _dateButton(
                            label: 'End date',
                            date: _endDate,
                            onSelect: (d) {
                              setState(() {
                                _endDate = d;
                                _endDateError = false;
                              });
                            },
                            firstDate: _startDate,
                            hasError: _endDateError,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),

              if (totalDays > 0) ...[
                const SizedBox(height: 18),
                Text(
                  'Pack your bag for $totalDays days',
                  style: TextStyle(
                    color: scheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ---------------- UI PARTS ----------------

  Widget _coverPicker(ColorScheme scheme) {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        height: 180,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: scheme.surfaceContainerHighest,
          image: _coverImage != null
              ? DecorationImage(
                  image: FileImage(_coverImage!),
                  fit: BoxFit.cover,
                )
              : null,
        ),
        child: Stack(
          children: [
            // ---------- Empty State ----------
            if (_coverImage == null)
              Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      LucideIcons.imagePlus,
                      size: 32,
                      color: scheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Add cover image (optional)',
                      style: TextStyle(color: scheme.outline),
                    ),
                  ],
                ),
              ),

            // ---------- Remove Button ----------
            if (_coverImage != null)
              Positioned(
                right: 12,
                top: 12,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () {
                    setState(() {
                      _coverImage = null;
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.35),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(LucideIcons.trash2, size: 16, color: Colors.white),
                        SizedBox(width: 6),
                        Text(
                          'Remove',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _section(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      ),
    );
  }

  Widget _input(
    TextEditingController ctrl,
    String label, {
    Function(String)? onChanged,
    String? Function(String?)? validator,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: ctrl,
        keyboardType: keyboardType,
        onChanged: onChanged,
        validator: validator,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }

  Widget _dateButton({
    required String label,
    DateTime? date,
    required Function(DateTime) onSelect,
    DateTime? firstDate,
    DateTime? lastDate,
    bool hasError = false,
  }) {
    final scheme = Theme.of(context).colorScheme;
    final borderColor = hasError ? scheme.error : scheme.outline;

    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        side: BorderSide(color: borderColor),
        foregroundColor: hasError ? scheme.error : null,
      ),
      icon: const Icon(LucideIcons.calendar),
      label: Text(
        date == null ? label : DateFormat('dd MMM yyyy').format(date),
      ),
      onPressed: () async {
        final picked = await showDatePicker(
          context: context,
          firstDate: firstDate ?? DateTime(2020),
          lastDate: lastDate ?? DateTime(2035),
          initialDate: date ?? firstDate ?? DateTime.now(),
        );
        if (picked != null) onSelect(picked);
      },
    );
  }

  // ---------------- LOGIC ----------------

  Future<void> _pickImage() async {
    final XFile? img = await _picker.pickImage(source: ImageSource.gallery);
    if (img != null) {
      setState(() => _coverImage = File(img.path));
    }
  }

  Future<void> _loadTour() async {
    final tour = await TourDb.getTourById(widget.tourId!);
    if (tour == null) return;

    // print(tour.toMap());

    setState(() {
      _nameCtrl.text = tour.name ?? '';
      _destinationCtrl.text = tour.destination;
      _startDate = tour.startDate;
      _endDate = tour.endDate;
      _budgetCtrl.text = tour.budget?.toString() ?? '';

      if (tour.coverImagePath != null) {
        _coverImage = File(tour.coverImagePath!);
      }
    });
  }

  Future<void> _saveTour() async {
    final isValidForm = _formKey.currentState?.validate() ?? false;

    if (_startDate == null) {
      setState(() {
        _startDateError = true;
      });
      return;
    }

    if (_endDate == null) {
      setState(() {
        _endDateError = true;
      });
      return;
    }

    if (_endDate!.isBefore(_startDate!)) {
      setState(() {
        _endDateError = true;
      });
      return;
    }

    if (!isValidForm) return;

    final tour = TourModel(
      id: widget.isEdit ? widget.tourId : null,
      name: _nameCtrl.text.trim(),
      destination: _destinationCtrl.text.trim(),
      startDate: _startDate!,
      endDate: _endDate!,
      budget: _budgetCtrl.text != ''
          ? double.tryParse(_budgetCtrl.text.trim())
          : null,
      totalDays: totalDays,
      coverImagePath: _coverImage != null
          ? await saveImageToAppDir(_coverImage!)
          : null,
    );

    await TourDb.upsertTour(tour);
    await Get.find<TourController>().refreshTours();
    Get.back();
  }
}
