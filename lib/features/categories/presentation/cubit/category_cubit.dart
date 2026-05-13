import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/category_model.dart';
import '../../data/repositories/category_repository.dart';

part 'category_state.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository _repo;

  CategoryCubit(this._repo) : super(CategoryInitial());

  Future<void> loadCategories() async {
    emit(CategoryLoading());
    try {
      final cats = await _repo.getCategories();
      emit(CategoryLoaded(cats));
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> addCategory(CategoryModel category) async {
    try {
      await _repo.addCategory(category);
      await loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> updateCategory(CategoryModel category) async {
    try {
      await _repo.updateCategory(category);
      await loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }

  Future<void> deleteCategory(String id) async {
    try {
      await _repo.deleteCategory(id);
      await loadCategories();
    } catch (e) {
      emit(CategoryError(e.toString()));
    }
  }
}
