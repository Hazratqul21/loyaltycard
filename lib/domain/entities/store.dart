/// ==========================================================================
/// store.dart
/// ==========================================================================
/// Do'kon entity - joylashuv va ma'lumotlar.
/// ==========================================================================
library;

import 'sync_status.dart' as domain_sync;

/// Ish vaqti
class WorkingHours {
  final String dayOfWeek;
  final String openTime;
  final String closeTime;
  final bool isClosed;

  const WorkingHours({
    required this.dayOfWeek,
    required this.openTime,
    required this.closeTime,
    this.isClosed = false,
  });

  bool get isOpen {
    if (isClosed) return false;

    final now = DateTime.now();
    final open = _parseTime(openTime);
    final close = _parseTime(closeTime);
    final current = TimeOfDay(hour: now.hour, minute: now.minute);

    return _isTimeInRange(current, open, close);
  }

  TimeOfDay _parseTime(String time) {
    final parts = time.split(':');
    return TimeOfDay(
      hour: int.parse(parts[0]),
      minute: int.parse(parts.length > 1 ? parts[1] : '0'),
    );
  }

  bool _isTimeInRange(TimeOfDay current, TimeOfDay open, TimeOfDay close) {
    final currentMinutes = current.hour * 60 + current.minute;
    final openMinutes = open.hour * 60 + open.minute;
    final closeMinutes = close.hour * 60 + close.minute;

    return currentMinutes >= openMinutes && currentMinutes <= closeMinutes;
  }

  Map<String, dynamic> toJson() => {
        'dayOfWeek': dayOfWeek,
        'openTime': openTime,
        'closeTime': closeTime,
        'isClosed': isClosed,
      };

  factory WorkingHours.fromJson(Map<String, dynamic> json) {
    return WorkingHours(
      dayOfWeek: json['dayOfWeek'],
      openTime: json['openTime'],
      closeTime: json['closeTime'],
      isClosed: json['isClosed'] ?? false,
    );
  }
}

/// TimeOfDay extension
class TimeOfDay {
  final int hour;
  final int minute;

  const TimeOfDay({required this.hour, required this.minute});
}

/// Do'kon entity
class Store {
  final String id;
  final String? userId;
  final String name;
  final String? description;
  final String? logoUrl;
  final String? imageUrl;

  // Joylashuv
  final double latitude;
  final double longitude;
  final String? address;
  final String? city;
  final String? country;

  // Bog'lanish
  final String? phone;
  final String? email;
  final String? website;

  // Kategoriya
  final String category;
  final List<String> tags;

  // Ish vaqti
  final List<WorkingHours> workingHours;

  // Loyalty card bog'lanish
  final String? linkedCardId;

  // Sync
  final DateTime lastModifiedAt;
  final domain_sync.SyncStatus syncStatus;

  final bool isActive;

  Store({
    required this.id,
    this.userId,
    required this.name,
    this.description,
    this.logoUrl,
    this.imageUrl,
    required this.latitude,
    required this.longitude,
    this.address,
    this.city,
    this.country,
    this.phone,
    this.email,
    this.website,
    this.category = 'General',
    this.tags = const [],
    this.workingHours = const [],
    this.linkedCardId,
    DateTime? lastModifiedAt,
    this.syncStatus = domain_sync.SyncStatus.notSynced,
    this.isActive = true,
  }) : lastModifiedAt = lastModifiedAt ?? DateTime.now();

  /// Bugun ochiqmi?
  bool get isOpenNow {
    if (workingHours.isEmpty) {
      return true; // Ma'lumot yo'q = ochiq deb hisoblaymiz
    }

    final today = DateTime.now().weekday;
    final dayNames = [
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
      'Sunday'
    ];
    final todayName = dayNames[today - 1];

    final todayHours = workingHours.firstWhere(
      (h) => h.dayOfWeek == todayName,
      orElse: () => const WorkingHours(
          dayOfWeek: '', openTime: '00:00', closeTime: '23:59'),
    );

    return todayHours.isOpen;
  }

  /// To'liq manzil
  String get fullAddress {
    final parts = <String>[];
    if (address != null) parts.add(address!);
    if (city != null) parts.add(city!);
    if (country != null) parts.add(country!);
    return parts.join(', ');
  }

  Store copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? logoUrl,
    String? imageUrl,
    double? latitude,
    double? longitude,
    String? address,
    String? city,
    String? country,
    String? phone,
    String? email,
    String? website,
    String? category,
    List<String>? tags,
    List<WorkingHours>? workingHours,
    String? linkedCardId,
    DateTime? lastModifiedAt,
    domain_sync.SyncStatus? syncStatus,
    bool? isActive,
  }) {
    return Store(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      logoUrl: logoUrl ?? this.logoUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      website: website ?? this.website,
      category: category ?? this.category,
      tags: tags ?? this.tags,
      workingHours: workingHours ?? this.workingHours,
      linkedCardId: linkedCardId ?? this.linkedCardId,
      lastModifiedAt: lastModifiedAt ?? this.lastModifiedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'name': name,
        'description': description,
        'logoUrl': logoUrl,
        'imageUrl': imageUrl,
        'latitude': latitude,
        'longitude': longitude,
        'address': address,
        'city': city,
        'country': country,
        'phone': phone,
        'email': email,
        'website': website,
        'category': category,
        'tags': tags,
        'workingHours': workingHours.map((h) => h.toJson()).toList(),
        'linkedCardId': linkedCardId,
        'lastModifiedAt': lastModifiedAt.toIso8601String(),
        'syncStatus': syncStatus.name,
        'isActive': isActive,
      };

  factory Store.fromJson(Map<String, dynamic> json) {
    return Store(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      description: json['description'],
      logoUrl: json['logoUrl'],
      imageUrl: json['imageUrl'],
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
      address: json['address'],
      city: json['city'],
      country: json['country'],
      phone: json['phone'],
      email: json['email'],
      website: json['website'],
      category: json['category'] ?? 'General',
      tags: List<String>.from(json['tags'] ?? []),
      workingHours: (json['workingHours'] as List?)
              ?.map((h) => WorkingHours.fromJson(h))
              .toList() ??
          [],
      linkedCardId: json['linkedCardId'],
      lastModifiedAt: json['lastModifiedAt'] != null
          ? DateTime.parse(json['lastModifiedAt'])
          : null,
      syncStatus: domain_sync.SyncStatusExtension.fromString(
        json['syncStatus'] ?? 'notSynced',
      ),
      isActive: json['isActive'] ?? true,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Store && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;
}
