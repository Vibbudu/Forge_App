import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../config/constants.dart';

/// Service for getting device GPS coordinates.
class LocationService {
  static final LocationService _instance = LocationService._();
  factory LocationService() => _instance;
  LocationService._();

  Future<({double lat, double lng})> getCurrentLocation() async {
    final permission = await Permission.location.request();
    if (permission.isGranted) {
      try {
        final position = await Geolocator.getCurrentPosition(
            locationSettings: const LocationSettings(accuracy: LocationAccuracy.medium));
        return (lat: position.latitude, lng: position.longitude);
      } catch (e) {
        return (lat: kDefaultLat, lng: kDefaultLng);
      }
    }
    return (lat: kDefaultLat, lng: kDefaultLng);
  }
}
