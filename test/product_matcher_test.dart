import 'package:flutter_test/flutter_test.dart';
import 'package:pos_voice/data/models/product.dart';
import 'package:pos_voice/services/product_matcher.dart';

void main() {
  const products = [
    Product(id: 1, nama: 'Mie Goreng Instan', hargaJual: 3500, stok: 120, stokMinimum: 20),
    Product(id: 2, nama: 'Gula Pasir 1 kg', hargaJual: 17000, stok: 8, stokMinimum: 10),
    Product(id: 3, nama: 'Teh Celup', hargaJual: 6500, stok: 60, stokMinimum: 10),
    Product(id: 4, nama: 'Kopi Sachet', hargaJual: 2000, stok: 200, stokMinimum: 30),
  ];

  group('ProductMatcher', () {
    test('cocok dengan sebagian nama', () {
      expect(ProductMatcher.best(products, 'mie goreng')?.id, 1);
      expect(ProductMatcher.best(products, 'gula')?.id, 2);
      expect(ProductMatcher.best(products, 'teh')?.id, 3);
    });

    test('sinonim "mi" dianggap "mie"', () {
      expect(ProductMatcher.best(products, 'mi goreng')?.id, 1);
    });

    test('produk tidak dikenal mengembalikan null', () {
      expect(ProductMatcher.best(products, 'sepatu'), isNull);
      expect(ProductMatcher.best(products, ''), isNull);
    });
  });
}
