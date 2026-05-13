import 'package:equatable/equatable.dart';

class ExpenseModel extends Equatable {
  final String id;
  final double amount;
  final String paymentType; // cash | card
  final String? description;
  final DateTime createdAt;

  const ExpenseModel({
    required this.id,
    required this.amount,
    required this.paymentType,
    this.description,
    required this.createdAt,
  });

  factory ExpenseModel.fromMap(Map<String, dynamic> map) => ExpenseModel(
        id: map['id'] as String,
        amount: (map['amount'] as num).toDouble(),
        paymentType: map['payment_type'] as String,
        description: map['description'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'amount': amount,
        'payment_type': paymentType,
        'description': description,
        'created_at': createdAt.toIso8601String(),
      };

  ExpenseModel copyWith({
    double? amount,
    String? paymentType,
    String? description,
    DateTime? createdAt,
  }) =>
      ExpenseModel(
        id: id,
        amount: amount ?? this.amount,
        paymentType: paymentType ?? this.paymentType,
        description: description ?? this.description,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, amount, paymentType, description, createdAt];
}
