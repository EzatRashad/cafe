import 'package:intl/intl.dart';

class DateFormatter {
  static String formatDate(DateTime date) =>
      DateFormat('yyyy-MM-dd').format(date);

  static String formatDateTime(DateTime date) =>
      DateFormat('yyyy-MM-dd HH:mm').format(date);

  static String formatDisplayDate(DateTime date) =>
      DateFormat('dd MMM yyyy').format(date);

  static String formatDisplayDateTime(DateTime date) =>
      DateFormat('dd MMM yyyy  HH:mm').format(date);

  static String formatMonth(DateTime date) =>
      DateFormat('MMMM yyyy').format(date);

  static String formatShortDate(DateTime date) =>
      DateFormat('dd/MM').format(date);

  static DateTime startOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 0, 0, 0);

  static DateTime endOfDay(DateTime date) =>
      DateTime(date.year, date.month, date.day, 23, 59, 59);

  static DateTime startOfMonth(DateTime date) =>
      DateTime(date.year, date.month, 1);

  static DateTime endOfMonth(DateTime date) =>
      DateTime(date.year, date.month + 1, 0, 23, 59, 59);

  static DateTime startOfYear(DateTime date) => DateTime(date.year, 1, 1);

  static DateTime endOfYear(DateTime date) =>
      DateTime(date.year, 12, 31, 23, 59, 59);
}
