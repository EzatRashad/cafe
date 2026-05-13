import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/product_grid_item.dart';
import '../../../../core/utils/localization_helper.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/data/repositories/category_repository.dart';
import '../../data/models/product_model.dart';
import '../cubit/product_cubit.dart';
import '../../../../core/keyboard/widgets/cafe_text_field.dart';
import '../../../../core/keyboard/models/cafe_keyboard_type.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _search = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                Text('products'.tr(),
                    style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(width: 16),
                Expanded(
                  child: CafeTextField(
                    hintText: 'search'.tr(),
                    decoration: InputDecoration(
                      prefixIcon: const Icon(Icons.search_rounded),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
                      isDense: true,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onChanged: (v) => setState(() => _search = v),
                  ),
                ),
                const SizedBox(width: 16),
                AppButton(
                  label: 'addProduct'.tr(),
                  icon: Icons.add,
                  onPressed: () => _showDialog(context, null),
                  width: 180,
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductCubit, ProductState>(
              builder: (context, state) {
                if (state is ProductLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is ProductLoaded) {
                  final filtered = _search.isEmpty
                      ? state.products
                      : state.products
                          .where((p) => p.localizedName
                              .toLowerCase()
                              .contains(_search.toLowerCase()))
                          .toList();
                  if (filtered.isEmpty) {
                    return Center(
                      child: Text('noData'.tr(),
                          style:
                              const TextStyle(color: AppColors.textSecondary)),
                    );
                  }
                  final cols = MediaQuery.of(context).size.width >= 1200
                      ? 6
                      : MediaQuery.of(context).size.width >= 900
                          ? 4
                          : 3;
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: cols,
                        crossAxisSpacing: 12,
                        mainAxisSpacing: 12,
                        childAspectRatio: 0.75,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, i) => Stack(
                        children: [
                          ProductGridItem(product: filtered[i], onTap: () {}),
                          Positioned(
                            top: 4,
                            right: 4,
                            child: Row(
                              children: [
                                _IconBtn(
                                  icon: Icons.edit_rounded,
                                  color: AppColors.primary,
                                  onTap: () =>
                                      _showDialog(context, filtered[i]),
                                ),
                                const SizedBox(width: 4),
                                _IconBtn(
                                  icon: Icons.delete_rounded,
                                  color: AppColors.error,
                                  onTap: () =>
                                      _confirmDelete(context, filtered[i]),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                if (state is ProductError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline_rounded,
                            size: 48, color: AppColors.error),
                        const SizedBox(height: 16),
                        Text(state.message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.textSecondary)),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () =>
                              context.read<ProductCubit>().loadProducts(),
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

  void _showDialog(BuildContext context, ProductModel? existing) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ProductCubit>(),
        child: _ProductDialog(existing: existing),
      ),
    );
  }

  void _confirmDelete(BuildContext context, ProductModel product) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('deleteProduct'.tr()),
        content: Text('deleteProductConfirm'.tr(args: [product.localizedName])),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              Navigator.pop(context);
              context.read<ProductCubit>().deleteProduct(product.id);
            },
            child: Text('delete'.tr(),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  const _IconBtn(
      {required this.icon, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration:
            BoxDecoration(color: color, borderRadius: BorderRadius.circular(6)),
        child: Icon(icon, color: Colors.white, size: 16),
      ),
    );
  }
}

class _ProductDialog extends StatefulWidget {
  final ProductModel? existing;
  const _ProductDialog({this.existing});

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _nameEnCtrl = TextEditingController();
  final _nameArCtrl = TextEditingController();
  final _nameBnCtrl = TextEditingController();
  final _priceCtrl = TextEditingController();
  String? _imagePath;
  String? _selectedCategoryId;
  List<CategoryModel> _categories = [];
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
    if (widget.existing != null) {
      final p = widget.existing!;
      final names = LocalizationHelper.decodeNames(p.name);
      _nameEnCtrl.text = names['en'] ?? '';
      _nameArCtrl.text = names['ar'] ?? '';
      _nameBnCtrl.text = names['bn'] ?? '';
      _priceCtrl.text = p.price.toString();
      _imagePath = p.imagePath;
      _selectedCategoryId = p.categoryId;
    }
  }

  Future<void> _loadCategories() async {
    final cats = await sl<CategoryRepository>().getCategories();
    if (mounted) setState(() => _categories = cats);
  }

  @override
  void dispose() {
    _nameEnCtrl.dispose();
    _nameArCtrl.dispose();
    _nameBnCtrl.dispose();
    _priceCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.existing == null ? 'addProduct'.tr() : 'editProduct'.tr()),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 100,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppColors.accent.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3)),
                  ),
                  child: _imagePath != null && File(_imagePath!).existsSync()
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child:
                              Image.file(File(_imagePath!), fit: BoxFit.cover))
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.add_photo_alternate_rounded,
                                size: 32, color: AppColors.accent),
                            Text('tapToSelectImage'.tr(),
                                style:
                                    const TextStyle(color: AppColors.accent)),
                          ],
                        ),
                ),
              ),
              const SizedBox(height: 12),
              AppTextField(label: 'englishName'.tr(), controller: _nameEnCtrl),
              const SizedBox(height: 8),
              AppTextField(label: 'arabicName'.tr(), controller: _nameArCtrl),
              const SizedBox(height: 8),
              AppTextField(label: 'bengaliName'.tr(), controller: _nameBnCtrl),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _selectedCategoryId,
                decoration: InputDecoration(
                  labelText: 'category'.tr(),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                items: _categories
                    .map((c) => DropdownMenuItem(
                        value: c.id, child: Text(c.localizedName)))
                    .toList(),
                onChanged: (v) => setState(() => _selectedCategoryId = v),
              ),
              const SizedBox(height: 12),
              AppTextField(
                  label: 'price'.tr(),
                  controller: _priceCtrl,
                  keyboardType: TextInputType.number),
              const SizedBox(height: 12),
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

  Future<void> _pickImage() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _imagePath = picked.path);
  }

  Future<void> _save() async {
    final en = _nameEnCtrl.text.trim();
    final ar = _nameArCtrl.text.trim();
    final bn = _nameBnCtrl.text.trim();
    if (en.isEmpty && ar.isEmpty && bn.isEmpty) return;
    if (_selectedCategoryId == null) return;

    setState(() => _saving = true);
    final finalName = LocalizationHelper.encodeNames(
        en: en, ar: ar, bn: _nameBnCtrl.text.trim());
    final cubit = context.read<ProductCubit>();
    final product = ProductModel(
      id: widget.existing?.id ?? '',
      name: finalName,
      categoryId: _selectedCategoryId!,
      price: double.tryParse(_priceCtrl.text) ?? 0,
      imagePath: _imagePath,
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    if (widget.existing == null) {
      await cubit.addProduct(product);
    } else {
      await cubit.updateProduct(product);
    }
    if (mounted) Navigator.pop(context);
  }
}
