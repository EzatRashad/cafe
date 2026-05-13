import 'package:equatable/equatable.dart';
import '../../../../core/utils/localization_helper.dart';

class CategoryModel extends Equatable {
  final String id;
  final String name;
  final String? imagePath;
  final DateTime createdAt;

  String get localizedName => LocalizationHelper.getLocalizedName(name);

  const CategoryModel({
    required this.id,
    required this.name,
    this.imagePath,
    required this.createdAt,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) => CategoryModel(
        id: map['id'] as String,
        name: map['name'] as String,
        imagePath: map['image_path'] as String?,
        createdAt: DateTime.parse(map['created_at'] as String),
      );

  Map<String, dynamic> toMap() => {
        'id': id,
        'name': name,
        'image_path': imagePath,
        'created_at': createdAt.toIso8601String(),
      };

  CategoryModel copyWith({String? id, String? name, String? imagePath, DateTime? createdAt}) =>
      CategoryModel(
        id: id ?? this.id,
        name: name ?? this.name,
        imagePath: imagePath ?? this.imagePath,
        createdAt: createdAt ?? this.createdAt,
      );

  @override
  List<Object?> get props => [id, name, imagePath, createdAt];
}
