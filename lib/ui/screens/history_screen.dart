import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../providers/sale_provider.dart';

/// Riwayat transaksi dan ringkasan penjualan (hari ini, 7 hari, 30 hari).
class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final sales = context.watch<SaleProvider>();
    final summary = sales.rangeSummary;

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: SizedBox(
              width: double.infinity,
              child: SegmentedButton<int>(
                segments: const [
                  ButtonSegment(value: 1, label: Text('Hari Ini')),
                  ButtonSegment(value: 7, label: Text('7 Hari')),
                  ButtonSegment(value: 30, label: Text('30 Hari')),
                ],
                selected: {sales.rangeDays},
                onSelectionChanged: (s) => context.read<SaleProvider>().loadHistory(s.first),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
            child: Card(
              margin: EdgeInsets.zero,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Total Penjualan', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(Fmt.rupiah(summary.total),
                              style: const TextStyle(
                                  fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Transaksi', style: TextStyle(color: AppTheme.textMuted, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('${summary.count}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: sales.isLoading && sales.history.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : sales.history.isEmpty
                    ? const Center(child: Text('Belum ada transaksi.'))
                    : ListView.builder(
                        padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                        itemCount: sales.history.length,
                        itemBuilder: (ctx, i) {
                          final s = sales.history[i];
                          final when = sales.rangeDays == 1
                              ? Fmt.jam(s.tanggal)
                              : Fmt.tanggalJam(s.tanggal);
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              title: Text(s.kode, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('$when • ${s.metode[0].toUpperCase()}${s.metode.substring(1)}'),
                              trailing: Text(Fmt.rupiah(s.total),
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              onTap: () async {
                                final nav = Navigator.of(ctx);
                                final full = await ctx.read<SaleProvider>().detail(s.id);
                                if (full != null) nav.pushNamed(Routes.receipt, arguments: full);
                              },
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
