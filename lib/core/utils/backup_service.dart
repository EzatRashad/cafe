import 'dart:convert';
import 'dart:io';
import '../database/database_helper.dart';

class BackupService {
  final DatabaseHelper _db;

  BackupService(this._db);

  /// Export all database tables into a single JSON file
  Future<String> exportToJson(String backupPath) async {
    final db = await _db.database;
    final Map<String, dynamic> backupData = {};

    final tables = [
      'auth',
      'categories',
      'products',
      'invoices',
      'invoice_items',
      'expenses'
    ];

    for (final table in tables) {
      final rows = await db.query(table);
      backupData[table] = rows;
    }

    final jsonString = jsonEncode(backupData);
    final timestamp =
        DateTime.now().toIso8601String().replaceAll(':', '-').split('.').first;
    final file = File('$backupPath/backup_$timestamp.json');
    await file.writeAsString(jsonString);

    return file.path;
  }

  /// Import database data from a JSON file
  /// This will clear existing tables and replace them with backup data
  Future<void> importFromJson(File file) async {
    final db = await _db.database;
    final jsonString = await file.readAsString();
    final Map<String, dynamic> backupData = jsonDecode(jsonString);

    await db.transaction((txn) async {
      // Clear tables in reverse dependency order
      await txn.delete('invoice_items');
      await txn.delete('invoices');
      await txn.delete('products');
      await txn.delete('categories');
      await txn.delete('expenses');
      await txn.delete('auth');

      // Populate tables
      for (final table in backupData.keys) {
        final List<dynamic> rows = backupData[table];
        for (final row in rows) {
          await txn.insert(table, Map<String, dynamic>.from(row));
        }
      }
    });
  }
}
