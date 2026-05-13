part of 'invoice_history_cubit.dart';


class InvoiceHistoryState extends Equatable {
  final List<InvoiceModel> invoices;
  final bool isLoading;
  final DateFilter filter;
  final double cashIncome;
  final double cardIncome;
  final DateTime? customFrom;
  final DateTime? customTo;
  final String? error;

  const InvoiceHistoryState({
    this.invoices = const [],
    this.isLoading = false,
    this.filter = DateFilter.today,
    this.cashIncome = 0,
    this.cardIncome = 0,
    this.customFrom,
    this.customTo,
    this.error,
  });

  double get totalIncome => cashIncome + cardIncome;

  InvoiceHistoryState copyWith({
    List<InvoiceModel>? invoices,
    bool? isLoading,
    DateFilter? filter,
    double? cashIncome,
    double? cardIncome,
    DateTime? customFrom,
    DateTime? customTo,
    String? error,
  }) =>
      InvoiceHistoryState(
        invoices: invoices ?? this.invoices,
        isLoading: isLoading ?? this.isLoading,
        filter: filter ?? this.filter,
        cashIncome: cashIncome ?? this.cashIncome,
        cardIncome: cardIncome ?? this.cardIncome,
        customFrom: customFrom ?? this.customFrom,
        customTo: customTo ?? this.customTo,
        error: error,
      );

  @override
  List<Object?> get props => [invoices, isLoading, filter, cashIncome, cardIncome, customFrom, customTo, error];
}
