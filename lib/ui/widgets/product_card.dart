import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/theme.dart';
import '../../data/models/product.dart';
import '../../providers/cart_provider.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({super.key, required this.product, required this.onTap});

  final Product product;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final inCart = context.select<CartProvider, int>((c) => c.quantityOf(product));
    final out = product.isOutOfStock;
    return Card(
      margin: EdgeInsets.zero,
      color: out ? const Color(0xFFEDEFEF) : Colors.white,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: out ? null : onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      product.nama,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                    ),
                  ),
                  if (inCart > 0)
                    Container(
                      margin: const EdgeInsets.only(left: 6),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primary,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text('$inCart',
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                    ),
                ],
              ),
              const Spacer(),
              Text(
                Fmt.rupiah(product.hargaJual),
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppTheme.primary),
              ),
              const SizedBox(height: 2),
              Text(
                out ? 'Habis' : 'Stok ${product.stok}',
                style: TextStyle(
                  fontSize: 12,
                  color: (out || product.isLowStock) ? AppTheme.danger : AppTheme.textMuted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
