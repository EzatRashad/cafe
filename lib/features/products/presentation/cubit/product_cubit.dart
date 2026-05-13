import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/product_model.dart';
import '../../data/repositories/product_repository.dart';

part 'product_state.dart';

class ProductCubit extends Cubit<ProductState> {
  final ProductRepository _repo;

  ProductCubit(this._repo) : super(ProductInitial());

  Future<void> loadProducts({String? categoryId}) async {
    emit(ProductLoading());
    try {
      final products = await _repo.getProducts(categoryId: categoryId);
      emit(ProductLoaded(products));
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> addProduct(ProductModel product) async {
    try {
      await _repo.addProduct(product);
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> updateProduct(ProductModel product) async {
    try {
      await _repo.updateProduct(product);
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

  Future<void> deleteProduct(String id) async {
    try {
      await _repo.deleteProduct(id);
      await loadProducts();
    } catch (e) {
      emit(ProductError(e.toString()));
    }
  }

}
