/// ==========================================================================
/// sync_status.dart
/// ==========================================================================
/// Sinxronizatsiya holati enum va sync metadatasi.
/// ==========================================================================

/// Elementning sinxronizatsiya holati
enum SyncStatus {
  /// Sinxronlangan (server bilan bir xil)
  synced,
  
  /// Mahalliy o'zgarish bor, serverga yuklash kerak
  pendingUpload,
  
  /// Serverdan yangi ma'lumot bor, yuklab olish kerak  
  pendingDownload,
  
  /// Konflikt bor (lokal va serverda farq)
  conflict,
  
  /// Hali sinxronlanmagan (yangi yaratilgan)
  notSynced,
}

/// SyncStatus uchun extension
extension SyncStatusExtension on SyncStatus {
  /// String ga o'girish
  String get name {
    switch (this) {
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.pendingUpload:
        return 'pendingUpload';
      case SyncStatus.pendingDownload:
        return 'pendingDownload';
      case SyncStatus.conflict:
        return 'conflict';
      case SyncStatus.notSynced:
        return 'notSynced';
    }
  }

  /// String dan yaratish
  static SyncStatus fromString(String value) {
    switch (value) {
      case 'synced':
        return SyncStatus.synced;
      case 'pendingUpload':
        return SyncStatus.pendingUpload;
      case 'pendingDownload':
        return SyncStatus.pendingDownload;
      case 'conflict':
        return SyncStatus.conflict;
      case 'notSynced':
      default:
        return SyncStatus.notSynced;
    }
  }
}
