import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../database/database_helper.dart';
import '../storage/storage_service.dart';
import '../utils/backup_service.dart';
import '../../features/setup/presentation/cubit/storage_cubit.dart';
import '../../features/auth/data/repositories/auth_repository.dart';
import '../../features/categories/data/repositories/category_repository.dart';
import '../../features/products/data/repositories/product_repository.dart';
import '../../features/billing/data/repositories/invoice_repository.dart';
import '../../features/expenses/data/repositories/expense_repository.dart';
import '../printer/printer_service.dart';
import '../printer/receipt_generator.dart';
import '../../features/settings/presentation/cubit/printer_cubit.dart';

import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/categories/presentation/cubit/category_cubit.dart';
import '../../features/products/presentation/cubit/product_cubit.dart';
import '../../features/billing/presentation/cubit/billing_cubit.dart';
import '../../features/invoice_history/presentation/cubit/invoice_history_cubit.dart';
import '../../features/expenses/presentation/cubit/expense_cubit.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';

import '../../features/settings/presentation/cubit/settings_cubit.dart';
import '../keyboard/cubit/keyboard_cubit.dart';

final sl = GetIt.instance;

Future<void> setupLocator() async {
  // External
  final prefs = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => prefs);

  // Core
  sl.registerLazySingleton<DatabaseHelper>(() => DatabaseHelper());
  sl.registerLazySingleton<StorageService>(() => StorageService(sl()));
  sl.registerLazySingleton<BackupService>(
      () => BackupService(sl<DatabaseHelper>()));
  sl.registerLazySingleton<PrinterService>(() => PrinterService());
  sl.registerLazySingleton<ReceiptGenerator>(() => ReceiptGenerator());

  // Cubits
  sl.registerLazySingleton<StorageCubit>(() => StorageCubit(sl(), sl()));
  sl.registerLazySingleton<PrinterCubit>(() => PrinterCubit(sl(), sl(), sl()));

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepositoryImpl(sl()));
  sl.registerLazySingleton<CategoryRepository>(
      () => CategoryRepositoryImpl(sl()));
  sl.registerLazySingleton<ProductRepository>(
      () => ProductRepositoryImpl(sl()));
  sl.registerLazySingleton<InvoiceRepository>(
      () => InvoiceRepositoryImpl(sl()));
  sl.registerLazySingleton<ExpenseRepository>(
      () => ExpenseRepositoryImpl(sl()));

  // Cubit Singletons (App-wide scope)
  sl.registerLazySingleton<AuthCubit>(() => AuthCubit(sl()));

  // Cubits - registered as factories so each page gets fresh instances
  sl.registerFactory<CategoryCubit>(() => CategoryCubit(sl()));
  sl.registerFactory<ProductCubit>(() => ProductCubit(sl()));
  sl.registerFactory<BillingCubit>(() => BillingCubit(sl()));
  sl.registerFactory<InvoiceHistoryCubit>(() => InvoiceHistoryCubit(sl()));
  sl.registerFactory<ExpenseCubit>(() => ExpenseCubit(sl()));
  sl.registerFactory<DashboardCubit>(() => DashboardCubit(sl()));

  // Settings - singleton so theme/language persist across navigation
  sl.registerLazySingleton<SettingsCubit>(() => SettingsCubit());

  // Keyboard
  sl.registerLazySingleton<KeyboardCubit>(() => KeyboardCubit());
}
