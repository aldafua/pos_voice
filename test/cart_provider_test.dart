import 'package:flutter_test/flutter_test.dart';
import 'package:pos_voice/data/models/product.dart';
import 'package:pos_voice/providers/cart_provider.dart';

void main() {
  const mie = Product(id: 1, nama: 'Mie Goreng', hargaJual: 3500, stok: 5, stokMinimum: 2);

  group('CartProvider', () {
    test('menambah item dan menghitung subtotal', () {
      final cart = CartProvider();
      expect(cart.add(mie, qty: 2), isNull);
      expect(cart.totalQty, 2);
      expect(cart.subtotal, 7000);
    });

    test('menolak jumlah melebihi stok', () {
      final cart = CartProvider();
      expect(cart.add(mie, qty: 5), isNull);
      expect(cart.add(mie), isNotNull);
      expect(cart.totalQty, 5);
    });

    test('setQty 0 menghapus item, clear mengosongkan', () {
      final cart = CartProvider();
      cart.add(mie, qty: 2);
      cart.setQty(mie, 0);
      expect(cart.isEmpty, isTrue);
      cart.add(mie);
      cart.clear();
      expect(cart.isEmpty, isTrue);
    });
  });
}
