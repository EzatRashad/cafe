import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../billing/data/models/invoice_model.dart';

class InvoiceDetailsScreen extends StatelessWidget {
  final InvoiceModel invoice;

  const InvoiceDetailsScreen({super.key, required this.invoice});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == ThemeMode.dark;
    final dateStr = DateFormat('yyyy-MM-dd').format(invoice.createdAt);
    final timeStr = DateFormat('hh:mm a').format(invoice.createdAt);

    return Scaffold(
      appBar: AppBar(
        title: Text('invoiceDetails'.tr()),
        // actions: [
        //   IconButton(
        //     icon: const Icon(Icons.print_rounded),
        //     onPressed: () {

        //      },
        //   ),
        // ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 🔹 Header Card: Invoice Info
            _InfoCard(
              isDark: isDark,
              children: [
                _InfoRow(
                    label: 'invoiceNumber'.tr(),
                    value: '#${invoice.id.substring(0, 8)}',
                    isBold: true),
                const Divider(),
                _InfoRow(label: 'date'.tr(), value: dateStr),
                _InfoRow(label: 'time'.tr(), value: timeStr),
                _InfoRow(
                  label: 'paymentMethod'.tr(),
                  value: invoice.paymentMethod.tr(),
                  valueColor: invoice.paymentMethod == 'cash'
                      ? AppColors.cashColor
                      : AppColors.cardColor,
                ),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Body Card: Products List
            Text('products'.tr(),
                style:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 8),
            _InfoCard(
              isDark: isDark,
              children: [
                ...invoice.items.map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.productName,
                                    style: const TextStyle(
                                        fontWeight: FontWeight.w600)),
                                Text(
                                  '${item.quantity} x ${item.price.toStringAsFixed(2)}',
                                  style: TextStyle(
                                      color: isDark
                                          ? Colors.white70
                                          : Colors.black54,
                                      fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          Text(
                            item.subtotal.toStringAsFixed(2),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
            const SizedBox(height: 16),

            // 🔹 Footer Card: Summary
            _InfoCard(
              isDark: isDark,
              color: isDark
                  ? AppColors.darkCard.withValues(alpha: 0.5)
                  : AppColors.primary.withValues(alpha: 0.05),
              children: [
                _SummaryRow(
                    label: 'subtotal'.tr(),
                    value: '${invoice.subtotal.toStringAsFixed(2)} ر.س'),
                _SummaryRow(
                  label:
                      '${'discount'.tr()} (${invoice.discountType == 'percentage' ? '${invoice.discountValue}%' : 'fixedAmount'.tr()})',
                  value: '-${invoice.discountAmount.toStringAsFixed(2)} ر.س',
                  color: invoice.discountAmount > 0 ? AppColors.error : null,
                ),
                _SummaryRow(
                  label: '${'tax'.tr()} (${invoice.taxPercent}%)',
                  value: '${invoice.taxAmount.toStringAsFixed(2)} ر.س',
                ),
                const Divider(),
                _SummaryRow(
                  label: 'total'.tr(),
                  value: '${invoice.total.toStringAsFixed(2)} ر.س',
                  isTotal: true,
                  color: AppColors.accent,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final List<Widget> children;
  final bool isDark;
  final Color? color;

  const _InfoCard({required this.children, required this.isDark, this.color});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: color ?? (isDark ? AppColors.darkCard : Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: children),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? valueColor;

  const _InfoRow(
      {required this.label,
      required this.value,
      this.isBold = false,
      this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isTotal;
  final Color? color;

  const _SummaryRow(
      {required this.label,
      required this.value,
      this.isTotal = false,
      this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 22 : 14,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
