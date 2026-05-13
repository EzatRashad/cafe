import 'dart:ffi';
import 'dart:isolate';
import 'package:ffi/ffi.dart';
import 'package:flutter/foundation.dart';
import 'package:win32/win32.dart';

/// Represents a Windows printer installed on the system.
class PrinterModel {
  final String name;
  final bool isDefault;

  const PrinterModel({required this.name, required this.isDefault});

  /// Label shown in the UI dropdown.
  String get displayName => isDefault ? '$name (Default)' : name;

  @override
  String toString() => 'PrinterModel(name: $name, isDefault: $isDefault)';
}

class PrinterService {
  // ── Printer Discovery (Win32 API) ─────────────────────────────────────────

  /// Enumerate all installed Windows printers using EnumPrintersW.
  Future<List<PrinterModel>> getWindowsPrinters() async {
    final printers = <PrinterModel>[];
    final defaultPrinter = _getDefaultPrinter();
    debugPrint('[PrinterService] Default printer in system: $defaultPrinter');

    final pNeeded = calloc<DWORD>();
    final pReturned = calloc<DWORD>();
    const flags = PRINTER_ENUM_LOCAL | PRINTER_ENUM_CONNECTIONS;

    try {
      // 1. Get the required buffer size
      EnumPrinters(flags, nullptr, 2, nullptr, 0, pNeeded, pReturned);

      if (pNeeded.value == 0) {
        debugPrint('[PrinterService] No printers found via EnumPrinters.');
        return [];
      }

      // 2. Allocate buffer and call EnumPrinters again
      final pBuffer = calloc<BYTE>(pNeeded.value);
      if (EnumPrinters(
              flags, nullptr, 2, pBuffer, pNeeded.value, pNeeded, pReturned) !=
          0) {
        final pPrinterInfos = pBuffer.cast<PRINTER_INFO_2>();

        for (var i = 0; i < pReturned.value; i++) {
          final printerInfo = pPrinterInfos[i];
          final printerName =
              printerInfo.pPrinterName.cast<Utf16>().toDartString();

          final isDefault = printerName == defaultPrinter;
          debugPrint(
              '[PrinterService] Found: $printerName (Default: $isDefault)');

          printers.add(PrinterModel(
            name: printerName,
            isDefault: isDefault,
          ));
        }
      } else {
        debugPrint('[PrinterService] EnumPrinters failed: ${GetLastError()}');
      }
      free(pBuffer);
    } catch (e) {
      debugPrint('[PrinterService] Error in discovery: $e');
    } finally {
      free(pNeeded);
      free(pReturned);
    }

    return printers;
  }

  /// Get the system default printer name using GetDefaultPrinterW.
  String? _getDefaultPrinter() {
    final pcchBuffer = calloc<DWORD>();
    try {
      GetDefaultPrinter(nullptr, pcchBuffer);
      if (pcchBuffer.value == 0) return null;

      final pszBuffer = calloc<Uint16>(pcchBuffer.value).cast<Utf16>();
      if (GetDefaultPrinter(pszBuffer, pcchBuffer) != 0) {
        return pszBuffer.toDartString();
      }
    } catch (_) {
      // Ignore
    } finally {
      free(pcchBuffer);
    }
    return null;
  }

  // ── Raw Printing (Win32 spooler) ─────────────────────────────────────────

  /// Send raw ESC/POS bytes to a named Windows printer via the spooler.
  /// Runs in a separate [Isolate] so the UI never freezes.
  Future<bool> printRawData(String printerName, Uint8List data) async {
    return await Isolate.run(() {
      final pName = printerName.toNativeUtf16();
      final hPrinter = calloc<HANDLE>();
      final docInfo = calloc<DOC_INFO_1>();
      final pDefault = calloc<PRINTER_DEFAULTS>();

      // Request enough access for basic spooling
      pDefault.ref.DesiredAccess = PRINTER_ACCESS_USE;
      pDefault.ref.pDatatype = 'RAW'.toNativeUtf16();
      pDefault.ref.pDevMode = nullptr;

      docInfo.ref.pDocName = 'POS Receipt'.toNativeUtf16();
      docInfo.ref.pOutputFile = nullptr;
      docInfo.ref.pDatatype = 'RAW'.toNativeUtf16();

      try {
        // Open the printer with explicit RAW datatype defaults
        if (OpenPrinter(pName, hPrinter, pDefault) == 0) {
          final err = GetLastError();
          throw Exception(
              'فشل فتح الطابعة (OpenPrinter Error: $err). تأكد من توصيل الطابعة وصحة الاسم.');
        }

        // Start the print job
        final jobId = StartDocPrinter(hPrinter.value, 1, docInfo);
        if (jobId == 0) {
          final err = GetLastError();
          ClosePrinter(hPrinter.value);
          throw Exception(
              'فشل بدء مهمة الطباعة (StartDocPrinter Error: $err). جرب إيقاف الطابعة وتشغيلها.');
        }

        if (StartPagePrinter(hPrinter.value) == 0) {
          final err = GetLastError();
          EndDocPrinter(hPrinter.value);
          ClosePrinter(hPrinter.value);
          throw Exception('فشل بدء الصفحة (StartPagePrinter Error: $err)');
        }

        final pBytes = calloc<BYTE>(data.length);
        pBytes.asTypedList(data.length).setAll(0, data);
        final dwWritten = calloc<DWORD>();

        final success =
            WritePrinter(hPrinter.value, pBytes, data.length, dwWritten);
        final err = success == 0 ? GetLastError() : 0;

        EndPagePrinter(hPrinter.value);
        EndDocPrinter(hPrinter.value);
        ClosePrinter(hPrinter.value);

        free(pBytes);
        free(dwWritten);

        if (success == 0)
          throw Exception('فشل إرسال البيانات (WritePrinter Error: $err)');
        return true;
      } finally {
        free(pName);
        free(hPrinter);
        free(docInfo.ref.pDocName);
        free(docInfo.ref.pDatatype);
        free(docInfo);
        free(pDefault.ref.pDatatype);
        free(pDefault);
      }
    });
  }
}
