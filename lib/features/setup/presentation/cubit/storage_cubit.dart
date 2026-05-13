import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/storage/storage_service.dart';
import '../../../../core/database/database_helper.dart';

abstract class StorageState extends Equatable {
  @override
  List<Object?> get props => [];
}

class StorageInitial extends StorageState {}

class StorageLoading extends StorageState {}

class StorageRequired extends StorageState {}

class StorageChecking extends StorageState {}

class StorageReady extends StorageState {
  final String path;
  StorageReady(this.path);
  @override
  List<Object?> get props => [path];
}

class StorageError extends StorageState {
  final String message;
  StorageError(this.message);
  @override
  List<Object?> get props => [message];
}

class StorageCubit extends Cubit<StorageState> {
  final StorageService _storageService;
  final DatabaseHelper _dbHelper;

  StorageCubit(this._storageService, this._dbHelper) : super(StorageInitial());

  String? get currentPath => _storageService.getStoredPath();

  Future<void> init() async {
    emit(StorageChecking());
    final storedPath = _storageService.getStoredPath();

    if (storedPath != null && _storageService.isPathValid(storedPath)) {
      await _dbHelper.initPath(_storageService.getDatabasePath(storedPath));
      emit(StorageReady(storedPath));
    } else {
      emit(StorageRequired());
    }
  }

  Future<void> selectAndConfirmFolder() async {
    try {
      emit(StorageLoading());
      final selectedPath = await _storageService.pickDirectory();

      if (selectedPath != null) {
        await _storageService.setupDirectories(selectedPath);
        await _storageService.setStoredPath(selectedPath);

        await _dbHelper.initPath(_storageService.getDatabasePath(selectedPath));
        emit(StorageReady(selectedPath));
      } else {
        emit(StorageRequired());
      }
    } catch (e) {
      emit(StorageError(e.toString()));
    }
  }

  Future<void> useDefaultStorage() async {
    try {
      emit(StorageLoading());
      final defaultPath = await _storageService.getDefaultPath();
      await _storageService.setupDirectories(defaultPath);
      await _storageService.setStoredPath(defaultPath);

      await _dbHelper.initPath(_storageService.getDatabasePath(defaultPath));
      emit(StorageReady(defaultPath));
    } catch (e) {
      emit(StorageError(e.toString()));
    }
  }

  Future<void> changeStoragePath() async {
    emit(StorageRequired());
  }
}
