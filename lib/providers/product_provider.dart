import 'package:flutter/foundation.dart' hide Category;

import '../data/models/product.dart';
import '../data/repositories/product_repository.dart';

class ProductProvider extends ChangeNotifier {
  ProductProvider(this._repo);

  final ProductRepository _repo;

  List<Product> _all = [];
  List<Category> _categories = [];
  String _query = '';
  int? _categoryId;
  bool _loading = false;

  List<Product> get all => _all;
  List<Category> get categories => _categories;
  int? get categoryId => _categoryId;
  bool get isLoading => _loading;
  List<Product> get lowStock => _all.where((p) => p.isLowStock).toList();

  /// Daftar produk untuk halaman Kasir (mengikuti kata kunci dan kategori terpilih).
  List<Product> get filtered => search(_query, categoryId: _categoryId);

  List<Product> search(String query, {int? categoryId}) {
    final q = query.trim().toLowerCase();
    return _all.where((p) {
      if (categoryId != null && p.categoryId != categoryId) return false;
      if (q.isEmpty) return true;
      return p.nama.toLowerCase().contains(q) || (p.barcode ?? '').contains(q);
    }).toList();
  }

  Future<void> load() async {
    _loading = true;
    notifyListeners();
    _all = await _repo.getActive();
    _categories = await _repo.getCategories();
    _loading = false;
    notifyListeners();
  }

  void setQuery(String value) {
    _query = value;
    notifyListeners();
  }

  void setCategory(int? id) {
    _categoryId = id;
    notifyListeners();
  }

  Future<void> save(Product product) async {
    if (product.id == null) {
      await _repo.insert(product);
    } else {
      await _repo.update(product);
    }
    await load();
  }

  Future<void> remove(Product product) async {
    await _repo.deactivate(product.id!);
    await load();
  }
}
