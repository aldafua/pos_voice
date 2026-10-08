import '../data/models/product.dart';

/// Mencocokkan frasa yang diucapkan dengan nama produk.
class ProductMatcher {
  static const double _threshold = 40;
  static const Map<String, String> _synonyms = {'mi': 'mie'};

  static String normalize(String s) {
    final lower = s.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), ' ');
    return lower
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) => _synonyms[w] ?? w)
        .join(' ');
  }

  /// Produk dengan skor tertinggi, atau null bila tidak ada yang cukup mirip.
  static Product? best(List<Product> products, String query) {
    final q = normalize(query);
    if (q.isEmpty) return null;
    Product? best;
    var bestScore = 0.0;
    for (final p in products) {
      final s = _score(normalize(p.nama), q);
      if (s > bestScore) {
        bestScore = s;
        best = p;
      }
    }
    return bestScore >= _threshold ? best : null;
  }

  static double _score(String name, String q) {
    if (name == q) return 100;
    if (name.contains(q)) return 80 + 10 * (q.length / name.length);
    if (q.contains(name)) return 70 + 10 * (name.length / q.length);
    final qt = q.split(' ');
    final nt = name.split(' ');
    var matched = 0;
    for (final a in qt) {
      final hit = nt.any((b) => a == b || (a.length >= 3 && b.length >= 3 && (b.startsWith(a) || a.startsWith(b))));
      if (hit) matched++;
    }
    if (matched == 0) return 0;
    return 60 * matched / qt.length + 10 * matched / nt.length;
  }
}
