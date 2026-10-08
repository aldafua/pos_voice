import 'package:flutter_test/flutter_test.dart';
import 'package:pos_voice/core/format.dart';

void main() {
  test('Fmt.rupiah memakai pemisah ribuan titik', () {
    final s = Fmt.rupiah(1250000).replaceAll('\u00A0', ' ');
    expect(s, 'Rp 1.250.000');
  });
}
