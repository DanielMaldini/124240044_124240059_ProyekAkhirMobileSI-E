import 'package:flutter/material.dart';

class EntryDetailPage extends StatelessWidget {
  const EntryDetailPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: const Center(child: Text('Entry Detail Page')),
    );
  }
}
