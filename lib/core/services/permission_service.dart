/// ==========================================================================
/// permission_service.dart
/// ==========================================================================
/// Ilova ruxsatlarini boshqarish xizmati.
/// ==========================================================================
library;

import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/material.dart';

class PermissionService {
  PermissionService._();
  static final instance = PermissionService._();

  /// Geolokatsiya ruxsatini tekshirish va so'rash
  Future<bool> requestLocationPermission(BuildContext context) async {
    var status = await Permission.location.status;

    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (context.mounted) {
        _showPermissionDialog(
          context,
          'Joylashuv ruxsati',
          'Yaqindagi do\'konlarni ko\'rish uchun sozlamalardan joylashuv ruxsatini yoqing.',
        );
      }
      return false;
    }

    status = await Permission.location.request();
    return status.isGranted;
  }

  /// Kamera ruxsatini tekshirish va so'rash
  Future<bool> requestCameraPermission(BuildContext context) async {
    var status = await Permission.camera.status;
    if (status.isGranted) return true;

    status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Bildirishnoma ruxsatini tekshirish va so'rash
  Future<bool> requestNotificationPermission() async {
    var status = await Permission.notification.status;
    if (status.isGranted) return true;

    status = await Permission.notification.request();
    return status.isGranted;
  }

  /// Sozlamalarga yo'naltiruvchi dialog
  void _showPermissionDialog(
      BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Bekor qilish'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Sozlamalar'),
          ),
        ],
      ),
    );
  }
}
