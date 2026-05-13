import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/printer/printer_service.dart';
import '../../../../core/printer/receipt_generator.dart';
import '../../../billing/data/models/invoice_model.dart';

// ── States ────────────────────────────────────────────────────────────────

abstract class PrinterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PrinterInitial extends PrinterState {}

class PrinterLoading extends PrinterState {}

class PrinterLoaded extends PrinterState {
  final List<PrinterModel> printers;
  final String? selectedPrinter;

  PrinterLoaded(this.printers, this.selectedPrinter);

  @override
  List<Object?> get props => [printers, selectedPrinter];
}

class PrinterError extends PrinterState {
  final String message;
  PrinterError(this.message);
  @override
  List<Object?> get props => [message];
}

class PrinterSuccess extends PrinterState {
  final String message;
  PrinterSuccess(this.message);
  @override
  List<Object?> get props => [message];
}

// ── Cubit ─────────────────────────────────────────────────────────────────

class PrinterCubit extends Cubit<PrinterState> {
  final PrinterService _printerService;
  final ReceiptGenerator _receiptGenerator;
  final SharedPreferences _prefs;

  static const String _printerKey = 'selected_printer_name';

  PrinterCubit(this._printerService, this._receiptGenerator, this._prefs)
      : super(PrinterInitial()) {
    // Auto-load printers when cubit is created
    loadPrinters();
  }

  String? get selectedPrinter => _prefs.getString(_printerKey);

  // ── Load ────────────────────────────────────────────────────────────────

  Future<void> loadPrinters() async {
    emit(PrinterLoading());
    try {
      final printers = await _printerService.getWindowsPrinters();
      final selected = _prefs.getString(_printerKey);

      // If saved selection no longer exists, clear it
      final validSelected =
          printers.any((p) => p.name == selected) ? selected : null;

      emit(PrinterLoaded(printers, validSelected));
    } catch (e) {
      emit(PrinterError(e.toString()));
    }
  }

  // ── Select ──────────────────────────────────────────────────────────────

  Future<void> selectPrinter(String name) async {
    await _prefs.setString(_printerKey, name);
    // Refresh state with new selection (keep cached printer list)
    if (state is PrinterLoaded) {
      final current = state as PrinterLoaded;
      emit(PrinterLoaded(current.printers, name));
    } else {
      await loadPrinters();
    }
  }

  // ── Print ───────────────────────────────────────────────────────────────

  Future<void> printInvoice(
    InvoiceModel invoice, {
    int copies = 1,
    String appName = 'قهوة مصر',
  }) async {
    final printer = selectedPrinter;
    if (printer == null || printer.isEmpty) {
      emit(PrinterError('selectPrinterFirst'.tr()));
      return;
    }

    emit(PrinterLoading());
    try {
      final bytes = await _receiptGenerator.generate80mmReceipt(
        invoice,
        appName: appName,
      );

      for (var i = 0; i < copies; i++) {
        final ok = await _printerService.printRawData(printer, bytes);
        if (!ok) {
          emit(PrinterError('dataSendError'.tr()));
          return;
        }
      }

      emit(PrinterSuccess('printSuccess'.tr()));
    } catch (e) {
      emit(PrinterError('printError'.tr(args: [e.toString()])));
    }
  }

  // ── Test Print ──────────────────────────────────────────────────────────

  Future<void> testPrint() async {
    final printer = selectedPrinter;
    if (printer == null || printer.isEmpty) {
      emit(PrinterError('selectPrinterFirst'.tr()));
      return;
    }

    final dummy = InvoiceModel(
      id: 'TEST-001',
      createdAt: DateTime.now(),
      paymentMethod: 'cash',
      total: 99.50,
      taxPercent: 15,
      taxAmount: 12.98,
      taxEnabled: true,
      discountValue: 10,
      discountAmount: 8.74,
      discountType: 'percentage',
      discountEnabled: true,
      items: const [
        InvoiceItemModel(
          id: '1',
          invoiceId: 'TEST-001',
          productId: 'p1',
          productName: 'كابتشينو',
          price: 25.0,
          quantity: 2,
        ),
        InvoiceItemModel(
          id: '2',
          invoiceId: 'TEST-001',
          productId: 'p2',
          productName: 'لاتيه',
          price: 30.0,
          quantity: 1,
        ),
      ],
    );
    await printInvoice(dummy);
  }
}
