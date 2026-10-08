import 'product.dart';

class CartItem {
  CartItem(this.product, this.qty);

  final Product product;
  int qty;

  int get subtotal => product.hargaJual * qty;
}
