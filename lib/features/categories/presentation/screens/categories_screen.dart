import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../data/models/category_model.dart';
import '../cubit/category_cubit.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          _Header(onAdd: () => _showDialog(context, null)),
          Expanded(
            child: BlocBuilder<CategoryCubit, CategoryState>(
              builder: (context, state) {
                if (state is CategoryLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is CategoryLoaded) {
                  if (state.categories.isEmpty) {
                    return _EmptyState(onAdd: () => _showDialog(context, null));
                  }
                  return _CategoryGrid(
                    categories: state.categories,
                    onEdit: (cat) => _showDialog(context, cat),
                    onDelete: (cat) => _confirmDelete(context, cat),
                  );
                }
                if (state is CategoryError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () => context.read<CategoryCubit>().loadCategories(),
                          child: Text('retry'.tr()),
                        ),
                      ],
                    ),
                  );
                }
                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDialog(BuildContext context, CategoryModel? existing) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<CategoryCubit>(),
        child: _CategoryDialog(existing: existing),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CategoryModel cat) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('deleteCategory'.tr()),
        content: Text('deleteCategoryConfirm'.tr(args: [cat.localizedName])),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr()),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              context.read<CategoryCubit>().deleteCategory(cat.id);
            },
            child: Text('delete'.tr(),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final VoidCallback onAdd;
  const _Header({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text('categories'.tr(),
              style: Theme.of(context).textTheme.headlineMedium),
          const Spacer(),
          AppButton(
              label: 'addCategory'.tr(),
              icon: Icons.add,
              onPressed: onAdd,
              width: 200),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final VoidCallback onAdd;
  const _EmptyState({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category_rounded,
              size: 80, color: AppColors.primaryLight),
          const SizedBox(height: 16),
          Text('noCategories'.tr(),
              style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 24),
          AppButton(
              label: 'addCategory'.tr(),
              icon: Icons.add,
              onPressed: onAdd,
              width: 180),
        ],
      ),
    );
  }
}

class _CategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final void Function(CategoryModel) onEdit;
  final void Function(CategoryModel) onDelete;

  const _CategoryGrid(
      {required this.categories, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.of(context).size.width >= 900 ? 5 : 3;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: GridView.builder(
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: cols,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemCount: categories.length,
        itemBuilder: (context, i) => _CategoryTile(
          category: categories[i],
          onEdit: () => onEdit(categories[i]),
          onDelete: () => onDelete(categories[i]),
        ),
      ),
    );
  }
}

class _CategoryTile extends StatelessWidget {
  final CategoryModel category;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _CategoryTile(
      {required this.category, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onEdit,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.category_rounded, size: 48, color: AppColors.accent),
          const SizedBox(height: 12),
          Text(
            category.localizedName,
            style: const TextStyle(fontWeight: FontWeight.w600),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.edit_rounded, size: 18),
                onPressed: onEdit,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: AppColors.primary,
              ),
              const SizedBox(width: 12),
              IconButton(
                icon: const Icon(Icons.delete_rounded, size: 18),
                onPressed: onDelete,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                color: AppColors.error,
              ),
            ],
          ),
        ],
      ),
    );
  }


}

class _CategoryDialog extends StatefulWidget {
  final CategoryModel? existing;
  const _CategoryDialog({this.existing});

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _nameEnCtrl = TextEditingController();
  final _nameArCtrl = TextEditingController();
  final _nameBnCtrl = TextEditingController();
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      final names = LocalizationHelper.decodeNames(widget.existing!.name);
      _nameEnCtrl.text = names['en'] ?? '';
      _nameArCtrl.text = names['ar'] ?? '';
      _nameBnCtrl.text = names['bn'] ?? '';

    }
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameArCtrl.dispose();
    _nameBnCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.existing == null ? 'addCategory'.tr() : 'editCategory'.tr()),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [

              AppTextField(
                label: 'englishName'.tr(),
                controller: _nameEnCtrl,
              ),
              const SizedBox(height: 8),
              AppTextField(
                label: 'arabicName'.tr(),
                controller: _nameArCtrl,
              ),
              const SizedBox(height: 8),
              AppTextField(
                label: 'bengaliName'.tr(),
                controller: _nameBnCtrl,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('cancel'.tr())),
        AppButton(
          label: widget.existing == null ? 'add'.tr() : 'save'.tr(),
          isLoading: _saving,
          width: 100,
          onPressed: _save,
        ),
      ],
    );
  }



  Future<void> _save() async {
    final en = _nameEnCtrl.text.trim();
    final ar = _nameArCtrl.text.trim();
    final bn = _nameBnCtrl.text.trim();
    if (en.isEmpty && ar.isEmpty && bn.isEmpty) return;

    setState(() => _saving = true);
    final finalName = LocalizationHelper.encodeNames(en: en, ar: ar, bn: bn);
    final cubit = context.read<CategoryCubit>();

    if (widget.existing == null) {
      await cubit.addCategory(CategoryModel(
        id: '',
        name: finalName,
        imagePath: null,
        createdAt: DateTime.now(),
      ));
    } else {
      await cubit.updateCategory(widget.existing!.copyWith(
        name: finalName,
        imagePath: null,
      ));
    }
    if (mounted) Navigator.pop(context);
  }
}
