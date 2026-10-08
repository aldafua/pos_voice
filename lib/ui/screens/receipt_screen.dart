import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../core/format.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../data/models/sale.dart';

/// Struk digital. Dipakai setelah pembayaran dan untuk detail riwayat.
class ReceiptScreen extends StatelessWidget {
  const ReceiptScreen({super.key, required this.sale});

  final Sale sale;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Struk Transaksi', style: TextStyle(fontWeight: FontWeight.bold))),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(AppConstants.storeName,
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  const Text(AppConstants.storeAddress,
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                  const Divider(height: 24),
                  Text(sale.kode, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 2),
                  Text(
                    '${Fmt.tanggalJam(sale.tanggal)} • Kasir: ${sale.kasirNama ?? '-'}',
                    style: const TextStyle(fontSize: 12, color: AppTheme.textMuted),
                  ),
                  const Divider(height: 24),
                  ...sale.items.map(
                    (it) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(it.namaProduk),
                          Row(
                            children: [
                              Text('${it.qty} × ${Fmt.rupiah(it.harga).replaceFirst('Rp ', '')}',
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                              const Spacer(),
                              Text(Fmt.rupiah(it.subtotal).replaceFirst('Rp ', '')),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 24),
                  if (sale.diskon > 0) _line('Diskon', Fmt.rupiah(sale.diskon)),
                  _line('Total', Fmt.rupiah(sale.total), bold: true),
                  _line('Bayar', Fmt.rupiah(sale.bayar)),
                  _line('Kembali', Fmt.rupiah(sale.kembalian)),
                  const Divider(height: 24),
                  const Text('Terima kasih atas kunjungan Anda',
                      textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: AppTheme.textMuted)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: () => Navigator.popUntil(context, ModalRoute.withName(Routes.home)),
            child: const Text('Selesai'),
          ),
        ],
      ),
    );
  }

  Widget _line(String label, String value, {bool bold = false}) {
    final style = TextStyle(fontSize: 14, fontWeight: bold ? FontWeight.bold : FontWeight.normal);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [Text(label, style: style), const Spacer(), Text(value, style: style)]),
    );
  }
}
