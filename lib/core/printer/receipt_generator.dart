import 'dart:typed_data';
import 'package:screenshot/screenshot.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import '../../features/billing/data/models/invoice_model.dart';
import 'thermal_receipt_widget.dart';

class ReceiptGenerator {
  final ScreenshotController _screenshotController = ScreenshotController();

  /// Generate ESC/POS bytes from an Invoice model
  Future<Uint8List> generate80mmReceipt(InvoiceModel invoice, {String appName = 'مقهي مصر'}) async {
    // 1. Capture the widget as an image
    final Uint8List? imageBytes = await _screenshotController.captureFromWidget(
      ThermalReceiptWidget(invoice: invoice, appName: appName),
      delay: const Duration(milliseconds: 100),
      context: null, // Screenshot controller handles the context internally if needed
    );

    if (imageBytes == null) throw Exception('Failed to capture receipt image');

    // 2. Process image with 'image' package
    final img.Image? originalImage = img.decodeImage(imageBytes);
    if (originalImage == null) throw Exception('Failed to decode receipt image');

    // Convert to grayscale and then to black/white (dithering or threshold)
    // Thermal printers need monochrome
    final img.Image grayscale = img.grayscale(originalImage);
    
    // 3. Convert to ESC/POS commands
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    List<int> bytes = [];

    // Print the image
    bytes += generator.imageRaster(grayscale, align: PosAlign.center);
    
    // Feed and Cut
    bytes += generator.feed(2);
    bytes += generator.cut();

    return Uint8List.fromList(bytes);
  }
}
