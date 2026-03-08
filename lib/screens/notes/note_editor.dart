// note_editor_screen.dart
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:get/get.dart';
import 'package:lucide_icons/lucide_icons.dart';

class NoteEditorScreen extends StatefulWidget {
  const NoteEditorScreen({super.key});

  @override
  State<NoteEditorScreen> createState() => _NoteEditorScreenState();
}

class _NoteEditorScreenState extends State<NoteEditorScreen> {
  late final QuillController _controller;

  @override
  void initState() {
    super.initState();
    _controller = QuillController(
      document: Document(),
      selection: const TextSelection.collapsed(offset: 0),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _save() {
    final delta = _controller.document.toDelta();
    final jsonContent = jsonEncode(delta.toJson());

    // 🔴 DB save will happen here later
    debugPrint(jsonContent);

    Get.back();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('New note'),
        actions: [
          IconButton(icon: const Icon(LucideIcons.check), onPressed: _save),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ---------- Toolbar ----------
            QuillSimpleToolbar(
              controller: _controller,
              config: const QuillSimpleToolbarConfig(),
            ),

            const Divider(height: 1),

            // ---------- Editor ----------
            Expanded(
              child: Container(
                color: scheme.surface,
                padding: const EdgeInsets.all(16),
                child: QuillEditor.basic(controller: _controller),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
