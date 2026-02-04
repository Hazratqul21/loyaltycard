/// ==========================================================================
/// location_service.dart
/// ==========================================================================
/// Geolokatsiya xizmati.
/// Joylashuv, ruxsat, masofa hisoblash, geofencing.
/// ==========================================================================

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

/// Joylashuv holati
enum LocationStatus {
  /// Ruxsat berilmagan
  denied,

  /// Doim rad etilgan
  deniedForever,

  /// Ruxsat berilgan
  granted,

  /// Xizmat o'chirilgan
  serviceDisabled,

  /// Noma'lum
  unknown,
}

/// Manzil ma'lumoti
class AddressInfo {
  final String? street;
  final String? city;
  final String? country;
  final String? postalCode;
  final String? fullAddress;

  const AddressInfo({
    this.street,
    this.city,
    this.country,
    this.postalCode,
    this.fullAddress,
  });
}

/// Geofence zone
class GeofenceZone {
  final String id;
  final String name;
  final double latitude;
  final double longitude;
  final double radiusMeters;

  const GeofenceZone({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    this.radiusMeters = 100,
  });
}

/// Geofence event
enum GeofenceEvent {
  enter,
  exit,
}

/// Location Service
class LocationService {
  static LocationService? _instance;
  static LocationService get instance => _instance ??= LocationService._();

  LocationService._();

  Position? _currentPosition;
  LocationStatus _status = LocationStatus.unknown;
  StreamSubscription<Position>? _positionSubscription;

  final List<GeofenceZone> _geofences = [];
  final Set<String> _insideZones = {};

  final StreamController<Position> _positionController =
      StreamController<Position>.broadcast();
  final StreamController<(GeofenceZone, GeofenceEvent)> _geofenceController =
      StreamController<(GeofenceZone, GeofenceEvent)>.broadcast();

  /// Joriy joylashuv
  Position? get currentPosition => _currentPosition;

  /// Joylashuv holati
  LocationStatus get status => _status;

  /// Joylashuv stream
  Stream<Position> get positionStream => _positionController.stream;

  /// Geofence event stream
  Stream<(GeofenceZone, GeofenceEvent)> get geofenceStream =>
      _geofenceController.stream;

  /// Xizmatni boshlash
  Future<LocationStatus> initialize() async {
    try {
      _status = await checkPermission();

      if (_status == LocationStatus.granted) {
        await _startLocationUpdates();
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ LocationService initialization failed: $e');
      }
      _status = LocationStatus.denied;
    }

    if (kDebugMode) {
      print('📍 LocationService initialized: $_status');
    }

    return _status;
  }

  /// Ruxsatni tekshirish
  Future<LocationStatus> checkPermission() async {
    // Location xizmati yoqilganmi?
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return LocationStatus.serviceDisabled;
    }

    // Ruxsat holati
    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return LocationStatus.denied;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return LocationStatus.deniedForever;
    }

    return LocationStatus.granted;
  }

  /// Ruxsat so'rash
  Future<LocationStatus> requestPermission() async {
    final permission = await Geolocator.requestPermission();

    switch (permission) {
      case LocationPermission.denied:
        _status = LocationStatus.denied;
        break;
      case LocationPermission.deniedForever:
        _status = LocationStatus.deniedForever;
        break;
      case LocationPermission.whileInUse:
      case LocationPermission.always:
        _status = LocationStatus.granted;
        await _startLocationUpdates();
        break;
      case LocationPermission.unableToDetermine:
        _status = LocationStatus.unknown;
        break;
    }

    return _status;
  }

  /// Joylashuv yangilanishlarini boshlash
  Future<void> _startLocationUpdates() async {
    try {
      // Bir martalik joriy joylashuvni olish
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      _positionController.add(_currentPosition!);

      // Doimiy yangilanishlar
      const locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // 10 metr o'zgarganda yangilash
      );

      _positionSubscription = Geolocator.getPositionStream(
        locationSettings: locationSettings,
      ).listen((position) {
        _currentPosition = position;
        _positionController.add(position);
        _checkGeofences(position);
      });

      if (kDebugMode) {
        print(
            '📍 Location: ${_currentPosition?.latitude}, ${_currentPosition?.longitude}');
      }
    } catch (e) {
      if (kDebugMode) print('❌ Location error: $e');
    }
  }

  /// Joriy joylashuvni olish
  Future<Position?> getCurrentPosition() async {
    if (_status != LocationStatus.granted) {
      final newStatus = await requestPermission();
      if (newStatus != LocationStatus.granted) return null;
    }

    try {
      _currentPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return _currentPosition;
    } catch (e) {
      if (kDebugMode) print('❌ Get position error: $e');
      return null;
    }
  }

  /// Koordinatalardan manzil olish
  Future<AddressInfo?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await placemarkFromCoordinates(latitude, longitude);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return AddressInfo(
          street: place.street,
          city: place.locality,
          country: place.country,
          postalCode: place.postalCode,
          fullAddress: [
            place.street,
            place.locality,
            place.country,
          ].where((s) => s != null && s.isNotEmpty).join(', '),
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Geocoding error: $e');
    }
    return null;
  }

  /// Manzildan koordinata olish
  Future<Position?> getCoordinatesFromAddress(String address) async {
    try {
      final locations = await locationFromAddress(address);

      if (locations.isNotEmpty) {
        final loc = locations.first;
        return Position(
          latitude: loc.latitude,
          longitude: loc.longitude,
          timestamp: DateTime.now(),
          accuracy: 0,
          altitude: 0,
          heading: 0,
          speed: 0,
          speedAccuracy: 0,
          altitudeAccuracy: 0,
          headingAccuracy: 0,
        );
      }
    } catch (e) {
      if (kDebugMode) print('❌ Geocoding error: $e');
    }
    return null;
  }

  // ==================== Distance Calculations ====================

  /// Ikki nuqta orasidagi masofani hisoblash (metrda)
  double calculateDistance(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    return Geolocator.distanceBetween(lat1, lon1, lat2, lon2);
  }

  /// Joriy joylashuvdan masofani hisoblash (metrda)
  double? distanceFromCurrent(double latitude, double longitude) {
    if (_currentPosition == null) return null;

    return calculateDistance(
      _currentPosition!.latitude,
      _currentPosition!.longitude,
      latitude,
      longitude,
    );
  }

  /// Masofani formatlash (inson o'qiy oladigan)
  String formatDistance(double meters) {
    if (meters < 1000) {
      return '${meters.round()} m';
    } else {
      return '${(meters / 1000).toStringAsFixed(1)} km';
    }
  }

  // ==================== Geofencing ====================

  /// Geofence qo'shish
  void addGeofence(GeofenceZone zone) {
    _geofences.add(zone);

    // Joriy joylashuv bilan tekshirish
    if (_currentPosition != null) {
      _checkSingleGeofence(zone, _currentPosition!);
    }
  }

  /// Geofence o'chirish
  void removeGeofence(String zoneId) {
    _geofences.removeWhere((z) => z.id == zoneId);
    _insideZones.remove(zoneId);
  }

  /// Barcha geofence'larni tekshirish
  void _checkGeofences(Position position) {
    for (final zone in _geofences) {
      _checkSingleGeofence(zone, position);
    }
  }

  /// Bitta geofence tekshirish
  void _checkSingleGeofence(GeofenceZone zone, Position position) {
    final distance = calculateDistance(
      position.latitude,
      position.longitude,
      zone.latitude,
      zone.longitude,
    );

    final isInside = distance <= zone.radiusMeters;
    final wasInside = _insideZones.contains(zone.id);

    if (isInside && !wasInside) {
      // Zone'ga kirdi
      _insideZones.add(zone.id);
      _geofenceController.add((zone, GeofenceEvent.enter));

      if (kDebugMode) print('📍 Entered geofence: ${zone.name}');
    } else if (!isInside && wasInside) {
      // Zone'dan chiqdi
      _insideZones.remove(zone.id);
      _geofenceController.add((zone, GeofenceEvent.exit));

      if (kDebugMode) print('📍 Exited geofence: ${zone.name}');
    }
  }

  // ==================== Settings ====================

  /// Sozlamalarni ochish
  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  /// App sozlamalarini ochish
  Future<void> openAppSettings() async {
    await Geolocator.openAppSettings();
  }

  /// Xizmatni to'xtatish
  void dispose() {
    _positionSubscription?.cancel();
    _positionController.close();
    _geofenceController.close();
  }
}
