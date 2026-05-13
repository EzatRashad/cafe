import '../../data/models/category_model.dart';
import '../../../../core/database/database_helper.dart';
import 'package:uuid/uuid.dart';

abstract class CategoryRepository {
  Future<List<CategoryModel>> getCategories();
  Future<void> addCategory(CategoryModel category);
  Future<void> updateCategory(CategoryModel category);
  Future<void> deleteCategory(String id);
}

class CategoryRepositoryImpl implements CategoryRepository {
  final DatabaseHelper _db;
  final _uuid = const Uuid();

  CategoryRepositoryImpl(this._db);

  @override
  Future<List<CategoryModel>> getCategories() async {
    final rows = await _db.getCategories();
    return rows.map(CategoryModel.fromMap).toList();
  }

  @override
  Future<void> addCategory(CategoryModel category) async {
    final model = CategoryModel(
      id: _uuid.v4(),
      name: category.name,
      imagePath: category.imagePath,
      createdAt: DateTime.now(),
    );
    await _db.insertCategory(model.toMap());
  }

  @override
  Future<void> updateCategory(CategoryModel category) async {
    await _db.updateCategory(category.id, category.toMap());
  }

  @override
  Future<void> deleteCategory(String id) async {
    await _db.deleteCategory(id);
  }
}
