import 'package:flutter/material.dart';
import 'package:tourio/models/tour_model.dart';
import 'package:tourio/screens/notes/note_editor.dart';

class NotesListScreen extends StatelessWidget {
  final TourModel tour;
  const NotesListScreen({super.key, required this.tour});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: Center(
        child: Text(
          'No notes yet',
          style: TextStyle(color: scheme.outline, fontSize: 16),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: scheme.primary,
        foregroundColor: scheme.onPrimary,
        child: const Icon(Icons.add),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const NoteEditorScreen()),
          );
        },
      ),
    );
  }
}
