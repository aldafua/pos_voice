import 'package:flutter/foundation.dart';

import '../data/models/cart_item.dart';
import '../data/models/product.dart';

class CartProvider extends ChangeNotifier {
  final Map<int, CartItem> _items = {};

  List<CartItem> get items => _items.values.toList();
  bool get isEmpty => _items.isEmpty;
  int get totalQty => _items.values.fold(0, (sum, e) => sum + e.qty);
  int get subtotal => _items.values.fold(0, (sum, e) => sum + e.subtotal);

  int quantityOf(Product p) => _items[p.id]?.qty ?? 0;

  /// Menambah produk. Mengembalikan pesan kesalahan, atau null bila berhasil.
  String? add(Product p, {int qty = 1}) {
    if (qty <= 0) return 'Jumlah harus lebih dari 0.';
    final current = _items[p.id]?.qty ?? 0;
    if (current + qty > p.stok) {
      return 'Stok ${p.nama} tidak cukup (sisa ${p.stok}).';
    }
    _items.putIfAbsent(p.id!, () => CartItem(p, 0)).qty = current + qty;
    notifyListeners();
    return null;
  }

  /// Mengubah jumlah item. Jumlah 0 atau kurang menghapus item.
  String? setQty(Product p, int qty) {
    if (qty <= 0) {
      remove(p.id!);
      return null;
    }
    if (qty > p.stok) return 'Stok ${p.nama} tidak cukup (sisa ${p.stok}).';
    final item = _items[p.id];
    if (item == null) return null;
    item.qty = qty;
    notifyListeners();
    return null;
  }

  void remove(int productId) {
    if (_items.remove(productId) != null) notifyListeners();
  }

  void clear() {
    if (_items.isEmpty) return;
    _items.clear();
    notifyListeners();
  }
}
