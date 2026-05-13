import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../cubit/storage_cubit.dart';

class SetupScreen extends StatelessWidget {
  const SetupScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: BlocConsumer<StorageCubit, StorageState>(
        listener: (context, state) {
          if (state is StorageError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text(state.message),
                  backgroundColor: AppColors.error),
            );
          }
        },
        builder: (context, state) {
          return Center(
            child: AppCard(
              width: 500,
              padding: const EdgeInsets.all(40),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.folder_shared_rounded,
                      size: 80, color: AppColors.primary),
                  const SizedBox(height: 24),
                  Text(
                    'setupTitle'.tr(),
                    style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.primary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'setupSubtitle'.tr(),
                    style: const TextStyle(color: AppColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  if (state is StorageLoading)
                    const CircularProgressIndicator()
                  else ...[
                    AppButton(
                      label: 'selectFolder'.tr(),
                      icon: Icons.drive_file_move_rounded,
                      onPressed: () =>
                          context.read<StorageCubit>().selectAndConfirmFolder(),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () =>
                          context.read<StorageCubit>().useDefaultStorage(),
                      child: Text('useDefaultStorage'.tr(),
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                  if (state is StorageReady) ...[
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.check_circle,
                            color: AppColors.success, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            '${'selectedPath'.tr()} ${state.path}',
                            style: const TextStyle(
                                fontSize: 12, color: AppColors.textSecondary),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
