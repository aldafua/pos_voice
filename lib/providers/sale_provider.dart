import 'package:flutter/foundation.dart';

import '../data/models/cart_item.dart';
import '../data/models/sale.dart';
import '../data/repositories/sale_repository.dart';

class SaleProvider extends ChangeNotifier {
  SaleProvider(this._repo);

  final SaleRepository _repo;

  SalesSummary today = const SalesSummary();
  SalesSummary rangeSummary = const SalesSummary();
  List<Sale> history = [];
  int rangeDays = 1;
  bool isLoading = false;

  DateTime get _startOfToday {
    final n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }

  Future<void> loadToday() async {
    final start = _startOfToday;
    today = await _repo.getSummary(start, start.add(const Duration(days: 1)));
    notifyListeners();
  }

  /// Memuat riwayat untuk [days] hari terakhir (1 = hari ini).
  Future<void> loadHistory(int days) async {
    rangeDays = days;
    isLoading = true;
    notifyListeners();
    final start = _startOfToday.subtract(Duration(days: days - 1));
    final end = _startOfToday.add(const Duration(days: 1));
    history = await _repo.getSales(start, end);
    rangeSummary = await _repo.getSummary(start, end);
    isLoading = false;
    notifyListeners();
  }

  Future<Sale> checkout({
    required List<CartItem> items,
    required int diskon,
    required int bayar,
    required int userId,
    String? kasirNama,
  }) async {
    final sale = await _repo.checkout(
      items: items,
      diskon: diskon,
      bayar: bayar,
      userId: userId,
      kasirNama: kasirNama,
    );
    await loadToday();
    await loadHistory(rangeDays);
    return sale;
  }

  Future<Sale?> detail(int id) => _repo.getSaleWithItems(id);
}
