import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/log_controller.dart';
import '../../utils/app_theme.dart';
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
            icon: const Icon(Icons.calendar_today_outlined, size: 20),
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
            icon: const Icon(Icons.clear, size: 20),
            tooltip: 'Hapus filter',
            onPressed: () => log.filterDate.value = null,
          ),
        ],
      ),
      body: Column(
        children: [
          Obx(() {
            final d = log.filterDate.value;
            final counts7d = log.last7DaysCounts;

            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _SummaryItem(
                                label: 'Hari Ini',
                                count: log.todayCount,
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: AppColors.border,
                              ),
                              _SummaryItem(
                                label: '7 Hari',
                                count: log.weekCount,
                              ),
                              Container(
                                width: 1,
                                height: 32,
                                color: AppColors.border,
                              ),
                              _SummaryItem(
                                label: '30 Hari',
                                count: log.monthCount,
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),
                          const Text(
                            'Aktivitas 7 Hari Terakhir',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.inkSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          _MiniWeekChart(counts: counts7d),
                        ],
                      ),
                    ),
                  ),
                  if (d != null) ...[
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.ink,
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            'Filter aktif: ${d.day}/${d.month}/${d.year}',
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
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
                return const Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.event_note_outlined,
                        size: 40,
                        color: AppColors.inkMuted,
                      ),
                      SizedBox(height: 10),
                      Text(
                        'Belum ada catatan',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.inkSecondary,
                        ),
                      ),
                    ],
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 84),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  final e = list[index];
                  final condOption = BowelConditions.fromLabel(e.condition);
                  final subtitleText = e.note.isNotEmpty
                      ? e.note
                      : (e.address ??
                          (e.lat != null ? 'Lokasi tersimpan' : 'Tanpa lokasi'));

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: Card(
                      child: InkWell(
                        borderRadius: BorderRadius.circular(14),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EntryDetailPage(entry: e),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(14),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          formatDateTime(e.dateTime),
                                          style: const TextStyle(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w700,
                                            color: AppColors.ink,
                                          ),
                                        ),
                                        if (condOption != null) ...[
                                          const SizedBox(width: 8),
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 8,
                                              vertical: 2,
                                            ),
                                            decoration: BoxDecoration(
                                              color: condOption.bgColor,
                                              borderRadius:
                                                  BorderRadius.circular(999),
                                            ),
                                            child: Text(
                                              condOption.label,
                                              style: TextStyle(
                                                fontSize: 11,
                                                fontWeight: FontWeight.w700,
                                                color: condOption.color,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ],
                                    ),
                                    const SizedBox(height: 5),
                                    Text(
                                      subtitleText,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 13,
                                        color: AppColors.inkSecondary,
                                      ),
                                    ),
                                    if (e.lat != null && e.note.isNotEmpty) ...[
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          const Icon(
                                            Icons.location_on_outlined,
                                            size: 13,
                                            color: AppColors.inkMuted,
                                          ),
                                          const SizedBox(width: 4),
                                          Expanded(
                                            child: Text(
                                              e.address ?? 'Lokasi tersimpan',
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                              style: const TextStyle(
                                                fontSize: 11,
                                                color: AppColors.inkMuted,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ],
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(
                                Icons.chevron_right,
                                size: 20,
                                color: AppColors.inkMuted,
                              ),
                            ],
                          ),
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
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: AppColors.ink,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.inkSecondary),
        ),
      ],
    );
  }
}

class _MiniWeekChart extends StatelessWidget {
  final List<int> counts;

  const _MiniWeekChart({required this.counts});

  static const _dayLabels = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  @override
  Widget build(BuildContext context) {
    // Cari nilai tertinggi dari 7 hari terakhir untuk skala tinggi bar
    int maxVal = 1;
    for (final c in counts) {
      if (c > maxVal) maxVal = c;
    }
    final today = DateTime.now();

    return SizedBox(
      height: 58,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (i) {
          final count = counts[i];
          final date = today.subtract(Duration(days: 6 - i));
          final dayName = _dayLabels[date.weekday - 1];
          final isToday = i == 6;
          final barHeight = count == 0 ? 4.0 : (count / maxVal) * 32.0 + 4.0;

          return Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 18,
                  height: barHeight,
                  decoration: BoxDecoration(
                    color: count == 0
                        ? AppColors.subtleBg
                        : (isToday ? AppColors.ink : const Color(0xFF4B5563)),
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  dayName,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                    color: isToday ? AppColors.ink : AppColors.inkMuted,
                  ),
                ),
              ],
            ),
          );
        }),
      ),
    );
  }
}
