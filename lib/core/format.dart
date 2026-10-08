import 'package:intl/intl.dart';

/// Utilitas pemformatan tampilan (rupiah, tanggal, jam).
class Fmt {
  static final NumberFormat _rupiah =
      NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0);

  static String rupiah(int value) => _rupiah.format(value);

  static String tanggalJam(DateTime d) => DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(d);

  static String tanggalPanjang(DateTime d) => DateFormat('EEEE, d MMMM yyyy', 'id_ID').format(d);

  static String jam(DateTime d) => DateFormat('HH:mm', 'id_ID').format(d);
}
