import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../data/models/product.dart';
import '../../providers/product_provider.dart';

/// Daftar produk (khusus Admin).
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  String _query = '';

  Future<void> _deactivate(Product p) async {
    final ok = await confirmDialog(
      context,
      title: 'Nonaktifkan produk',
      message: '"${p.nama}" tidak akan tampil lagi di Kasir. Riwayat transaksi tetap tersimpan.',
      confirmLabel: 'Nonaktifkan',
    );
    if (!ok || !mounted) return;
    await context.read<ProductProvider>().remove(p);
    if (mounted) showSnack(context, '${p.nama} dinonaktifkan.');
  }

  @override
  Widget build(BuildContext context) {
    final list = context.watch<ProductProvider>().search(_query);

    return Scaffold(
      appBar: AppBar(title: const Text('Produk', style: TextStyle(fontWeight: FontWeight.bold))),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.accent,
        foregroundColor: Colors.black87,
        tooltip: 'Tambah produk',
        onPressed: () => Navigator.pushNamed(context, Routes.productForm),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 10, 12, 6),
            child: TextField(
              onChanged: (v) => setState(() => _query = v),
              decoration: AppTheme.input('Cari nama atau barcode…', suffix: const Icon(Icons.search)),
            ),
          ),
          Expanded(
            child: list.isEmpty
                ? const Center(child: Text('Produk tidak ditemukan.'))
                : ListView.builder(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 88),
                    itemCount: list.length,
                    itemBuilder: (ctx, i) {
                      final p = list[i];
                      final low = p.isLowStock;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const CircleAvatar(
                            backgroundColor: AppTheme.primarySoft,
                            child: Icon(Icons.inventory_2_outlined, color: AppTheme.primary),
                          ),
                          title: Text(p.nama, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Text('${p.categoryName ?? 'Tanpa kategori'} • ${Fmt.rupiah(p.hargaJual)}'),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: low ? AppTheme.dangerSoft : AppTheme.primarySoft,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Text(
                              '${p.stok}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: low ? AppTheme.danger : AppTheme.primary,
                              ),
                            ),
                          ),
                          onTap: () => Navigator.pushNamed(ctx, Routes.productForm, arguments: p),
                          onLongPress: () => _deactivate(p),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
