import 'package:cafe/core/printer/printer_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../cubit/settings_cubit.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/data/repositories/auth_repository.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import '../../../setup/presentation/cubit/storage_cubit.dart';
import '../../../../core/utils/backup_service.dart';
import '../../../../core/storage/storage_service.dart';
import '../cubit/printer_cubit.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<PrinterCubit, PrinterState>(
      listener: (context, state) {
        if (state is PrinterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message), backgroundColor: AppColors.error),
          );
        } else if (state is PrinterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text(state.message),
                backgroundColor: AppColors.success),
          );
        }
      },
      child: BlocBuilder<SettingsCubit, SettingsState>(
        builder: (context, settings) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 640),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('settings'.tr(),
                        style: Theme.of(context).textTheme.headlineMedium),
                    const SizedBox(height: 24),

                    // Appearance
                    _SectionTitle('appearance'.tr()),
                    AppCard(
                      child: Column(
                        children: [
                          SwitchListTile(
                            value: settings.isDark,
                            onChanged: (_) =>
                                context.read<SettingsCubit>().toggleTheme(),
                            title: Text('darkMode'.tr()),
                            subtitle: Text(settings.isDark
                                ? 'darkMode'.tr()
                                : 'lightMode'.tr()),
                            secondary: Icon(
                              settings.isDark
                                  ? Icons.dark_mode_rounded
                                  : Icons.light_mode_rounded,
                              color: AppColors.accent,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Language
                    _SectionTitle('language'.tr()),
                    AppCard(
                      child: Column(
                        children: [
                          _LangTile(
                              code: 'en',
                              label: 'english'.tr(),
                              flag: '🇬🇧',
                              current: context.locale.languageCode),
                          const Divider(height: 1),
                          _LangTile(
                              code: 'ar',
                              label: 'arabic'.tr(),
                              flag: '🇸🇦',
                              current: context.locale.languageCode),
                          const Divider(height: 1),
                          _LangTile(
                              code: 'bn',
                              label: 'bengali'.tr(),
                              flag: '🇧🇩',
                              current: context.locale.languageCode),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Security
                    _SectionTitle('security'.tr()),
                    AppCard(
                      child: ListTile(
                        leading: const Icon(Icons.lock_outline_rounded,
                            color: AppColors.primary),
                        title: Text('changePassword'.tr()),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 16),
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Storage Location
                    _SectionTitle('storageLocation'.tr()),
                    BlocBuilder<StorageCubit, StorageState>(
                      builder: (context, state) {
                        final path = state is StorageReady ? state.path : '...';
                        return AppCard(
                          child: ListTile(
                            leading: const Icon(Icons.folder_open_rounded,
                                color: AppColors.primary),
                            title: Text(path),
                            subtitle: Text('changeStoragePath'.tr(),
                                style: const TextStyle(fontSize: 11)),
                            trailing: const Icon(Icons.edit_rounded, size: 16),
                            onTap: () => context
                                .read<StorageCubit>()
                                .changeStoragePath(),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Data Management
                    _SectionTitle('dataManagement'.tr()),
                    AppCard(
                      child: Column(
                        children: [
                          ListTile(
                            leading: const Icon(Icons.backup_rounded,
                                color: AppColors.success),
                            title: Text('backup'.tr()),
                            onTap: () => _handleBackup(context),
                          ),
                          const Divider(height: 1),
                          ListTile(
                            leading: const Icon(Icons.restore_rounded,
                                color: AppColors.accent),
                            title: Text('restore'.tr()),
                            onTap: () => _handleRestore(context),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Billing Settings
                    _SectionTitle('taxSettings'.tr()),
                    AppCard(
                      child: ListTile(
                        leading: const Icon(Icons.receipt_long_rounded,
                            color: AppColors.primary),
                        title: Text('taxSettings'.tr()),
                        trailing: const Icon(Icons.arrow_forward_ios_rounded,
                            size: 16),
                        onTap: () => context.push(AppRoutes.taxSettings),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Printer Settings
                    _SectionTitle('إعدادات الطابعة'),
                    BlocBuilder<PrinterCubit, PrinterState>(
                      builder: (context, state) {
                        if (state is PrinterLoading)
                          return const Center(
                              child: CircularProgressIndicator());

                        final List<PrinterModel> printers =
                            state is PrinterLoaded ? state.printers : [];
                        final String? selected = state is PrinterLoaded
                            ? state.selectedPrinter
                            : null;

                        return AppCard(
                          child: Column(
                            children: [
                              DropdownButtonFormField<String>(
                                value: (selected != null &&
                                        printers.any((p) => p.name == selected))
                                    ? selected
                                    : null,
                                isExpanded: true,
                                decoration: const InputDecoration(
                                  labelText: 'اختر الطابعة (USB/Thermal)',
                                  prefixIcon: Icon(Icons.print_rounded),
                                ),
                                hint: Text(printers.isEmpty
                                    ? 'لم يتم العثور على طابعات'
                                    : 'اختر طابعة الفواتير'),
                                items: printers.map((PrinterModel p) {
                                  return DropdownMenuItem<String>(
                                    value: p.name,
                                    child: Text(p.displayName),
                                  );
                                }).toList(),
                                onChanged: (String? val) {
                                  if (val != null) {
                                    context
                                        .read<PrinterCubit>()
                                        .selectPrinter(val);
                                  }
                                },
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  Expanded(
                                    child: AppButton(
                                      label: 'تحديث القائمة',
                                      icon: Icons.refresh_rounded,
                                      isOutlined: true,
                                      onPressed: () => context
                                          .read<PrinterCubit>()
                                          .loadPrinters(),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: AppButton(
                                      label: 'طباعة تجربة',
                                      icon: Icons.print_rounded,
                                      onPressed: selected == null
                                          ? null
                                          : () => context
                                              .read<PrinterCubit>()
                                              .testPrint(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),

                    // Logout
                    AppButton(
                      label: 'logout'.tr(),
                      icon: Icons.logout_rounded,
                      color: AppColors.error,
                      onPressed: () => _confirmLogout(context),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleBackup(BuildContext context) async {
    try {
      final storageCubit = context.read<StorageCubit>();
      final state = storageCubit.state;
      if (state is! StorageReady) return;

      final backupService = sl<BackupService>();
      final storageService = sl<StorageService>();
      final backupPath = storageService.getBackupPath(state.path);

      await backupService.exportToJson(backupPath);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('backupSuccess'.tr()),
              backgroundColor: AppColors.success),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('backupError'.tr()),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  Future<void> _handleRestore(BuildContext context) async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);
        await sl<BackupService>().importFromJson(file);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('restoreSuccess'.tr()),
                backgroundColor: AppColors.success),
          );
          // Reload essential data or app
          context.go(AppRoutes.dashboard);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('restoreError'.tr()),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('logout'.tr()),
        content: Text('logoutConfirm'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthCubit>().logout();
            },
            child: Text('logout'.tr(),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    final ctrl = TextEditingController();
    final confirmCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('changePassword'.tr()),
        content: SizedBox(
          width: 320,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                  label: 'newPassword'.tr(),
                  controller: ctrl,
                  obscureText: true),
              const SizedBox(height: 12),
              AppTextField(
                  label: 'confirmPassword'.tr(),
                  controller: confirmCtrl,
                  obscureText: true),
            ],
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr())),
          AppButton(
            label: 'save'.tr(),
            width: 90,
            onPressed: () async {
              if (ctrl.text.length >= 4 && ctrl.text == confirmCtrl.text) {
                await sl<AuthRepository>().createPassword(ctrl.text);
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('passwordChanged'.tr())));
                }
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String text;
  const _SectionTitle(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
              )),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String code, label, flag, current;
  const _LangTile(
      {required this.code,
      required this.label,
      required this.flag,
      required this.current});

  @override
  Widget build(BuildContext context) {
    final selected = code == current;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(label),
      trailing: selected
          ? const Icon(Icons.check_circle_rounded, color: AppColors.accent)
          : const Icon(Icons.radio_button_unchecked_rounded,
              color: AppColors.textSecondary),
      onTap: () {
        context.read<SettingsCubit>().setLanguage(code);
        context.setLocale(Locale(code));
      },
    );
  }
}
