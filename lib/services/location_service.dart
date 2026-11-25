import 'package:geolocator/geolocator.dart';

class LocationService {
  /// Returns the device's current [Position], or null if:
  /// - location services are disabled,
  /// - permission is denied / permanently denied, or
  /// - any other error occurs.
  static Future<Position?> getPosition() async {
    try {
      // 1. Check if location services are enabled on the device.
      final bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) return null;

      // 2. Check / request permission.
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return null;
      }
      if (permission == LocationPermission.deniedForever) return null;

      // 3. All good — fetch the position.
      return await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
    } catch (_) {
      return null;
    }
  }
}
