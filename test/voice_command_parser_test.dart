import 'package:flutter_test/flutter_test.dart';
import 'package:pos_voice/services/voice_command_parser.dart';

void main() {
  const parser = VoiceCommandParser();

  group('VoiceCommandParser', () {
    test('tambah dengan bilangan kata', () {
      final c = parser.parse('Tambah dua mie goreng');
      expect(c.intent, VoiceIntent.addItem);
      expect(c.quantity, 2);
      expect(c.productQuery, 'mie goreng');
    });

    test('tambah dengan angka', () {
      final c = parser.parse('tambah 3 gula pasir');
      expect(c.intent, VoiceIntent.addItem);
      expect(c.quantity, 3);
      expect(c.productQuery, 'gula pasir');
    });

    test('bilangan belasan dan puluhan', () {
      expect(parser.parse('dua belas telur').quantity, 12);
      expect(parser.parse('beli sebelas roti').quantity, 11);
      expect(parser.parse('dua puluh lima kopi').quantity, 25);
    });

    test('kata pengisi diabaikan', () {
      final c = parser.parse('tolong tambah satu gula');
      expect(c.intent, VoiceIntent.addItem);
      expect(c.quantity, 1);
      expect(c.productQuery, 'gula');
    });

    test('cek stok dan harga', () {
      final s = parser.parse('cek stok gula pasir');
      expect(s.intent, VoiceIntent.checkStock);
      expect(s.productQuery, 'gula pasir');
      final h = parser.parse('berapa harga teh celup');
      expect(h.intent, VoiceIntent.checkPrice);
      expect(h.productQuery, 'teh celup');
    });

    test('ringkasan penjualan, hapus, kosongkan, bayar', () {
      expect(parser.parse('total penjualan hari ini').intent, VoiceIntent.salesToday);
      final r = parser.parse('hapus kopi sachet');
      expect(r.intent, VoiceIntent.removeItem);
      expect(r.productQuery, 'kopi sachet');
      expect(parser.parse('kosongkan keranjang').intent, VoiceIntent.clearCart);
      expect(parser.parse('hapus semua').intent, VoiceIntent.clearCart);
      expect(parser.parse('bayar').intent, VoiceIntent.checkout);
    });

    test('perintah tidak dikenal', () {
      expect(parser.parse('halo apa kabar').intent, VoiceIntent.unknown);
      expect(parser.parse('').intent, VoiceIntent.unknown);
    });
  });
}
