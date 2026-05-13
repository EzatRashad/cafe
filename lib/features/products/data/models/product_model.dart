import 'package:equatable/equatable.dart';
import '../../../../core/utils/localization_helper.dart';

class ProductModel extends Equatable {
  final String id;
  final String name;
  final String categoryId;
  final double price;
  final String? imagePath;
  final int soldCount;
  final DateTime createdAt;

  String get localizedName => LocalizationHelper.getLocalizedName(name);

  const ProductModel({
    required this.id,
    required this.name,
    required this.categoryId,
    required this.price,
    this.imagePath,
    this.soldCount = 0,
    required this.createdAt,
  });

  factory ProductModel.fromMap(Map<String, dynamic> map) => ProductModel(
        id: map['id'] as String,
        name: map['name'] as String,
        categoryId: map['category_id'] as String,
        price: (map['price'] as num).toDouble(),
        imagePath: map['image_path'] as String?,
        soldCount: (map['sold_count'] as num?)?.toInt() ?? 0,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'category_id': categoryId,
        'price': price,
        'image_path': imagePath,
        'sold_count': soldCount,
        'created_at': createdAt.toIso8601String(),
      };

  ProductModel copyWith({
    String? id,
    String? name,
    String? categoryId,
    double? price,
    String? imagePath,
    int? soldCount,
    DateTime? createdAt,
  }) =>
      ProductModel(
        id: id ?? this.id,
        name: name ?? this.name,
        categoryId: categoryId ?? this.categoryId,
        price: price ?? this.price,
        imagePath: imagePath ?? this.imagePath,
        soldCount: soldCount ?? this.soldCount,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, name, categoryId, price, imagePath, soldCount, createdAt];
}
