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

  factory InvoiceItemModel.fromMap(Map<String, dynamic> map) =>
      InvoiceItemModel(
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

  InvoiceItemModel copyWith({int? quantity}) => InvoiceItemModel(
        id: id,
        invoiceId: invoiceId,
        productId: productId,
        productName: productName,
        price: price,
        quantity: quantity ?? this.quantity,
      );

  @override
  List<Object?> get props =>
      [id, invoiceId, productId, productName, price, quantity];
}

class InvoiceModel extends Equatable {
  final String id;
  final DateTime createdAt;
  final String paymentMethod;
  final double total;
  final double taxPercent;
  final double taxAmount;
  final bool taxEnabled;
  final double discountValue;
  final double discountAmount;
  final String discountType; // 'percentage' | 'fixed'
  final bool discountEnabled;
  final String status;
  final List<InvoiceItemModel> items;

  const InvoiceModel({
    required this.id,
    required this.createdAt,
    required this.paymentMethod,
    required this.total,
    this.taxPercent = 0,
    this.taxAmount = 0,
    this.taxEnabled = false,
    this.discountValue = 0,
    this.discountAmount = 0,
    this.discountType = 'percentage',
    this.discountEnabled = false,
    this.status = 'closed',
    this.items = const [],
  });

  double get subtotal => items.fold(0, (sum, item) => sum + item.subtotal);

  factory InvoiceModel.fromMap(Map<String, dynamic> map,
          {List<InvoiceItemModel>? items}) =>
      InvoiceModel(
        id: map['id'] as String,
        createdAt: DateTime.parse(map['created_at'] as String),
        paymentMethod: map['payment_method'] as String,
        total: (map['total'] as num).toDouble(),
        taxPercent: (map['tax_percent'] as num? ?? 0).toDouble(),
        taxAmount: (map['tax_amount'] as num? ?? 0).toDouble(),
        taxEnabled: (map['tax_enabled'] as int? ?? 0) == 1,
        discountValue: (map['discount_value'] as num? ?? 0).toDouble(),
        discountAmount: (map['discount_amount'] as num? ?? 0).toDouble(),
        discountType: map['discount_type'] as String? ?? 'percentage',
        discountEnabled: (map['discount_enabled'] as int? ?? 0) == 1,
        status: map['status'] as String? ?? 'closed',
        items: items ?? [],
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'payment_method': paymentMethod,
        'total': total,
        'tax_percent': taxPercent,
        'tax_amount': taxAmount,
        'tax_enabled': taxEnabled ? 1 : 0,
        'discount_value': discountValue,
        'discount_amount': discountAmount,
        'discount_type': discountType,
        'discount_enabled': discountEnabled ? 1 : 0,
        'status': status,
      };

  InvoiceModel copyWith({
    String? id,
    DateTime? createdAt,
    String? paymentMethod,
    double? total,
    double? taxPercent,
    double? taxAmount,
    bool? taxEnabled,
    double? discountValue,
    double? discountAmount,
    String? discountType,
    bool? discountEnabled,
    String? status,
    List<InvoiceItemModel>? items,
  }) =>
      InvoiceModel(
        id: id ?? this.id,
        createdAt: createdAt ?? this.createdAt,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        total: total ?? this.total,
        taxPercent: taxPercent ?? this.taxPercent,
        taxAmount: taxAmount ?? this.taxAmount,
        taxEnabled: taxEnabled ?? this.taxEnabled,
        discountValue: discountValue ?? this.discountValue,
        discountAmount: discountAmount ?? this.discountAmount,
        discountType: discountType ?? this.discountType,
        discountEnabled: discountEnabled ?? this.discountEnabled,
        status: status ?? this.status,
        items: items ?? this.items,
      );

  @override
  List<Object?> get props => [
        id,
        createdAt,
        paymentMethod,
        total,
        taxPercent,
        taxAmount,
        taxEnabled,
        discountValue,
        discountAmount,
        discountType,
        discountEnabled,
        status,
        items
      ];
}
