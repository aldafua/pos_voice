# POS Voice

Rancang Bangun Aplikasi Point of Sales (POS) Berbasis Mobile dengan Fitur Voice Assistant
Menggunakan Flutter (Studi Kasus: Toko Retail).

Tugas Mobile Programming, Tahap 3 (Implementasi, target MVP). Rancangan mengacu pada
laporan Tahap 2 (diagram alur, use case, navigasi, ERD, wireframe, purwarupa).

## Fitur MVP

- Login dengan peran **Admin** dan **Kasir** (Kasir: Beranda, Kasir, Riwayat; Admin: ditambah Produk).
- Kasir: cari produk (nama/barcode), filter kategori, keranjang, batas stok, pembayaran, kembalian.
- **Voice Assistant** (bahasa Indonesia): `tambah dua mie goreng`, `cek stok gula`,
  `harga teh celup`, `total penjualan hari ini`, `hapus kopi sachet`, `kosongkan keranjang`, `bayar`.
  Perintah yang mengubah keranjang meminta konfirmasi. Tersedia kolom ketik sebagai cadangan.
- Manajemen produk (tambah, ubah, nonaktifkan) dengan validasi masukan.
- Stok berkurang otomatis, notifikasi stok menipis, struk digital.
- Riwayat dan ringkasan penjualan (Hari Ini, 7 Hari, 30 Hari).
- Data lokal SQLite sehingga tetap berjalan tanpa internet.

Akun demo: `admin` / `admin123` dan `kasir` / `kasir123`.

## Cara Menjalankan

Prasyarat: Flutter 3.22 atau lebih baru (Dart 3.3+) dan Android SDK.

```bash
# 1. masuk ke folder proyek ini
cd pos_voice

# 2. buat folder platform Android (lib/ dan pubspec.yaml tidak ditimpa)
flutter create --project-name pos_voice --org id.ac.uinmalang --platforms=android .

# 3. ambil dependensi, analisis, dan uji
flutter pub get
flutter analyze
flutter test

# 4. jalankan di perangkat/emulator
flutter run
```

Setelah langkah 2, lakukan dua penyesuaian Android:

**a. Izin mikrofon** pada `android/app/src/main/AndroidManifest.xml`
(sebelum tag `<application>` dan sesudah `</application>`):

```xml
<uses-permission android:name="android.permission.RECORD_AUDIO"/>
<uses-permission android:name="android.permission.INTERNET"/>
<!-- ... <application> ... </application> -->
<queries>
    <intent>
        <action android:name="android.speech.RecognitionService"/>
    </intent>
</queries>
```

**b. Versi minimum Android 8.0** (sesuai KNF-06) pada `android/app/build.gradle`
atau `build.gradle.kts`: atur `minSdk` (atau `minSdkVersion`) menjadi `26`.

Jika `lib/main.dart` ikut berubah menjadi contoh counter setelah langkah 2, salin kembali
`lib/main.dart` dari arsip ini.

Catatan Voice Assistant: emulator perlu layanan Google Speech dan mikrofon aktif. Bila
pengenalan suara tidak tersedia, Voice Assistant otomatis memakai kolom **Atau ketik perintah**.

## Struktur Kode

```
lib/
  main.dart, app.dart          Titik masuk, provider, dan rute
  core/                        Tema, format rupiah, rute, konstanta, keamanan, helper UI
  data/
    models/                    AppUser, Product, CartItem, Sale
    repositories/              Akses data (auth, produk, penjualan)
    database_helper.dart       Skema SQLite dan data awal (sesuai ERD)
  providers/                   State (Auth, Product, Cart, Sale) dengan Provider
  services/                    Voice (STT, parser perintah, pencocok produk, perencana aksi)
  ui/screens/                  Login, MainShell, Beranda, Kasir, Pembayaran, Struk,
                               Produk, Form Produk, Riwayat
  ui/widgets/                  ProductCard, CartPanel, VoiceSheet
test/                          Uji unit: parser suara, pencocok produk, keranjang, format
docs/PROGRESS.md               Dokumentasi perkembangan aplikasi
```

Pemisahan tanggung jawab: **UI** (ui/), **logika aplikasi** (providers/, services/),
**pengelolaan data** (data/), dan **layanan** (services/voice_service.dart).

## Git

```bash
git init
git add pubspec.yaml analysis_options.yaml .gitignore README.md docs
git commit -m "chore: inisialisasi proyek dan dokumentasi"
git add lib/core lib/data
git commit -m "feat: lapisan data (model, SQLite, repository)"
git add lib/providers lib/services
git commit -m "feat: state management dan layanan voice assistant"
git add lib/ui lib/app.dart lib/main.dart
git commit -m "feat: antarmuka dan navigasi antarhalaman"
git add test
git commit -m "test: uji unit parser suara, pencocok produk, keranjang"
# tambahkan android/ (hasil flutter create) lalu:
git add android
git commit -m "chore: konfigurasi Android (izin mikrofon, minSdk 26)"
```

## Keamanan (catatan MVP)

Kata sandi disimpan sebagai hash SHA-256 dengan salt tetap. Untuk produk sesungguhnya
gunakan salt unik per pengguna dan algoritma khusus kata sandi (bcrypt/argon2).
