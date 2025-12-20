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
      onUpgrade: _upgradeDB,
    );
  }

  Future _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add bookings table
      await db.execute('''
        CREATE TABLE ${AppStrings.tableBookings} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          customer_name TEXT NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          booking_date TEXT NOT NULL,
          booking_time TEXT NOT NULL,
          reminder_before INTEGER DEFAULT 60,
          is_completed INTEGER DEFAULT 0,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES ${AppStrings.tableUsers} (id) ON DELETE CASCADE
        )
      ''');

      // Add wishlist table
      await db.execute('''
        CREATE TABLE ${AppStrings.tableWishlist} (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          item_name TEXT NOT NULL,
          quantity INTEGER DEFAULT 1,
          priority TEXT NOT NULL,
          expected_month TEXT NOT NULL,
          notes TEXT,
          is_purchased INTEGER DEFAULT 0,
          purchased_date TEXT,
          created_at TEXT NOT NULL,
          FOREIGN KEY (user_id) REFERENCES ${AppStrings.tableUsers} (id) ON DELETE CASCADE
        )
      ''');
    }
    
    if (oldVersion < 3) {
      // Add new columns to inventory table
      try {
        await db.execute('ALTER TABLE ${AppStrings.tableInventory} ADD COLUMN category TEXT');
      } catch (e) {
        // Column might already exist
      }
      try {
        await db.execute('ALTER TABLE ${AppStrings.tableInventory} ADD COLUMN unit TEXT DEFAULT "pcs"');
      } catch (e) {
        // Column might already exist
      }
      try {
        await db.execute('ALTER TABLE ${AppStrings.tableInventory} ADD COLUMN notes TEXT');
      } catch (e) {
        // Column might already exist
      }
      
      // Create inventory_history table
      await db.execute('''
        CREATE TABLE IF NOT EXISTS inventory_history (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          inventory_id INTEGER NOT NULL,
          user_id INTEGER NOT NULL,
          action_type TEXT NOT NULL,
          quantity INTEGER NOT NULL,
          reason TEXT NOT NULL,
          date TEXT NOT NULL,
          FOREIGN KEY (inventory_id) REFERENCES ${AppStrings.tableInventory} (id) ON DELETE CASCADE,
          FOREIGN KEY (user_id) REFERENCES ${AppStrings.tableUsers} (id) ON DELETE CASCADE
        )
      ''');
    }
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
        category TEXT,
        quantity $intType,
        lowStockThreshold $intType,
        unit TEXT DEFAULT 'pcs',
        notes TEXT,
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

    // Bookings table
    await db.execute('''
      CREATE TABLE ${AppStrings.tableBookings} (
        id $idType,
        user_id $intType,
        customer_name $textType,
        title $textType,
        description TEXT,
        booking_date $textType,
        booking_time $textType,
        reminder_before INTEGER DEFAULT 60,
        is_completed INTEGER DEFAULT 0,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES ${AppStrings.tableUsers} (id) ON DELETE CASCADE
      )
    ''');

    // Wishlist table
    await db.execute('''
      CREATE TABLE ${AppStrings.tableWishlist} (
        id $idType,
        user_id $intType,
        item_name $textType,
        quantity INTEGER DEFAULT 1,
        priority $textType,
        expected_month $textType,
        notes TEXT,
        is_purchased INTEGER DEFAULT 0,
        purchased_date TEXT,
        created_at $textType,
        FOREIGN KEY (user_id) REFERENCES ${AppStrings.tableUsers} (id) ON DELETE CASCADE
      )
    ''');

    // Inventory History table
    await db.execute('''
      CREATE TABLE inventory_history (
        id $idType,
        inventory_id $intType,
        user_id $intType,
        action_type $textType,
        quantity $intType,
        reason $textType,
        date $textType,
        FOREIGN KEY (inventory_id) REFERENCES ${AppStrings.tableInventory} (id) ON DELETE CASCADE,
        FOREIGN KEY (user_id) REFERENCES ${AppStrings.tableUsers} (id) ON DELETE CASCADE
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
