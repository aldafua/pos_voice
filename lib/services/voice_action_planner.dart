import '../core/format.dart';
import '../data/models/product.dart';
import '../providers/cart_provider.dart';
import '../providers/sale_provider.dart';
import 'product_matcher.dart';
import 'voice_command_parser.dart';

class VoiceResult {
  const VoiceResult(this.message, {this.ok = true});
  final String message;
  final bool ok;
}

/// Rencana aksi hasil penguraian perintah suara.
///
/// Aksi yang mengubah data ([needsConfirm] = true) harus dikonfirmasi
/// pengguna lebih dulu; aksi baca-saja dijalankan langsung.
class VoicePlan {
  const VoicePlan({
    required this.description,
    this.needsConfirm = false,
    this.run,
    this.error,
    this.opensPayment = false,
  });

  final String description;
  final bool needsConfirm;
  final Future<VoiceResult> Function()? run;
  final String? error;
  final bool opensPayment;
}

class VoiceActionPlanner {
  VoiceActionPlanner({
    required this.products,
    required this.cart,
    required this.sales,
    this.parser = const VoiceCommandParser(),
  });

  final List<Product> products;
  final CartProvider cart;
  final SaleProvider sales;
  final VoiceCommandParser parser;

  VoicePlan plan(String text) {
    final cmd = parser.parse(text);
    final intent = cmd.intent;

    if (intent == VoiceIntent.addItem) {
      final p = ProductMatcher.best(products, cmd.productQuery);
      if (p == null) return _notFound(cmd.productQuery);
      return VoicePlan(
        description: 'Tambah ${cmd.quantity} × ${p.nama} ke keranjang',
        needsConfirm: true,
        run: () async {
          final err = cart.add(p, qty: cmd.quantity);
          return err == null
              ? VoiceResult('${cmd.quantity} × ${p.nama} ditambahkan ke keranjang.')
              : VoiceResult(err, ok: false);
        },
      );
    }

    if (intent == VoiceIntent.removeItem) {
      final inCart = cart.items.map((e) => e.product).toList();
      final p = ProductMatcher.best(inCart, cmd.productQuery);
      if (p == null) {
        return VoicePlan(description: '', error: 'Tidak ada "${cmd.productQuery}" di keranjang.');
      }
      return VoicePlan(
        description: 'Hapus ${p.nama} dari keranjang',
        needsConfirm: true,
        run: () async {
          cart.remove(p.id!);
          return VoiceResult('${p.nama} dihapus dari keranjang.');
        },
      );
    }

    if (intent == VoiceIntent.clearCart) {
      if (cart.isEmpty) return const VoicePlan(description: '', error: 'Keranjang sudah kosong.');
      return VoicePlan(
        description: 'Kosongkan keranjang (${cart.totalQty} item)',
        needsConfirm: true,
        run: () async {
          cart.clear();
          return const VoiceResult('Keranjang dikosongkan.');
        },
      );
    }

    if (intent == VoiceIntent.checkStock) {
      final p = ProductMatcher.best(products, cmd.productQuery);
      if (p == null) return _notFound(cmd.productQuery);
      return VoicePlan(
        description: 'Cek stok ${p.nama}',
        run: () async => VoiceResult('Stok ${p.nama}: ${p.stok} (minimum ${p.stokMinimum}).'),
      );
    }

    if (intent == VoiceIntent.checkPrice) {
      final p = ProductMatcher.best(products, cmd.productQuery);
      if (p == null) return _notFound(cmd.productQuery);
      return VoicePlan(
        description: 'Cek harga ${p.nama}',
        run: () async => VoiceResult('Harga ${p.nama}: ${Fmt.rupiah(p.hargaJual)}.'),
      );
    }

    if (intent == VoiceIntent.salesToday) {
      return VoicePlan(
        description: 'Ringkasan penjualan hari ini',
        run: () async {
          await sales.loadToday();
          return VoiceResult(
            'Penjualan hari ini ${Fmt.rupiah(sales.today.total)} dari ${sales.today.count} transaksi.',
          );
        },
      );
    }

    if (intent == VoiceIntent.checkout) {
      if (cart.isEmpty) return const VoicePlan(description: '', error: 'Keranjang masih kosong.');
      return VoicePlan(
        description: 'Buka pembayaran (${cart.totalQty} item, ${Fmt.rupiah(cart.subtotal)})',
        needsConfirm: true,
        opensPayment: true,
        run: () async => const VoiceResult('Membuka halaman pembayaran.'),
      );
    }

    return const VoicePlan(
      description: '',
      error: 'Perintah belum dikenali. Coba: "tambah dua mie goreng" atau "cek stok gula".',
    );
  }

  VoicePlan _notFound(String query) =>
      VoicePlan(description: '', error: 'Produk "$query" tidak ditemukan.');
}
