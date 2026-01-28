/// ==========================================================================
/// merchant_scan_screen.dart
/// ==========================================================================
/// Sotuvchilar uchun mijoz QR-kodini skanerlash ekrani.
/// ==========================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_sizes.dart';
import '../../providers/merchant_provider.dart';
import '../../widgets/glassmorphic_card.dart';

class MerchantScanScreen extends ConsumerStatefulWidget {
  const MerchantScanScreen({super.key});

  @override
  ConsumerState<MerchantScanScreen> createState() => _MerchantScanScreenState();
}

class _MerchantScanScreenState extends ConsumerState<MerchantScanScreen> {
  final MobileScannerController _controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Scanner
          MobileScanner(
            controller: _controller,
            onDetect: (capture) {
              if (_isProcessing) return;
              final List<Barcode> barcodes = capture.barcodes;
              for (final barcode in barcodes) {
                if (barcode.rawValue != null) {
                  _onDetect(barcode.rawValue!);
                  break;
                }
              }
            },
          ),

          // Overlay
          _buildOverlay(),

          // Back/Close Button
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.black38,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: AppColors.primaryColor,
          borderRadius: 20,
          borderLength: 40,
          borderWidth: 10,
          cutOutSize: 280,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            padding: const EdgeInsets.all(32),
            width: double.infinity,
            color: Colors.black54,
            child: const Column(
              children: [
                Text(
                  'Mijoz QR-kodini skanerlang',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ball qo\'shish uchun mijoz kartasini markazga joylashtiring',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _onDetect(String qrData) async {
    setState(() => _isProcessing = true);
    _controller.stop();

    final repo = ref.read(merchantRepositoryProvider);
    final customerUid = await repo.validateCustomerQr(qrData);

    if (customerUid != null) {
      if (mounted) {
        _showAwardPointsSheet(customerUid);
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Noto\'g\'ri QR-kod')),
        );
        setState(() => _isProcessing = false);
        _controller.start();
      }
    }
  }

  void _showAwardPointsSheet(String customerId) {
    final TextEditingController pointsController = TextEditingController(text: '10');
    final TextEditingController amountController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ball qo\'shish',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                'Mijoz ID: $customerId',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              const SizedBox(height: 20),
              
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Xarid summasi (ixtiyoriy)',
                  prefixIcon: const Icon(FontAwesomeIcons.tag, size: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pointsController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Beriladigan ballar',
                  prefixIcon: const Icon(FontAwesomeIcons.coins, size: 16),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                ),
              ),
              
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () => _submitPoints(customerId, pointsController.text, amountController.text),
                  child: const Text('Tasdiqlash'),
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    ).then((_) {
      if (mounted) {
        setState(() => _isProcessing = false);
        _controller.start();
      }
    });
  }

  Future<void> _submitPoints(String customerId, String pointsStr, String amountStr) async {
    final points = int.tryParse(pointsStr) ?? 0;
    final amount = double.tryParse(amountStr);

    if (points <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ballni to\'g\'ri kiriting')),
      );
      return;
    }

    final success = await ref.read(merchantNotifierProvider.notifier).awardPoints(
      customerId: customerId,
      storeId: 'demo_store_1',
      points: points,
      amount: amount,
    );

    if (mounted) {
      Navigator.pop(context); // Close sheet
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.success,
            content: Text('Mijozga $points ball muvaffaqiyatli qo\'shildi'),
          ),
        );
      }
    }
  }
}

// Custom QR Overlay Shape
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) =>
      Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;
    final cutOutRect = Rect.fromCenter(
      center: Offset(width / 2, height / 2),
      width: cutOutSize,
      height: cutOutSize,
    );

    final backgroundPaint = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    // Draw background with cutout
    canvas.drawPath(
      Path.combine(
        PathOperation.difference,
        Path()..addRect(rect),
        Path()..addRRect(RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius))),
      ),
      backgroundPaint,
    );

    // Draw corners
    final boxRRect = RRect.fromRectAndRadius(cutOutRect, Radius.circular(borderRadius));
    final cornerPath = Path()
      // Top left
      ..moveTo(boxRRect.left, boxRRect.top + borderLength)
      ..lineTo(boxRRect.left, boxRRect.top)
      ..lineTo(boxRRect.left + borderLength, boxRRect.top)
      // Top right
      ..moveTo(boxRRect.right - borderLength, boxRRect.top)
      ..lineTo(boxRRect.right, boxRRect.top)
      ..lineTo(boxRRect.right, boxRRect.top + borderLength)
      // Bottom right
      ..moveTo(boxRRect.right, boxRRect.bottom - borderLength)
      ..lineTo(boxRRect.right, boxRRect.bottom)
      ..lineTo(boxRRect.right - borderLength, boxRRect.bottom)
      // Bottom left
      ..moveTo(boxRRect.left + borderLength, boxRRect.bottom)
      ..lineTo(boxRRect.left, boxRRect.bottom)
      ..lineTo(boxRRect.left, boxRRect.bottom - borderLength);

    canvas.drawPath(cornerPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => QrScannerOverlayShape();
}
