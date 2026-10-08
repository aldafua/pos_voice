class SaleItem {
  const SaleItem({
    this.productId,
    required this.namaProduk,
    required this.harga,
    required this.qty,
  });

  final int? productId;
  final String namaProduk;
  final int harga;
  final int qty;

  int get subtotal => harga * qty;

  factory SaleItem.fromMap(Map<String, Object?> m) => SaleItem(
        productId: m['product_id'] as int?,
        namaProduk: m['nama_produk'] as String,
        harga: m['harga'] as int,
        qty: m['qty'] as int,
      );
}

class Sale {
  const Sale({
    required this.id,
    required this.kode,
    required this.tanggal,
    required this.subtotal,
    required this.diskon,
    required this.total,
    required this.bayar,
    required this.kembalian,
    required this.metode,
    this.kasirNama,
    this.items = const [],
  });

  final int id;
  final String kode;
  final DateTime tanggal;
  final int subtotal;
  final int diskon;
  final int total;
  final int bayar;
  final int kembalian;
  final String metode;
  final String? kasirNama;
  final List<SaleItem> items;

  factory Sale.fromMap(Map<String, Object?> m, {List<SaleItem> items = const []}) => Sale(
        id: m['id'] as int,
        kode: m['kode'] as String,
        tanggal: DateTime.parse(m['tanggal'] as String),
        subtotal: m['subtotal'] as int,
        diskon: m['diskon'] as int,
        total: m['total'] as int,
        bayar: m['bayar'] as int,
        kembalian: m['kembalian'] as int,
        metode: m['metode'] as String,
        kasirNama: m['kasir_nama'] as String?,
        items: items,
      );
}

class SalesSummary {
  const SalesSummary({this.total = 0, this.count = 0, this.itemsSold = 0});

  final int total;
  final int count;
  final int itemsSold;
}
