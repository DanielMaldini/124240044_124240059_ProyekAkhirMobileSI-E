import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controller/log_controller.dart';
import '../../utils/format.dart';
import 'entry_detail_page.dart';
import 'entry_form_page.dart';

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final log = Get.find<LogController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat'),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            tooltip: 'Filter tanggal',
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: log.filterDate.value ?? DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              if (picked != null) {
                log.filterDate.value = picked;
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.clear),
            tooltip: 'Hapus filter',
            onPressed: () => log.filterDate.value = null,
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            final d = log.filterDate.value;
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                        horizontal: 12,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _SummaryItem(
                            label: 'Hari Ini',
                            count: log.todayCount,
                          ),
                          _SummaryItem(
                            label: '7 Hari',
                            count: log.weekCount,
                          ),
                          _SummaryItem(
                            label: '30 Hari',
                            count: log.monthCount,
                          ),
                        ],
                      ),
                    ),
                  ),
                  if (d != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Filter aktif: ${d.day}/${d.month}/${d.year}',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey[700],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            );
          }),
          Expanded(
            child: Obx(() {
              final list = log.visibleEntries;
              if (list.isEmpty) {
                return const Center(child: Text('Belum ada catatan'));
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 80),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final e = list[index];
                  final subtitleText = e.address ??
                      (e.lat != null
                          ? 'Lokasi tersimpan'
                          : (e.note.isNotEmpty ? e.note : 'Tanpa lokasi'));

                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: const Color(0xFF718B73),
                        foregroundColor: Colors.white,
                        child: Icon(
                          e.lat != null
                              ? Icons.location_on
                              : Icons.event_note,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        formatDateTime(e.dateTime),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        subtitleText,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EntryDetailPage(entry: e),
                        ),
                      ),
                    ),
                  );
                },
              );
            }),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const EntryFormPage()),
        ),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final String label;
  final int count;

  const _SummaryItem({required this.label, required this.count});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          '$count',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Color(0xFF718B73),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
        ),
      ],
    );
  }
}
