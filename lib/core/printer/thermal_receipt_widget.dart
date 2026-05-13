import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:intl/intl.dart';
import '../../features/billing/data/models/invoice_model.dart';

/// A Flutter widget that renders a professional 80mm POS receipt.
/// It is captured as a raster image and sent to the thermal printer.
/// Width is fixed at 576px — matching the 80mm printer's dot width at 203 DPI.
class ThermalReceiptWidget extends StatelessWidget {
  final InvoiceModel invoice;
  final String appName;

  const ThermalReceiptWidget({
    super.key,
    required this.invoice,
    this.appName = 'قهوة مصر',
  });

  // ── helpers ──────────────────────────────────────────────
  String _shortId(String id) {
    if (id.length <= 10) return id.toUpperCase();
    return '#${id.substring(id.length - 8).toUpperCase()}';
  }

  String _paymentLabel(String method) {
    switch (method.toLowerCase()) {
      case 'cash':
        return 'نقدي';
      case 'card':
        return 'بطاقة بنكية / شبكة';
      default:
        return method;
    }
  }

  // ── text styles ───────────────────────────────────────────
  static const _base = TextStyle(
    color: Colors.black,
    fontFamily: 'Cairo',
    fontSize: 14,
    height: 1.5,
    decoration: TextDecoration.none,
  );

  static const _bold = TextStyle(
    color: Colors.black,
    fontFamily: 'Cairo',
    fontSize: 14,
    fontWeight: FontWeight.bold,
    height: 1.5,
    decoration: TextDecoration.none,
  );

  // ── build ─────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    final date = DateFormat('dd/MM/yyyy').format(invoice.createdAt);
    final time = DateFormat('HH:mm').format(invoice.createdAt);

    return Directionality(
      textDirection: ui.TextDirection.rtl,
      child: DefaultTextStyle(
        style: _base,
        child: Container(
          width: 576,
          color: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ═══ App Name ═══
              _doubleDivider(),
              const SizedBox(height: 10),
              Text(
                appName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Cairo',
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 10),
              _doubleDivider(),
              const SizedBox(height: 14),

              // ═══ Invoice Meta ═══
              _metaRow('رقم الفاتورة', _shortId(invoice.id)),
              _metaRow('التاريخ', date),
              _metaRow('الوقت', time),
              _metaRow('طريقة الدفع', _paymentLabel(invoice.paymentMethod)),
              const SizedBox(height: 14),
              _singleDivider(),

              // ═══ Table Header ═══
              const SizedBox(height: 6),
              Row(
                children: [
                  Expanded(
                    flex: 5,
                    child: Text('الصنف', style: _bold),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('الكمية',
                        textAlign: TextAlign.center, style: _bold),
                  ),
                  Expanded(
                    flex: 2,
                    child: Text('السعر',
                        textAlign: TextAlign.center, style: _bold),
                  ),
                  Expanded(
                    flex: 3,
                    child: Text('الإجمالي',
                        textAlign: TextAlign.end, style: _bold),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              _singleDivider(),
              const SizedBox(height: 4),

              // ═══ Items ═══
              ...invoice.items.map((item) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Row(
                      children: [
                        Expanded(
                          flex: 5,
                          child: Text(item.productName, style: _base),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            '×${item.quantity}',
                            textAlign: TextAlign.center,
                            style: _base,
                          ),
                        ),
                        Expanded(
                          flex: 2,
                          child: Text(
                            item.price.toStringAsFixed(2),
                            textAlign: TextAlign.center,
                            style: _base,
                          ),
                        ),
                        Expanded(
                          flex: 3,
                          child: Text(
                            item.subtotal.toStringAsFixed(2),
                            textAlign: TextAlign.end,
                            style: _bold,
                          ),
                        ),
                      ],
                    ),
                  )),

              const SizedBox(height: 10),
              _singleDivider(),
              const SizedBox(height: 10),

              // ═══ Summary ═══
              if (invoice.discountEnabled || invoice.taxEnabled) ...[
                _summaryRow('المجموع الفرعي',
                    invoice.subtotal.toStringAsFixed(2), false),
                const SizedBox(height: 4),
              ],
              if (invoice.discountEnabled && invoice.discountAmount > 0) ...[
                _summaryRow(
                  'الخصم (${invoice.discountType == 'percentage' ? '${invoice.discountValue.toStringAsFixed(0)}%' : 'قيمة ثابتة'})',
                  '-${invoice.discountAmount.toStringAsFixed(2)}',
                  false,
                ),
                const SizedBox(height: 4),
              ],
              if (invoice.taxEnabled) ...[
                _summaryRow(
                  'الضريبة (${invoice.taxPercent.toStringAsFixed(0)}%)',
                  invoice.taxAmount.toStringAsFixed(2),
                  false,
                ),
                const SizedBox(height: 4),
              ],

              _doubleDivider(),
              const SizedBox(height: 8),
              _summaryRow(
                'الإجمالي النهائي',
                '${invoice.total.toStringAsFixed(2)} ر.س',
                true,
                fontSize: 20,
              ),
              const SizedBox(height: 8),
              _doubleDivider(),

              // ═══ Footer ═══
              const SizedBox(height: 20),
              Text(
                'شكراً لزيارتكم! 🤍',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black,
                  fontFamily: 'Cairo',
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'نتطلع لخدمتكم مجدداً',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.black54,
                  fontFamily: 'Cairo',
                  fontSize: 13,
                  decoration: TextDecoration.none,
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  // ── private builders ──────────────────────────────────────

  Widget _metaRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: _base),
            Text(value, style: _bold),
          ],
        ),
      );

  Widget _summaryRow(String label, String value, bool isBold,
      {double fontSize = 15}) {
    final style = TextStyle(
      color: Colors.black,
      fontFamily: 'Cairo',
      fontSize: fontSize,
      fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
      decoration: TextDecoration.none,
      height: 1.5,
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: style),
        Text(value, style: style),
      ],
    );
  }

  Widget _singleDivider() => Container(
        height: 1,
        color: Colors.black,
        margin: const EdgeInsets.symmetric(vertical: 2),
      );

  Widget _doubleDivider() => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(height: 1.5, color: Colors.black),
          const SizedBox(height: 3),
          Container(height: 1.5, color: Colors.black),
        ],
      );
}
