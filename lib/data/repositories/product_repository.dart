import '../database_helper.dart';
import '../models/product.dart';

class ProductRepository {
  ProductRepository([DatabaseHelper? helper]) : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  static const String _select =
      'SELECT p.*, c.nama AS category_name FROM products p '
      'LEFT JOIN categories c ON c.id = p.category_id';

  Future<List<Product>> getActive() async {
    final db = await _helper.database;
    final rows = await db.rawQuery('$_select WHERE p.is_active = 1 ORDER BY p.nama COLLATE NOCASE');
    return rows.map(Product.fromMap).toList();
  }

  Future<List<Category>> getCategories() async {
    final db = await _helper.database;
    final rows = await db.query('categories', orderBy: 'id');
    return rows.map(Category.fromMap).toList();
  }

  Future<int> insert(Product p) async {
    final db = await _helper.database;
    return db.insert('products', p.toMap());
  }

  Future<void> update(Product p) async {
    final db = await _helper.database;
    await db.update('products', p.toMap(), where: 'id = ?', whereArgs: [p.id]);
  }

  /// Produk tidak dihapus permanen agar riwayat transaksi tetap valid.
  Future<void> deactivate(int id) async {
    final db = await _helper.database;
    await db.update(
      'products',
      {'is_active': 0, 'barcode': null},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}
