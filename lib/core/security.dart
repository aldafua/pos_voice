import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Pengamanan kata sandi sederhana untuk keperluan MVP.
///
/// Catatan: untuk produk sesungguhnya gunakan salt unik per pengguna dan
/// algoritma khusus kata sandi (bcrypt/argon2).
class Security {
  static const String _salt = 'pos_voice_v1';

  static String hashPassword(String plain) {
    return sha256.convert(utf8.encode('$_salt:$plain')).toString();
  }
}
