import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/utils/date_formatter.dart';
import '../../../../shared/widgets/common_widgets.dart';
import '../../data/models/expense_model.dart';
import '../cubit/expense_cubit.dart';

class ExpensesScreen extends StatelessWidget {
  const ExpensesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ExpenseCubit, ExpenseState>(
      builder: (context, state) {
        return Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Text('expenses'.tr(),
                      style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(width: 16),
                  TextButton.icon(
                    icon: const Icon(Icons.date_range_rounded),
                    label: Text(state.from != null
                        ? '${DateFormatter.formatDisplayDate(state.from!)} → ${DateFormatter.formatDisplayDate(state.to!)}'
                        : 'search'.tr()),
                    onPressed: () => _pickRange(context),
                  ),
                  const Spacer(),
                  AppButton(
                    label: 'addExpense'.tr(),
                    icon: Icons.add,
                    onPressed: () => _showDialog(context, null),
                    width: 200,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                      child: StatCard(
                          title: 'cashIncome'.tr(),
                          value: state.cashTotal.toStringAsFixed(2),
                          icon: Icons.payments_rounded,
                          color: AppColors.cashColor)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: StatCard(
                          title: 'cardIncome'.tr(),
                          value: state.cardTotal.toStringAsFixed(2),
                          icon: Icons.credit_card_rounded,
                          color: AppColors.cardColor)),
                  const SizedBox(width: 12),
                  Expanded(
                      child: StatCard(
                          title: 'total'.tr(),
                          value: state.grandTotal.toStringAsFixed(2),
                          icon: Icons.account_balance_wallet_rounded,
                          color: AppColors.error)),
                ],
              ),
            ),
            const SizedBox(height: 12),
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
                                    context.read<ExpenseCubit>().load(),
                                child: Text('retry'.tr()),
                              ),
                            ],
                          ),
                        )
                      : state.expenses.isEmpty
                          ? Center(
                              child: Text('noExpenses'.tr(),
                                  style: const TextStyle(
                                      color: AppColors.textSecondary)))
                          : Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                              child: AppCard(
                                padding: EdgeInsets.zero,
                                child: SingleChildScrollView(
                                  child: DataTable(
                                    headingRowColor: WidgetStateProperty.all(
                                        AppColors.error
                                            .withValues(alpha: 0.08)),
                                    columns: [
                                      const DataColumn(label: Text('#')),
                                      DataColumn(label: Text('date'.tr())),
                                      DataColumn(
                                          label: Text('description'.tr())),
                                      DataColumn(label: Text('type'.tr())),
                                      DataColumn(label: Text('amount'.tr())),
                                      DataColumn(
                                          label: Text('search'
                                              .tr())), // 'Actions' is often just icons
                                    ],
                                    rows:
                                        state.expenses.asMap().entries.map((e) {
                                      final expense = e.value;
                                      return DataRow(cells: [
                                        DataCell(Text('${e.key + 1}')),
                                        DataCell(Text(
                                            DateFormatter.formatDisplayDate(
                                                expense.createdAt))),
                                        DataCell(
                                            Text(expense.description ?? '-')),
                                        DataCell(
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color:
                                                  (expense.paymentType == 'cash'
                                                          ? AppColors.cashColor
                                                          : AppColors.cardColor)
                                                      .withValues(alpha: 0.12),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: Text(
                                                expense.paymentType == 'cash'
                                                    ? 'cash'.tr()
                                                    : 'card'.tr(),
                                                style: TextStyle(
                                                  color: expense.paymentType ==
                                                          'cash'
                                                      ? AppColors.cashColor
                                                      : AppColors.cardColor,
                                                  fontSize: 11,
                                                  fontWeight: FontWeight.w600,
                                                )),
                                          ),
                                        ),
                                        DataCell(Text(
                                            expense.amount.toStringAsFixed(2),
                                            style: const TextStyle(
                                                fontWeight: FontWeight.bold,
                                                color: AppColors.error))),
                                        DataCell(Row(children: [
                                          IconButton(
                                            icon: const Icon(Icons.edit_rounded,
                                                size: 18,
                                                color: AppColors.primary),
                                            onPressed: () =>
                                                _showDialog(context, expense),
                                          ),
                                          IconButton(
                                            icon: const Icon(
                                                Icons.delete_rounded,
                                                size: 18,
                                                color: AppColors.error),
                                            onPressed: () => context
                                                .read<ExpenseCubit>()
                                                .deleteExpense(expense.id),
                                          ),
                                        ])),
                                      ]);
                                    }).toList(),
                                  ),
                                ),
                              ),
                            ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _pickRange(BuildContext context) async {
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (range != null) {
      context.read<ExpenseCubit>().load(from: range.start, to: range.end);
    }
  }

  void _showDialog(BuildContext context, ExpenseModel? existing) {
    showDialog(
      context: context,
      builder: (_) => BlocProvider.value(
        value: context.read<ExpenseCubit>(),
        child: _ExpenseDialog(existing: existing),
      ),
    );
  }
}

class _ExpenseDialog extends StatefulWidget {
  final ExpenseModel? existing;
  const _ExpenseDialog({this.existing});

  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
  final _amountCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _type = 'cash';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    if (widget.existing != null) {
      _amountCtrl.text = widget.existing!.amount.toString();
      _descCtrl.text = widget.existing!.description ?? '';
      _type = widget.existing!.paymentType;
    }
  }

  @override
  void dispose() {
    _amountCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          widget.existing == null ? 'addExpense'.tr() : 'editExpense'.tr()),
      content: SizedBox(
        width: 360,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppTextField(
                label: 'amount'.tr(),
                controller: _amountCtrl,
                keyboardType: TextInputType.number,
                prefixIcon: const Icon(Icons.attach_money_rounded)),
            const SizedBox(height: 12),
            AppTextField(
                label: 'description'.tr(), controller: _descCtrl, maxLines: 2),
            const SizedBox(height: 12),
            Row(
              children: ['cash', 'card']
                  .map((t) => Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label:
                                Text(t == 'cash' ? 'cash'.tr() : 'card'.tr()),
                            selected: _type == t,
                            selectedColor: t == 'cash'
                                ? AppColors.cashColor
                                : AppColors.cardColor,
                            onSelected: (_) => setState(() => _type = t),
                            labelStyle: TextStyle(
                                color: _type == t ? Colors.white : null),
                          ),
                        ),
                      ))
                  .toList(),
            ),
          ],
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
    final amount = double.tryParse(_amountCtrl.text);
    if (amount == null || amount <= 0) return;
    setState(() => _saving = true);
    final expense = ExpenseModel(
      id: widget.existing?.id ?? '',
      amount: amount,
      paymentType: _type,
      description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
      createdAt: widget.existing?.createdAt ?? DateTime.now(),
    );
    final cubit = context.read<ExpenseCubit>();
    if (widget.existing == null) {
      await cubit.addExpense(expense);
    } else {
      await cubit.updateExpense(expense);
    }
    if (mounted) Navigator.pop(context);
  }
}
