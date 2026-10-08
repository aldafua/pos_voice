import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../widgets/cart_panel.dart';
import '../widgets/product_card.dart';
import '../widgets/voice_sheet.dart';

class PosScreen extends StatelessWidget {
  const PosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pp = context.watch<ProductProvider>();
    final products = pp.filtered;

    return Scaffold(
      appBar: AppBar(title: const Text('Kasir', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    onChanged: context.read<ProductProvider>().setQuery,
                    onSubmitted: (v) => _addByBarcode(context, v),
                    textInputAction: TextInputAction.search,
                    decoration: AppTheme.input(
                      'Cari produk atau barcode…',
                      suffix: const Icon(Icons.search),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  tooltip: 'Voice Assistant',
                  style: IconButton.styleFrom(
                    backgroundColor: AppTheme.accent,
                    foregroundColor: Colors.black87,
                    minimumSize: const Size(52, 52),
                  ),
                  icon: const Icon(Icons.mic, size: 28),
                  onPressed: () => showVoiceSheet(context),
                ),
              ],
            ),
          ),
          SizedBox(
            height: 42,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              children: [
                _chip(context, 'Semua', pp.categoryId == null, () => pp.setCategory(null)),
                ...pp.categories.map(
                  (c) => _chip(context, c.nama, pp.categoryId == c.id, () => pp.setCategory(c.id)),
                ),
              ],
            ),
          ),
          Expanded(
            child: pp.isLoading && pp.all.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : products.isEmpty
                    ? const Center(child: Text('Produk tidak ditemukan.'))
                    : GridView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
                        gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                          maxCrossAxisExtent: 220,
                          mainAxisExtent: 118,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: products.length,
                        itemBuilder: (ctx, i) {
                          final p = products[i];
                          return ProductCard(
                            product: p,
                            onTap: () {
                              final err = ctx.read<CartProvider>().add(p);
                              if (err != null) showSnack(ctx, err, error: true);
                            },
                          );
                        },
                      ),
          ),
          const CartPanel(),
        ],
      ),
    );
  }

  Widget _chip(BuildContext context, String label, bool selected, VoidCallback onTap) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onTap(),
      ),
    );
  }

  /// Menekan Enter pada kolom cari dengan kode barcode menambahkan produknya.
  void _addByBarcode(BuildContext context, String value) {
    final code = value.trim();
    if (code.isEmpty) return;
    final all = context.read<ProductProvider>().all;
    final matches = all.where((p) => p.barcode == code).toList();
    if (matches.isEmpty) return;
    final err = context.read<CartProvider>().add(matches.first);
    showSnack(context, err ?? '${matches.first.nama} ditambahkan.', error: err != null);
  }
}
