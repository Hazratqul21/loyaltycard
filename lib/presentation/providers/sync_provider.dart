/// ==========================================================================
/// sync_provider.dart
/// ==========================================================================
/// Sinxronizatsiya holati uchun Riverpod provider.
/// ==========================================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/sync_service.dart' as service;

import 'connectivity_provider.dart';
import 'auth_provider.dart';

/// Sync service provider
final syncServiceProvider = Provider<service.SyncService>((ref) {
  final authService = ref.watch(authServiceProvider);
  final connectivityService = ref.watch(connectivityServiceProvider);

  return service.SyncService(
    authService: authService,
    connectivityService: connectivityService,
  );
});

/// Sync status provider
final syncStatusProvider = StateProvider<service.SyncStatus>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.status;
});

/// Last sync time provider
final lastSyncTimeProvider = Provider<DateTime?>((ref) {
  final syncService = ref.watch(syncServiceProvider);
  return syncService.lastSyncTime;
});
