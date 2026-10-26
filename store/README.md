# Aset Listing Google Play

Semua gambar untuk halaman toko Terator di Play Console (Pertumbuhan pengguna › Listingan toko).

| Folder | File | Ukuran | Tempat upload di Play Console |
|---|---|---|---|
| `app-icon/` | `app-icon-512.png` | 512 × 512 | Ikon aplikasi |
| `feature-graphic/` | `feature-graphic.png` | 1024 × 500 | Grafik fitur |
| `phone-screenshots/` | `01` … `08` | 1080 × 1920 (9:16) | Screenshot ponsel (upload sesuai urutan nomor) |

Urutan screenshot ponsel:

1. `01-buat-surat-resmi` — dua mockup bertumpuk (Beranda + daftar template)
2. `02-template-surat` — daftar 100+ template
3. `03-akun-surat` — simpan data diri sekali
4. `04-isi-data-surat` — formulir isi data surat
5. `05-edit-surat` — editor surat (tanpa kop; kop tampil saat preview & download)
6. `06-kop-surat` — desain kop surat (ditandai Fitur Premium)
7. `07-file-saya` — surat tersimpan sebagai PDF
8. `08-preview-surat` — preview template

Semua file PNG 24-bit tanpa alpha dan di bawah 8 MB, sesuai syarat Play Console.

## Membuat ulang

Screenshot asli aplikasi ada di `source/screens/` (diambil dari build web dengan data contoh). Ikon mahkota pada label Fitur Premium (`source/icons/`) berasal dari [Lucide](https://lucide.dev) (lisensi ISC). Untuk membuat ulang semua gambar setelah mengubah teks atau desain di `source/generate.js`:

```bash
# butuh Node.js + Playwright (Chromium) dan koneksi internet untuk font Poppins
node store/source/generate.js
```
