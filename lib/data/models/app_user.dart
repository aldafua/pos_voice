class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.nama,
    required this.role,
  });

  final int id;
  final String username;
  final String nama;
  final String role;

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(Map<String, Object?> m) => AppUser(
        id: m['id'] as int,
        username: m['username'] as String,
        nama: m['nama'] as String,
        role: m['role'] as String,
      );
}
