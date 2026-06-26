// utils/database_helper.dart

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/transaction_model.dart';
import '../models/budget_model.dart';
import '../models/user_model.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'expense_tracker.db');

    return openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        email TEXT UNIQUE NOT NULL,
        passwordHash TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE transactions (
        id TEXT PRIMARY KEY,
        type TEXT NOT NULL,
        amount REAL NOT NULL,
        category TEXT NOT NULL,
        description TEXT NOT NULL,
        paymentMethod TEXT NOT NULL,
        date TEXT NOT NULL,
        createdAt TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE budgets (
        id TEXT PRIMARY KEY,
        category TEXT NOT NULL,
        `limit` REAL NOT NULL,
        month INTEGER NOT NULL,
        year INTEGER NOT NULL
      )
    ''');
  }

  // ─── USER OPERATIONS ───────────────────────────────────────────────────────

  Future<int> insertUser(UserModel user) async {
    final db = await database;
    return db.insert('users', user.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<UserModel?> getUserByEmail(String email) async {
    final db = await database;
    final maps = await db.query('users', where: 'email = ?', whereArgs: [email]);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  Future<UserModel?> getUserById(String id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isEmpty) return null;
    return UserModel.fromMap(maps.first);
  }

  // ─── TRANSACTION OPERATIONS ────────────────────────────────────────────────

  Future<int> insertTransaction(TransactionModel txn) async {
    final db = await database;
    return db.insert('transactions', txn.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<int> updateTransaction(TransactionModel txn) async {
    final db = await database;
    return db.update('transactions', txn.toMap(), where: 'id = ?', whereArgs: [txn.id]);
  }

  Future<int> deleteTransaction(String id) async {
    final db = await database;
    return db.delete('transactions', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<TransactionModel>> getAllTransactions() async {
    final db = await database;
    final maps = await db.query('transactions', orderBy: 'date DESC, createdAt DESC');
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> getTransactionsByMonth(int month, int year) async {
    final db = await database;
    final start = DateTime(year, month, 1).toIso8601String();
    final end = DateTime(year, month + 1, 0, 23, 59, 59).toIso8601String();
    final maps = await db.query(
      'transactions',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [start, end],
      orderBy: 'date DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  Future<List<TransactionModel>> searchTransactions(String query) async {
    final db = await database;
    final maps = await db.query(
      'transactions',
      where: 'description LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'date DESC',
    );
    return maps.map((m) => TransactionModel.fromMap(m)).toList();
  }

  // ─── BUDGET OPERATIONS ────────────────────────────────────────────────────

  Future<int> insertOrUpdateBudget(BudgetModel budget) async {
    final db = await database;
    return db.insert('budgets', budget.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
  }

  Future<List<BudgetModel>> getBudgetsForMonth(int month, int year) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'month = ? AND year = ?',
      whereArgs: [month, year],
    );
    return maps.map((m) => BudgetModel.fromMap(m)).toList();
  }

  Future<BudgetModel?> getTotalBudget(int month, int year) async {
    final db = await database;
    final maps = await db.query(
      'budgets',
      where: 'category = ? AND month = ? AND year = ?',
      whereArgs: ['total', month, year],
    );
    if (maps.isEmpty) return null;
    return BudgetModel.fromMap(maps.first);
  }

  Future<int> deleteBudget(String id) async {
    final db = await database;
    return db.delete('budgets', where: 'id = ?', whereArgs: [id]);
  }
}