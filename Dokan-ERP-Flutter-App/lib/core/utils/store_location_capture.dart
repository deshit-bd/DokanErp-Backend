import 'package:geolocator/geolocator.dart';

class StoreLocationCaptureResult {
  const StoreLocationCaptureResult({
    required this.label,
    required this.latitude,
    required this.longitude,
  });

  final String label;
  final double latitude;
  final double longitude;
}

abstract final class StoreLocationCapture {
  static Future<StoreLocationCaptureResult> capture() async {
    final enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      throw const StoreLocationException('লোকেশন সার্ভিস চালু করুন।');
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      throw const StoreLocationException('লোকেশন permission প্রয়োজন।');
    }

    final position = await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
    final latitude = double.parse(position.latitude.toStringAsFixed(6));
    final longitude = double.parse(position.longitude.toStringAsFixed(6));

    return StoreLocationCaptureResult(
      label: 'Lat $latitude, Lng $longitude',
      latitude: latitude,
      longitude: longitude,
    );
  }
}

class StoreLocationException implements Exception {
  const StoreLocationException(this.message);

  final String message;
}
