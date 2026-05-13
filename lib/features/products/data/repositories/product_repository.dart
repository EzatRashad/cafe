import '../../data/models/product_model.dart';
import '../../../../core/database/database_helper.dart';
import 'package:uuid/uuid.dart';

abstract class ProductRepository {
  Future<List<ProductModel>> getProducts({String? categoryId});

  Future<void> addProduct(ProductModel product);
  Future<void> updateProduct(ProductModel product);
  Future<void> deleteProduct(String id);
}

class ProductRepositoryImpl implements ProductRepository {
  final DatabaseHelper _db;
  final _uuid = const Uuid();

  ProductRepositoryImpl(this._db);

  @override
  Future<List<ProductModel>> getProducts({String? categoryId}) async {
    final rows = await _db.getProducts(categoryId: categoryId);
    return rows.map(ProductModel.fromMap).toList();
  }


  @override
  Future<void> addProduct(ProductModel product) async {
    final model = ProductModel(
      id: _uuid.v4(),
      name: product.name,
      categoryId: product.categoryId,
      price: product.price,
      imagePath: product.imagePath,
      soldCount: 0,

      createdAt: DateTime.now(),
    );
    await _db.insertProduct(model.toMap());
  }

  @override
  Future<void> updateProduct(ProductModel product) async {
    await _db.updateProduct(product.id, product.toMap());
  }

  @override
  Future<void> deleteProduct(String id) async {
    await _db.deleteProduct(id);
  }
}
