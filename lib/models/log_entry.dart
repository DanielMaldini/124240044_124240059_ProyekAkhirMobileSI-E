import 'package:hive/hive.dart';

part 'log_entry.g.dart';

@HiveType(typeId: 1)
class LogEntry extends HiveObject {
  @HiveField(0)
  String username;

  @HiveField(1)
  DateTime dateTime;

  @HiveField(2)
  String note;

  @HiveField(3)
  double? lat;

  @HiveField(4)
  double? lng;

  @HiveField(5)
  String? address;

  /// Kondisi BAB berdasarkan rasa/konsistensi:
  /// 'Normal', 'Keras / Susah', 'Lembek', atau 'Cair / Diare'.
  @HiveField(6)
  String? condition;

  /// Gejala penyerta opsional (mis. 'Kembung', 'Mulas', 'Tidak Tuntas').
  @HiveField(7)
  List<String>? symptoms;

  LogEntry({
    required this.username,
    required this.dateTime,
    required this.note,
    this.lat,
    this.lng,
    this.address,
    this.condition,
    this.symptoms,
  });
}
