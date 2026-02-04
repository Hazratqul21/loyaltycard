/// ==========================================================================
/// scanner_screen.dart
/// ==========================================================================
/// Enhanced QR/Barcode skaner sahifasi - NFC va kamera.
/// ==========================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/services/qr_service.dart';
import '../../../core/services/scanner_service.dart';
import '../../../domain/entities/loyalty_card.dart';
import '../../providers/cards_provider.dart';
import '../../widgets/glassmorphic_card.dart';
import '../../widgets/gradient_button.dart';

/// Scan mode
enum ScanMode {
  camera,
  nfc,
}

/// Scanner provider
final scannerServiceProvider = Provider<ScannerService>((ref) {
  final service = ScannerService.instance;
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

/// Scanner ekrani
class ScannerScreen extends ConsumerStatefulWidget {
  const ScannerScreen({super.key});

  @override
  ConsumerState<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends ConsumerState<ScannerScreen>
    with SingleTickerProviderStateMixin {
  MobileScannerController? _scannerController;
  late AnimationController _animationController;
  late Animation<double> _scanlineAnimation;

  ScanMode _mode = ScanMode.camera;
  bool _isScanning = true;
  bool _hasScanned = false;
  String? _scannedData;
  bool _isTorchOn = false;
  List<ScanResult> _scanHistory = [];

  @override
  void initState() {
    super.initState();
    _initScanner();
    _setupAnimation();
    _listenToScans();
  }

  void _setupAnimation() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _scanlineAnimation = Tween<double>(begin: 0, end: 260).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  void _initScanner() {
    _scannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.normal,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  void _listenToScans() {
    final scannerService = ref.read(scannerServiceProvider);
    scannerService.scanResults.listen((result) {
      if (!_hasScanned) {
        setState(() {
          _hasScanned = true;
          _scannedData = result.rawValue;
          _isScanning = false;
          _scanHistory.insert(0, result);
          if (_scanHistory.length > 10) _scanHistory.removeLast();
        });
        _processScannedData(result);
      }
    });
  }

  @override
  void dispose() {
    _scannerController?.dispose();
    _animationController.dispose();
    if (_mode == ScanMode.nfc) {
      ref.read(scannerServiceProvider).stopNfcScanning();
    }
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_hasScanned) return;
    if (_mode != ScanMode.camera) return;

    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final barcode = barcodes.first;
    if (barcode.rawValue == null) return;

    final result = ScanResult(
      rawValue: barcode.rawValue!,
      type: barcode.format == BarcodeFormat.qrCode
          ? ScanType.qrCode
          : ScanType.barcode,
      format: barcode.format.name,
    );

    setState(() {
      _hasScanned = true;
      _scannedData = barcode.rawValue;
      _isScanning = false;
      _scanHistory.insert(0, result);
      if (_scanHistory.length > 10) _scanHistory.removeLast();
    });

    _processScannedData(result);
  }

  void _processScannedData(ScanResult result) {
    // Karta ID ni tekshirish
    if (result.cardId != null) {
      _showAddCardDialog(result);
    } else if (result.transactionData != null) {
      _showTransactionDialog(result);
    } else {
      // Oddiy matn
      _showManualAddDialog(result.rawValue);
    }
  }

  void _showAddCardDialog(ScanResult result) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildFoundCardSheet(result),
    );
  }

  void _showTransactionDialog(ScanResult result) {
    final txData = result.transactionData!;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Tranzaksiya: ${txData['cardId']} - ${txData['points']} ball',
        ),
        backgroundColor: AppColors.success,
      ),
    );
    _resetScanner();
  }

  void _showManualAddDialog(String data) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildManualAddSheet(data),
    );
  }

  void _resetScanner() {
    setState(() {
      _hasScanned = false;
      _scannedData = null;
      _isScanning = true;
    });
  }

  void _toggleTorch() async {
    await _scannerController?.toggleTorch();
    setState(() => _isTorchOn = !_isTorchOn);
  }

  void _switchMode(ScanMode newMode) {
    if (newMode == _mode) return;

    final scannerService = ref.read(scannerServiceProvider);

    setState(() {
      _mode = newMode;
      _hasScanned = false;
      _scannedData = null;
      _isScanning = true;
    });

    if (newMode == ScanMode.nfc) {
      _scannerController?.stop();
      scannerService.startNfcScanning();
    } else {
      scannerService.stopNfcScanning();
      _scannerController?.start();
    }
  }

  @override
  Widget build(BuildContext context) {
    final scannerService = ref.watch(scannerServiceProvider);
    final isNfcAvailable = scannerService.isNfcAvailable;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.scanner),
        centerTitle: true,
        actions: [
          if (_mode == ScanMode.camera)
            IconButton(
              icon: FaIcon(
                _isTorchOn
                    ? FontAwesomeIcons.lightbulb
                    : FontAwesomeIcons.solidLightbulb,
                size: 18,
              ),
              onPressed: _toggleTorch,
            ),
          IconButton(
            icon: const FaIcon(FontAwesomeIcons.clockRotateLeft, size: 18),
            onPressed: _showScanHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          // Mode toggle
          if (isNfcAvailable) _buildModeToggle(),

          // Scanner area
          Expanded(
            child: Stack(
              children: [
                // Camera mode
                if (_mode == ScanMode.camera && _isScanning) ...[
                  if (_scannerController != null)
                    MobileScanner(
                      controller: _scannerController!,
                      onDetect: _onDetect,
                    ),
                  _buildCameraOverlay(),
                ],

                // NFC mode
                if (_mode == ScanMode.nfc && _isScanning) _buildNfcOverlay(),

                // Success state
                if (!_isScanning && _hasScanned) _buildSuccessState(),
              ],
            ),
          ),

          // Instructions
          if (_isScanning) _buildInstructions(),
        ],
      ),
    );
  }

  Widget _buildModeToggle() {
    return Container(
      margin: const EdgeInsets.all(AppSizes.paddingMD),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(AppSizes.radiusMD),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildModeButton(
              icon: FontAwesomeIcons.camera,
              label: 'Kamera',
              mode: ScanMode.camera,
            ),
          ),
          Expanded(
            child: _buildModeButton(
              icon: FontAwesomeIcons.nfcSymbol,
              label: 'NFC',
              mode: ScanMode.nfc,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton({
    required IconData icon,
    required String label,
    required ScanMode mode,
  }) {
    final isSelected = _mode == mode;

    return GestureDetector(
      onTap: () => _switchMode(mode),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppSizes.radiusMD),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FaIcon(
              icon,
              size: 16,
              color: isSelected ? Colors.white : AppColors.primaryColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppColors.primaryColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCameraOverlay() {
    return Stack(
      children: [
        // Dark overlay with cutout
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.5),
          ),
          child: Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppColors.primaryColor,
                  width: 3,
                ),
                borderRadius: BorderRadius.circular(AppSizes.radiusXL),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppSizes.radiusXL - 2),
                child: ColorFiltered(
                  colorFilter: const ColorFilter.mode(
                    Colors.transparent,
                    BlendMode.clear,
                  ),
                  child: Container(color: Colors.black),
                ),
              ),
            ),
          ),
        ),

        // Scanline animation
        Center(
          child: SizedBox(
            width: 280,
            height: 280,
            child: AnimatedBuilder(
              animation: _scanlineAnimation,
              builder: (context, child) {
                return Stack(
                  children: [
                    Positioned(
                      top: _scanlineAnimation.value,
                      left: 10,
                      right: 10,
                      child: Container(
                        height: 2,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              Colors.transparent,
                              AppColors.accentColor.withValues(alpha: 0.8),
                              Colors.transparent,
                            ],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color:
                                  AppColors.accentColor.withValues(alpha: 0.5),
                              blurRadius: 10,
                              spreadRadius: 2,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),

        // Corner decorations
        _buildCornerDecorations(),
      ],
    );
  }

  Widget _buildNfcOverlay() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0.8, end: 1.0),
            duration: const Duration(seconds: 1),
            curve: Curves.easeInOut,
            builder: (context, scale, child) {
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 200,
                  height: 200,
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor.withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppColors.primaryColor,
                      width: 3,
                    ),
                  ),
                  child: const Center(
                    child: FaIcon(
                      FontAwesomeIcons.nfcSymbol,
                      size: 64,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
              );
            },
            onEnd: () => setState(() {}), // Restart animation
          ),
          const SizedBox(height: AppSizes.paddingLG),
          Text(
            'NFC kartani telefonga yaqinlashtiring',
            style: Theme.of(context).textTheme.titleMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessState() {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const FaIcon(
                FontAwesomeIcons.circleCheck,
                color: AppColors.success,
                size: 64,
              ),
            ),
            const SizedBox(height: AppSizes.paddingMD),
            const Text(
              AppStrings.scanSuccessful,
              style: TextStyle(
                fontSize: AppSizes.fontXL,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppSizes.paddingSM),
            Text(
              _scannedData ?? '',
              style: Theme.of(context).textTheme.bodySmall,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: AppSizes.paddingXL),
            GradientButton.primary(
              text: 'Qayta skanerlash',
              icon: FontAwesomeIcons.camera,
              onPressed: _resetScanner,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCornerDecorations() {
    const cornerSize = 30.0;
    const strokeWidth = 4.0;

    Widget corner({required bool isTop, required bool isLeft}) {
      return Container(
        width: cornerSize,
        height: cornerSize,
        decoration: BoxDecoration(
          border: Border(
            top: isTop
                ? const BorderSide(
                    color: AppColors.accentColor,
                    width: strokeWidth,
                  )
                : BorderSide.none,
            bottom: !isTop
                ? const BorderSide(
                    color: AppColors.accentColor,
                    width: strokeWidth,
                  )
                : BorderSide.none,
            left: isLeft
                ? const BorderSide(
                    color: AppColors.accentColor,
                    width: strokeWidth,
                  )
                : BorderSide.none,
            right: !isLeft
                ? const BorderSide(
                    color: AppColors.accentColor,
                    width: strokeWidth,
                  )
                : BorderSide.none,
          ),
        ),
      );
    }

    return Center(
      child: SizedBox(
        width: 286,
        height: 286,
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              child: corner(isTop: true, isLeft: true),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: corner(isTop: true, isLeft: false),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              child: corner(isTop: false, isLeft: true),
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: corner(isTop: false, isLeft: false),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      child: Column(
        children: [
          Text(
            _mode == ScanMode.camera
                ? AppStrings.scanQrCode
                : 'NFC kartani kutmoqda...',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
          const SizedBox(height: AppSizes.paddingSM),
          Text(
            _mode == ScanMode.camera
                ? AppStrings.pointCamera
                : 'Kartani telefonning orqasiga yaqinlashtiring',
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _showScanHistory() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildHistorySheet(),
    );
  }

  Widget _buildHistorySheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXXL),
        ),
      ),
      child: Column(
        children: [
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
            child: Text(
              'Skanerlash tarixi',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),
          Expanded(
            child: _scanHistory.isEmpty
                ? const Center(child: Text('Tarix bo\'sh'))
                : ListView.builder(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSizes.paddingMD,
                    ),
                    itemCount: _scanHistory.length,
                    itemBuilder: (context, index) {
                      final scan = _scanHistory[index];
                      return ListTile(
                        leading: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color:
                                AppColors.primaryColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: FaIcon(
                            scan.type == ScanType.nfc
                                ? FontAwesomeIcons.nfcSymbol
                                : scan.type == ScanType.qrCode
                                    ? FontAwesomeIcons.qrcode
                                    : FontAwesomeIcons.barcode,
                            size: 16,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        title: Text(
                          scan.rawValue,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(scan.format ?? scan.type.name),
                        trailing: Text(
                          _formatTime(scan.timestamp),
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Hozirgina';
    if (diff.inMinutes < 60) return '${diff.inMinutes} daqiqa';
    return '${diff.inHours} soat';
  }

  Widget _buildFoundCardSheet(ScanResult result) {
    return Container(
      padding: const EdgeInsets.all(AppSizes.paddingLG),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXXL),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSizes.paddingLG),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: FaIcon(
              result.type == ScanType.nfc
                  ? FontAwesomeIcons.nfcSymbol
                  : FontAwesomeIcons.creditCard,
              color: AppColors.primaryColor,
              size: 48,
            ),
          ),
          const SizedBox(height: AppSizes.paddingMD),
          Text(
            'Karta topildi!',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: AppSizes.paddingSM),
          Text(
            'ID: ${result.cardId}',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: AppSizes.paddingXL),
          GradientButton.primary(
            text: 'Karta qo\'shish',
            icon: FontAwesomeIcons.plus,
            width: double.infinity,
            onPressed: () => _addCardFromScan(result),
          ),
          const SizedBox(height: AppSizes.paddingMD),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _resetScanner();
            },
            child: const Text(AppStrings.cancel),
          ),
          const SizedBox(height: AppSizes.paddingMD),
        ],
      ),
    );
  }

  Widget _buildManualAddSheet(String data) {
    final storeNameController = TextEditingController(text: 'Yangi do\'kon');

    return Container(
      padding: EdgeInsets.only(
        left: AppSizes.paddingLG,
        right: AppSizes.paddingLG,
        top: AppSizes.paddingLG,
        bottom: MediaQuery.of(context).viewInsets.bottom + AppSizes.paddingLG,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppSizes.radiusXXL),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: AppSizes.paddingLG),
            const FaIcon(
              FontAwesomeIcons.creditCard,
              color: AppColors.accentColor,
              size: 48,
            ),
            const SizedBox(height: AppSizes.paddingMD),
            Text(
              AppStrings.addNewCard,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: AppSizes.paddingLG),
            TextField(
              controller: storeNameController,
              decoration: const InputDecoration(
                labelText: 'Do\'kon nomi',
                prefixIcon: Icon(Icons.store),
              ),
            ),
            const SizedBox(height: AppSizes.paddingXL),
            GradientButton.accent(
              text: AppStrings.add,
              icon: FontAwesomeIcons.plus,
              width: double.infinity,
              onPressed: () {
                final card = LoyaltyCard(
                  id: QrService.generateUuid(),
                  storeName: storeNameController.text,
                  currentPoints: 0,
                  tier: 'Bronze',
                  colorIndex: DateTime.now().millisecond % 10,
                  createdAt: DateTime.now(),
                  lastActivityAt: DateTime.now(),
                );
                ref.read(cardsProvider.notifier).addCard(card);
                Navigator.pop(context);
                _resetScanner();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Karta qo\'shildi!')),
                );
              },
            ),
            const SizedBox(height: AppSizes.paddingMD),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _resetScanner();
              },
              child: const Text(AppStrings.cancel),
            ),
          ],
        ),
      ),
    );
  }

  void _addCardFromScan(ScanResult result) {
    final card = LoyaltyCard(
      id: result.cardId ?? QrService.generateUuid(),
      storeName: 'Skanlangan karta',
      currentPoints: 0,
      tier: 'Bronze',
      colorIndex: DateTime.now().millisecond % 10,
      createdAt: DateTime.now(),
      lastActivityAt: DateTime.now(),
    );
    ref.read(cardsProvider.notifier).addCard(card);
    Navigator.pop(context);
    _resetScanner();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Karta qo\'shildi!')),
    );
  }
}
