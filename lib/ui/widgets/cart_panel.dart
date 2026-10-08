import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../data/models/cart_item.dart';
import '../../providers/cart_provider.dart';

class CartPanel extends StatelessWidget {
  const CartPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    return Material(
      color: Colors.white,
      elevation: 8,
      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Text('Keranjang (${cart.totalQty} item)',
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const Spacer(),
                if (!cart.isEmpty) TextButton(onPressed: cart.clear, child: const Text('Kosongkan')),
              ],
            ),
            if (cart.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 14),
                child: Text(
                  'Belum ada item. Pilih produk atau gunakan perintah suara.',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              )
            else
              ConstrainedBox(
                constraints: const BoxConstraints(maxHeight: 132),
                child: ListView(
                  shrinkWrap: true,
                  children: cart.items.map((it) => _CartRow(item: it)).toList(),
                ),
              ),
            const Divider(height: 16),
            Row(
              children: [
                const Text('Total', style: TextStyle(fontSize: 15, color: AppTheme.textMuted)),
                const Spacer(),
                Text(Fmt.rupiah(cart.subtotal),
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              ],
            ),
            const SizedBox(height: 8),
            FilledButton(
              onPressed: cart.isEmpty ? null : () => Navigator.pushNamed(context, Routes.payment),
              child: const Text('Bayar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _CartRow extends StatelessWidget {
  const _CartRow({required this.item});

  final CartItem item;

  @override
  Widget build(BuildContext context) {
    final cart = context.read<CartProvider>();
    return Row(
      children: [
        Expanded(
          child: Text(item.product.nama, maxLines: 1, overflow: TextOverflow.ellipsis),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.remove_circle_outline),
          onPressed: () => cart.setQty(item.product, item.qty - 1),
        ),
        Text('${item.qty}', style: const TextStyle(fontWeight: FontWeight.bold)),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: const Icon(Icons.add_circle_outline),
          onPressed: () {
            final err = cart.add(item.product);
            if (err != null) showSnack(context, err, error: true);
          },
        ),
        SizedBox(
          width: 78,
          child: Text(Fmt.rupiah(item.subtotal), textAlign: TextAlign.right),
        ),
      ],
    );
  }
}
