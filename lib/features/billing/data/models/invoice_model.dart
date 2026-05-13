import 'package:equatable/equatable.dart';

class InvoiceItemModel extends Equatable {
  final String id;
  final String invoiceId;
  final String productId;
  final String productName;
  final double price;
  final int quantity;

  const InvoiceItemModel({
    required this.id,
    required this.invoiceId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  double get subtotal => price * quantity;

  factory InvoiceItemModel.fromMap(Map<String, dynamic> map) => InvoiceItemModel(
        id: map['id'] as String,
        invoiceId: map['invoice_id'] as String,
        productId: map['product_id'] as String,
        productName: map['product_name'] as String,
        price: (map['price'] as num).toDouble(),
        quantity: (map['quantity'] as num).toInt(),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'invoice_id': invoiceId,
        'product_id': productId,
        'product_name': productName,
        'price': price,
        'quantity': quantity,
      };

  InvoiceItemModel copyWith({int? quantity}) =>
      InvoiceItemModel(
        id: id,
        invoiceId: invoiceId,
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity ?? this.quantity,
      );

  @override
  List<Object?> get props => [id, invoiceId, productId, productName, price, quantity];
}

class InvoiceModel extends Equatable {
  final String id;
  final DateTime createdAt;
  final String paymentMethod;
  final double total;
  final String status;
  final List<InvoiceItemModel> items;

  const InvoiceModel({
    required this.id,
    required this.createdAt,
    required this.paymentMethod,
    required this.total,
    this.status = 'closed',
    this.items = const [],
  });

  factory InvoiceModel.fromMap(Map<String, dynamic> map, {List<InvoiceItemModel>? items}) =>
      InvoiceModel(
        id: map['id'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        paymentMethod: map['payment_method'] as String,
        total: (map['total'] as num).toDouble(),
        status: map['status'] as String? ?? 'closed',
        items: items ?? [],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'payment_method': paymentMethod,
        'total': total,
        'status': status,
      };

  InvoiceModel copyWith({
    String? paymentMethod,
    double? total,
    String? status,
    List<InvoiceItemModel>? items,
  }) =>
      InvoiceModel(
        id: id,
        createdAt: createdAt,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        total: total ?? this.total,
        status: status ?? this.status,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [id, createdAt, paymentMethod, total, status, items];
}
