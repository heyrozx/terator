# Video Tutorial Terator: Skrip & Instruksi Editing

Dokumen ini adalah **brief lengkap untuk editor video (manusia atau AI)**. Isinya: spesifikasi rekaman mentah, konsep video, skrip voice-over per adegan (dengan timestamp rekaman), dan aturan editing.

---

## 1. Bahan yang diserahkan

| File | Isi |
|---|---|
| `terator_tutorial_2k_raw.mp4` | Rekaman layar mentah. **1440 × 2560 (2K, portrait 9:16), 30 fps, H.264, durasi 2:01.8, tanpa audio.** |
| `timeline.json` | Penanda waktu tiap adegan (detik, dari awal rekaman mentah). Sama dengan kolom "Waktu rekaman" di bawah. |

Catatan tentang rekaman:
- Lingkaran abu-abu semi-transparan dengan tepi putih = **titik sentuhan jari** (seperti "Tampilkan ketukan" di Android). Sudah ada di video, tidak perlu ditambah lagi.
- Tidak ada status bar Android dan keyboard di layar, sehingga tampilannya bersih. **Jangan tambahkan keyboard palsu.**
- Data yang dipakai adalah data contoh fiktif (Budi Santoso, PT Maju Bersama, PT Sinar Digital Nusantara).
- Ketikan di rekaman berjalan ±15 karakter/detik. Bagian mengetik **boleh dipercepat** (lihat bagian 4).
- Di 00:35.4–00:36.6 (setelah tap "Simpan Akun") ada lompatan kecil karena animasi transisi tidak terekam. Tutupi dengan transisi *zoom/whip* singkat atau potong langsung.

---

## 2. Konsep video

- **Judul:** "Bikin Surat Resmi dalam 1 Menit dengan Terator"
- **Target penonton:** pelajar, mahasiswa, pencari kerja, dan pegawai yang sering butuh surat resmi (izin, lamaran, keterangan), tapi malas mengetik dari nol.
- **Pesan utama:** Isi data diri sekali → pilih template → surat terisi otomatis → edit seperlunya → simpan PDF.
- **Nada:** santai, ramah, cepat, gaya "teman yang ngajarin". Bahasa Indonesia sehari-hari yang tetap sopan (pakai "kamu").
- **Durasi target hasil akhir:** **75–90 detik** (versi utama). Opsional: potongan pendek 30 detik untuk Reels/TikTok/Shorts (lihat bagian 6).
- **Format output:** 1440 × 2560 (9:16) untuk Shorts/Reels/TikTok/Status. Opsional versi 16:9 (lihat bagian 6).

### Identitas visual (ambil dari aplikasi)
| Token | Warna | Pemakaian |
|---|---|---|
| Primary (indigo) | `#4F46E5` | Judul, highlight, progress bar |
| Violet | `#7C3AED` | Gradasi bersama primary (kiri-atas → kanan-bawah) |
| Primary dark | `#3730A3` | Bayangan / teks di atas latar terang |
| Latar | `#F8FAFC` / putih | Kartu teks |
| Aksen Premium | oranye/emas `#F59E0B` | Label "PREMIUM" |

- **Font:** Poppins (sama dengan aplikasi). Judul SemiBold/Bold, caption Medium.
- **Logo:** gunakan logo Terator dari `store/logo-hd.png` / `store/app-icon/`.

---

## 3. Skrip voice-over & storyboard

Kolom **Waktu rekaman** mengacu ke `terator_tutorial_2k_raw.mp4`. Kolom **Durasi akhir** adalah target setelah dipercepat.
Teks dalam **[TEKS LAYAR]** = teks/caption yang muncul di atas video (judul langkah), terpisah dari subtitle VO.

### Adegan 0: Hook / Pembuka (tambahan, bukan dari rekaman), ±3 dtk
- **Visual:** latar gradasi `#4F46E5 → #7C3AED`. Mockup HP berisi frame rekaman 01:51 (preview surat jadi dengan tanda tangan) muncul dengan animasi *pop/scale-in*. Logo Terator kecil di atas.
- **[TEKS LAYAR]:** "Surat resmi jadi dalam 1 menit?" (kata "1 menit" diberi highlight kuning/emas)
- **VO:** "Masih ngetik surat resmi dari nol? Coba cara ini."

### Adegan 1: Panduan Memulai, rekaman 00:00.0–00:02.5, durasi akhir ±2,5 dtk
- **Visual:** layar onboarding "Panduan Memulai" dengan 3 langkah (Akun, Kop, Template). Zoom pelan 100% → 105%.
- **[TEKS LAYAR]:** "3 langkah saja"
- **VO:** "Saat pertama buka Terator, kamu dipandu tiga langkah singkat."

### Adegan 2: Buat Akun Surat, rekaman 00:02.5–00:36.6, durasi akhir ±16 dtk
| Waktu rekaman | Kejadian | Instruksi edit |
|---|---|---|
| 00:02.5 | Tap "Buat Akun Surat" | Zoom-in 115% ke tombol sesaat sebelum tap |
| 00:03.9–00:12.7 | Isi Nama, TTL, Jenis Kelamin, Agama, Status | **Percepat 3×**, zoom 120% mengikuti kolom yang sedang diisi |
| 00:12.7–00:15.8 | Tab Pendidikan → Pendidikan Terakhir | Percepat 2× |
| 00:15.8–00:25.4 | Tab Lainnya → No. Telp, Email, Kota, Alamat | **Percepat 3×** |
| 00:25.4–00:35.4 | Tab Tanda Tangan → menggambar tanda tangan | **Kecepatan normal** untuk goresan (momen "wow"), zoom 125% ke kotak tanda tangan |
| 00:35.4–00:36.6 | Tap "Simpan Akun" → snackbar "Akun berhasil ditambahkan!" | Transisi cepat; tambahkan efek "ding" kecil |

- **[TEKS LAYAR]:** "Langkah 1 · Buat Akun Surat" → lalu chip kecil "Cukup sekali!"
- **VO:** "Langkah pertama, buat Akun Surat. Isi data diri seperti nama, tempat tanggal lahir, pendidikan, dan nomor telepon. Lalu bubuhkan tanda tangan langsung di layar. Cukup sekali, data ini otomatis terisi di semua surat."

### Adegan 3: Kop Surat (opsional, Premium), rekaman 00:36.6–00:58.8, durasi akhir ±10 dtk
| Waktu rekaman | Kejadian | Instruksi edit |
|---|---|---|
| 00:36.6 | Tap "Atur Kop Surat" | Potong cepat |
| 00:38.0–00:41.2 | Upload logo, logo "MB" muncul | Zoom ke kartu Logo Utama |
| 00:41.2–00:49.4 | Isi nama instansi, alamat, telepon | **Percepat 3×** |
| 00:49.4–00:54.9 | Buka Desain Kop Surat, gulir, pilih "Tengah Biru", Simpan Desain | Percepat 1,5×, sorot kartu desain yang dipilih |
| 00:54.9–00:58.8 | Simpan Kop Surat → kembali ke panduan "Kop surat siap" | Normal |

- **[TEKS LAYAR]:** "Langkah 2 · Kop Surat" + badge oranye "PREMIUM"
- **VO:** "Kalau butuh surat atas nama instansi, atur kop surat dengan logo, alamat, dan pilihan desain. Fitur ini khusus pengguna Premium, dan boleh dilewati."

### Adegan 4: Pilih Template & Beranda, rekaman 00:58.8–01:08.6, durasi akhir ±7 dtk
| Waktu rekaman | Kejadian | Instruksi edit |
|---|---|---|
| 00:58.8–01:00.7 | Langkah 3: grid kategori surat | Normal |
| 01:00.7–01:03.0 | Tap "Selesai" → Beranda | Transisi slide |
| 01:03.0–01:04.2 | Beranda ("Selamat Pagi!", kategori) | Normal |
| 01:04.2–01:06.3 | Ketik "lamaran" di pencarian | Zoom 120% ke kolom cari |
| 01:06.3–01:08.6 | Tap "Surat Lamaran Pekerjaan" | Sorot hasil pencarian |

- **[TEKS LAYAR]:** "Langkah 3 · Pilih Template" lalu "100+ template surat"
- **VO:** "Langkah ketiga, pilih template. Ada lebih dari seratus template dalam delapan kategori. Tinggal cari, misalnya surat lamaran pekerjaan."

### Adegan 5: Detail template → Isi Data Surat, rekaman 01:08.6–01:21.6, durasi akhir ±8 dtk
| Waktu rekaman | Kejadian | Instruksi edit |
|---|---|---|
| 01:08.6–01:10.3 | Pratinjau template, gulir ke bawah | Normal |
| 01:10.3 | Tap "Gunakan Template" | Zoom ke tombol |
| 01:11.9–01:21.6 | Isi Nama Perusahaan, Alamat, Jabatan → tap "Lanjut" | **Percepat 3×** |

- **[TEKS LAYAR]:** "Isi data khusus surat"
- **VO:** "Lihat dulu pratinjaunya, lalu tap Gunakan Template. Isi data khusus surat ini, seperti nama perusahaan dan posisi yang dilamar."

### Adegan 6: Pilih akun & tanda tangan, rekaman 01:21.6–01:27.1, durasi akhir ±4 dtk
| Waktu rekaman | Kejadian | Instruksi edit |
|---|---|---|
| 01:21.6 | Pilih akun "Budi Santoso" | Normal |
| 01:23.0–01:27.1 | Dialog "Tanda Tangan" → "Ya, Gunakan" | Percepat 1,5× pada jeda loading |

- **VO:** "Pilih Akun Surat yang mau dipakai, dan tanda tangan bisa langsung disertakan."

### Adegan 7: Editor, rekaman 01:27.1–01:43.7, durasi akhir ±12 dtk
| Waktu rekaman | Kejadian | Instruksi edit |
|---|---|---|
| 01:27.1–01:30.3 | Surat sudah terisi otomatis (nama, TTL, status, pendidikan, dll.) | **Momen utama**: tahan normal, zoom 115% ke tabel data diri, beri highlight kotak/garis bawah animasi pada data yang terisi |
| 01:30.3–01:37.0 | Gulir, tambah baris "Sertifikat Pelatihan Komputer" di daftar lampiran | Percepat 2× saat mengetik, zoom ke daftar |
| 01:37.0–01:41.1 | Gulir ke tanda tangan → tap "Simpan Surat" → isi nama file | Percepat 2× saat mengetik nama file |
| 01:41.1–01:43.7 | Tap "SIMPAN & DOWNLOAD" | Efek "whoosh" + transisi |

- **[TEKS LAYAR]:** "Terisi otomatis ✨" lalu "Bisa diedit bebas"
- **VO:** "Lihat, surat langsung terisi otomatis. Masih bisa kamu edit bebas, misalnya menambah lampiran. Kalau sudah, simpan dan download sebagai PDF."

### Adegan 8: File Saya & Preview, rekaman 01:43.7–01:57.9, durasi akhir ±9 dtk
| Waktu rekaman | Kejadian | Instruksi edit |
|---|---|---|
| 01:43.7–01:47.3 | File Saya: "Lamaran Staff Admin - Budi" + snackbar sukses | Normal |
| 01:47.3–01:51.9 | Menu opsi: Preview, Edit, Ubah Nama, Berbagi, Download, Hapus | Percepat 1,5× |
| 01:51.9–01:57.9 | Preview surat jadi, gulir sampai tanda tangan | Normal, zoom ke tanda tangan di akhir |

- **[TEKS LAYAR]:** "Tersimpan di File Saya"
- **VO:** "Semua surat tersimpan rapi di menu File Saya. Bisa dilihat ulang, diedit, atau langsung dibagikan."

### Adegan 9: Penutup / CTA, rekaman 01:57.9–02:01.8 + kartu penutup ±4 dtk
- **Visual:** Beranda dengan "1 Surat Dibuat" (zoom ke angka tersebut), lalu transisi ke kartu penutup: latar gradasi brand, ikon aplikasi, teks dan badge "Temukan di Google Play".
- **[TEKS LAYAR]:** "Terator · Template Surat Generator" + "Download gratis di Google Play"
- **VO:** "Bikin surat resmi jadi cepat dan rapi. Download Terator sekarang di Google Play!"

### Naskah VO utuh (untuk text-to-speech / pengisi suara)
> Masih ngetik surat resmi dari nol? Coba cara ini.
> Saat pertama buka Terator, kamu dipandu tiga langkah singkat.
> Langkah pertama, buat Akun Surat. Isi data diri seperti nama, tempat tanggal lahir, pendidikan, dan nomor telepon. Lalu bubuhkan tanda tangan langsung di layar. Cukup sekali, data ini otomatis terisi di semua surat.
> Kalau butuh surat atas nama instansi, atur kop surat dengan logo, alamat, dan pilihan desain. Fitur ini khusus pengguna Premium, dan boleh dilewati.
> Langkah ketiga, pilih template. Ada lebih dari seratus template dalam delapan kategori. Tinggal cari, misalnya surat lamaran pekerjaan.
> Lihat dulu pratinjaunya, lalu tap Gunakan Template. Isi data khusus surat ini, seperti nama perusahaan dan posisi yang dilamar.
> Pilih Akun Surat yang mau dipakai, dan tanda tangan bisa langsung disertakan.
> Lihat, surat langsung terisi otomatis. Masih bisa kamu edit bebas, misalnya menambah lampiran. Kalau sudah, simpan dan download sebagai PDF.
> Semua surat tersimpan rapi di menu File Saya. Bisa dilihat ulang, diedit, atau langsung dibagikan.
> Bikin surat resmi jadi cepat dan rapi. Download Terator sekarang di Google Play!

(±190 kata, sekitar 75–85 detik dengan tempo bicara santai-cepat.)

---

## 4. Aturan editing

**Ritme & kecepatan**
- Ikuti tabel kecepatan per adegan. Prinsipnya: **bagian mengetik dan loading dipercepat 2–3×**; **momen "wow" tetap normal**: menggambar tanda tangan, surat terisi otomatis (01:27), dan preview akhir.
- Pakai *speed ramp* halus (ease in/out ±0,2 dtk), bukan lompatan kasar.
- Sinkronkan potongan dengan VO: tiap kalimat VO dimulai saat aksi yang dibicarakan muncul di layar.
- Jangan biarkan layar diam lebih dari 1,5 detik tanpa gerakan, zoom, atau teks.

**Kamera virtual (zoom & pan)**
- Ikuti titik sentuhan (lingkaran abu-abu) untuk menentukan area zoom.
- Zoom maksimal 130% (sumber 2K masih tajam). Gerak zoom 0,4–0,6 dtk, easing *ease-in-out*.
- Kembali ke 100% setiap pindah layar agar penonton tetap tahu konteks.

**Teks layar & subtitle**
- Judul langkah ("Langkah 1 · Buat Akun Surat", dst.) tampil sebagai pill/kartu di atas (±12% dari atas), latar putih 90% atau gradasi brand, sudut membulat, animasi *slide-down + fade* 0,3 dtk.
- **Subtitle VO wajib** (banyak orang menonton tanpa suara): Poppins Medium, putih dengan outline/bayangan gelap atau kotak semi-transparan, di sepertiga bawah tapi **di atas** tombol bawah aplikasi (hindari menutupi tombol "Simpan …" dan navbar, sekitar y 70–78% tinggi frame). Maksimal 2 baris, ±32 karakter per baris.
- Highlight kata kunci di subtitle dengan warna emas/kuning: *sekali*, *otomatis*, *PDF*, *100+ template*.
- Area aman 9:16: kosongkan ±10% atas dan ±18% bawah dari teks penting (UI TikTok/Reels).

**Audio**
- Musik latar: instrumental upbeat ringan (lo-fi/corporate pop, 100–120 BPM), bebas royalti. Volume −20 s/d −24 LUFS di bawah VO (*ducking* saat VO bicara).
- SFX halus: *tap/pop* pada tiap titik sentuhan penting (bukan semua), *ding* saat snackbar sukses, *whoosh* untuk transisi antar-langkah.
- VO: suara ramah, usia 20–30-an, tempo sedikit cepat. Normalisasi akhir −14 LUFS (standar media sosial).

**Transisi**
- Antar-langkah: *whip pan* / *zoom blur* singkat (≤0,3 dtk). Di dalam satu langkah: potong langsung (*hard cut*).
- Lompatan di 00:35.4–00:36.6: tutupi dengan transisi zoom-out cepat ke layar Panduan.

**Yang dilarang**
- Jangan ubah rasio/meregangkan video. Jangan menambah filter warna berat (warna UI harus tetap sesuai brand).
- Jangan menutupi data yang sedang dijelaskan dengan stiker/teks.
- Jangan menyebut harga atau janji yang tidak ada di aplikasi.
- Jangan pakai logo Google Play selain badge resmi "Temukan di Google Play".

---

## 5. Daftar penanda waktu (ringkas, dari `timeline.json`)

| Waktu | ID | Kejadian |
|---|---|---|
| 00:00.0 | S01_onboarding | Layar Panduan Memulai |
| 00:02.5 | S02_akun_buka | Tap "Buat Akun Surat" |
| 00:03.9 | S02_akun_data | Isi tab Akun |
| 00:12.7 | S02_akun_pendidikan | Tab Pendidikan |
| 00:15.8 | S02_akun_lainnya | Tab Lainnya |
| 00:25.4 | S02_akun_ttd | Gambar tanda tangan |
| 00:35.4 | S02_akun_simpan | Simpan Akun |
| 00:36.6 | S03_kop_buka | Atur Kop Surat |
| 00:38.0 | S03_kop_logo | Upload logo |
| 00:41.2 | S03_kop_identitas | Isi identitas instansi |
| 00:49.4 | S03_kop_desain | Pilih desain kop |
| 00:54.9 | S03_kop_simpan | Simpan kop surat |
| 00:58.8 | S04_template_step | Langkah 3: kategori |
| 01:00.7 | S04_selesai | Tap "Selesai" → Beranda |
| 01:03.0 | S05_beranda | Beranda |
| 01:04.2 | S05_cari | Cari "lamaran" |
| 01:06.3 | S05_pilih | Pilih Surat Lamaran Pekerjaan |
| 01:08.6 | S06_detail | Pratinjau template |
| 01:10.3 | S06_gunakan | Tap "Gunakan Template" |
| 01:11.9 | S07_isi_data | Isi Data Surat |
| 01:21.6 | S08_pilih_akun | Pilih akun |
| 01:23.0 | S08_ttd | "Ya, Gunakan" tanda tangan |
| 01:27.1 | S09_editor | Editor terisi otomatis |
| 01:30.3 | S09_edit | Tambah baris lampiran |
| 01:37.0 | S09_simpan | Simpan Surat + nama file |
| 01:41.1 | S09_download | SIMPAN & DOWNLOAD |
| 01:43.7 | S10_file_saya | File Saya |
| 01:47.3 | S10_opsi | Menu opsi file |
| 01:51.9 | S10_preview | Preview surat jadi |
| 01:57.9 | S11_beranda | Beranda (1 surat dibuat) |
| 02:01.8 | END | Akhir rekaman |

---

## 6. Versi tambahan (opsional)

**A. Potongan pendek 30 detik (Reels/TikTok/Shorts)**
Hook (3 dtk) → tanda tangan digambar (00:27–00:33, 2×) → cari "lamaran" (01:04–01:08) → editor terisi otomatis (01:27–01:30, normal) → simpan PDF (01:41–01:44) → preview + tanda tangan (01:52–01:58) → CTA (3 dtk).
VO singkat: *"Isi data sekali, pilih template, surat resmi langsung jadi lengkap dengan tanda tangan. Download Terator di Google Play!"*

**B. Versi 16:9 (YouTube, 3840×2160 atau 2560×1440)**
Letakkan video 9:16 di dalam mockup HP di sisi kiri/tengah atas latar gradasi brand. Judul langkah dan poin penjelasan tampil besar di sisi kanan. Zoom tetap dilakukan di dalam layar HP.

**C. Thumbnail (1280×720 & 1080×1920)**
Mockup HP berisi preview surat bertanda tangan + teks besar "SURAT RESMI 1 MENIT" + logo Terator, latar gradasi `#4F46E5 → #7C3AED`.

---

## 7. Checklist sebelum ekspor
- [ ] Durasi versi utama 75–90 detik.
- [ ] Subtitle lengkap, ejaan Bahasa Indonesia benar, tidak menutupi tombol.
- [ ] Musik di-*duck* saat VO, loudness akhir ±−14 LUFS.
- [ ] Teks penting berada di area aman 9:16.
- [ ] Ekspor: H.264 atau H.265, 1440×2560, 30 fps, bitrate ≥ 16 Mbps (atau CRF 18), audio AAC 48 kHz 192 kbps.
