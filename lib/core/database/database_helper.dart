import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _instance;
  static Database? _database;

  DatabaseHelper._();
  factory DatabaseHelper() => _instance ??= DatabaseHelper._();

  String? _customPath;
  Future<Database>? _initDbFuture;

  /// Set the database path before initialization
  Future<void> initPath(String path) async {
    if (_customPath == path && _database != null) return;

    // Close existing connection if any
    await close();

    _customPath = path;
    _initDbFuture = null;
  }

  /// Close the current database connection
  Future<void> close() async {
    _initDbFuture = null;
    if (_database != null) {
      if (kDebugMode) debugPrint('Closing database at: $_customPath');
      await _database!.close();
      _database = null;
    }
  }

  Future<Database> get database async {
    if (_database != null) return _database!;

    // Ensure we don't have multiple simultaneous initializations
    _initDbFuture ??= _initDatabase();
    return await _initDbFuture!;
  }

  Future<Database> _initDatabase() async {
    String path;
    if (_customPath != null) {
      path = _customPath!;
    } else {
      final dir = await getApplicationDocumentsDirectory();
      path = join(dir.path, 'cafe_db.sqlite');
    }

    if (kDebugMode) debugPrint('DB path: $path');

    try {
      final db = await _openPlatformSpecificDatabase(path);
      _database = db;
      return db;
    } catch (e) {
      _initDbFuture = null; // Allow retry on failure
      if (kDebugMode) debugPrint('Error initializing database: $e');
      rethrow;
    }
  }

  Future<Database> _openPlatformSpecificDatabase(String path) async {
    if (Platform.isWindows || Platform.isLinux) {
      return await databaseFactoryFfi.openDatabase(
        path,
        options: OpenDatabaseOptions(
          version: 3,
          onCreate: _onCreate,
          onUpgrade: _onUpgrade,
          onConfigure: (db) async =>
              await db.execute('PRAGMA foreign_keys = ON'),
        ),
      );
    } else {
      return await openDatabase(
        path,
        version: 3,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
        onConfigure: (db) async => await db.execute('PRAGMA foreign_keys = ON'),
      );
    }
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE auth (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        password_hash TEXT NOT NULL,
        remember_me INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE categories (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        image_path TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        category_id TEXT NOT NULL,
        price REAL NOT NULL,
        image_path TEXT,
        sold_count INTEGER DEFAULT 0,
        created_at TEXT NOT NULL,
        FOREIGN KEY (category_id) REFERENCES categories(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        created_at TEXT NOT NULL,
        payment_method TEXT NOT NULL,
        total REAL NOT NULL,
        tax_enabled INTEGER DEFAULT 0,
        tax_percent REAL DEFAULT 0,
        tax_amount REAL DEFAULT 0,
        discount_enabled INTEGER DEFAULT 0,
        discount_type TEXT DEFAULT 'percentage',
        discount_value REAL DEFAULT 0,
        discount_amount REAL DEFAULT 0,
        status TEXT DEFAULT 'closed'
      )
    ''');

    await db.execute('''
      CREATE TABLE invoice_items (
        id TEXT PRIMARY KEY,
        invoice_id TEXT NOT NULL,
        product_id TEXT NOT NULL,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        FOREIGN KEY (invoice_id) REFERENCES invoices(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE expenses (
        id TEXT PRIMARY KEY,
        amount REAL NOT NULL,
        payment_type TEXT NOT NULL,
        description TEXT,
        created_at TEXT NOT NULL
      )
    ''');
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute(
          'ALTER TABLE invoices ADD COLUMN tax_enabled INTEGER DEFAULT 0');
      await db.execute(
          'ALTER TABLE invoices ADD COLUMN tax_percent REAL DEFAULT 0');
      await db
          .execute('ALTER TABLE invoices ADD COLUMN tax_amount REAL DEFAULT 0');
    }
    if (oldVersion < 3) {
      await db.execute(
          'ALTER TABLE invoices ADD COLUMN discount_enabled INTEGER DEFAULT 0');
      await db.execute(
          'ALTER TABLE invoices ADD COLUMN discount_type TEXT DEFAULT "percentage"');
      await db.execute(
          'ALTER TABLE invoices ADD COLUMN discount_value REAL DEFAULT 0');
      await db.execute(
          'ALTER TABLE invoices ADD COLUMN discount_amount REAL DEFAULT 0');
    }
  }

  // ── Auth ────────────────────────────────────────────────────────────────────
  Future<void> upsertAuth(String passwordHash) async {
    final db = await database;
    final existing = await db.query('auth', limit: 1);
    if (existing.isEmpty) {
      await db
          .insert('auth', {'password_hash': passwordHash, 'remember_me': 0});
    } else {
      await db.update('auth', {'password_hash': passwordHash});
    }
  }

  Future<Map<String, dynamic>?> getAuth() async {
    final db = await database;
    final rows = await db.query('auth', limit: 1);
    return rows.isEmpty ? null : rows.first;
  }

  // ── Categories ──────────────────────────────────────────────────────────────
  Future<int> insertCategory(Map<String, dynamic> data) async =>
      (await database).insert('categories', data);

  Future<int> updateCategory(String id, Map<String, dynamic> data) async =>
      (await database)
          .update('categories', data, where: 'id = ?', whereArgs: [id]);

  Future<int> deleteCategory(String id) async =>
      (await database).delete('categories', where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getCategories() async =>
      (await database).query('categories', orderBy: 'created_at DESC');

  // ── Products ─────────────────────────────────────────────────────────────────
  Future<int> insertProduct(Map<String, dynamic> data) async =>
      (await database).insert('products', data);

  Future<int> updateProduct(String id, Map<String, dynamic> data) async =>
      (await database)
          .update('products', data, where: 'id = ?', whereArgs: [id]);

  Future<int> deleteProduct(String id) async =>
      (await database).delete('products', where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getProducts({String? categoryId}) async {
    final db = await database;
    if (categoryId != null) {
      return db.query('products',
          where: 'category_id = ?',
          whereArgs: [categoryId],
          orderBy: 'name ASC');
    }
    return db.query('products', orderBy: 'name ASC');
  }

  Future<void> incrementSoldCount(String productId, int qty) async {
    final db = await database;
    await db.rawUpdate(
      'UPDATE products SET sold_count = sold_count + ? WHERE id = ?',
      [qty, productId],
    );
  }

  // ── Invoices ─────────────────────────────────────────────────────────────────
  Future<String> insertInvoice(Map<String, dynamic> invoiceData,
      List<Map<String, dynamic>> items) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.insert('invoices', invoiceData);
      for (final item in items) {
        await txn.insert('invoice_items', item);
      }
      // Update sold counts
      for (final item in items) {
        await txn.rawUpdate(
          'UPDATE products SET sold_count = sold_count + ? WHERE id = ?',
          [item['quantity'], item['product_id']],
        );
      }
    });
    return invoiceData['id'] as String;
  }

  Future<int> updateInvoice(String id, Map<String, dynamic> data,
      List<Map<String, dynamic>> items) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.update('invoices', data, where: 'id = ?', whereArgs: [id]);
      await txn
          .delete('invoice_items', where: 'invoice_id = ?', whereArgs: [id]);
      for (final item in items) {
        await txn.insert('invoice_items', item);
      }
    });
    return 1;
  }

  Future<int> deleteInvoice(String id) async {
    final db = await database;
    int result = 0;
    await db.transaction((txn) async {
      final items = await txn
          .query('invoice_items', where: 'invoice_id = ?', whereArgs: [id]);
      for (final item in items) {
        await txn.rawUpdate(
          'UPDATE products SET sold_count = MAX(0, sold_count - ?) WHERE id = ?',
          [item['quantity'], item['product_id']],
        );
      }
      result = await txn.delete('invoices', where: 'id = ?', whereArgs: [id]);
    });
    return result;
  }

  Future<List<Map<String, dynamic>>> getInvoices(
      {String? from, String? to}) async {
    final db = await database;
    if (from != null && to != null) {
      return db.query('invoices',
          where: 'created_at >= ? AND created_at <= ?',
          whereArgs: [from, to],
          orderBy: 'created_at DESC');
    }
    return db.query('invoices', orderBy: 'created_at DESC');
  }

  Future<List<Map<String, dynamic>>> getInvoiceItems(String invoiceId) async =>
      (await database).query('invoice_items',
          where: 'invoice_id = ?', whereArgs: [invoiceId]);

  Future<Map<String, dynamic>?> getInvoiceById(String id) async {
    final db = await database;
    final rows = await db.query('invoices', where: 'id = ?', whereArgs: [id]);
    return rows.isEmpty ? null : rows.first;
  }

  // ── Expenses ─────────────────────────────────────────────────────────────────
  Future<int> insertExpense(Map<String, dynamic> data) async =>
      (await database).insert('expenses', data);

  Future<int> updateExpense(String id, Map<String, dynamic> data) async =>
      (await database)
          .update('expenses', data, where: 'id = ?', whereArgs: [id]);

  Future<int> deleteExpense(String id) async =>
      (await database).delete('expenses', where: 'id = ?', whereArgs: [id]);

  Future<List<Map<String, dynamic>>> getExpenses(
      {String? from, String? to}) async {
    final db = await database;
    if (from != null && to != null) {
      return db.query('expenses',
          where: 'created_at >= ? AND created_at <= ?',
          whereArgs: [from, to],
          orderBy: 'created_at DESC');
    }
    return db.query('expenses', orderBy: 'created_at DESC');
  }

  // ── Dashboard ────────────────────────────────────────────────────────────────
  Future<Map<String, dynamic>> getDashboardStats(
      {String? from, String? to}) async {
    final db = await database;

    // Simpler approach
    final invoiceRows = await db.query('invoices',
        where: from != null ? 'created_at >= ? AND created_at <= ?' : null,
        whereArgs: from != null ? [from, to] : null);

    double cashIncome = 0, cardIncome = 0;
    for (final r in invoiceRows) {
      if (r['payment_method'] == 'cash') {
        cashIncome += (r['total'] as num).toDouble();
      } else {
        cardIncome += (r['total'] as num).toDouble();
      }
    }

    final expenseRows = await db.query('expenses',
        where: from != null ? 'created_at >= ? AND created_at <= ?' : null,
        whereArgs: from != null ? [from, to] : null);

    double totalExpenses = 0;
    for (final r in expenseRows) {
      totalExpenses += (r['amount'] as num).toDouble();
    }

    return {
      'cashIncome': cashIncome,
      'cardIncome': cardIncome,
      'totalIncome': cashIncome + cardIncome,
      'totalExpenses': totalExpenses,
      'netProfit': cashIncome + cardIncome - totalExpenses,
      'totalInvoices': invoiceRows.length,
    };
  }

  Future<List<Map<String, dynamic>>> getTopProducts(
      {String? from, String? to, int limit = 7}) async {
    final db = await database;
    String dateFilter = '';
    List<dynamic> args = [];
    if (from != null && to != null) {
      dateFilter = ' WHERE i.created_at >= ? AND i.created_at <= ?';
      args = [from, to];
    }
    return db.rawQuery('''
      SELECT ii.product_name, SUM(ii.quantity) as total_qty, SUM(ii.quantity * ii.price) as total_revenue
      FROM invoice_items ii
      JOIN invoices i ON ii.invoice_id = i.id
      $dateFilter
      GROUP BY ii.product_id
      ORDER BY total_qty DESC
      LIMIT $limit
    ''', args);
  }

  Future<List<Map<String, dynamic>>> getSalesByDay(
      {String? from, String? to}) async {
    final db = await database;
    String dateFilter = '';
    List<dynamic> args = [];
    if (from != null && to != null) {
      dateFilter = 'WHERE created_at >= ? AND created_at <= ?';
      args = [from, to];
    }
    return db.rawQuery('''
      SELECT substr(created_at, 1, 10) as day, SUM(total) as total, COUNT(*) as count
      FROM invoices
      $dateFilter
      GROUP BY day
      ORDER BY day ASC
    ''', args);
  }
}
