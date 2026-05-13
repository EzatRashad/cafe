import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:image/image.dart' as img;
import '../../features/billing/data/models/invoice_model.dart';
import 'thermal_receipt_widget.dart';

/// Converts an [InvoiceModel] into raw ESC/POS bytes ready to be sent
/// to an 80mm thermal printer via Windows spooler or USB.
///
/// Strategy:
///   1. Render [ThermalReceiptWidget] offscreen using [ScreenshotController].
///   2. Decode the captured PNG into an [img.Image].
///   3. Convert to grayscale and apply a binary threshold (cleaner dots).
///   4. Wrap in ESC/POS raster-image commands via [Generator.imageRaster].
///   5. Append feed + cut commands.
class ReceiptGenerator {
  ReceiptGenerator();

  final ScreenshotController _screenshotController = ScreenshotController();

  /// Width of an 80mm printer in dots at 203 DPI:
  ///   80mm × (203 dots / 25.4mm) ≈ 640 dots.
  /// 576 is the commonly used safe printable width (leaves margins).
  static const double _widthPx = 576;

  /// Brightness threshold: pixels brighter than this become white (0xFF).
  static const int _threshold = 140;

  // ─────────────────────────────────────────────────────────────────────────
  /// Build ESC/POS bytes for a complete 80mm receipt.
  // ─────────────────────────────────────────────────────────────────────────
  Future<Uint8List> generate80mmReceipt(
    InvoiceModel invoice, {
    String appName = 'قهوة مصر',
  }) async {
    // ── 1. Render widget ────────────────────────────────────────────────────
    // We wrap in MediaQuery so the widget knows its viewport width.
    final Uint8List pngBytes = await _screenshotController.captureFromWidget(
      MediaQuery(
        data: const MediaQueryData(
          size: Size(_widthPx, 4000),
          devicePixelRatio: 1.0,
        ),
        child: ThermalReceiptWidget(invoice: invoice, appName: appName),
      ),
      delay: const Duration(milliseconds: 200),
      pixelRatio: 1.0, // 1 logical px = 1 printer dot
    );

    // ── 2. Decode PNG ────────────────────────────────────────────────────────
    final img.Image? original = img.decodeImage(pngBytes);
    if (original == null) {
      throw Exception('ReceiptGenerator: فشل في فك ترميز صورة الإيصال');
    }

    // ── 3. Grayscale + threshold → clean black/white image ──────────────────
    final img.Image grayscale = img.grayscale(original);
    final img.Image bw = _applyThreshold(grayscale);

    // ── 4. Build ESC/POS commands ────────────────────────────────────────────
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final List<int> bytes = [];

    // Initialize printer
    bytes.addAll(generator.reset());

    // Print the receipt as a raster image (best Arabic support)
    bytes.addAll(generator.imageRaster(
      bw,
      align: PosAlign.center,
      highDensityHorizontal: true,
      highDensityVertical: true,
    ));

    // Feed 3 lines then cut
    bytes.addAll(generator.feed(3));
    bytes.addAll(generator.cut(mode: PosCutMode.full));

    return Uint8List.fromList(bytes);
  }

  // ─────────────────────────────────────────────────────────────────────────
  /// Apply a binary threshold to a grayscale image.
  /// Pixels below [_threshold] → black (0,0,0).
  /// Pixels at or above        → white (255,255,255).
  // ─────────────────────────────────────────────────────────────────────────
  img.Image _applyThreshold(img.Image src) {
    final img.Image out = img.Image(width: src.width, height: src.height);
    for (int y = 0; y < src.height; y++) {
      for (int x = 0; x < src.width; x++) {
        final pixel = src.getPixel(x, y);
        // Luma: use red channel (grayscale images have R=G=B)
        final int luma = pixel.r.toInt();
        final int c = luma < _threshold ? 0 : 255;
        out.setPixelRgb(x, y, c, c, c);
      }
    }
    return out;
  }
}
