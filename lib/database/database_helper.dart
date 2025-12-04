import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:expense_tracker/utils/constants.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB(AppStrings.databaseName);
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: AppStrings.databaseVersion,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';

    // Users table
    await db.execute('''
      CREATE TABLE ${AppStrings.tableUsers} (
        id $idType,
        username $textType,
        email $textType UNIQUE,
        password $textType,
        createdAt $textType
      )
    ''');

    // Income table
    await db.execute('''
      CREATE TABLE ${AppStrings.tableIncome} (
        id $idType,
        userId $intType,
        amount $realType,
        category $textType,
        notes $textType,
        date $textType,
        FOREIGN KEY (userId) REFERENCES ${AppStrings.tableUsers} (id) ON DELETE CASCADE
      )
    ''');

    // Expenses table
    await db.execute('''
      CREATE TABLE ${AppStrings.tableExpense} (
        id $idType,
        userId $intType,
        amount $realType,
        category $textType,
        notes $textType,
        billPath TEXT,
        date $textType,
        FOREIGN KEY (userId) REFERENCES ${AppStrings.tableUsers} (id) ON DELETE CASCADE
      )
    ''');

    // Inventory table
    await db.execute('''
      CREATE TABLE ${AppStrings.tableInventory} (
        id $idType,
        userId $intType,
        name $textType,
        quantity $intType,
        lowStockThreshold $intType,
        lastUpdated $textType,
        FOREIGN KEY (userId) REFERENCES ${AppStrings.tableUsers} (id) ON DELETE CASCADE
      )
    ''');

    // Budgets table
    await db.execute('''
      CREATE TABLE ${AppStrings.tableBudget} (
        id $idType,
        userId $intType,
        monthlyBudget $realType,
        spentAmount $realType,
        month $intType,
        year $intType,
        FOREIGN KEY (userId) REFERENCES ${AppStrings.tableUsers} (id) ON DELETE CASCADE
      )
    ''');

    // Categories table
    await db.execute('''
      CREATE TABLE ${AppStrings.tableCategory} (
        id $idType,
        name $textType,
        type $textType,
        userId $intType,
        FOREIGN KEY (userId) REFERENCES ${AppStrings.tableUsers} (id) ON DELETE CASCADE
      )
    ''');

    // GST Calculations table
    await db.execute('''
      CREATE TABLE ${AppStrings.tableGST} (
        id $idType,
        userId $intType,
        amount $realType,
        gstPercent $realType,
        cgst $realType,
        sgst $realType,
        total $realType,
        date $textType,
        FOREIGN KEY (userId) REFERENCES ${AppStrings.tableUsers} (id) ON DELETE CASCADE
      )
    ''');
  }

  // Generic CRUD operations
  Future<int> insert(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAll(String table) async {
    final db = await instance.database;
    return await db.query(table);
  }

  Future<List<Map<String, dynamic>>> queryWhere(
    String table,
    String where,
    List<dynamic> whereArgs,
  ) async {
    final db = await instance.database;
    return await db.query(table, where: where, whereArgs: whereArgs);
  }

  Future<int> update(String table, Map<String, dynamic> row) async {
    final db = await instance.database;
    final id = row['id'];
    return await db.update(table, row, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> delete(String table, int id) async {
    final db = await instance.database;
    return await db.delete(table, where: 'id = ?', whereArgs: [id]);
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
