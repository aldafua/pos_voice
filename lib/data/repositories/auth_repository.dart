import '../../core/security.dart';
import '../database_helper.dart';
import '../models/app_user.dart';

class AuthRepository {
  AuthRepository([DatabaseHelper? helper]) : _helper = helper ?? DatabaseHelper.instance;

  final DatabaseHelper _helper;

  /// Mengembalikan pengguna bila kredensial cocok, atau null bila tidak.
  Future<AppUser?> login(String username, String password) async {
    final db = await _helper.database;
    final rows = await db.query(
      'users',
      where: 'username = ? AND password_hash = ?',
      whereArgs: [username, Security.hashPassword(password)],
      limit: 1,
    );
    if (rows.isEmpty) return null;
    return AppUser.fromMap(rows.first);
  }
}
