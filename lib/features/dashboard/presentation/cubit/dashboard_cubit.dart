import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/database/database_helper.dart';
import '../../../../core/utils/date_formatter.dart';

part 'dashboard_state.dart';

class DashboardCubit extends Cubit<DashboardState> {
  final DatabaseHelper _db;

  DashboardCubit(this._db) : super(const DashboardState());

  Future<void> load({DateTime? from, DateTime? to}) async {
    final now = DateTime.now();
    final f = from ?? DateFormatter.startOfDay(now);
    final t = to ?? DateFormatter.endOfDay(now);
    emit(state.copyWith(isLoading: true, from: f, to: t));
    try {
      final stats = await _db.getDashboardStats(
        from: f.toIso8601String(),
        to: t.toIso8601String(),
      );
      final topProducts = await _db.getTopProducts(
        from: f.toIso8601String(),
        to: t.toIso8601String(),
      );
      final salesByDay = await _db.getSalesByDay(
        from: f.toIso8601String(),
        to: t.toIso8601String(),
      );
      
      if (isClosed) return;

      emit(state.copyWith(
        isLoading: false,
        cashIncome: (stats['cashIncome'] as num).toDouble(),
        cardIncome: (stats['cardIncome'] as num).toDouble(),
        totalExpenses: (stats['totalExpenses'] as num).toDouble(),
        netProfit: (stats['netProfit'] as num).toDouble(),
        totalInvoices: stats['totalInvoices'] as int,
        topProducts: topProducts,
        salesByDay: salesByDay,
        from: f,
        to: t,
      ));
    } catch (e) {
      if (isClosed) return;
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }
}
