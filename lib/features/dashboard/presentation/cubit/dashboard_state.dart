part of 'dashboard_cubit.dart';

class DashboardState extends Equatable {
  final bool isLoading;
  final double cashIncome;
  final double cardIncome;
  final double totalExpenses;
  final double netProfit;
  final int totalInvoices;
  final List<Map<String, dynamic>> topProducts;
  final List<Map<String, dynamic>> salesByDay;
  final DateTime? from;
  final DateTime? to;
  final String? error;

  const DashboardState({
    this.isLoading = false,
    this.cashIncome = 0,
    this.cardIncome = 0,
    this.totalExpenses = 0,
    this.netProfit = 0,
    this.totalInvoices = 0,
    this.topProducts = const [],
    this.salesByDay = const [],
    this.from,
    this.to,
    this.error,
  });

  double get totalIncome => cashIncome + cardIncome;

  DashboardState copyWith({
    bool? isLoading,
    double? cashIncome,
    double? cardIncome,
    double? totalExpenses,
    double? netProfit,
    int? totalInvoices,
    List<Map<String, dynamic>>? topProducts,
    List<Map<String, dynamic>>? salesByDay,
    DateTime? from,
    DateTime? to,
    String? error,
  }) =>
      DashboardState(
        isLoading: isLoading ?? this.isLoading,
        cashIncome: cashIncome ?? this.cashIncome,
        cardIncome: cardIncome ?? this.cardIncome,
        totalExpenses: totalExpenses ?? this.totalExpenses,
        netProfit: netProfit ?? this.netProfit,
        totalInvoices: totalInvoices ?? this.totalInvoices,
        topProducts: topProducts ?? this.topProducts,
        salesByDay: salesByDay ?? this.salesByDay,
        from: from ?? this.from,
        to: to ?? this.to,
        error: error,
      );

  @override
  List<Object?> get props => [isLoading, cashIncome, cardIncome, totalExpenses, netProfit, totalInvoices, topProducts.length, salesByDay.length, from, to, error];
}
