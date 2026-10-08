import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/format.dart';
import '../../core/routes.dart';
import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../data/repositories/sale_repository.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/sale_provider.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _diskonCtrl = TextEditingController(text: '0');
  final _bayarCtrl = TextEditingController();
  bool _saving = false;

  int get _diskon => int.tryParse(_diskonCtrl.text) ?? 0;
  int get _bayar => int.tryParse(_bayarCtrl.text) ?? 0;

  @override
  void dispose() {
    _diskonCtrl.dispose();
    _bayarCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final cart = context.read<CartProvider>();
    final auth = context.read<AuthProvider>();
    final sales = context.read<SaleProvider>();
    final products = context.read<ProductProvider>();
    final user = auth.user;
    if (user == null) return;

    final items = cart.items;
    setState(() => _saving = true);
    try {
      final sale = await sales.checkout(
        items: items,
        diskon: _diskon,
        bayar: _bayar,
        userId: user.id,
        kasirNama: user.nama,
      );
      final low = items
          .where((it) => it.product.stok - it.qty <= it.product.stokMinimum)
          .map((it) => it.product.nama)
          .toList();
      cart.clear();
      await products.load();
      if (!mounted) return;
      if (low.isNotEmpty) {
        showSnack(context, 'Stok menipis: ${low.join(', ')}');
      }
      Navigator.pushReplacementNamed(context, Routes.receipt, arguments: sale);
    } on CheckoutException catch (e) {
      if (mounted) showSnack(context, e.message, error: true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cart = context.watch<CartProvider>();
    if (cart.isEmpty && !_saving) {
      return Scaffold(
        appBar: AppBar(title: const Text('Pembayaran')),
        body: const Center(child: Text('Keranjang kosong.')),
      );
    }

    final subtotal = cart.subtotal;
    final total = _diskon > subtotal ? 0 : subtotal - _diskon;
    final kembalian = _bayar >= total ? _bayar - total : 0;

    return Scaffold(
      appBar: AppBar(title: const Text('Pembayaran', style: TextStyle(fontWeight: FontWeight.bold))),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(12),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _row('Subtotal (${cart.totalQty} item)', Fmt.rupiah(subtotal)),
                    const SizedBox(height: 8),
                    _row('Diskon', Fmt.rupiah(_diskon > subtotal ? subtotal : _diskon)),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        const Spacer(),
                        Text(Fmt.rupiah(total),
                            style: const TextStyle(
                                fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.primary)),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _diskonCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              decoration: AppTheme.input('Diskon (Rp)'),
              validator: (v) {
                if (v == null || v.isEmpty) return null;
                final n = int.tryParse(v);
                if (n == null) return 'Angka tidak valid';
                if (n > subtotal) return 'Diskon melebihi subtotal';
                return null;
              },
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _bayarCtrl,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (_) => setState(() {}),
              style: const TextStyle(fontSize: 20),
              decoration: AppTheme.input('Nominal Bayar', prefixText: 'Rp '),
              validator: (v) {
                if (v == null || v.isEmpty) return 'Nominal bayar wajib diisi';
                final n = int.tryParse(v);
                if (n == null) return 'Angka tidak valid';
                if (n < total) return 'Nominal kurang dari total (${Fmt.rupiah(total)})';
                return null;
              },
            ),
            const Padding(
              padding: EdgeInsets.only(top: 6, left: 4),
              child: Text(
                'Nominal harus lebih dari atau sama dengan total',
                style: TextStyle(fontSize: 12, color: AppTheme.textMuted),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              children: [
                ActionChip(
                  label: const Text('Uang Pas'),
                  onPressed: () => setState(() => _bayarCtrl.text = '$total'),
                ),
                ActionChip(
                  label: const Text('Rp 50.000'),
                  onPressed: () => setState(() => _bayarCtrl.text = '50000'),
                ),
                ActionChip(
                  label: const Text('Rp 100.000'),
                  onPressed: () => setState(() => _bayarCtrl.text = '100000'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: AppTheme.successSoft, borderRadius: BorderRadius.circular(12)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Kembalian', style: TextStyle(color: AppTheme.textMuted)),
                  const SizedBox(height: 4),
                  Text(Fmt.rupiah(kembalian),
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.success)),
                ],
              ),
            ),
            const SizedBox(height: 20),
            FilledButton(
              onPressed: _saving ? null : _submit,
              child: _saving
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : const Text('Proses Pembayaran'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(String label, String value) {
    return Row(
      children: [
        Text(label, style: const TextStyle(color: AppTheme.textMuted)),
        const Spacer(),
        Text(value),
      ],
    );
  }
}
