import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/models/expense_model.dart';
import '../../data/repositories/expense_repository.dart';
import '../../../../core/utils/date_formatter.dart';

part 'expense_state.dart';

class ExpenseCubit extends Cubit<ExpenseState> {
  final ExpenseRepository _repo;

  ExpenseCubit(this._repo) : super(const ExpenseState());

  Future<void> load({DateTime? from, DateTime? to}) async {
    final now = DateTime.now();
    final f = from ?? DateFormatter.startOfDay(now);
    final t = to ?? DateFormatter.endOfDay(now);
    emit(state.copyWith(isLoading: true, from: f, to: t));
    try {
      final expenses = await _repo.getExpenses(from: f, to: t);
      double cash = 0, card = 0;
      for (final e in expenses) {
        if (e.paymentType == 'cash') cash += e.amount;
        else card += e.amount;
      }
      emit(state.copyWith(
        isLoading: false,
        expenses: expenses,
        cashTotal: cash,
        cardTotal: card,
        from: f,
        to: t,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> addExpense(ExpenseModel expense) async {
    try {
      await _repo.addExpense(expense);
      await load(from: state.from, to: state.to);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateExpense(ExpenseModel expense) async {
    try {
      await _repo.updateExpense(expense);
      await load(from: state.from, to: state.to);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _repo.deleteExpense(id);
      await load(from: state.from, to: state.to);
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
