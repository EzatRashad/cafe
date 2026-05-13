part of 'expense_cubit.dart';

class ExpenseState extends Equatable {
  final List<ExpenseModel> expenses;
  final bool isLoading;
  final double cashTotal;
  final double cardTotal;
  final DateTime? from;
  final DateTime? to;
  final String? error;

  const ExpenseState({
    this.expenses = const [],
    this.isLoading = false,
    this.cashTotal = 0,
    this.cardTotal = 0,
    this.from,
    this.to,
    this.error,
  });

  double get grandTotal => cashTotal + cardTotal;

  ExpenseState copyWith({
    List<ExpenseModel>? expenses,
    bool? isLoading,
    double? cashTotal,
    double? cardTotal,
    DateTime? from,
    DateTime? to,
    String? error,
  }) =>
      ExpenseState(
        expenses: expenses ?? this.expenses,
        isLoading: isLoading ?? this.isLoading,
        cashTotal: cashTotal ?? this.cashTotal,
        cardTotal: cardTotal ?? this.cardTotal,
        from: from ?? this.from,
        to: to ?? this.to,
        error: error,
      );

  @override
  List<Object?> get props => [expenses, isLoading, cashTotal, cardTotal, from, to, error];
}
