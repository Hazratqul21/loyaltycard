/// ==========================================================================
/// scanner_service.dart
/// ==========================================================================
/// Barcode va NFC skanerlash xizmati.
/// ==========================================================================
library;

import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:nfc_manager/nfc_manager.dart';

/// Skan turi
enum ScanType {
  /// QR kod
  qrCode,

  /// Barcode (EAN, Code128, etc.)
  barcode,

  /// NFC tag
  nfc,
}

/// Skan natijasi
class ScanResult {
  final String rawValue;
  final ScanType type;
  final String? format;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ScanResult({
    required this.rawValue,
    required this.type,
    this.format,
    Map<String, dynamic>? metadata,
  })  : timestamp = DateTime.now(),
        metadata = metadata;

  /// Karta ID sifatida parse qilish
  String? get cardId {
    // Custom format: loyalty://card/{id}
    if (rawValue.startsWith('loyalty://card/')) {
      return rawValue.replaceFirst('loyalty://card/', '');
    }
    // Oddiy raqamli ID
    if (RegExp(r'^\d+$').hasMatch(rawValue)) {
      return rawValue;
    }
    return null;
  }

  /// Tranzaksiya sifatida parse qilish
  Map<String, dynamic>? get transactionData {
    // Custom format: loyalty://tx/{cardId}/{points}/{type}
    if (rawValue.startsWith('loyalty://tx/')) {
      final parts = rawValue.replaceFirst('loyalty://tx/', '').split('/');
      if (parts.length >= 3) {
        return {
          'cardId': parts[0],
          'points': int.tryParse(parts[1]) ?? 0,
          'type': parts[2],
        };
      }
    }
    return null;
  }

  @override
  String toString() => 'ScanResult($type: $rawValue)';
}

/// Scanner Service
class ScannerService {
  static ScannerService? _instance;
  static ScannerService get instance => _instance ??= ScannerService._();

  ScannerService._();

  MobileScannerController? _cameraController;
  bool _isNfcAvailable = false;
  bool _isScanning = false;

  final StreamController<ScanResult> _scanController =
      StreamController<ScanResult>.broadcast();
  final StreamController<bool> _scanningStateController =
      StreamController<bool>.broadcast();

  /// NFC mavjudmi?
  bool get isNfcAvailable => _isNfcAvailable;

  /// Skanerlash jarayonida
  bool get isScanning => _isScanning;

  /// Skan natijalari stream
  Stream<ScanResult> get scanResults => _scanController.stream;

  /// Scanning state stream
  Stream<bool> get scanningState => _scanningStateController.stream;

  /// Camera controller
  MobileScannerController? get cameraController => _cameraController;

  /// Xizmatni boshlash
  Future<void> initialize() async {
    // NFC mavjudligini tekshirish
    if (Platform.isAndroid || Platform.isIOS) {
      try {
        _isNfcAvailable = await NfcManager.instance.isAvailable();
      } catch (e) {
        _isNfcAvailable = false;
      }
    }

    if (kDebugMode) {
      print('📷 ScannerService initialized');
      print('   NFC available: $_isNfcAvailable');
    }
  }

  // ==================== Camera Scanning ====================

  /// Kamera controller yaratish
  MobileScannerController createCameraController() {
    _cameraController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
    return _cameraController!;
  }

  /// Barcode/QR skanerlashni boshlash
  void startCameraScanning() {
    _isScanning = true;
    _scanningStateController.add(true);
    _cameraController?.start();
  }

  /// Skanerlashni to'xtatish
  void stopCameraScanning() {
    _isScanning = false;
    _scanningStateController.add(false);
    _cameraController?.stop();
  }

  /// Barcode aniqlanganda
  void onBarcodeDetected(BarcodeCapture capture) {
    for (final barcode in capture.barcodes) {
      if (barcode.rawValue != null) {
        final result = ScanResult(
          rawValue: barcode.rawValue!,
          type: _getBarcodeType(barcode.format),
          format: barcode.format.name,
        );

        _scanController.add(result);

        if (kDebugMode) {
          print('📷 Barcode detected: ${result.rawValue}');
        }
      }
    }
  }

  /// Barcode format'dan scan type olish
  ScanType _getBarcodeType(BarcodeFormat format) {
    if (format == BarcodeFormat.qrCode) {
      return ScanType.qrCode;
    }
    return ScanType.barcode;
  }

  /// Torch yoqish/o'chirish
  Future<void> toggleTorch() async {
    await _cameraController?.toggleTorch();
  }

  /// Kamerani almashtirish
  Future<void> switchCamera() async {
    await _cameraController?.switchCamera();
  }

  // ==================== NFC Scanning ====================

  /// NFC skanerlashni boshlash
  Future<void> startNfcScanning() async {
    if (!_isNfcAvailable) {
      if (kDebugMode) print('❌ NFC not available');
      return;
    }

    _isScanning = true;
    _scanningStateController.add(true);

    try {
      await NfcManager.instance.startSession(
        pollingOptions: {
          NfcPollingOption.iso14443,
          NfcPollingOption.iso15693,
        },
        onDiscovered: (NfcTag tag) async {
          final result = _parseNfcTag(tag);
          if (result != null) {
            _scanController.add(result);
          }

          // Session'ni tugatmaslik (doimiy o'qish)
        },
      );

      if (kDebugMode) print('📱 NFC scanning started');
    } catch (e) {
      if (kDebugMode) print('❌ NFC start error: $e');
      _scanController.addError(e);
    }
  }

  /// NFC skanerlashni to'xtatish
  Future<void> stopNfcScanning() async {
    if (!_isNfcAvailable) return;

    try {
      await NfcManager.instance.stopSession();
      if (kDebugMode) print('📱 NFC scanning stopped');
    } catch (e) {
      if (kDebugMode) print('❌ NFC stop error: $e');
    }
  }

  /// NFC tag'ni parse qilish
  ScanResult? _parseNfcTag(NfcTag tag) {
    // Raw tag data (using toString as data is protected)
    final tagData = tag.toString();

    return ScanResult(
      rawValue: tagData,
      type: ScanType.nfc,
      format: 'Raw',
      metadata: {'description': 'NFC Tag Detected'},
    );
  }

  // ==================== Utility ====================

  /// Custom loyalty QR yaratish
  static String createLoyaltyCardQR(String cardId) {
    return 'loyalty://card/$cardId';
  }

  /// Custom transaction QR yaratish
  static String createTransactionQR(String cardId, int points, String type) {
    return 'loyalty://tx/$cardId/$points/$type';
  }

  /// Xizmatni to'xtatish
  void dispose() {
    stopCameraScanning();
    stopNfcScanning();
    _cameraController?.dispose();
    _scanController.close();
    _scanningStateController.close();
  }
}
