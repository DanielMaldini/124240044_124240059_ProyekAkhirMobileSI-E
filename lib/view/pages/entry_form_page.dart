import 'package:flutter/material.dart';
import '../../models/log_entry.dart';

class EntryFormPage extends StatelessWidget {
  final LogEntry? entry;

  const EntryFormPage({super.key, this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(entry == null ? 'Catat BAB' : 'Edit Catatan')),
      body: const Center(child: Text('Entry Form Page')),
    );
  }
}
