import 'dart:io';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';
import 'core/di/service_locator.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/setup/presentation/cubit/storage_cubit.dart';
import 'features/settings/presentation/cubit/printer_cubit.dart';
import 'features/settings/presentation/cubit/settings_cubit.dart';
import 'core/keyboard/cubit/keyboard_cubit.dart';
import 'core/keyboard/keyboard_overlay.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  await setupLocator();

  if (Platform.isWindows || Platform.isLinux) {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  }

  // Initialize storage first
  final storageCubit = sl<StorageCubit>();
  await storageCubit.init();

  // Pre-load settings
  await sl<SettingsCubit>().loadSettings();

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('ar'), Locale('bn')],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const CafeApp(),
    ),
  );
}

class CafeApp extends StatefulWidget {
  const CafeApp({super.key});

  @override
  State<CafeApp> createState() => _CafeAppState();
}

class _CafeAppState extends State<CafeApp> {
  late final AuthCubit _authCubit;

  @override
  void initState() {
    super.initState();
    _authCubit = sl<AuthCubit>();
    // Delay checkAuth until we know storage is ready to avoid opening the wrong DB
    final storageCubit = sl<StorageCubit>();
    if (storageCubit.state is StorageReady) {
      _authCubit.checkAuth();
    }
  }

  @override
  void dispose() {
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
        providers: [
          BlocProvider.value(value: _authCubit),
          BlocProvider.value(value: sl<PrinterCubit>()..loadPrinters()),
          BlocProvider.value(value: sl<SettingsCubit>()),
          BlocProvider.value(value: sl<StorageCubit>()),
          BlocProvider.value(value: sl<KeyboardCubit>()),
        ],
        child: BlocListener<StorageCubit, StorageState>(
          listener: (context, state) {
            if (state is StorageReady) {
              _authCubit.checkAuth();
            }
          },
          child: BlocBuilder<SettingsCubit, SettingsState>(
            builder: (context, settings) {
              final router = createRouter(_authCubit, sl<StorageCubit>());
              return MaterialApp.router(
                title: 'Café Egypt',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: settings.themeMode,
                locale: context.locale,
                supportedLocales: context.supportedLocales,
                localizationsDelegates: context.localizationDelegates,
                routerConfig: router,
                builder: (context, child) => KeyboardOverlay(
                  child: GestureDetector(
                    onTap: () {
                      final currentFocus = FocusScope.of(context);
                      if (!currentFocus.hasPrimaryFocus &&
                          currentFocus.hasFocus) {
                        FocusManager.instance.primaryFocus?.unfocus();
                      }
                    },
                    behavior: HitTestBehavior.translucent,
                    child: child ?? const SizedBox.shrink(),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
