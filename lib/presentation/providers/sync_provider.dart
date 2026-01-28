/// ==========================================================================
/// sync_provider.dart
/// ==========================================================================
/// Sinxronizatsiya holati uchun Riverpod provider.
/// ==========================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/services/sync_service.dart' as service;
import 'auth_provider.dart';

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
