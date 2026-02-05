/// ==========================================================================
/// stores_provider.dart
/// ==========================================================================
/// Do'konlar uchun Riverpod providerlar.
/// ==========================================================================
library;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/services/location_service.dart';
import '../../domain/entities/store.dart';

/// LocationService provider
final locationServiceProvider = Provider<LocationService>((ref) {
  final service = LocationService.instance;
  ref.onDispose(() => service.dispose());
  return service;
});

/// Joriy joylashuv provider
final currentPositionProvider = FutureProvider<Position?>((ref) async {
  final locationService = ref.watch(locationServiceProvider);
  await locationService.initialize();
  return locationService.getCurrentPosition();
});

/// Demo do'konlar - Toshkent
List<Store> _getDemoStores() {
  return [
    Store(
      id: 'store_1',
      name: 'Makro Supermarket',
      description: 'Yirik supermarket tarmog\'i',
      category: 'Supermarket',
      latitude: 41.3111,
      longitude: 69.2797,
      address: 'Amir Temur xiyoboni, 1',
      city: 'Toshkent',
      country: 'O\'zbekiston',
      phone: '+998 71 200 00 00',
      linkedCardId: 'card_1',
      tags: ['supermarket', 'oziq-ovqat', 'chegirma'],
      workingHours: [
        const WorkingHours(
            dayOfWeek: 'Monday', openTime: '08:00', closeTime: '22:00'),
        const WorkingHours(
            dayOfWeek: 'Tuesday', openTime: '08:00', closeTime: '22:00'),
        const WorkingHours(
            dayOfWeek: 'Wednesday', openTime: '08:00', closeTime: '22:00'),
        const WorkingHours(
            dayOfWeek: 'Thursday', openTime: '08:00', closeTime: '22:00'),
        const WorkingHours(
            dayOfWeek: 'Friday', openTime: '08:00', closeTime: '22:00'),
        const WorkingHours(
            dayOfWeek: 'Saturday', openTime: '09:00', closeTime: '21:00'),
        const WorkingHours(
            dayOfWeek: 'Sunday', openTime: '09:00', closeTime: '20:00'),
      ],
    ),
    Store(
      id: 'store_2',
      name: 'Korzinka Go',
      description: 'Qulay supermarket',
      category: 'Supermarket',
      latitude: 41.3150,
      longitude: 69.2850,
      address: 'Mustaqillik maydoni yaqinida',
      city: 'Toshkent',
      country: 'O\'zbekiston',
      phone: '+998 71 203 00 00',
      linkedCardId: 'card_2',
      tags: ['supermarket', 'express', 'chegirma'],
    ),
    Store(
      id: 'store_3',
      name: 'Havas Restoran',
      description: 'Milliy oshxona va kofe',
      category: 'Restoran',
      latitude: 41.3090,
      longitude: 69.2750,
      address: 'Bobur ko\'chasi, 15',
      city: 'Toshkent',
      country: 'O\'zbekiston',
      phone: '+998 71 205 00 00',
      linkedCardId: 'card_3',
      tags: ['restoran', 'milliy', 'kofe'],
      workingHours: [
        const WorkingHours(
            dayOfWeek: 'Monday', openTime: '10:00', closeTime: '23:00'),
        const WorkingHours(
            dayOfWeek: 'Tuesday', openTime: '10:00', closeTime: '23:00'),
        const WorkingHours(
            dayOfWeek: 'Wednesday', openTime: '10:00', closeTime: '23:00'),
        const WorkingHours(
            dayOfWeek: 'Thursday', openTime: '10:00', closeTime: '23:00'),
        const WorkingHours(
            dayOfWeek: 'Friday', openTime: '10:00', closeTime: '00:00'),
        const WorkingHours(
            dayOfWeek: 'Saturday', openTime: '10:00', closeTime: '00:00'),
        const WorkingHours(
            dayOfWeek: 'Sunday', openTime: '11:00', closeTime: '22:00'),
      ],
    ),
    Store(
      id: 'store_4',
      name: 'Oila Market',
      description: 'Oilaviy do\'kon',
      category: 'Supermarket',
      latitude: 41.3200,
      longitude: 69.2900,
      address: 'Chilonzor tumani',
      city: 'Toshkent',
      country: 'O\'zbekiston',
      linkedCardId: 'card_4',
      tags: ['supermarket', 'mahalliy'],
    ),
  ];
}

/// Do'konlar state
class StoresState {
  final List<Store> stores;
  final bool isLoading;
  final String? errorMessage;
  final String? selectedStoreId;

  const StoresState({
    this.stores = const [],
    this.isLoading = false,
    this.errorMessage,
    this.selectedStoreId,
  });

  StoresState copyWith({
    List<Store>? stores,
    bool? isLoading,
    String? errorMessage,
    String? selectedStoreId,
  }) {
    return StoresState(
      stores: stores ?? this.stores,
      isLoading: isLoading ?? this.isLoading,
      errorMessage: errorMessage,
      selectedStoreId: selectedStoreId ?? this.selectedStoreId,
    );
  }

  Store? get selectedStore {
    if (selectedStoreId == null) return null;
    return stores.firstWhere(
      (s) => s.id == selectedStoreId,
      orElse: () => stores.first,
    );
  }
}

/// Stores notifier
class StoresNotifier extends StateNotifier<StoresState> {
  final Ref ref;

  StoresNotifier(this.ref) : super(const StoresState()) {
    loadStores();
  }

  /// Do'konlarni yuklash
  Future<void> loadStores() async {
    state = state.copyWith(isLoading: true);

    try {
      // Demo data
      final stores = _getDemoStores();
      state = state.copyWith(stores: stores, isLoading: false);
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: 'Do\'konlarni yuklashda xato: $e',
      );
    }
  }

  /// Do'kon tanlash
  void selectStore(String storeId) {
    state = state.copyWith(selectedStoreId: storeId);
  }
}

/// Stores provider
final storesProvider =
    StateNotifierProvider<StoresNotifier, StoresState>((ref) {
  return StoresNotifier(ref);
});

/// Yaqin do'konlar provider (masofaga qarab tartiblangan)
final nearbyStoresProvider = Provider<List<(Store, double?)>>((ref) {
  final storesState = ref.watch(storesProvider);
  final positionAsync = ref.watch(currentPositionProvider);
  final locationService = ref.watch(locationServiceProvider);

  final stores = storesState.stores;

  return positionAsync.when(
    data: (position) {
      if (position == null) {
        return stores.map((s) => (s, null as double?)).toList();
      }

      // Masofani hisoblash va tartiblash
      final storesWithDistance = stores.map((store) {
        final distance = locationService.distanceFromCurrent(
          store.latitude,
          store.longitude,
        );
        return (store, distance);
      }).toList();

      // Masofaga qarab tartiblash
      storesWithDistance.sort((a, b) {
        if (a.$2 == null) return 1;
        if (b.$2 == null) return -1;
        return a.$2!.compareTo(b.$2!);
      });

      return storesWithDistance;
    },
    loading: () => stores.map((s) => (s, null as double?)).toList(),
    error: (_, __) => stores.map((s) => (s, null as double?)).toList(),
  );
});
