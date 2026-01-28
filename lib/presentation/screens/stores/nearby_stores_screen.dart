import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/services/location_service.dart';
import '../../../core/services/permission_service.dart';
import '../../../domain/entities/store.dart';
import '../../providers/stores_provider.dart';
import '../../widgets/glassmorphic_card.dart';

/// Nearby Stores Screen
class NearbyStoresScreen extends ConsumerStatefulWidget {
  const NearbyStoresScreen({super.key});

  @override
  ConsumerState<NearbyStoresScreen> createState() => _NearbyStoresScreenState();
}

class _NearbyStoresScreenState extends ConsumerState<NearbyStoresScreen> {
  GoogleMapController? _mapController;
  bool _showList = true;
  Store? _selectedStore;
  bool _isLocating = false;

  // Default: Toshkent markazi
  static const _defaultCenter = LatLng(41.3111, 69.2797);

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final hasPermission = await PermissionService.instance.requestLocationPermission(context);
    if (hasPermission) {
      ref.read(storesProvider.notifier).loadStores();
    }
  }

  @override
  Widget build(BuildContext context) {
    final nearbyStores = ref.watch(nearbyStoresProvider);
    final positionAsync = ref.watch(currentPositionProvider);
    final locationService = ref.watch(locationServiceProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yaqin do\'konlar'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: FaIcon(
              _showList ? FontAwesomeIcons.map : FontAwesomeIcons.list,
              size: 18,
            ),
            onPressed: () => setState(() => _showList = !_showList),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Xarita
          positionAsync.when(
            data: (position) => GoogleMap(
              initialCameraPosition: CameraPosition(
                target: position != null
                    ? LatLng(position.latitude, position.longitude)
                    : _defaultCenter,
                zoom: 14,
              ),
              onMapCreated: (controller) => _mapController = controller,
              myLocationEnabled: true,
              myLocationButtonEnabled: false,
              zoomControlsEnabled: false,
              markers: _buildMarkers(nearbyStores),
              onTap: (_) => setState(() => _selectedStore = null),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => GoogleMap(
              initialCameraPosition: const CameraPosition(
                target: _defaultCenter,
                zoom: 14,
              ),
              onMapCreated: (controller) => _mapController = controller,
              markers: _buildMarkers(nearbyStores),
            ),
          ),

          // Joriy joylashuvga o'tish tugmasi
          Positioned(
            right: AppSizes.paddingMD,
            bottom: _showList ? 320 : 100,
            child: FloatingActionButton.small(
              heroTag: 'locate_me',
              onPressed: _goToCurrentLocation,
              backgroundColor: Colors.white,
              child: const Icon(Icons.my_location, color: AppColors.primaryColor),
            ),
          ),

          // Do'konlar ro'yxati (pastda)
          if (_showList)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _buildStoresList(nearbyStores, locationService),
            ),

          // Tanlangan do'kon detallari
          if (_selectedStore != null && !_showList)
            Positioned(
              left: AppSizes.paddingMD,
              right: AppSizes.paddingMD,
              bottom: AppSizes.paddingLG,
              child: _buildSelectedStoreCard(
                _selectedStore!,
                locationService.distanceFromCurrent(
                  _selectedStore!.latitude,
                  _selectedStore!.longitude,
                ),
                locationService,
              ),
            ),
        ],
      ),
    );
  }

  /// Markerlar yaratish
  Set<Marker> _buildMarkers(List<(Store, double?)> stores) {
    return stores.map((item) {
      final store = item.$1;
      return Marker(
        markerId: MarkerId(store.id),
        position: LatLng(store.latitude, store.longitude),
        infoWindow: InfoWindow(title: store.name),
        icon: BitmapDescriptor.defaultMarkerWithHue(
          store.isOpenNow ? BitmapDescriptor.hueGreen : BitmapDescriptor.hueRed,
        ),
        onTap: () {
          setState(() => _selectedStore = store);
          _showList = false;
        },
      );
    }).toSet();
  }

  /// Do'konlar ro'yxati
  Widget _buildStoresList(
    List<(Store, double?)> stores,
    LocationService locationService,
  ) {
    return Container(
      height: 300,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXL),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: Column(
        children: [
          // Handle
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          Padding(
            padding: const EdgeInsets.all(AppSizes.paddingMD),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${stores.length} ta do\'kon',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                TextButton.icon(
                  onPressed: () => ref.read(storesProvider.notifier).loadStores(),
                  icon: const Icon(Icons.refresh, size: 18),
                  label: const Text('Yangilash'),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppSizes.paddingMD),
              itemCount: stores.length,
              itemBuilder: (context, index) {
                final (store, distance) = stores[index];
                return _buildStoreListItem(store, distance, locationService);
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Do'kon list item
  Widget _buildStoreListItem(
    Store store,
    double? distance,
    LocationService locationService,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSizes.paddingSM),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSizes.paddingMD,
          vertical: AppSizes.paddingXS,
        ),
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(AppSizes.radiusSM),
          ),
          child: Center(
            child: FaIcon(
              _getCategoryIcon(store.category),
              color: AppColors.primaryColor,
              size: 20,
            ),
          ),
        ),
        title: Text(
          store.name,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: store.isOpenNow ? AppColors.success : AppColors.error,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(store.isOpenNow ? 'Ochiq' : 'Yopiq'),
            if (distance != null) ...[
              const Text(' • '),
              Text(locationService.formatDistance(distance)),
            ],
          ],
        ),
        trailing: IconButton(
          icon: const Icon(Icons.navigation_outlined),
          onPressed: () => _openNavigation(store),
        ),
        onTap: () => _goToStore(store),
      ),
    );
  }

  /// Tanlangan do'kon card
  Widget _buildSelectedStoreCard(
    Store store,
    double? distance,
    LocationService locationService,
  ) {
    return GlassmorphicCard(
      padding: const EdgeInsets.all(AppSizes.paddingMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppSizes.radiusMD),
                ),
                child: Center(
                  child: FaIcon(
                    _getCategoryIcon(store.category),
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              const SizedBox(width: AppSizes.paddingMD),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      store.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: store.isOpenNow
                                ? AppColors.success.withOpacity(0.2)
                                : AppColors.error.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            store.isOpenNow ? 'Ochiq' : 'Yopiq',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: store.isOpenNow
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                        ),
                        if (distance != null) ...[
                          const SizedBox(width: 8),
                          Text(
                            locationService.formatDistance(distance),
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => setState(() => _selectedStore = null),
              ),
            ],
          ),
          if (store.address != null) ...[
            const SizedBox(height: AppSizes.paddingMD),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 18),
                const SizedBox(width: 8),
                Expanded(child: Text(store.fullAddress)),
              ],
            ),
          ],
          const SizedBox(height: AppSizes.paddingMD),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: store.phone != null ? () => _callStore(store) : null,
                  icon: const FaIcon(FontAwesomeIcons.phone, size: 14),
                  label: const Text('Qo\'ng\'iroq'),
                ),
              ),
              const SizedBox(width: AppSizes.paddingSM),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => _openNavigation(store),
                  icon: const FaIcon(FontAwesomeIcons.route, size: 14),
                  label: const Text('Yo\'nalish'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Kategoriya ikonkasi
  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'supermarket':
        return FontAwesomeIcons.cartShopping;
      case 'restoran':
      case 'restaurant':
        return FontAwesomeIcons.utensils;
      case 'kofe':
      case 'cafe':
        return FontAwesomeIcons.mugHot;
      case 'apteka':
      case 'pharmacy':
        return FontAwesomeIcons.pills;
      default:
        return FontAwesomeIcons.store;
    }
  }

  /// Joriy joylashuvga o'tish
  Future<void> _goToCurrentLocation() async {
    final position = await ref.read(currentPositionProvider.future);
    if (position != null) {
      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(
          LatLng(position.latitude, position.longitude),
          15,
        ),
      );
    }
  }

  /// Do'konga o'tish
  void _goToStore(Store store) {
    setState(() {
      _selectedStore = store;
      _showList = false;
    });
    _mapController?.animateCamera(
      CameraUpdate.newLatLngZoom(
        LatLng(store.latitude, store.longitude),
        16,
      ),
    );
  }

  /// Navigatsiya ochish
  Future<void> _openNavigation(Store store) async {
    final url = Uri.parse(
      'https://www.google.com/maps/dir/?api=1&destination=${store.latitude},${store.longitude}',
    );
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  /// Qo'ng'iroq qilish
  Future<void> _callStore(Store store) async {
    if (store.phone == null) return;
    final url = Uri.parse('tel:${store.phone}');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    }
  }
}
