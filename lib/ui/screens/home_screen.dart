import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.onStartTransaction});

  final VoidCallback onStartTransaction;

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: 'Keluar',
      message: 'Keluar dari aplikasi?',
      confirmLabel: 'Keluar',
    );
    if (!ok || !context.mounted) return;
    context.read<CartProvider>().clear();
    context.read<AuthProvider>().logout();
    Navigator.pushNamedAndRemoveUntil(context, Routes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AuthProvider>().user;
    final today = context.watch<SaleProvider>().today;
    final low = context.watch<ProductProvider>().lowStock;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Beranda', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          TextButton(
            onPressed: () => _logout(context),
            child: const Text('Keluar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          Text('Halo, ${user?.nama ?? ''}',
              style: const TextStyle(fontSize: 21, fontWeight: FontWeight.bold)),
          const SizedBox(height: 2),
          Text(Fmt.tanggalPanjang(DateTime.now()), style: const TextStyle(color: AppTheme.textMuted)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: AppTheme.primary, borderRadius: BorderRadius.circular(14)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Penjualan Hari Ini', style: TextStyle(color: Colors.white, fontSize: 14)),
                const SizedBox(height: 6),
                Text(Fmt.rupiah(today.total),
                    style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Text('${today.count} transaksi', style: const TextStyle(color: Colors.white)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _StatCard(
                  color: Colors.white,
                  label: 'Item Terjual',
                  value: '${today.itemsSold}',
                  valueColor: Colors.black87,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _StatCard(
                  color: AppTheme.dangerSoft,
                  label: 'Stok Menipis',
                  value: '${low.length} produk',
                  valueColor: AppTheme.danger,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          FilledButton(onPressed: onStartTransaction, child: const Text('Mulai Transaksi')),
          const SizedBox(height: 22),
          const Text('Perlu Restok', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: 8),
          if (low.isEmpty)
            const Text('Semua stok aman.', style: TextStyle(color: AppTheme.textMuted))
          else
            ...low.take(5).map(
                  (p) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(p.nama),
                      trailing: Text(
                        p.isOutOfStock ? 'Habis' : 'Sisa ${p.stok}',
                        style: const TextStyle(color: AppTheme.danger, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({required this.color, required this.label, required this.value, required this.valueColor});

  final Color color;
  final String label;
  final String value;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD5DFDC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppTheme.textMuted, fontSize: 13)),
          const SizedBox(height: 6),
          Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: valueColor)),
        ],
      ),
    );
  }
}
