import 'dart:convert';

import 'package:http/http.dart' as http;

class GeocodingService {
  /// Reverse-geocodes [lat]/[lng] via Nominatim.
  /// Returns the `display_name` string, or null on any error
  /// (network offline, timeout, bad status code, parse error, …).
  static Future<String?> reverse(double lat, double lng) async {
    try {
      final uri = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse'
        '?lat=$lat&lon=$lng&format=jsonv2',
      );

      final response = await http.get(
        uri,
        headers: {
          'User-Agent': 'LeegaApp/1.0 (maldinidanielroby@gmail.com)',
        },
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return data['display_name'] as String?;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
