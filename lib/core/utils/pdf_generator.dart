import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../../../../core/database/database_helper.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/utils/date_formatter.dart';

class PdfGenerator {
  static Future<Uint8List> generateReport({
    required DateTime from,
    required DateTime to,
  }) async {
    final db = sl<DatabaseHelper>();
    final stats = await db.getDashboardStats(
      from: from.toIso8601String(),
      to: to.toIso8601String(),
    );
    final topProducts = await db.getTopProducts(
      from: from.toIso8601String(),
      to: to.toIso8601String(),
    );
    final invoices = await db.getInvoices(
      from: from.toIso8601String(),
      to: to.toIso8601String(),
    );
    final expenses = await db.getExpenses(
      from: from.toIso8601String(),
      to: to.toIso8601String(),
    );

    final pdf = pw.Document();

    final brown = PdfColor.fromHex('#5D4037');
    final amber = PdfColor.fromHex('#FFB300');
    final cream = PdfColor.fromHex('#FFF8E1');
    final darkBrown = PdfColor.fromHex('#3E2723');
    final green = PdfColor.fromHex('#2E7D32');
    final red = PdfColor.fromHex('#C62828');

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        header: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(bottom: 12),
          decoration: pw.BoxDecoration(
            border: pw.Border(bottom: pw.BorderSide(color: amber, width: 2)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text('CAFÉ EGYPT',
                      style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                          color: darkBrown)),
                  pw.Text('Business Report',
                      style: pw.TextStyle(fontSize: 11, color: brown)),
                ],
              ),
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.end,
                children: [
                  pw.Text('Period:',
                      style: pw.TextStyle(fontSize: 9, color: brown)),
                  pw.Text(
                    '${DateFormatter.formatDisplayDate(from)} → ${DateFormatter.formatDisplayDate(to)}',
                    style: pw.TextStyle(
                        fontSize: 10, fontWeight: pw.FontWeight.bold),
                  ),
                  pw.Text(
                      'Generated: ${DateFormatter.formatDisplayDate(DateTime.now())}',
                      style: pw.TextStyle(fontSize: 8, color: brown)),
                ],
              ),
            ],
          ),
        ),
        footer: (ctx) => pw.Container(
          padding: const pw.EdgeInsets.only(top: 8),
          decoration: pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(color: amber, width: 1)),
          ),
          child: pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text('Café Egypt — Confidential',
                  style: pw.TextStyle(fontSize: 8, color: brown)),
              pw.Text('Page ${ctx.pageNumber} of ${ctx.pagesCount}',
                  style: pw.TextStyle(fontSize: 8, color: brown)),
            ],
          ),
        ),
        build: (ctx) => [
          pw.SizedBox(height: 20),

          // Summary Section
          pw.Container(
            padding: const pw.EdgeInsets.all(16),
            decoration: pw.BoxDecoration(
              color: cream,
              borderRadius: pw.BorderRadius.circular(8),
            ),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Financial Summary',
                    style: pw.TextStyle(
                        fontSize: 14,
                        fontWeight: pw.FontWeight.bold,
                        color: darkBrown)),
                pw.SizedBox(height: 12),
                pw.Row(
                  children: [
                    _summaryBox('Cash Income', stats['cashIncome'], green),
                    pw.SizedBox(width: 8),
                    _summaryBox('Card Income', stats['cardIncome'],
                        PdfColor.fromHex('#1565C0')),
                    pw.SizedBox(width: 8),
                    _summaryBox('Total Income', stats['totalIncome'], amber),
                    pw.SizedBox(width: 8),
                    _summaryBox('Expenses', stats['totalExpenses'], red),
                    pw.SizedBox(width: 8),
                    _summaryBox('Net Profit', stats['netProfit'],
                        (stats['netProfit'] as num) >= 0 ? green : red),
                  ],
                ),
              ],
            ),
          ),

          pw.SizedBox(height: 20),

          // Top products
          if (topProducts.isNotEmpty) ...[
            pw.Text('Top Selling Products',
                style: pw.TextStyle(
                    fontSize: 13,
                    fontWeight: pw.FontWeight.bold,
                    color: darkBrown)),
            pw.SizedBox(height: 8),
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#EFEBE9'), width: 0.5),
              children: [
                pw.TableRow(
                  decoration: pw.BoxDecoration(color: amber),
                  children: ['#', 'Product', 'Qty Sold', 'Revenue']
                      .map((h) => pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(h,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10)),
                          ))
                      .toList(),
                ),
                ...topProducts.asMap().entries.map((e) {
                  final p = e.value;
                  return pw.TableRow(
                    decoration:
                        e.key.isEven ? pw.BoxDecoration(color: cream) : null,
                    children: [
                      '${e.key + 1}',
                      p['product_name']?.toString() ?? '',
                      '${p['total_qty']}',
                      (p['total_revenue'] as num).toStringAsFixed(2),
                    ]
                        .map((v) => pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text(v,
                                  style: const pw.TextStyle(fontSize: 10)),
                            ))
                        .toList(),
                  );
                }),
              ],
            ),
            pw.SizedBox(height: 20),
          ],

          // Invoice list
          pw.Text('Invoice Summary (${invoices.length} invoices)',
              style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: darkBrown)),
          pw.SizedBox(height: 8),
          pw.Text(
              'Total invoices: ${invoices.length}   |   Total income: ${(stats['totalIncome'] as num).toStringAsFixed(2)}',
              style: pw.TextStyle(fontSize: 10, color: brown)),

          pw.SizedBox(height: 20),

          // Expenses
          pw.Text('Expense Summary (${expenses.length} entries)',
              style: pw.TextStyle(
                  fontSize: 13,
                  fontWeight: pw.FontWeight.bold,
                  color: darkBrown)),
          pw.SizedBox(height: 8),
          if (expenses.isNotEmpty)
            pw.Table(
              border: pw.TableBorder.all(
                  color: PdfColor.fromHex('#EFEBE9'), width: 0.5),
              children: [
                pw.TableRow(
                  decoration:
                      pw.BoxDecoration(color: PdfColor.fromHex('#FFCCBC')),
                  children: ['Date', 'Description', 'Type', 'Amount']
                      .map((h) => pw.Padding(
                            padding: const pw.EdgeInsets.all(6),
                            child: pw.Text(h,
                                style: pw.TextStyle(
                                    fontWeight: pw.FontWeight.bold,
                                    fontSize: 10)),
                          ))
                      .toList(),
                ),
                ...expenses.asMap().entries.map((e) {
                  final exp = e.value;
                  return pw.TableRow(
                    decoration:
                        e.key.isEven ? pw.BoxDecoration(color: cream) : null,
                    children: [
                      DateFormatter.formatDisplayDate(
                          DateTime.parse(exp['created_at'] as String)),
                      exp['description']?.toString() ?? '-',
                      exp['payment_type']?.toString().toUpperCase() ?? '',
                      (exp['amount'] as num).toStringAsFixed(2),
                    ]
                        .map((v) => pw.Padding(
                              padding: const pw.EdgeInsets.all(6),
                              child: pw.Text(v,
                                  style: const pw.TextStyle(fontSize: 10)),
                            ))
                        .toList(),
                  );
                }),
              ],
            ),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _summaryBox(String label, dynamic value, PdfColor color) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColors.white,
          borderRadius: pw.BorderRadius.circular(6),
          border: pw.Border.all(color: color, width: 1),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(label, style: pw.TextStyle(fontSize: 8, color: color)),
            pw.SizedBox(height: 4),
            pw.Text(
              (value as num).toStringAsFixed(2),
              style: pw.TextStyle(
                  fontSize: 11, fontWeight: pw.FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}
