/// Jenis maksud (intent) yang dikenali dari ucapan kasir.
enum VoiceIntent {
  addItem,
  removeItem,
  clearCart,
  checkStock,
  checkPrice,
  salesToday,
  checkout,
  unknown,
}

class VoiceCommand {
  const VoiceCommand(
    this.intent, {
    this.productQuery = '',
    this.quantity = 1,
    this.raw = '',
  });

  final VoiceIntent intent;
  final String productQuery;
  final int quantity;
  final String raw;
}

class _Num {
  const _Num(this.value, this.used);
  final int value;
  final int used;
}

/// Mengurai teks hasil pengenalan suara menjadi [VoiceCommand].
///
/// Contoh perintah: "tambah dua mie goreng", "cek stok gula",
/// "harga teh celup", "total penjualan hari ini", "hapus kopi sachet",
/// "kosongkan keranjang", "bayar".
class VoiceCommandParser {
  const VoiceCommandParser();

  static const Set<String> _fillers = {
    'tolong', 'coba', 'dong', 'deh', 'ya', 'yaa', 'kak', 'bisa', 'saya', 'mau',
  };
  static const Set<String> _addVerbs = {
    'tambah', 'tambahkan', 'masukkan', 'masukin', 'beli', 'input', 'ambil',
  };
  static const Set<String> _removeVerbs = {'hapus', 'buang', 'batalkan', 'keluarkan'};
  static const Set<String> _units = {'buah', 'biji', 'pcs', 'bungkus', 'bks'};
  static const Map<String, int> _small = {
    'nol': 0, 'satu': 1, 'dua': 2, 'tiga': 3, 'empat': 4, 'lima': 5, 'enam': 6,
    'tujuh': 7, 'delapan': 8, 'sembilan': 9, 'sepuluh': 10, 'sebelas': 11, 'selusin': 12,
  };

  VoiceCommand parse(String input) {
    final t = _tokenize(input).where((w) => !_fillers.contains(w)).toList();
    VoiceCommand unknown() => VoiceCommand(VoiceIntent.unknown, raw: input);
    if (t.isEmpty) return unknown();
    final joined = t.join(' ');

    // Perintah tanpa nama produk.
    if (joined.contains('total penjualan') ||
        joined.contains('omzet') ||
        (t.contains('penjualan') && joined.contains('hari ini'))) {
      return VoiceCommand(VoiceIntent.salesToday, raw: input);
    }
    if (t.contains('kosongkan') || t.contains('bersihkan') || t.contains('reset')) {
      return VoiceCommand(VoiceIntent.clearCart, raw: input);
    }
    if (t.first == 'bayar' || t.first == 'checkout' || joined.contains('proses pembayaran') || joined == 'selesai') {
      return VoiceCommand(VoiceIntent.checkout, raw: input);
    }

    // Cek stok dan harga.
    if (t.contains('stok') || t.contains('stock') || t.contains('sisa')) {
      final q = _strip(t, const {
        'cek', 'berapa', 'stok', 'stock', 'sisa', 'tersisa', 'masih', 'ada', 'apa',
        'untuk', 'dari', 'barang', 'produk', 'nya', 'stoknya',
      });
      return VoiceCommand(q.isEmpty ? VoiceIntent.unknown : VoiceIntent.checkStock,
          productQuery: q, raw: input);
    }
    if (t.contains('harga') || t.contains('harganya')) {
      final q = _strip(t, const {
        'cek', 'berapa', 'berapaan', 'harga', 'harganya', 'untuk', 'dari', 'barang', 'produk', 'nya',
      });
      return VoiceCommand(q.isEmpty ? VoiceIntent.unknown : VoiceIntent.checkPrice,
          productQuery: q, raw: input);
    }

    // Hapus item.
    if (_removeVerbs.contains(t.first)) {
      final rest = t.sublist(1);
      final q = rest.join(' ');
      if (q == 'semua' || q == 'semuanya' || q == 'keranjang' || q == 'semua keranjang') {
        return VoiceCommand(VoiceIntent.clearCart, raw: input);
      }
      var k = 0;
      final rn = _readNumber(rest, 0);
      if (rn != null) {
        k = rn.used;
        if (k < rest.length && _units.contains(rest[k])) k++;
      }
      final name = rest.sublist(k).join(' ');
      if (name.isEmpty) return unknown();
      return VoiceCommand(VoiceIntent.removeItem, productQuery: name, raw: input);
    }

    // Tambah item (dengan kata kerja, atau diawali angka).
    var i = 0;
    if (_addVerbs.contains(t.first)) i = 1;
    final n = _readNumber(t, i);
    var qty = 1;
    if (n != null) {
      qty = n.value;
      i += n.used;
      if (i < t.length && _units.contains(t[i])) i++;
    } else if (i == 0) {
      return unknown();
    }
    final q = t.sublist(i).join(' ');
    if (q.isEmpty || qty <= 0) return unknown();
    return VoiceCommand(VoiceIntent.addItem, productQuery: q, quantity: qty, raw: input);
  }

  List<String> _tokenize(String s) {
    final cleaned = s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    return cleaned.split(RegExp(r'\s+')).where((w) => w.isNotEmpty).toList();
  }

  String _strip(List<String> t, Set<String> remove) =>
      t.where((w) => !remove.contains(w)).join(' ');

  /// Membaca bilangan pada posisi [i]: angka ("3"), kata ("dua"),
  /// belasan ("dua belas"), puluhan ("dua puluh lima"), atau lusin.
  _Num? _readNumber(List<String> t, int i) {
    if (i >= t.length) return null;
    final w = t[i];
    final digits = int.tryParse(w);
    if (digits != null) return _Num(digits, 1);
    final base = _small[w];
    if (base == null) return null;
    var value = base;
    var used = 1;
    if (base >= 1 && base <= 9 && i + 1 < t.length) {
      final next = t[i + 1];
      if (next == 'belas') {
        value = base + 10;
        used = 2;
      } else if (next == 'puluh') {
        value = base * 10;
        used = 2;
        if (i + 2 < t.length) {
          final u = _small[t[i + 2]];
          if (u != null && u >= 1 && u <= 9) {
            value += u;
            used = 3;
          }
        }
      } else if (next == 'lusin') {
        value = base * 12;
        used = 2;
      }
    }
    return _Num(value, used);
  }
}
