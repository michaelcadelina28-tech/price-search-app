import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/product.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  factory DatabaseService() => _instance;
  DatabaseService._internal();

  Database? _db;

  Future<Database> get database async {
    _db ??= await _initDatabase();
    return _db!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'price_search.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE products (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            itemNo      TEXT,
            description TEXT NOT NULL,
            quantity    INTEGER DEFAULT 0,
            regularPrice REAL DEFAULT 0,
            retailPrice  REAL DEFAULT 0,
            vendor      TEXT,
            encoded     TEXT
          )
        ''');
        await db.execute('CREATE INDEX idx_description ON products(description)');
        await db.execute('CREATE INDEX idx_itemNo      ON products(itemNo)');
        await db.execute('CREATE INDEX idx_vendor      ON products(vendor)');
      },
    );
  }

  // Replace all data with new import
  Future<void> importProducts(List<Product> products) async {
    final db = await database;
    final batch = db.batch();
    batch.delete('products');
    for (final p in products) {
      batch.insert('products', p.toMap());
    }
    await batch.commit(noResult: true);
  }

  // Search by description or itemNo; optional vendor filter
  Future<List<Product>> searchProducts(String query, {String? vendor}) async {
    final db = await database;
    final q = '%${query.toLowerCase()}%';

    String where = '(LOWER(description) LIKE ? OR LOWER(itemNo) LIKE ?)';
    List<dynamic> args = [q, q];

    if (vendor != null && vendor.isNotEmpty && vendor != 'All') {
      where += ' AND vendor = ?';
      args.add(vendor);
    }

    final maps = await db.query(
      'products',
      where: where,
      whereArgs: args,
      orderBy: 'description ASC',
      limit: 150,
    );
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  // Get all products (optional vendor filter)
  Future<List<Product>> getAllProducts({String? vendor}) async {
    final db = await database;
    if (vendor != null && vendor.isNotEmpty && vendor != 'All') {
      final maps = await db.query(
        'products',
        where: 'vendor = ?',
        whereArgs: [vendor],
        orderBy: 'description ASC',
        limit: 150,
      );
      return maps.map((m) => Product.fromMap(m)).toList();
    }
    final maps = await db.query('products', orderBy: 'description ASC', limit: 150);
    return maps.map((m) => Product.fromMap(m)).toList();
  }

  // Get distinct vendor list
  Future<List<String>> getVendors() async {
    final db = await database;
    final result = await db.rawQuery(
      "SELECT DISTINCT vendor FROM products "
      "WHERE vendor IS NOT NULL AND vendor != '' "
      "ORDER BY vendor ASC",
    );
    return result.map((r) => r['vendor'].toString()).toList();
  }

  Future<int> getProductCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) as c FROM products');
    return (result.first['c'] as int?) ?? 0;
  }
}
