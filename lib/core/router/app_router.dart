import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/presentation/cubit/auth_cubit.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/auth/presentation/screens/create_password_screen.dart';
import '../../features/categories/presentation/cubit/category_cubit.dart';
import '../../features/categories/presentation/screens/categories_screen.dart';
import '../../features/products/presentation/cubit/product_cubit.dart';
import '../../features/products/presentation/screens/products_screen.dart';
import '../../features/billing/presentation/cubit/billing_cubit.dart';
import '../../features/billing/presentation/screens/billing_screen.dart';
import '../../features/invoice_history/presentation/cubit/invoice_history_cubit.dart';
import '../../features/invoice_history/presentation/screens/invoice_history_screen.dart';
import '../../features/expenses/presentation/cubit/expense_cubit.dart';
import '../../features/expenses/presentation/screens/expenses_screen.dart';
import '../../features/dashboard/presentation/cubit/dashboard_cubit.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';

import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/settings/presentation/screens/tax_settings_screen.dart';
import '../../features/setup/presentation/cubit/storage_cubit.dart';
import '../../features/setup/presentation/screens/setup_screen.dart';
import '../../shared/widgets/app_shell.dart';
import '../di/service_locator.dart';

class AppRoutes {
  static const String login = '/login';
  static const String createPassword = '/create-password';
  static const String dashboard = '/dashboard';
  static const String categories = '/categories';
  static const String products = '/products';
  static const String billing = '/billing';
  static const String invoiceHistory = '/invoice-history';
  static const String expenses = '/expenses';

  static const String settings = '/settings';
  static const String taxSettings = '/tax-settings';
  static const String setup = '/setup';
}

GoRouter createRouter(AuthCubit authCubit, StorageCubit storageCubit) {
  return GoRouter(
    initialLocation: AppRoutes.dashboard,
    redirect: (context, state) async {
      final storageState = storageCubit.state;
      final isSetupRoute = state.matchedLocation == AppRoutes.setup;

      // 1. Storage setup takes absolute priority
      if (storageState is! StorageReady) {
        return isSetupRoute ? null : AppRoutes.setup;
      }
      if (isSetupRoute) {
        return AppRoutes.dashboard;
      }

      // 2. Auth logic
      final authState = authCubit.state;
      final isAuthRoute = state.matchedLocation == AppRoutes.login ||
          state.matchedLocation == AppRoutes.createPassword;

      if (authState is AuthNeedsSetup) {
        return isAuthRoute ? null : AppRoutes.createPassword;
      }
      if (authState is AuthNeedsLogin) {
        return isAuthRoute ? null : AppRoutes.login;
      }
      if (authState is AuthAuthenticated) {
        return isAuthRoute ? AppRoutes.dashboard : null;
      }
      return null;
    },
    refreshListenable: Listenable.merge([
      GoRouterRefreshStream(authCubit.stream),
      GoRouterRefreshStream(storageCubit.stream),
    ]),
    routes: [
      GoRoute(
        path: AppRoutes.setup,
        builder: (context, state) => const SetupScreen(),
      ),
      GoRoute(
        path: AppRoutes.createPassword,
        builder: (context, state) => const CreatePasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.dashboard,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<DashboardCubit>()..load(),
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.categories,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<CategoryCubit>()..loadCategories(),
              child: const CategoriesScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.products,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<ProductCubit>()..loadProducts(),
              child: const ProductsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.billing,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<BillingCubit>(),
              child: const BillingScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.invoiceHistory,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<InvoiceHistoryCubit>()..load(),
              child: const InvoiceHistoryScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.expenses,
            builder: (context, state) => BlocProvider(
              create: (_) => sl<ExpenseCubit>()..load(),
              child: const ExpensesScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            builder: (context, state) => const SettingsScreen(),
          ),
          GoRoute(
            path: AppRoutes.taxSettings,
            builder: (context, state) => const TaxSettingsScreen(),
          ),
        ],
      ),
    ],
  );
}

/// Bridges a Bloc stream to GoRouter's Listenable interface
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream stream) {
    _sub = stream.listen((_) => notifyListeners());
  }

  late final dynamic _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}
