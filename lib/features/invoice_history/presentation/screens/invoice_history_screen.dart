import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../../billing/data/models/invoice_model.dart';
import 'invoice_details_screen.dart';
import '../cubit/invoice_history_cubit.dart';
import '../../../settings/presentation/cubit/printer_cubit.dart';

class InvoiceHistoryScreen extends StatelessWidget {
  const InvoiceHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<InvoiceHistoryCubit, InvoiceHistoryState>(
      builder: (context, state) {
        return Column(
          children: [
            _Header(state: state),
            _SummaryRow(state: state),
            Expanded(
              child: state.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : state.error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.error_outline_rounded,
                                  size: 48, color: AppColors.error),
                              const SizedBox(height: 16),
                              Text(state.error!,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: () =>
                                    context.read<InvoiceHistoryCubit>().load(),
                                child: Text('retry'.tr()),
                              ),
                            ],
                          ),
                        )
                      : state.invoices.isEmpty
                          ? Center(
                              child: Text('noInvoices'.tr(),
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)))
                          : _InvoiceTable(invoices: state.invoices),
            ),
          ],
        );
      },
    );
  }
}

class _Header extends StatelessWidget {
  final InvoiceHistoryState state;
  const _Header({required this.state});

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<InvoiceHistoryCubit>();
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text('invoiceHistory'.tr(),
              style: Theme.of(context).textTheme.headlineMedium),
          const SizedBox(width: 16),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                  label: 'today'.tr(),
                  filter: DateFilter.today,
                  current: state.filter,
                  cubit: cubit),
              _FilterChip(
                  label: 'thisMonth'.tr(),
                  filter: DateFilter.thisMonth,
                  current: state.filter,
                  cubit: cubit),
              _FilterChip(
                  label: 'thisYear'.tr(),
                  filter: DateFilter.thisYear,
                  current: state.filter,
                  cubit: cubit),
              _FilterChip(
                  label: 'all'.tr(),
                  filter: DateFilter.all,
                  current: state.filter,
                  cubit: cubit),
              ActionChip(
                label: Text('custom'.tr()),
                avatar: const Icon(Icons.date_range_rounded, size: 16),
                onPressed: () => _pickCustomRange(context, cubit),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _pickCustomRange(
      BuildContext context, InvoiceHistoryCubit cubit) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (range != null) {
      cubit.load(
          filter: DateFilter.custom,
          customFrom: range.start,
          customTo: range.end);
    }
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final DateFilter filter;
  final DateFilter current;
  final InvoiceHistoryCubit cubit;
  const _FilterChip(
      {required this.label,
      required this.filter,
      required this.current,
      required this.cubit});

  @override
  Widget build(BuildContext context) {
    final selected = filter == current;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) => cubit.load(filter: filter),
      selectedColor: AppColors.accent,
      labelStyle: TextStyle(color: selected ? AppColors.primaryDark : null),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final InvoiceHistoryState state;
  const _SummaryRow({required this.state});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: Row(
        children: [
          Expanded(
              child: StatCard(
                  title: 'cashIncome'.tr(),
                  value: state.cashIncome.toStringAsFixed(2),
                  icon: Icons.payments_rounded,
                  color: AppColors.cashColor)),
          const SizedBox(width: 12),
          Expanded(
              child: StatCard(
                  title: 'cardIncome'.tr(),
                  value: state.cardIncome.toStringAsFixed(2),
                  icon: Icons.credit_card_rounded,
                  color: AppColors.cardColor)),
          const SizedBox(width: 12),
          Expanded(
              child: StatCard(
                  title: 'totalIncome'.tr(),
                  value: state.totalIncome.toStringAsFixed(2),
                  icon: Icons.account_balance_wallet_rounded,
                  color: AppColors.accent)),
          const SizedBox(width: 12),
          Expanded(
              child: StatCard(
                  title: 'reports'.tr(),
                  value: '${state.invoices.length}',
                  icon: Icons.receipt_long_rounded,
                  color: AppColors.primary)),
        ],
      ),
    );
  }
}

class _InvoiceTable extends StatelessWidget {
  final List<InvoiceModel> invoices;
  const _InvoiceTable({required this.invoices});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: AppCard(
        padding: EdgeInsets.zero,
        child: SingleChildScrollView(
          child: DataTable(
            headingRowColor: WidgetStateProperty.all(
                AppColors.accent.withValues(alpha: 0.1)),
            columns: [
              const DataColumn(
                  label:
                      Text('#', style: TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('date'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('products'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('paymentMethod'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('discount'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('tax'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('total'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
              DataColumn(
                  label: Text('search'.tr(),
                      style: const TextStyle(fontWeight: FontWeight.bold))),
            ],
            rows: invoices.asMap().entries.map((e) {
              final i = e.key;
              final inv = e.value;
              return DataRow(
                  onSelectChanged: (_) => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => InvoiceDetailsScreen(invoice: inv)),
                      ),
                  cells: [
                    DataCell(Text('${i + 1}')),
                    DataCell(Text(
                        DateFormatter.formatDisplayDateTime(inv.createdAt))),
                    DataCell(Text('${inv.items.length} ${'products'.tr()}')),
                    DataCell(
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: (inv.paymentMethod == 'cash'
                                  ? AppColors.cashColor
                                  : AppColors.cardColor)
                              .withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          inv.paymentMethod == 'cash'
                              ? 'cash'.tr()
                              : 'card'.tr(),
                          style: TextStyle(
                            color: inv.paymentMethod == 'cash'
                                ? AppColors.cashColor
                                : AppColors.cardColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ),
                    DataCell(Text(
                        inv.discountAmount > 0
                            ? '-${inv.discountAmount.toStringAsFixed(2)} ر.س'
                            : '0.00 ر.س',
                        style: const TextStyle(
                            color: AppColors.error, fontSize: 12))),
                    DataCell(Text('${inv.taxAmount.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(
                            color: AppColors.textSecondary, fontSize: 12))),
                    DataCell(Text('${inv.total.toStringAsFixed(2)} ر.س',
                        style: const TextStyle(fontWeight: FontWeight.bold))),
                    DataCell(
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.visibility_rounded,
                                size: 18, color: Colors.grey),
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) =>
                                      InvoiceDetailsScreen(invoice: inv)),
                            ),
                            tooltip: 'view'.tr(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.print_rounded,
                                size: 18, color: AppColors.accent),
                            onPressed: () =>
                                context.read<PrinterCubit>().printInvoice(inv),
                            tooltip: 'print'.tr(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded,
                                size: 18, color: AppColors.primary),
                            onPressed: () => _showEditDialog(context, inv),
                            tooltip: 'edit'.tr(),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_rounded,
                                size: 18, color: AppColors.error),
                            onPressed: () => _confirmDelete(context, inv),
                            tooltip: 'delete'.tr(),
                          ),
                        ],
                      ),
                    ),
                  ]);
            }).toList(),
          ),
        ),
      ),
    );
  }

  void _showEditDialog(BuildContext context, InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<InvoiceHistoryCubit>(),
        child: _EditInvoiceDialog(invoice: invoice),
      ),
    );
  }

  void _confirmDelete(BuildContext context, InvoiceModel invoice) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('delete'.tr()),
        content: Text('confirmDelete'.tr()),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text('cancel'.tr())),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () {
              context.read<InvoiceHistoryCubit>().deleteInvoice(invoice.id);
              Navigator.pop(ctx);
            },
            child: Text('delete'.tr(),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _EditInvoiceDialog extends StatefulWidget {
  final InvoiceModel invoice;
  const _EditInvoiceDialog({required this.invoice});

  @override
  State<_EditInvoiceDialog> createState() => _EditInvoiceDialogState();
}

class _EditInvoiceDialogState extends State<_EditInvoiceDialog> {
  late List<InvoiceItemModel> _items;

  @override
  void initState() {
    super.initState();
    _items = List.from(widget.invoice.items);
  }

  double get _subtotal => _items.fold(0.0, (sum, i) => sum + i.subtotal);
  double get _discountAmount {
    if (!widget.invoice.discountEnabled || widget.invoice.discountValue <= 0)
      return 0;
    if (widget.invoice.discountType == 'percentage') {
      return _subtotal * (widget.invoice.discountValue / 100);
    } else {
      return widget.invoice.discountValue;
    }
  }

  double get _taxAmount => widget.invoice.taxEnabled
      ? _subtotal * (widget.invoice.taxPercent / 100)
      : 0;
  double get _total => _subtotal - _discountAmount + _taxAmount;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          '${'edit'.tr()} — ${DateFormatter.formatDisplayDateTime(widget.invoice.createdAt)}'),
      content: SizedBox(
        width: 500,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ..._items.asMap().entries.map((e) {
                final i = e.key;
                final item = e.value;
                return ListTile(
                  dense: true,
                  title: Text(item.productName),
                  subtitle: Text(item.price.toStringAsFixed(2)),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.remove, size: 18),
                        onPressed: () {
                          if (item.quantity > 1) {
                            setState(() => _items[i] =
                                item.copyWith(quantity: item.quantity - 1));
                          }
                        },
                      ),
                      Text('${item.quantity}',
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      IconButton(
                        icon: const Icon(Icons.add, size: 18),
                        onPressed: () => setState(() => _items[i] =
                            item.copyWith(quantity: item.quantity + 1)),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline,
                            color: AppColors.error, size: 18),
                        onPressed: () => setState(() => _items.removeAt(i)),
                      ),
                    ],
                  ),
                );
              }),
              const Divider(),
              if (widget.invoice.discountEnabled ||
                  widget.invoice.taxEnabled) ...[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('subtotal'.tr(), style: const TextStyle(fontSize: 14)),
                    Text(_subtotal.toStringAsFixed(2),
                        style: const TextStyle(fontSize: 14)),
                  ],
                ),
                const SizedBox(height: 4),
                if (widget.invoice.discountEnabled && _discountAmount > 0) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '${'discount'.tr()} (${widget.invoice.discountType == 'percentage' ? '${widget.invoice.discountValue}%' : 'fixedAmount'.tr()})',
                        style: const TextStyle(
                            fontSize: 14, color: AppColors.error),
                      ),
                      Text('-${_discountAmount.toStringAsFixed(2)}',
                          style: const TextStyle(
                              fontSize: 14, color: AppColors.error)),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                if (widget.invoice.taxEnabled) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('${'tax'.tr()} (${widget.invoice.taxPercent}%)',
                          style: const TextStyle(fontSize: 14)),
                      Text(_taxAmount.toStringAsFixed(2),
                          style: const TextStyle(fontSize: 14)),
                    ],
                  ),
                  const SizedBox(height: 4),
                ],
                const Divider(),
              ],
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('total'.tr(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(_total.toStringAsFixed(2),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: AppColors.accent)),
                ],
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
          label: 'save'.tr(),
          width: 130,
          onPressed: () {
            Navigator.pop(context);
            context.read<InvoiceHistoryCubit>().updateInvoice(
                  widget.invoice.copyWith(
                    items: _items,
                    total: _total,
                    taxAmount: _taxAmount,
                    discountAmount: _discountAmount,
                  ),
                );
          },
        ),
      ],
    );
  }
}
