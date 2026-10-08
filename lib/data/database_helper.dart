import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import '../core/security.dart';

/// Membuka basis data SQLite lokal dan mengisi data awal (seed).
class DatabaseHelper {
  DatabaseHelper._();
  static final DatabaseHelper instance = DatabaseHelper._();

  static const String _dbName = 'pos_voice.db';
  static const int _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    return _db ??= await _open();
  }

  Future<Database> _open() async {
    final dir = await getDatabasesPath();
    return openDatabase(
      join(dir, _dbName),
      version: _dbVersion,
      onConfigure: (db) => db.execute('PRAGMA foreign_keys = ON'),
      onCreate: _onCreate,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE users (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        password_hash TEXT NOT NULL,
        nama TEXT NOT NULL,
        role TEXT NOT NULL CHECK (role IN ('admin', 'kasir'))
      )''');
    await db.execute('''
      CREATE TABLE categories (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        nama TEXT NOT NULL UNIQUE
      )''');
    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        category_id INTEGER,
        nama TEXT NOT NULL,
        harga_jual INTEGER NOT NULL,
        stok INTEGER NOT NULL DEFAULT 0,
        stok_minimum INTEGER NOT NULL DEFAULT 5,
        barcode TEXT UNIQUE,
        is_active INTEGER NOT NULL DEFAULT 1,
        FOREIGN KEY (category_id) REFERENCES categories (id) ON DELETE SET NULL
      )''');
    await db.execute('''
      CREATE TABLE transactions (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        user_id INTEGER NOT NULL,
        kode TEXT NOT NULL UNIQUE,
        tanggal TEXT NOT NULL,
        subtotal INTEGER NOT NULL,
        diskon INTEGER NOT NULL DEFAULT 0,
        total INTEGER NOT NULL,
        bayar INTEGER NOT NULL,
        kembalian INTEGER NOT NULL,
        metode TEXT NOT NULL DEFAULT 'tunai',
        FOREIGN KEY (user_id) REFERENCES users (id)
      )''');
    await db.execute('''
      CREATE TABLE transaction_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        transaction_id INTEGER NOT NULL,
        product_id INTEGER,
        nama_produk TEXT NOT NULL,
        harga INTEGER NOT NULL,
        qty INTEGER NOT NULL,
        subtotal INTEGER NOT NULL,
        FOREIGN KEY (transaction_id) REFERENCES transactions (id) ON DELETE CASCADE,
        FOREIGN KEY (product_id) REFERENCES products (id) ON DELETE SET NULL
      )''');
    await db.execute('CREATE INDEX idx_transactions_tanggal ON transactions (tanggal)');
    await _seed(db);
  }

  Future<void> _seed(Database db) async {
    final batch = db.batch();
    batch.insert('users', {
      'username': 'admin',
      'password_hash': Security.hashPassword('admin123'),
      'nama': 'Admin Toko',
      'role': 'admin',
    });
    batch.insert('users', {
      'username': 'kasir',
      'password_hash': Security.hashPassword('kasir123'),
      'nama': 'Kasir Toko',
      'role': 'kasir',
    });
    for (final c in ['Makanan', 'Minuman', 'Sembako', 'Rumah Tangga']) {
      batch.insert('categories', {'nama': c});
    }
    // kategori: 1 Makanan, 2 Minuman, 3 Sembako, 4 Rumah Tangga
    const products = <List<Object?>>[
      ['Mie Goreng Instan', 1, 3500, 120, 20, '8990000000011'],
      ['Biskuit Kelapa', 1, 8000, 40, 10, '8990000000028'],
      ['Roti Tawar', 1, 16000, 5, 5, '8990000000035'],
      ['Telur Ayam 1 kg', 3, 28000, 25, 5, null],
      ['Beras 5 kg', 3, 68000, 18, 5, '8990000000042'],
      ['Gula Pasir 1 kg', 3, 17000, 8, 10, '8990000000059'],
      ['Minyak Goreng 1 L', 3, 18500, 35, 8, '8990000000066'],
      ['Teh Celup', 2, 6500, 60, 10, '8990000000073'],
      ['Kopi Sachet', 2, 2000, 200, 30, '8990000000080'],
      ['Air Mineral 600 ml', 2, 3500, 150, 24, '8990000000097'],
      ['Susu Kental Manis', 2, 12500, 30, 6, '8990000000103'],
      ['Sabun Mandi', 4, 4500, 45, 10, '8990000000110'],
      ['Deterjen 800 g', 4, 21000, 4, 5, '8990000000127'],
    ];
    for (final p in products) {
      batch.insert('products', {
        'nama': p[0],
        'category_id': p[1],
        'harga_jual': p[2],
        'stok': p[3],
        'stok_minimum': p[4],
        'barcode': p[5],
      });
    }
    await batch.commit(noResult: true);
  }
}
