# CatatKas 💰

Aplikasi pencatat keuangan pribadi berbasis Android yang membantu kamu mencatat pemasukan dan pengeluaran dengan mudah.

## 📱 Tentang Aplikasi

CatatKas adalah aplikasi keuangan sederhana yang dapat digunakan oleh siapa saja, mulai dari anak kos, ibu rumah tangga, hingga pelaku UMKM untuk mencatat dan memantau kondisi keuangan mereka. Semua data tersimpan secara lokal di perangkat tanpa memerlukan koneksi internet.

## ✨ Fitur

- 💸 Catat pemasukan dan pengeluaran
- 🗂️ Kategorisasi transaksi (Makanan, Transportasi, Gaji, dll)
- 📅 Filter riwayat per hari, minggu, bulan, tahun, atau custom tanggal
- 📋 Detail transaksi lengkap beserta catatan
- ✏️ Edit dan hapus transaksi
- 📊 Laporan keuangan per periode
- 📄 Export laporan ke PDF
- 💾 Penyimpanan lokal menggunakan SQLite (tanpa internet)

## 🛠️ Teknologi yang Digunakan

| Teknologi | Keterangan |
|-----------|------------|
| Flutter | Framework utama |
| Dart | Bahasa pemrograman |
| SQLite (sqflite) | Database lokal |
| pdf & printing | Export laporan PDF |
| intl | Format tanggal & mata uang |

## 📂 Isi Repository

| File/Folder | Keterangan |
|-------------|------------|
| lib/ | Source code aplikasi Flutter |
| pubspec.yaml | Konfigurasi dependencies |
| CatatKas.apk.zip | File APK siap install |
| keuangan.db | Contoh database SQLite |

## 📦 Cara Install APK

1. Download file **CatatKas.apk.zip**
2. Extract file zip tersebut
3. Pindahkan file **CatatKas.apk** ke HP Android
4. Buka file manager di HP, cari file APK tersebut
5. Tap file APK untuk menginstall
6. Jika muncul pesan **"Install from unknown sources"**, aktifkan di **Settings → Security → Install unknown apps**
7. Selesai, aplikasi siap digunakan

## 🚀 Cara Menjalankan dari Source Code

Prasyarat yang dibutuhkan: Flutter SDK >= 3.0.0, Android Studio atau VS Code, dan Android device atau emulator. 
Clone repository ini dengan perintah `git clone https://github.com/yafinaufal220-alt/CatatKas.git`, lalu masuk ke folder project dengan `cd CatatKas`, install dependencies dengan `flutter pub get`, dan jalankan aplikasi dengan `flutter run`. 
Untuk build APK jalankan `flutter build apk --release` dan file APK tersedia di `build/app/outputs/flutter-apk/app-release.apk`.

## 👨‍💻 Developer

**Yafi' Naufal Riadi** — PeTIK II Jombang

## 📄 Lisensi

Project ini dibuat untuk keperluan pembelajaran.
