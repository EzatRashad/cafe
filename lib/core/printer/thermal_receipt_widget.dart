import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import '../../features/billing/data/models/invoice_model.dart';
import 'package:intl/intl.dart';

class ThermalReceiptWidget extends StatelessWidget {
  final InvoiceModel invoice;
  final String appName;

  const ThermalReceiptWidget({
    super.key,
    required this.invoice,
    this.appName = 'مقهي مصر',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400, // Roughly 80mm at 96 DPI
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Directionality(
        textDirection: ui.TextDirection.rtl,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Text(
              appName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.black,
                fontFamily: 'Cairo',
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'فاتورة رقم: ${invoice.id}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 16, color: Colors.black, fontFamily: 'Cairo'),
            ),
            Text(
              'التاريخ: ${DateFormat('yyyy-MM-dd HH:mm').format(invoice.createdAt)}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontSize: 14, color: Colors.black, fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 16),
            const Divider(color: Colors.black, thickness: 1.5),

            // Table Header
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Row(
                children: const [
                  Expanded(
                      flex: 3,
                      child: Text('الصنف',
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo'))),
                  Expanded(
                      flex: 1,
                      child: Text('الكمية',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo'))),
                  Expanded(
                      flex: 2,
                      child: Text('السعر',
                          textAlign: TextAlign.left,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Cairo'))),
                ],
              ),
            ),
            const Divider(color: Colors.black),

            // Items
            ...invoice.items.map((item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: Text(item.productName,
                              style: const TextStyle(fontFamily: 'Cairo'))),
                      Expanded(
                          flex: 1,
                          child: Text('${item.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontFamily: 'Cairo'))),
                      Expanded(
                          flex: 2,
                          child: Text(item.price.toStringAsFixed(2),
                              textAlign: TextAlign.left,
                              style: const TextStyle(fontFamily: 'Cairo'))),
                    ],
                  ),
                )),

            const SizedBox(height: 16),
            const Divider(color: Colors.black, thickness: 1.5),

            // Summary
            if (invoice.discountEnabled || invoice.taxEnabled) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('المجموع الفرعي:',
                      style: TextStyle(fontSize: 16, fontFamily: 'Cairo')),
                  Text('${invoice.subtotal.toStringAsFixed(2)} ر.س',
                      style:
                          const TextStyle(fontSize: 16, fontFamily: 'Cairo')),
                ],
              ),
              const SizedBox(height: 4),
              if (invoice.discountEnabled && invoice.discountAmount > 0) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                        'الخصم (${invoice.discountType == 'percentage' ? '${invoice.discountValue}%' : 'قيمة ثابتة'}):',
                        style: const TextStyle(
                            fontSize: 16,
                            fontFamily: 'Cairo',
                            color: Colors.black)),
                    Text('-${invoice.discountAmount.toStringAsFixed(2)} ر.س',
                        style:
                            const TextStyle(fontSize: 16, fontFamily: 'Cairo')),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              if (invoice.taxEnabled) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('الضريبة (${invoice.taxPercent}%):',
                        style:
                            const TextStyle(fontSize: 16, fontFamily: 'Cairo')),
                    Text('${invoice.taxAmount.toStringAsFixed(2)} ر.س',
                        style:
                            const TextStyle(fontSize: 16, fontFamily: 'Cairo')),
                  ],
                ),
                const SizedBox(height: 4),
              ],
              const Divider(color: Colors.black),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('الإجمالي النهائي:',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo')),
                Text('${invoice.total.toStringAsFixed(2)} ر.س',
                    style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Cairo')),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'طريقة الدفع: ${invoice.paymentMethod == 'cash' ? 'نقدي' : 'فيزا'}',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 14, fontFamily: 'Cairo'),
            ),

            const SizedBox(height: 32),
            const Text(
              'شكراً لزيارتكم!',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Cairo'),
            ),
            const SizedBox(height: 4),
            const Text(
              'صنع بكل حب في مصر',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: Colors.black54, fontFamily: 'Cairo'),
            ),
          ],
        ),
      ),
    );
  }
}
