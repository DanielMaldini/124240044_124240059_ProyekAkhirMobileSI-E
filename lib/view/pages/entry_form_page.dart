import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:geolocator/geolocator.dart';

import '../../controller/auth_controller.dart';
import '../../controller/log_controller.dart';
import '../../models/log_entry.dart';
import '../../services/geocoding_service.dart';
import '../../services/location_service.dart';
import '../../services/notification_service.dart';
import '../../utils/app_theme.dart';
import '../../utils/format.dart';

/// Halaman untuk TAMBAH catatan baru atau EDIT catatan yang sudah ada.
class EntryFormPage extends StatefulWidget {
  final LogEntry? entry;

  const EntryFormPage({super.key, this.entry});

  @override
  State<EntryFormPage> createState() => _EntryFormPageState();
}

class _EntryFormPageState extends State<EntryFormPage> {
  late final bool _isEditMode;
  late DateTime _selectedDateTime;
  late final TextEditingController _noteController;

  // Pilihan kondisi BAB berdasarkan rasa/konsistensi
  late String _selectedCondition;

  // Gejala penyerta opsional (multi-pilih)
  late final Set<String> _selectedSymptoms;

  bool _recordLocation = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.entry != null;

    _selectedDateTime = _isEditMode ? widget.entry!.dateTime : DateTime.now();
    _noteController = TextEditingController(
      text: _isEditMode ? widget.entry!.note : '',
    );
    _selectedCondition = _isEditMode
        ? (widget.entry!.condition ?? BowelConditions.normal)
        : BowelConditions.normal;
    _selectedSymptoms = _isEditMode
        ? Set<String>.from(widget.entry!.symptoms ?? const [])
        : <String>{};
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime() async {
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (pickedDate == null) return;

    if (!mounted) return;
    final pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
    );
    if (pickedTime == null) return;
    if (!mounted) return;

    setState(() {
      _selectedDateTime = DateTime(
        pickedDate.year,
        pickedDate.month,
        pickedDate.day,
        pickedTime.hour,
        pickedTime.minute,
      );
    });
  }

  Future<void> _save() async {
    setState(() => _isSaving = true);

    final username = Get.find<AuthController>().currentUser.value?.username;
    if (username == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sesi login tidak ditemukan'),
          backgroundColor: AppColors.red,
        ),
      );
      setState(() => _isSaving = false);
      return;
    }

    final logController = Get.find<LogController>();
    final symptomsList = _selectedSymptoms.toList();

    try {
      if (_isEditMode) {
        widget.entry!.dateTime = _selectedDateTime;
        widget.entry!.note = _noteController.text.trim();
        widget.entry!.condition = _selectedCondition;
        widget.entry!.symptoms = symptomsList.isEmpty ? null : symptomsList;
        await logController.updateEntry(widget.entry!);
      } else {
        double? lat;
        double? lng;
        String? address;

        if (_recordLocation) {
          final Position? position = await LocationService.getPosition();

          if (position == null) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'Lokasi tidak tersedia, catatan disimpan tanpa lokasi',
                  ),
                ),
              );
            }
          } else {
            lat = position.latitude;
            lng = position.longitude;
            address = await GeocodingService.reverse(lat, lng);
          }
        }

        final newEntry = LogEntry(
          username: username,
          dateTime: _selectedDateTime,
          note: _noteController.text.trim(),
          lat: lat,
          lng: lng,
          address: address,
          condition: _selectedCondition,
          symptoms: symptomsList.isEmpty ? null : symptomsList,
        );
        await logController.addEntry(newEntry);
      }

      // Cek pola frekuensi BAB setelah menyimpan catatan
      try {
        final allDates = logController.entries.map((e) => e.dateTime).toList();
        await NotificationService().checkDigestivePattern(allDates);
      } catch (_) {
        // Jangan gagalkan simpan bila plugin notifikasi tidak aktif
      }

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
            backgroundColor: AppColors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Catatan' : 'Tambah Catatan'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Pemilihan Kondisi BAB (Wrap + ChoiceChip agar ringkas & mudah diubah) ──
            const Text(
              'Kondisi BAB',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Pilih kondisi yang paling sesuai dengan yang dirasakan',
              style: TextStyle(fontSize: 12, color: AppColors.inkSecondary),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BowelConditions.all.map((option) {
                final isSelected = _selectedCondition == option.label;
                return ChoiceChip(
                  avatar: Icon(
                    option.icon,
                    size: 16,
                    color: isSelected ? option.color : AppColors.inkSecondary,
                  ),
                  label: Text(option.label),
                  selected: isSelected,
                  onSelected: (_) {
                    setState(() => _selectedCondition = option.label);
                  },
                  showCheckmark: false,
                  selectedColor: option.bgColor,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: isSelected ? option.color : AppColors.ink,
                  ),
                  side: BorderSide(
                    color: isSelected ? option.color : AppColors.border,
                    width: isSelected ? 1.5 : 1,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // ── Gejala Penyerta (Opsional, multi-pilih via FilterChip) ──
            const Text(
              'Gejala Penyerta (Opsional)',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: BowelConditions.symptomOptions.map((symptom) {
                final selected = _selectedSymptoms.contains(symptom);
                return FilterChip(
                  label: Text(symptom),
                  selected: selected,
                  onSelected: (isChecked) {
                    setState(() {
                      if (isChecked) {
                        _selectedSymptoms.add(symptom);
                      } else {
                        _selectedSymptoms.remove(symptom);
                      }
                    });
                  },
                  showCheckmark: false,
                  selectedColor: AppColors.ink,
                  backgroundColor: AppColors.surface,
                  labelStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: selected ? Colors.white : AppColors.ink,
                  ),
                  side: BorderSide(
                    color: selected ? AppColors.ink : AppColors.border,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                );
              }).toList(),
            ),

            const SizedBox(height: 18),

            // ── Pemilih Tanggal & Waktu ──
            const Text(
              'Waktu',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(
                  Icons.calendar_today_outlined,
                  size: 20,
                  color: AppColors.ink,
                ),
                title: const Text(
                  'Tanggal & Waktu',
                  style: TextStyle(fontSize: 13, color: AppColors.inkSecondary),
                ),
                subtitle: Text(
                  formatDateTime(_selectedDateTime),
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                trailing: const Icon(
                  Icons.chevron_right,
                  color: AppColors.inkSecondary,
                ),
                onTap: _pickDateTime,
              ),
            ),

            const SizedBox(height: 18),

            // ── TextField Catatan ──
            const Text(
              'Catatan Tambahan',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppColors.ink,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _noteController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'Catatan (opsional)',
                alignLabelWithHint: true,
              ),
            ),

            const SizedBox(height: 14),

            // ── Switch lokasi (hanya muncul saat mode tambah) ──
            if (!_isEditMode) ...[
              Card(
                child: SwitchListTile(
                  title: const Text(
                    'Catat lokasi saat ini',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.ink,
                    ),
                  ),
                  subtitle: const Text(
                    'Matikan untuk mencatat tanpa lokasi GPS',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.inkSecondary,
                    ),
                  ),
                  value: _recordLocation,
                  onChanged: (val) => setState(() => _recordLocation = val),
                ),
              ),
              const SizedBox(height: 14),
            ],

            // ── Disclaimer Medis ──
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.subtleBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: AppColors.inkSecondary,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Leega bukan alat diagnosis medis.',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.inkSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 22),

            // ── Tombol Simpan ──
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
