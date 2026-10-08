# Dokumentasi Perkembangan Aplikasi POS Voice

Tahap 3: Implementasi Aplikasi dengan Flutter (target MVP).

## 1. Pemetaan Luaran Tahap 3

| No | Luaran | Wujud pada proyek |
|----|--------|-------------------|
| 1 | Proyek Flutter yang dapat dijalankan | Proyek `pos_voice` (lihat README untuk langkah menjalankan) |
| 2 | Implementasi antarmuka | `lib/ui/screens/*`, `lib/ui/widgets/*`, tema di `lib/core/theme.dart` |
| 3 | Navigasi antarhalaman | Rute bernama di `lib/app.dart`, bottom navigation di `main_shell.dart` |
| 4 | Implementasi fungsi utama | Transaksi (`pos_screen`, `payment_screen`), Voice Assistant (`lib/services`, `voice_sheet.dart`) |
| 5 | Pengelolaan data aplikasi | SQLite (`lib/data`), state dengan Provider (`lib/providers`) |
| 6 | Validasi masukan pengguna | Login, diskon, nominal bayar, form produk, batas stok keranjang |
| 7 | Dokumentasi perkembangan | Berkas ini |
| 8 | Kode sumber pada repositori Git | Riwayat commit disarankan pada README |

## 2. Status Kebutuhan Fungsional (Tahap 1)

| Kode | Kebutuhan | Status | Lokasi |
|------|-----------|--------|--------|
| KF-01 | Login/logout dan peran | Selesai | `auth_repository.dart`, `login_screen.dart`, `home_screen.dart` |
| KF-02 | Kelola produk | Selesai | `products_screen.dart`, `product_form_screen.dart` |
| KF-03 | Cari produk (nama, kategori, barcode) | Sebagian: barcode diketik (Enter menambahkan ke keranjang); pemindaian kamera belum | `pos_screen.dart`, `product_provider.dart` |
| KF-04 | Keranjang belanja | Selesai | `cart_provider.dart`, `cart_panel.dart` |
| KF-05 | Total, diskon, kembalian | Selesai | `payment_screen.dart` |
| KF-06 | Perintah suara: tambah item | Selesai | `voice_command_parser.dart`, `voice_action_planner.dart` |
| KF-07 | Perintah suara: cek stok dan harga | Selesai | idem |
| KF-08 | Perintah suara: ringkasan penjualan | Selesai | idem |
| KF-09 | Stok otomatis dan notifikasi stok menipis | Selesai | `sale_repository.dart`, `payment_screen.dart`, `home_screen.dart` |
| KF-10 | Riwayat transaksi | Selesai | `history_screen.dart` |
| KF-11 | Laporan harian/mingguan/bulanan | Sebagian: ringkasan dan daftar per rentang; ekspor belum | `history_screen.dart`, `sale_repository.dart` |
| KF-12 | Struk digital dan cetak Bluetooth | Sebagian: struk digital selesai; cetak Bluetooth (opsional) belum | `receipt_screen.dart` |

Kebutuhan nonfungsional: mode offline dipenuhi oleh SQLite lokal (KNF-05); peran dan hash
kata sandi (KNF-03); Android 8.0+ melalui pengaturan `minSdk 26` (KNF-06); konfirmasi
sebelum perintah suara mengubah keranjang (KNF-07).

## 3. Keputusan Teknis

| Aspek | Pilihan | Alasan |
|-------|---------|--------|
| State management | Provider | Sederhana, cukup untuk skala MVP |
| Penyimpanan | sqflite (SQLite) | Offline, relasional sesuai ERD Tahap 2 |
| Pengenalan suara | speech_to_text (id_ID) | Mendukung bahasa Indonesia di Android |
| Penguraian perintah | Parser berbasis aturan | Deterministik, mudah diuji, tanpa internet |
| Produk dihapus | Dinonaktifkan (`is_active = 0`) | Riwayat transaksi tetap valid |
| Transaksi | Satu transaksi basis data (cek stok, simpan, kurangi stok) | Mencegah data setengah tersimpan |

## 4. Batasan yang Diketahui

- Pemindaian barcode dengan kamera belum ada (barcode dapat diketik).
- Ekspor laporan dan cetak struk Bluetooth belum ada.
- Voice Assistant belum membalas dengan suara (text-to-speech).
- Parser mengenali bilangan 1 sampai 99 dan pola perintah yang tercantum di README.

## 5. Checklist Pengujian Manual (isi setelah menjalankan di perangkat)

- [x] Login Admin berhasil, login salah menampilkan pesan
- [x] Tab Produk hanya muncul untuk Admin
- [ ] Tambah, ubah, dan nonaktifkan produk
- [x] Sentuh produk menambah ke keranjang; melebihi stok ditolak
- [x] Pembayaran: nominal kurang ditolak, kembalian benar, struk tampil
- [x] Stok berkurang setelah transaksi; notifikasi stok menipis muncul
- [ ] Voice: "tambah dua mie goreng" (konfirmasi lalu masuk keranjang)
- [x] Voice: "cek stok gula", "harga teh celup", "total penjualan hari ini"
- [x] Voice: mode ketik bekerja saat mikrofon tidak tersedia
- [ ] Riwayat: Hari Ini, 7 Hari, 30 Hari, dan detail struk
- [ ] Aplikasi tetap berjalan tanpa internet

## 6. Catatan Iterasi

| Iterasi | Cakupan | Catatan |
|---------|---------|---------|
| 1 | Kerangka proyek, tema, data lokal, login | Proyek dijalankan di emulator Android. Login awalnya gagal sampai data aplikasi dibersihkan, lalu berhasil dengan akun demo admin.|
| 2 | Produk, keranjang, pembayaran, struk | Batas stok dan validasi nominal bayar berfungsi sesuai rancangan.|
| 3 | Voice Assistant (STT, parser, konfirmasi) | Pengenalan suara tidak tersedia di emulator, sehingga pengujian memakai kolom ketik perintah.|
| 4 | Riwayat, validasi, uji unit, dokumentasi | flutter test lulus 14 tes.|
