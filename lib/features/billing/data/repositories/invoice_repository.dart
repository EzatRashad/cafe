import '../../data/models/invoice_model.dart';
import '../../../../core/database/database_helper.dart';
import 'package:uuid/uuid.dart';

abstract class InvoiceRepository {
  Future<List<InvoiceModel>> getInvoices({DateTime? from, DateTime? to});
  Future<InvoiceModel?> getInvoiceById(String id);
  Future<String> saveInvoice(InvoiceModel invoice);
  Future<void> updateInvoice(InvoiceModel invoice);
  Future<void> deleteInvoice(String id);
}

class InvoiceRepositoryImpl implements InvoiceRepository {
  final DatabaseHelper _db;
  final _uuid = const Uuid();

  InvoiceRepositoryImpl(this._db);

  @override
  Future<List<InvoiceModel>> getInvoices({DateTime? from, DateTime? to}) async {
    final rows = await _db.getInvoices(
      from: from?.toIso8601String(),
      to: to?.toIso8601String(),
    );
    final invoices = <InvoiceModel>[];
    for (final row in rows) {
      final itemRows = await _db.getInvoiceItems(row['id'] as String);
      final items = itemRows.map(InvoiceItemModel.fromMap).toList();
      invoices.add(InvoiceModel.fromMap(row, items: items));
    }
    return invoices;
  }

  @override
  Future<InvoiceModel?> getInvoiceById(String id) async {
    final row = await _db.getInvoiceById(id);
    if (row == null) return null;
    final itemRows = await _db.getInvoiceItems(id);
    final items = itemRows.map(InvoiceItemModel.fromMap).toList();
    return InvoiceModel.fromMap(row, items: items);
  }

  @override
  Future<String> saveInvoice(InvoiceModel invoice) async {
    final id = _uuid.v4();
    final model = invoice.copyWith(
      id: id,
      createdAt: DateTime.now(),
      status: 'closed',
    );
    final itemMaps = model.items
        .map((item) => InvoiceItemModel(
              id: _uuid.v4(),
              invoiceId: id,
              productId: item.productId,
              productName: item.productName,
              price: item.price,
              quantity: item.quantity,
            ).toMap())
        .toList();
    await _db.insertInvoice(model.toMap(), itemMaps);
    return id;
  }

  @override
  Future<void> updateInvoice(InvoiceModel invoice) async {
    final itemMaps = invoice.items.map((item) => InvoiceItemModel(
          id: _uuid.v4(),
          invoiceId: invoice.id,
          productId: item.productId,
          productName: item.productName,
          price: item.price,
          quantity: item.quantity,
        ).toMap()).toList();
    await _db.updateInvoice(
      invoice.id,
      invoice.toMap(),
      itemMaps,
    );
  }

  @override
  Future<void> deleteInvoice(String id) async {
    await _db.deleteInvoice(id);
  }
}
