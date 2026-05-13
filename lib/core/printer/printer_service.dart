import 'dart:ffi';
import 'dart:typed_data';
import 'dart:isolate';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:win32/win32.dart';

class PrinterService {
  /// List all attached printers using Win32 API
  List<String> getWindowsPrinters() {
    final List<String> printers = [];
    final pPrinterName = calloc<BYTE>(1024);
    final pNeeded = calloc<DWORD>();
    final pReturned = calloc<DWORD>();

    try {
      // EnumPrinters with PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS
      EnumPrinters(PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS, nullptr, 2, nullptr, 0, pNeeded, pReturned);
      
      if (pNeeded.value > 0) {
        final pBuffer = calloc<BYTE>(pNeeded.value);
        if (EnumPrinters(PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS, nullptr, 2, pBuffer, pNeeded.value, pNeeded, pReturned) != 0) {
          final pPrinterInfos = pBuffer.cast<PRINTER_INFO_2>();
          for (var i = 0; i < pReturned.value; i++) {
            final printerInfo = pPrinterInfos[i];
            printers.add(printerInfo.pPrinterName.toDartString());
          }
        }
        free(pBuffer);
      }
    } finally {
      free(pPrinterName);
      free(pNeeded);
      free(pReturned);
    }
    return printers;
  }

  /// Send raw bytes directly to a Windows printer spooler without blocking UI
  Future<bool> printRawData(String printerName, Uint8List data) async {
    return await Isolate.run(() {
      final pPrinterName = printerName.toNativeUtf16();
      final hPrinter = calloc<HANDLE>();
      final docInfo = calloc<DOC_INFO_1>();
      
      docInfo.ref.pDocName = 'Cafe Invoice'.toNativeUtf16();
      docInfo.ref.pOutputFile = nullptr;
      docInfo.ref.pDatatype = 'RAW'.toNativeUtf16();

      try {
        if (OpenPrinter(pPrinterName, hPrinter, nullptr) == 0) {
          throw Exception('OpenPrinter failed: \${GetLastError()}');
        }

        // Retry StartDocPrinter a few times if spooler is busy
        int docStarted = 0;
        for (var i = 0; i < 3; i++) {
          docStarted = StartDocPrinter(hPrinter.value, 1, docInfo);
          if (docStarted != 0) break;
          sleep(const Duration(milliseconds: 200));
        }

        if (docStarted == 0) {
          final err = GetLastError();
          ClosePrinter(hPrinter.value);
          throw Exception('StartDocPrinter failed: $err');
        }

        if (StartPagePrinter(hPrinter.value) == 0) {
          final err = GetLastError();
          EndDocPrinter(hPrinter.value);
          ClosePrinter(hPrinter.value);
          throw Exception('StartPagePrinter failed: $err');
        }

        final pBytes = calloc<BYTE>(data.length);
        pBytes.asTypedList(data.length).setAll(0, data);
        final dwWritten = calloc<DWORD>();

        // Try writing the data
        int success = WritePrinter(hPrinter.value, pBytes, data.length, dwWritten);
        final err = success == 0 ? GetLastError() : 0;

        EndPagePrinter(hPrinter.value);
        EndDocPrinter(hPrinter.value);
        ClosePrinter(hPrinter.value);

        free(pBytes);
        free(dwWritten);

        if (success == 0) {
          throw Exception('WritePrinter failed: $err');
        }

        return true;
      } finally {
        free(pPrinterName);
        free(hPrinter);
        free(docInfo.ref.pDocName);
        free(docInfo.ref.pDatatype);
        free(docInfo);
      }
    });
  }
}
