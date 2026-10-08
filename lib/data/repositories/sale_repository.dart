import 'package:intl/intl.dart';

import '../database_helper.dart';
import '../models/cart_item.dart';
import '../models/sale.dart';

/// Kesalahan yang dapat ditampilkan langsung kepada pengguna saat checkout.
class CheckoutException implements Exception {
  CheckoutException(this.message);
  final String message;

  @override
  String toString() => message;
}

class SaleRepository {
  SaleRepository([DatabaseHelper? helper]) : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  /// Menyimpan transaksi dan mengurangi stok dalam satu transaksi basis data.
  Future<Sale> checkout({
    required List<CartItem> items,
    required int diskon,
    required int bayar,
    required int userId,
    String? kasirNama,
  }) async {
    if (items.isEmpty) throw CheckoutException('Keranjang masih kosong.');
    final db = await _helper.database;
    return db.transaction<Sale>((txn) async {
      var subtotal = 0;
      for (final it in items) {
        final rows = await txn.query(
          'products',
          columns: ['stok'],
          where: 'id = ? AND is_active = 1',
          whereArgs: [it.product.id],
        );
        if (rows.isEmpty) {
          throw CheckoutException('Produk "${it.product.nama}" sudah tidak tersedia.');
        }
        final stok = rows.first['stok'] as int;
        if (stok < it.qty) {
          throw CheckoutException('Stok "${it.product.nama}" tidak cukup (sisa $stok).');
        }
        subtotal += it.subtotal;
      }
      if (diskon < 0 || diskon > subtotal) {
        throw CheckoutException('Diskon tidak valid.');
      }
      final total = subtotal - diskon;
      if (bayar < total) {
        throw CheckoutException('Nominal bayar kurang dari total.');
      }

      final now = DateTime.now();
      final start = DateTime(now.year, now.month, now.day);
      final end = start.add(const Duration(days: 1));
      final countRows = await txn.rawQuery(
        'SELECT COUNT(*) AS c FROM transactions WHERE tanggal >= ? AND tanggal < ?',
        [start.toIso8601String(), end.toIso8601String()],
      );
      final seq = (countRows.first['c'] as int) + 1;
      final kode = 'TRX-${DateFormat('yyyyMMdd').format(now)}-${seq.toString().padLeft(4, '0')}';
      final kembalian = bayar - total;

      final saleId = await txn.insert('transactions', {
        'user_id': userId,
        'kode': kode,
        'tanggal': now.toIso8601String(),
        'subtotal': subtotal,
        'diskon': diskon,
        'total': total,
        'bayar': bayar,
        'kembalian': kembalian,
        'metode': 'tunai',
      });

      for (final it in items) {
        await txn.insert('transaction_items', {
          'transaction_id': saleId,
          'product_id': it.product.id,
          'nama_produk': it.product.nama,
          'harga': it.product.hargaJual,
          'qty': it.qty,
          'subtotal': it.subtotal,
        });
        await txn.rawUpdate(
          'UPDATE products SET stok = stok - ? WHERE id = ?',
          [it.qty, it.product.id],
        );
      }

      return Sale(
        id: saleId,
        kode: kode,
        tanggal: now,
        subtotal: subtotal,
        diskon: diskon,
        total: total,
        bayar: bayar,
        kembalian: kembalian,
        metode: 'tunai',
        kasirNama: kasirNama,
        items: items
            .map((e) => SaleItem(
                  productId: e.product.id,
                  namaProduk: e.product.nama,
                  harga: e.product.hargaJual,
                  qty: e.qty,
                ))
            .toList(),
      );
    });
  }

  Future<List<Sale>> getSales(DateTime from, DateTime to) async {
    final db = await _helper.database;
    final rows = await db.rawQuery(
      'SELECT t.*, u.nama AS kasir_nama FROM transactions t '
      'LEFT JOIN users u ON u.id = t.user_id '
      'WHERE t.tanggal >= ? AND t.tanggal < ? ORDER BY t.tanggal DESC',
      [from.toIso8601String(), to.toIso8601String()],
    );
    return rows.map((m) => Sale.fromMap(m)).toList();
  }

  Future<Sale?> getSaleWithItems(int id) async {
    final db = await _helper.database;
    final rows = await db.rawQuery(
      'SELECT t.*, u.nama AS kasir_nama FROM transactions t '
      'LEFT JOIN users u ON u.id = t.user_id WHERE t.id = ?',
      [id],
    );
    if (rows.isEmpty) return null;
    final itemRows = await db.query('transaction_items', where: 'transaction_id = ?', whereArgs: [id]);
    return Sale.fromMap(rows.first, items: itemRows.map(SaleItem.fromMap).toList());
  }

  Future<SalesSummary> getSummary(DateTime from, DateTime to) async {
    final db = await _helper.database;
    final args = [from.toIso8601String(), to.toIso8601String()];
    final t = await db.rawQuery(
      'SELECT COALESCE(SUM(total), 0) AS total, COUNT(*) AS cnt FROM transactions '
      'WHERE tanggal >= ? AND tanggal < ?',
      args,
    );
    final i = await db.rawQuery(
      'SELECT COALESCE(SUM(i.qty), 0) AS qty FROM transaction_items i '
      'JOIN transactions t ON t.id = i.transaction_id '
      'WHERE t.tanggal >= ? AND t.tanggal < ?',
      args,
    );
    return SalesSummary(
      total: t.first['total'] as int,
      count: t.first['cnt'] as int,
      itemsSold: i.first['qty'] as int,
    );
  }
}
