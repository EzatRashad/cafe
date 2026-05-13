import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/di/service_locator.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../../shared/widgets/product_grid_item.dart';
import '../../../categories/data/models/category_model.dart';
import '../../../categories/data/repositories/category_repository.dart';
import '../../../products/data/models/product_model.dart';
import '../../../products/data/repositories/product_repository.dart';
import '../cubit/billing_cubit.dart';
import '../../../settings/presentation/cubit/printer_cubit.dart';
import '../../data/models/invoice_model.dart';
import '../../../settings/presentation/cubit/settings_cubit.dart';
import '../../../../core/keyboard/widgets/cafe_text_field.dart';
import '../../../../core/keyboard/models/cafe_keyboard_type.dart';

class BillingScreen extends StatefulWidget {
  const BillingScreen({super.key});
  @override
  State<BillingScreen> createState() => _BillingScreenState();
}

class _BillingScreenState extends State<BillingScreen> {
  List<CategoryModel> _categories = [];
  List<ProductModel> _products = [];
  String? _selectedCategoryId;
  bool _loadingData = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final cats = await sl<CategoryRepository>().getCategories();
    final prods = await sl<ProductRepository>().getProducts();
    if (mounted) {
      setState(() {
        _categories = cats;
        _products = prods;
        _selectedCategoryId = cats.isNotEmpty ? cats.first.id : null;
        _loadingData = false;
      });
    }
  }

  List<ProductModel> get _filteredProducts => _selectedCategoryId == null
      ? _products
      : _products.where((p) => p.categoryId == _selectedCategoryId).toList();

  @override
  Widget build(BuildContext context) {
    final isDesktop = MediaQuery.of(context).size.width >= 900;
    return BlocListener<PrinterCubit, PrinterState>(
      listener: (context, printerState) {
        if (printerState is PrinterError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(printerState.message),
              backgroundColor: AppColors.error,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else if (printerState is PrinterSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(printerState.message),
              backgroundColor: AppColors.success,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      },
      child: BlocConsumer<BillingCubit, BillingState>(
        listener: (context, state) {
          if (state.lastSavedMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.lastSavedMessage!.tr())),
            );
            if (state.lastSavedInvoice != null) {
              _showPrintConfirmDialog(context, state.lastSavedInvoice!);
              context.read<BillingCubit>().clearLastSaved();
            }
          }
        },
        builder: (context, state) {
          if (_loadingData) return const Center(child: CircularProgressIndicator());

          final cubit = context.read<BillingCubit>();

          if (isDesktop) {
            return Row(
              children: [
                Expanded(flex: 3, child: _ProductPanel(
                  categories: _categories,
                  products: _filteredProducts,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (id) => setState(() => _selectedCategoryId = id),
                  onProductTap: (p) {
                    if (state.activeTabIndex == -1) {
                      _showRenameDialog(context, -1, '', initialProduct: p);
                    } else {
                      cubit.addProductToCurrentTab(p);
                    }
                  },
                )),
                SizedBox(width: 340, child: _InvoicePanel(state: state, onShowRename: _showRenameDialog)),
              ],
            );
          }

          return Column(
            children: [
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.55,
                child: _ProductPanel(
                  categories: _categories,
                  products: _filteredProducts,
                  selectedCategoryId: _selectedCategoryId,
                  onCategorySelected: (id) => setState(() => _selectedCategoryId = id),
                  onProductTap: (p) {
                    if (state.activeTabIndex == -1) {
                      _showRenameDialog(context, -1, '', initialProduct: p);
                    } else {
                      cubit.addProductToCurrentTab(p);
                    }
                  },
                ),
              ),
              Expanded(child: _InvoicePanel(state: state, onShowRename: _showRenameDialog)),
            ],
          );
        },
      ),
    );
  }

  void _showPrintConfirmDialog(BuildContext context, InvoiceModel invoice) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: Text('invoiceSavedSuccess'.tr(), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo')),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.print_rounded, size: 48, color: AppColors.primary),
            const SizedBox(height: 16),
            Text('confirmPrint'.tr(), textAlign: TextAlign.center, style: const TextStyle(fontFamily: 'Cairo')),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('close'.tr(), style: const TextStyle(fontFamily: 'Cairo')),
          ),
          AppButton(
            label: 'print'.tr(),
            width: 100,
            onPressed: () {
              context.read<PrinterCubit>().printInvoice(invoice);
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(BuildContext context, int index, String currentName, {ProductModel? initialProduct}) {
    final ctrl = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(index == -1 ? 'newInvoice'.tr() : 'rename'.tr()),
        content: CafeTextField(
          controller: ctrl,
          hintText: 'enterName'.tr(),
          autofocus: false,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
          ElevatedButton(
            onPressed: () {
              final name = ctrl.text.trim();
              if (index == -1) {
                context.read<BillingCubit>().addTab(label: name.isEmpty ? null : name);
                if (initialProduct != null) {
                  context.read<BillingCubit>().addProductToCurrentTab(initialProduct);
                }
              } else {
                if (name.isNotEmpty) {
                  context.read<BillingCubit>().renameTab(index, name);
                }
              }
              Navigator.pop(ctx);
            },
            child: Text('save'.tr()),
          ),
        ],
      ),
    );
  }
}

class _ProductPanel extends StatelessWidget {
  final List<CategoryModel> categories;
  final List<ProductModel> products;
  final String? selectedCategoryId;
  final void Function(String?) onCategorySelected;
  final void Function(ProductModel) onProductTap;

  const _ProductPanel({
    required this.categories,
    required this.products,
    required this.selectedCategoryId,
    required this.onCategorySelected,
    required this.onProductTap,
  });

  @override
  Widget build(BuildContext context) {
    final cols = MediaQuery.of(context).size.width >= 1200 ? 5 : 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 56,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: categories.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, i) {
              final cat = categories[i];
              final isSelected = cat.id == selectedCategoryId;
              return ChoiceChip(
                label: Text(cat.localizedName),
                selected: isSelected,
                onSelected: (_) => onCategorySelected(cat.id),
                selectedColor: AppColors.accent,
                labelStyle: TextStyle(
                  color: isSelected ? AppColors.primaryDark : null,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              );
            },
          ),
        ),
        Expanded(
          child: products.isEmpty
              ? Center(child: Text('noProducts'.tr()))
              : Padding(
                  padding: const EdgeInsets.all(12),
                  child: GridView.builder(
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: cols,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: 0.8,
                    ),
                    itemCount: products.length,
                    itemBuilder: (_, i) => ProductGridItem(
                      product: products[i],
                      onTap: () => onProductTap(products[i]),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _InvoicePanel extends StatelessWidget {
  final BillingState state;
  final Function(BuildContext, int, String, {ProductModel? initialProduct}) onShowRename;
  const _InvoicePanel({required this.state, required this.onShowRename});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<BillingCubit>();
    final hasActiveTab = state.activeTabIndex != -1 && state.tabs.isNotEmpty;
    final tab = hasActiveTab ? state.activeTab : null;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : Colors.white,
        boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 12)],
      ),
      child: Column(
        children: [
          Container(
            height: 48,
            color: isDark ? AppColors.darkCard : AppColors.background,
            child: Row(
              children: [
                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: state.tabs.length,
                    itemBuilder: (_, i) {
                      final t = state.tabs[i];
                      final active = i == state.activeTabIndex;
                      return GestureDetector(
                        onTap: () => cubit.setActiveTab(i),
                        onLongPress: () => onShowRename(context, i, t.label),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          decoration: BoxDecoration(
                            color: active ? (isDark ? AppColors.darkSurface : Colors.white) : Colors.transparent,
                            border: active
                                ? const Border(bottom: BorderSide(color: AppColors.accent, width: 2))
                                : null,
                          ),
                          child: Row(
                            children: [
                              Text(t.label,
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                                    color: active ? AppColors.accent : null,
                                  )),
                              if (state.tabs.length > 1) ...[
                                const SizedBox(width: 4),
                                GestureDetector(
                                  onTap: () => cubit.removeTab(i),
                                  child: const Icon(Icons.close, size: 14),
                                ),
                              ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.add_rounded, size: 20),
                  onPressed: () => onShowRename(context, -1, ''),
                  tooltip: 'newInvoice'.tr(),
                ),
              ],
            ),
          ),
          Expanded(
            child: !hasActiveTab
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_rounded, size: 64, color: AppColors.textSecondary),
                        const SizedBox(height: 16),
                        Text('noActiveInvoice'.tr(), style: const TextStyle(color: AppColors.textSecondary, fontSize: 16)),
                        const SizedBox(height: 24),
                        AppButton(
                          label: 'newInvoice'.tr(),
                          icon: Icons.add_rounded,
                          width: 180,
                          onPressed: () => onShowRename(context, -1, ''),
                        ),
                      ],
                    ),
                  )
                : tab!.items.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.shopping_basket_outlined, size: 48, color: AppColors.textSecondary),
                            const SizedBox(height: 8),
                            Text('emptyInvoice'.tr(), style: const TextStyle(color: AppColors.textSecondary)),
                          ],
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.all(8),
                        itemCount: tab.items.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, i) {
                          final item = tab.items[i];
                          return ListTile(
                            dense: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 8),
                            title: Text(item.productName, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                            subtitle: Text('${item.price.toStringAsFixed(2)} × ${item.quantity}',
                                style: const TextStyle(fontSize: 12)),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(item.subtotal.toStringAsFixed(2),
                                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                  ],
                                ),
                                const SizedBox(width: 12),
                                Container(
                                  decoration: BoxDecoration(
                                    color: isDark ? AppColors.darkCard : AppColors.background,
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: AppColors.divider),
                                  ),
                                  child: Row(
                                    children: [
                                      _QtyButton(icon: Icons.remove, onTap: () => cubit.updateQuantity(i, item.quantity - 1)),
                                      const SizedBox(width: 8),
                                      Text('${item.quantity}', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      const SizedBox(width: 8),
                                      _QtyButton(icon: Icons.add, onTap: () => cubit.updateQuantity(i, item.quantity + 1)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline, color: AppColors.error, size: 20),
                                  onPressed: () => cubit.removeItem(i),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
          if (hasActiveTab)
            BlocBuilder<SettingsCubit, SettingsState>(
              builder: (context, settings) {
                final taxAmount = tab!.calculateTax(settings.isTaxEnabled, settings.taxPercent);
                final discountAmount = tab.calculateDiscount();
                final finalTotal = tab.calculateTotal(
                  taxEnabled: settings.isTaxEnabled,
                  taxPercent: settings.taxPercent,
                );

                return Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkCard : AppColors.background,
                    border: const Border(top: BorderSide(color: AppColors.divider)),
                  ),
                  child: Column(
                    children: [
                      // Manual Discount Section
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Row(
                                children: [
                                  _DiscountTypeToggle(
                                    label: '%',
                                    selected: tab.discountType == 'percentage',
                                    onTap: () => cubit.setDiscount(
                                      enabled: tab.discountEnabled,
                                      type: 'percentage',
                                      value: tab.discountValue,
                                    ),
                                  ),
                                  _DiscountTypeToggle(
                                    label: 'fixed'.tr(),
                                    selected: tab.discountType == 'fixed',
                                    onTap: () => cubit.setDiscount(
                                      enabled: tab.discountEnabled,
                                      type: 'fixed',
                                      value: tab.discountValue,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              flex: 3,
                              child: SizedBox(
                                height: 36,
                                child: CafeTextField(
                                  key: ValueKey(tab.tabId),
                                  initialValue: tab.discountValue > 0 ? tab.discountValue.toString() : '',
                                  hintText: 'discount'.tr(),
                                  keyboardType: CafeKeyboardType.numeric,
                                  onChanged: (val) {
                                    final d = double.tryParse(val) ?? 0;
                                    cubit.setDiscount(
                                      enabled: d > 0,
                                      type: tab.discountType,
                                      value: d,
                                    );
                                  },
                                  prefixIcon: const Icon(Icons.local_offer_rounded, size: 16),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('subtotal'.tr(), style: const TextStyle(fontSize: 14)),
                          Text(tab.subtotal.toStringAsFixed(2), style: const TextStyle(fontSize: 14)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      if (tab.discountEnabled && discountAmount > 0) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${'discount'.tr()} (${tab.discountType == 'percentage' ? '${tab.discountValue}%' : 'fixedAmount'.tr()})',
                              style: const TextStyle(fontSize: 14, color: AppColors.error),
                            ),
                            Text('-${discountAmount.toStringAsFixed(2)}',
                                style: const TextStyle(fontSize: 14, color: AppColors.error)),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      if (settings.isTaxEnabled) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${'tax'.tr()} (${settings.taxPercent}%)', style: const TextStyle(fontSize: 14)),
                            Text(taxAmount.toStringAsFixed(2), style: const TextStyle(fontSize: 14)),
                          ],
                        ),
                        const SizedBox(height: 4),
                      ],
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('total'.tr(), style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                          Text(finalTotal.toStringAsFixed(2),
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: AppColors.accent)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: _PayBtn(
                              label: 'cash'.tr(),
                              icon: Icons.payments_rounded,
                              selected: tab.paymentMethod == 'cash',
                              color: AppColors.cashColor,
                              onTap: () {
                                cubit.setPaymentMethod('cash');
                              },
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: _PayBtn(
                              label: 'card'.tr(),
                              icon: Icons.credit_card_rounded,
                              selected: tab.paymentMethod == 'card',
                              color: AppColors.cardColor,
                              onTap: () {
                                cubit.setPaymentMethod('card');
                              },
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'saveAndPrint'.tr(),
                        icon: Icons.print_rounded,
                        isLoading: state.isSaving,
                        onPressed: (tab.items.isEmpty || tab.paymentMethod == null)
                            ? null
                            : () => cubit.saveCurrentInvoice(
                                  taxEnabled: settings.isTaxEnabled,
                                  taxPercent: settings.taxPercent,
                                ),
                      ),
                    ],
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: AppColors.accent.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, size: 16, color: AppColors.accent),
      ),
    );
  }
}

class _DiscountTypeToggle extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _DiscountTypeToggle({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: 36,
          margin: const EdgeInsets.only(right: 4),
          decoration: BoxDecoration(
            color: selected ? AppColors.accent : AppColors.background,
            borderRadius: BorderRadius.circular(6),
            border: Border.all(color: selected ? AppColors.accentDark : AppColors.divider),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: selected ? FontWeight.bold : FontWeight.normal,
                color: selected ? AppColors.primaryDark : AppColors.textSecondary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _PayBtn extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selected;
  final Color color;
  final VoidCallback onTap;
  const _PayBtn({required this.label, required this.icon, required this.selected, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: selected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: color, width: selected ? 0 : 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: selected ? Colors.white : color, size: 18),
            const SizedBox(width: 6),
            Text(label, style: TextStyle(color: selected ? Colors.white : color, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
