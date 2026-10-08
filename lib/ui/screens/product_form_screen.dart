import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme.dart';
import '../../core/ui_helpers.dart';
import '../../data/models/product.dart';
import '../../providers/product_provider.dart';

/// Form tambah / ubah produk.
class ProductFormScreen extends StatefulWidget {
  const ProductFormScreen({super.key, this.product});

  final Product? product;

  @override
  State<ProductFormScreen> createState() => _ProductFormScreenState();
}

class _ProductFormScreenState extends State<ProductFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nama;
  late final TextEditingController _harga;
  late final TextEditingController _stok;
  late final TextEditingController _stokMin;
  late final TextEditingController _barcode;
  int? _categoryId;
  bool _saving = false;

  bool get _isEdit => widget.product != null;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _nama = TextEditingController(text: p?.nama ?? '');
    _harga = TextEditingController(text: p == null ? '' : '${p.hargaJual}');
    _stok = TextEditingController(text: p == null ? '0' : '${p.stok}');
    _stokMin = TextEditingController(text: p == null ? '5' : '${p.stokMinimum}');
    _barcode = TextEditingController(text: p?.barcode ?? '');
    _categoryId = p?.categoryId;
  }

  @override
  void dispose() {
    _nama.dispose();
    _harga.dispose();
    _stok.dispose();
    _stokMin.dispose();
    _barcode.dispose();
    super.dispose();
  }

  String? _requiredNumber(String? v, String label, {bool positive = false}) {
    if (v == null || v.trim().isEmpty) return '$label wajib diisi';
    final n = int.tryParse(v.trim());
    if (n == null) return 'Angka tidak valid';
    if (positive && n <= 0) return '$label harus lebih dari 0';
    if (n < 0) return '$label tidak boleh negatif';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final provider = context.read<ProductProvider>();
    final barcode = _barcode.text.trim();
    final product = Product(
      id: widget.product?.id,
      nama: _nama.text.trim(),
      categoryId: _categoryId,
      hargaJual: int.parse(_harga.text.trim()),
      stok: int.parse(_stok.text.trim()),
      stokMinimum: int.parse(_stokMin.text.trim()),
      barcode: barcode.isEmpty ? null : barcode,
    );
    setState(() => _saving = true);
    try {
      await provider.save(product);
      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      final dup = e.toString().contains('UNIQUE');
      showSnack(context, dup ? 'Barcode sudah digunakan produk lain.' : 'Gagal menyimpan produk.', error: true);
      setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final categories = context.watch<ProductProvider>().categories;
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Ubah Produk' : 'Tambah Produk', style: const TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nama,
              textCapitalization: TextCapitalization.words,
              decoration: AppTheme.input('Nama Produk', hint: 'mis. Mie Goreng Instan'),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isEmpty) return 'Nama produk wajib diisi';
                if (t.length < 2) return 'Minimal 2 karakter';
                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<int>(
              value: _categoryId,
              decoration: AppTheme.input('Kategori'),
              hint: const Text('Pilih kategori'),
              items: categories.map((c) => DropdownMenuItem<int>(value: c.id, child: Text(c.nama))).toList(),
              onChanged: (v) => setState(() => _categoryId = v),
              validator: (v) => v == null ? 'Pilih kategori' : null,
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _harga,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: AppTheme.input('Harga Jual (Rp)', hint: 'mis. 3500'),
              validator: (v) => _requiredNumber(v, 'Harga', positive: true),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _stok,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: AppTheme.input(_isEdit ? 'Stok' : 'Stok Awal'),
              validator: (v) => _requiredNumber(v, 'Stok'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _stokMin,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: AppTheme.input('Stok Minimum'),
              validator: (v) => _requiredNumber(v, 'Stok minimum'),
            ),
            const SizedBox(height: 14),
            TextFormField(
              controller: _barcode,
              keyboardType: TextInputType.number,
              decoration: AppTheme.input('Barcode (opsional)', hint: 'Ketik kode barcode'),
              validator: (v) {
                final t = v?.trim() ?? '';
                if (t.isNotEmpty && t.length < 4) return 'Barcode minimal 4 karakter';
                return null;
              },
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(height: 22, width: 22, child: CircularProgressIndicator(strokeWidth: 2.5))
                  : const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}
