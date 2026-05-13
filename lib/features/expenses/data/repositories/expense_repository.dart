import '../../data/models/expense_model.dart';
import '../../../../core/database/database_helper.dart';
import 'package:uuid/uuid.dart';

abstract class ExpenseRepository {
  Future<List<ExpenseModel>> getExpenses({DateTime? from, DateTime? to});
  Future<void> addExpense(ExpenseModel expense);
  Future<void> updateExpense(ExpenseModel expense);
  Future<void> deleteExpense(String id);
}

class ExpenseRepositoryImpl implements ExpenseRepository {
  final DatabaseHelper _db;
  final _uuid = const Uuid();

  ExpenseRepositoryImpl(this._db);

  @override
  Future<List<ExpenseModel>> getExpenses({DateTime? from, DateTime? to}) async {
    final rows = await _db.getExpenses(
      from: from?.toIso8601String(),
      to: to?.toIso8601String(),
    );
    return rows.map(ExpenseModel.fromMap).toList();
  }

  @override
  Future<void> addExpense(ExpenseModel expense) async {
    final model = ExpenseModel(
      id: _uuid.v4(),
      amount: expense.amount,
      paymentType: expense.paymentType,
      description: expense.description,
      createdAt: DateTime.now(),
    );
    await _db.insertExpense(model.toMap());
  }

  @override
  Future<void> updateExpense(ExpenseModel expense) async {
    await _db.updateExpense(expense.id, expense.toMap());
  }

  @override
  Future<void> deleteExpense(String id) async {
    await _db.deleteExpense(id);
  }
}
