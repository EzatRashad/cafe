import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../billing/data/models/invoice_model.dart';
import '../../../billing/data/repositories/invoice_repository.dart';
import '../../../../core/utils/date_formatter.dart';

part 'invoice_history_state.dart';

enum DateFilter { today, thisMonth, thisYear, custom, all }

class InvoiceHistoryCubit extends Cubit<InvoiceHistoryState> {
  final InvoiceRepository _repo;

  InvoiceHistoryCubit(this._repo) : super(InvoiceHistoryState());

  Future<void> load({DateFilter? filter, DateTime? customFrom, DateTime? customTo}) async {
    final f = filter ?? state.filter;
    emit(state.copyWith(isLoading: true, filter: f));
    try {
      DateTime? from, to;
      final now = DateTime.now();
      switch (f) {
        case DateFilter.today:
          from = DateFormatter.startOfDay(now);
          to = DateFormatter.endOfDay(now);
          break;
        case DateFilter.thisMonth:
          from = DateFormatter.startOfMonth(now);
          to = DateFormatter.endOfMonth(now);
          break;
        case DateFilter.thisYear:
          from = DateFormatter.startOfYear(now);
          to = DateFormatter.endOfYear(now);
          break;
        case DateFilter.custom:
          from = customFrom;
          to = customTo;
          break;
        case DateFilter.all:
          from = null;
          to = null;
          break;
      }
      final invoices = await _repo.getInvoices(from: from, to: to);
      double cash = 0, card = 0;
      for (final inv in invoices) {
        if (inv.paymentMethod == 'cash') {
          cash += inv.total;
        } else {
          card += inv.total;
        }
      }
      emit(state.copyWith(
        isLoading: false,
        invoices: invoices,
        cashIncome: cash,
        cardIncome: card,
        customFrom: customFrom,
        customTo: customTo,
      ));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: e.toString()));
    }
  }

  Future<void> deleteInvoice(String id) async {
    try {
      await _repo.deleteInvoice(id);
      await load();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }

  Future<void> updateInvoice(InvoiceModel invoice) async {
    try {
      await _repo.updateInvoice(invoice);
      await load();
    } catch (e) {
      emit(state.copyWith(error: e.toString()));
    }
  }
}
