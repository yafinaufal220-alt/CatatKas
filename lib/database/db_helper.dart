import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction.dart';

class DBHelper {
  static final DBHelper instance = DBHelper._init();
  static Database? _database;

  DBHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('keuangan.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(path, version: 1, onCreate: _createDB);
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        title TEXT NOT NULL,
        amount REAL NOT NULL,
        type TEXT NOT NULL,
        category TEXT NOT NULL,
        note TEXT,
        date TEXT NOT NULL
      )
    ''');
  }

  // Tambah transaksi
  Future<int> insertTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.insert('transactions', transaction.toMap());
  }

  // Ambil semua transaksi
  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await instance.database;
    final result = await db.query('transactions', orderBy: 'date DESC');
    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }

  // Ambil transaksi berdasarkan periode
  Future<List<TransactionModel>> getTransactionsByPeriod(
      DateTime start, DateTime end) async {
    final db = await instance.database;
    final result = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start.toIso8601String(), end.toIso8601String()],
      orderBy: 'date DESC',
    );
    return result.map((e) => TransactionModel.fromMap(e)).toList();
  }

  // Update transaksi
  Future<int> updateTransaction(TransactionModel transaction) async {
    final db = await instance.database;
    return await db.update(
      'transactions',
      transaction.toMap(),
      where: 'id = ?',
      whereArgs: [transaction.id],
    );
  }

  // Hapus transaksi
  Future<int> deleteTransaction(int id) async {
    final db = await instance.database;
    return await db.delete(
      'transactions',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // Total pemasukan
  Future<double> getTotalIncome() async {
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE type = 'income'");
    return result.first['total'] as double? ?? 0.0;
  }

  // Total pengeluaran
  Future<double> getTotalExpense() async {
    final db = await instance.database;
    final result = await db.rawQuery(
        "SELECT SUM(amount) as total FROM transactions WHERE type = 'expense'");
    return result.first['total'] as double? ?? 0.0;
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}