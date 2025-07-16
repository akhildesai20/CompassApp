import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class LocationService {
  /// Returns (lat, lon, placeName) or throws.
  static Future<(
  double latitude,
  double longitude,
  String? place,
  )> getCurrent() async {
    // handle runtime permission
    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) {
        throw 'Location permission denied';
      }
    }
    if (perm == LocationPermission.deniedForever) {
      throw 'Location permission permanently denied';
    }

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.medium,
    );

    String? place;
    try {
      final placemarks =
      await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        place = '${p.locality ?? p.subAdministrativeArea}, ${p.country}';
      }
    } catch (_) {
      // ignore reverse-geo errors
    }

    return (pos.latitude, pos.longitude, place);
  }
}
