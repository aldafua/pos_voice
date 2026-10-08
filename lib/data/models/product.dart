class Category {
  const Category({required this.id, required this.nama});

  final int id;
  final String nama;

  factory Category.fromMap(Map<String, Object?> m) =>
      Category(id: m['id'] as int, nama: m['nama'] as String);
}

class Product {
  const Product({
    this.id,
    required this.nama,
    this.categoryId,
    this.categoryName,
    required this.hargaJual,
    required this.stok,
    required this.stokMinimum,
    this.barcode,
  });

  final int? id;
  final String nama;
  final int? categoryId;
  final String? categoryName;
  final int hargaJual;
  final int stok;
  final int stokMinimum;
  final String? barcode;

  bool get isLowStock => stok <= stokMinimum;
  bool get isOutOfStock => stok <= 0;

  factory Product.fromMap(Map<String, Object?> m) => Product(
        id: m['id'] as int,
        nama: m['nama'] as String,
        categoryId: m['category_id'] as int?,
        categoryName: m['category_name'] as String?,
        hargaJual: m['harga_jual'] as int,
        stok: m['stok'] as int,
        stokMinimum: m['stok_minimum'] as int,
        barcode: m['barcode'] as String?,
      );

  Map<String, Object?> toMap() => {
        'nama': nama,
        'category_id': categoryId,
        'harga_jual': hargaJual,
        'stok': stok,
        'stok_minimum': stokMinimum,
        'barcode': barcode,
      };
}
