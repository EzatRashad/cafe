import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../../core/printer/printer_service.dart';
import '../../../../core/printer/receipt_generator.dart';
import '../../../billing/data/models/invoice_model.dart';

abstract class PrinterState extends Equatable {
  @override
  List<Object?> get props => [];
}

class PrinterInitial extends PrinterState {}

class PrinterLoading extends PrinterState {}

class PrinterLoaded extends PrinterState {
  final List<String> availablePrinters;
  final String? selectedPrinter;

  PrinterLoaded(this.availablePrinters, this.selectedPrinter);

  @override
  List<Object?> get props => [availablePrinters, selectedPrinter];
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

class PrinterCubit extends Cubit<PrinterState> {
  final PrinterService _printerService;
  final ReceiptGenerator _receiptGenerator;
  final SharedPreferences _prefs;
  static const String _printerKey = 'selected_printer_name';

  PrinterCubit(this._printerService, this._receiptGenerator, this._prefs)
      : super(PrinterInitial());

  String? get selectedPrinter => _prefs.getString(_printerKey);

  Future<void> loadPrinters() async {
    emit(PrinterLoading());
    try {
      final printers = _printerService.getWindowsPrinters();
      final selected = _prefs.getString(_printerKey);
      emit(PrinterLoaded(printers, selected));
    } catch (e) {
      emit(PrinterError(e.toString()));
    }
  }

  Future<void> selectPrinter(String name) async {
    await _prefs.setString(_printerKey, name);
    loadPrinters();
  }

  Future<void> printInvoice(InvoiceModel invoice,
      {int copies = 1, String appName = 'مقهي مصر'}) async {
    final printer = selectedPrinter;
    if (printer == null) {
      emit(PrinterError('selectPrinterFirst'.tr()));
      return;
    }

    try {
      final bytes = await _receiptGenerator.generate80mmReceipt(invoice,
          appName: appName);

      bool allSuccessful = true;
      for (var i = 0; i < copies; i++) {
        final success = await _printerService.printRawData(printer, bytes);
        if (!success) {
          allSuccessful = false;
          break;
        }
      }

      if (allSuccessful) {
        emit(PrinterSuccess('printSuccess'.tr()));
      } else {
        emit(PrinterError('dataSendError'.tr()));
      }
    } catch (e) {
      emit(PrinterError('printError'.tr(args: [e.toString()])));
    }
  }

  Future<void> testPrint() async {
    final printer = selectedPrinter;
    if (printer == null) return;

    // We can create a dummy invoice for test
    final dummyInvoice = InvoiceModel(
      id: 'TEST-000',
      createdAt: DateTime.now(),
      paymentMethod: 'cash',
      total: 0.0,
      items: const [
        InvoiceItemModel(
            id: '1',
            invoiceId: 'TEST-000',
            productId: '1',
            productName: 'تجربة طباعة ناجحة',
            price: 0.0,
            quantity: 1),
      ],
    );
    await printInvoice(dummyInvoice);
  }
}
