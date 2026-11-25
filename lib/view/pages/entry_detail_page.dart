import 'package:flutter/material.dart';
import '../../models/log_entry.dart';

class EntryDetailPage extends StatelessWidget {
  final LogEntry entry;

  const EntryDetailPage({super.key, required this.entry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: const Center(child: Text('Entry Detail Page')),
    );
  }
}
