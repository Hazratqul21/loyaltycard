/// ==========================================================================
/// connectivity_service.dart
/// ==========================================================================
/// Internet aloqasini kuzatish xizmati.
/// ==========================================================================
library;

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Aloqa holatini saqlash uchun enum
enum ConnectivityStatus {
  /// Aloqa bor
  connected,

  /// Aloqa yo'q
  disconnected,

  /// Tekshirilmoqda
  checking,
}

/// Internet aloqasini kuzatish xizmati
class ConnectivityService {
  final Connectivity _connectivity;

  /// Aloqa holatini stream sifatida olish uchun controller
  final StreamController<ConnectivityStatus> _statusController =
      StreamController<ConnectivityStatus>.broadcast();

  /// Joriy aloqa holati
  ConnectivityStatus _currentStatus = ConnectivityStatus.checking;

  /// Stream subscription
  StreamSubscription<ConnectivityResult>? _subscription;

  ConnectivityService({Connectivity? connectivity})
      : _connectivity = connectivity ?? Connectivity();

  /// Joriy aloqa holati
  ConnectivityStatus get currentStatus => _currentStatus;

  /// Internet bilan aloqa bormi?
  bool get isConnected => _currentStatus == ConnectivityStatus.connected;

  /// Aloqa holatini tinglash
  Stream<ConnectivityStatus> get statusStream => _statusController.stream;

  /// Xizmatni boshlash
  Future<void> initialize() async {
    // Joriy holatni tekshirish
    await _checkConnectivity();

    // O'zgarishlarni tinglash
    _subscription =
        _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
  }

  /// Xizmatni to'xtatish
  void dispose() {
    _subscription?.cancel();
    _statusController.close();
  }

  /// Joriy aloqa holatini tekshirish
  Future<bool> checkConnectivity() async {
    await _checkConnectivity();
    return isConnected;
  }

  /// Aloqa holatini tekshirish (ichki)
  Future<void> _checkConnectivity() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _updateStatus(_resultToStatus(result));
    } catch (e) {
      if (kDebugMode) {
        print('❌ Aloqa tekshirish xatosi: $e');
      }
      _updateStatus(ConnectivityStatus.disconnected);
    }
  }

  /// Aloqa o'zgarganda chaqiriladi
  void _onConnectivityChanged(ConnectivityResult result) {
    _updateStatus(_resultToStatus(result));
  }

  /// ConnectivityResult ni ConnectivityStatus ga o'girish
  ConnectivityStatus _resultToStatus(ConnectivityResult result) {
    if (result == ConnectivityResult.none) {
      return ConnectivityStatus.disconnected;
    }
    return ConnectivityStatus.connected;
  }

  /// Holatni yangilash
  void _updateStatus(ConnectivityStatus status) {
    if (_currentStatus != status) {
      _currentStatus = status;
      _statusController.add(status);

      if (kDebugMode) {
        final emoji = status == ConnectivityStatus.connected ? '🌐' : '📵';
        print('$emoji Aloqa holati: $status');
      }
    }
  }
}
