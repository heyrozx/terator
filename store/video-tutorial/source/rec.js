// Perekam tutorial Terator.
//   MODE=dry   node rec.js   -> uji cepat (DPR 1, waktu nyata, screenshot per penanda ke dry/)
//   MODE=final node rec.js   -> render 1440x2560 @30fps (jam palsu, frame-by-frame) ke out/
const { chromium } = require('playwright');
const { spawn } = require('child_process');
const fs = require('fs');
const sig = require('./sig.js');

const MODE = process.env.MODE || 'dry';
const FINAL = MODE === 'final';
const FPS = 30, DT = 1000 / FPS;
const VW = 384, VH = 683, DPR = process.env.DPR ? +process.env.DPR : (FINAL ? 3.75 : 1);   // 384*3.75 = 1440, 683*3.75 = 2561 -> crop 2560

(async () => {
  const browser = await chromium.launch({ args: ['--enable-unsafe-swiftshader', '--use-angle=swiftshader', '--ignore-gpu-blocklist'] });
  const ctx = await browser.newContext({ viewport: { width: VW, height: VH }, deviceScaleFactor: DPR, isMobile: true, hasTouch: true, locale: 'id-ID', timezoneId: 'Asia/Jakarta' });
  const p = await ctx.newPage();
  p.on('pageerror', e => { if (!/toString/.test(e.message)) console.log('PAGEERR', e.message.slice(0, 200)); });
  p.on('console', m => { if (process.env.DBG || /context|lost/i.test(m.text())) console.log('CONSOLE', m.text().slice(0,200)); });
  p.on('filechooser', fc => fc.setFiles(__dirname + '/logo.png'));
  if (FINAL) await p.clock.install({ time: new Date('2026-11-16T08:20:00+07:00') });
  await p.goto('http://localhost:8088/');
  await p.waitForTimeout(12000);
  const cdp = await ctx.newCDPSession(p);

  await p.evaluate(() => { document.addEventListener('webglcontextlost', () => console.log('CTX LOST'), true); document.addEventListener('webglcontextrestored', () => console.log('CTX RESTORED'), true);
    new MutationObserver(()=>{}).observe(document.body,{childList:true,subtree:true}); });
  // overlay penanda sentuhan
  await p.evaluate(() => {
    const d = document.createElement('div'); d.id = 'tapdot';
    Object.assign(d.style, { position: 'fixed', left: '0', top: '0', width: '46px', height: '46px', marginLeft: '-23px', marginTop: '-23px',
      borderRadius: '50%', background: 'rgba(40,40,40,0.30)', border: '2.5px solid rgba(255,255,255,0.95)', boxShadow: '0 0 0 1.5px rgba(0,0,0,0.25)',
      zIndex: '2147483647', pointerEvents: 'none', opacity: '0', boxSizing: 'border-box' });
    document.body.appendChild(d);
    window.__dot = (x, y, o, s) => { d.style.transform = `translate(${x}px,${y}px) scale(${s})`; d.style.opacity = o; };
  });

  // ffmpeg
  let ff = null, frameNo = 0, vt = 0, acc = 0;
  if (FINAL) {
    fs.mkdirSync('out', { recursive: true });
    ff = spawn('ffmpeg', ['-y', '-loglevel', 'error', '-f', 'image2pipe', '-framerate', String(FPS), '-c:v', 'mjpeg', '-i', '-',
      '-vf', 'crop=iw:trunc(ih/2)*2:0:0', '-c:v', 'libx264', '-preset', 'medium', '-crf', '15', '-pix_fmt', 'yuv420p', '-r', String(FPS),
      '-movflags', '+faststart', process.env.OUT || 'out/terator_tutorial_2k_raw.mp4'], { stdio: ['pipe', 'inherit', 'inherit'] });
  }
  fs.rmSync('dry', { recursive: true, force: true }); fs.mkdirSync('dry');

  // status titik sentuh
  const dot = { x: 0, y: 0, down: false, age: 99, shown: false };
  const applyDot = async () => {
    let o = 0, s = 1;
    if (dot.down) { o = 1; s = Math.min(1, 0.6 + dot.age * 0.1); }
    else if (dot.age < 8) { o = 1 - dot.age / 8; s = 1 + dot.age * 0.06; }
    if (o > 0 || dot.shown) { await p.evaluate(([x, y, o, s]) => window.__dot(x, y, o, s), [dot.x, dot.y, o, s]); dot.shown = o > 0; }
    dot.age++;
  };

  let since = 0, lastT = 0;
  const frame = async () => {
    if (!FINAL) return;
    acc += DT; const step = Math.round(acc - vt); vt += step;
    await p.clock.runFor(step);
    await applyDot();
    const buf = await p.screenshot({ type: 'jpeg', quality: 94 });
    if (!ff.stdin.write(buf)) await new Promise(r => ff.stdin.once('drain', r));
    frameNo++;
    if (frameNo % 150 === 0) { const now = Date.now(); console.log(`frame ${frameNo} (${(frameNo / FPS).toFixed(1)}s) ${((now - lastT) / 150).toFixed(0)}ms/frame`); lastT = now; }
  };
  const wait = async (ms) => { if (!FINAL) { await applyDot(); return p.waitForTimeout(ms); } for (let i = 0; i < Math.round(ms / DT); i++) await frame(); };
  const touch = (type, pts) => cdp.send('Input.dispatchTouchEvent', { type, touchPoints: pts.map(([x, y]) => ({ x, y })) });

  // timeline
  const timeline = []; let mk = 0;
  const mark = async (id, label) => {
    if (process.env.STOP && id === process.env.STOP) throw new Error('STOP');
    const t = FINAL ? frameNo / FPS : 0;
    timeline.push({ id, t: +t.toFixed(2), label });
    console.log(`[${t.toFixed(2)}s] ${id} ${label}`);
    if (!FINAL) await p.screenshot({ path: `dry/${String(mk++).padStart(2, '0')}_${id}.png` });
  };

  // semantik
  let semOn = false;
  const find = async (re, top = false) => {
    if (!semOn) { await p.evaluate(() => document.querySelector('flt-semantics-placeholder')?.click()); await p.waitForTimeout(400); semOn = true; }
    for (let attempt = 0; attempt < 20; attempt++) {
      const r = await p.evaluate(([src, top]) => {
        const rx = new RegExp(src, 'i'); let best = null;
        for (const e of document.querySelectorAll('flt-semantics, input, textarea')) {
          const own = [...e.childNodes].filter(c => c.nodeType === 3).map(c => c.textContent).join('');
          const t = (e.getAttribute('aria-label') || own || e.getAttribute('placeholder') || '').trim();
          const b = e.getBoundingClientRect(); if (b.width === 0 || b.height === 0) continue;
          if (b.y + b.height / 2 < 0 || b.y + b.height / 2 > innerHeight) continue;
          if (rx.test(t) && (!best || (top ? b.y < best.y0 : b.width * b.height < best.a))) best = { x: b.x + b.width / 2, y: b.y + b.height / 2, a: b.width * b.height, y0: b.y, input: /INPUT|TEXTAREA/.test(e.tagName) };
        }
        return best;
      }, [re.source, top]);
      if (r) return r;
      await wait(150);
    }
    throw new Error('tidak ketemu ' + re);
  };
  const tap = async (x, y, after = 700) => {
    dot.x = x; dot.y = y; dot.down = true; dot.age = 0;
    await touch('touchStart', [[x, y]]); await wait(100); if (!FINAL) await p.waitForTimeout(60);
    await touch('touchEnd', []); dot.down = false; dot.age = 0;
    await wait(after);
  };
  const tapText = async (re, after = 700, top = false) => { const r = await find(re, top); await tap(r.x, r.y, after); return r; };
  const ensureFocus = async (x, y) => {
    await p.evaluate(([x, y]) => {
      const a = document.activeElement; if (a && /INPUT|TEXTAREA|IFRAME/.test(a.tagName)) return;
      for (const e of document.querySelectorAll('input, textarea')) { const b = e.getBoundingClientRect(); if (x >= b.left && x <= b.right && y >= b.top && y <= b.bottom) { e.focus(); return; } }
    }, [x, y]);
  };
  const typeText = async (text, fpc = 2) => {
    for (const ch of text) { await p.keyboard.type(ch); if (FINAL) { for (let i = 0; i < fpc; i++) await frame(); } }
    if (!FINAL) await p.waitForTimeout(200);
  };
  const fill = async (re, text, after = 400) => { const r = await tapText(re, 350); await ensureFocus(r.x, r.y); await typeText(text); await wait(after); };
  const drag = async (pts, holdEnd = 0) => {
    dot.x = pts[0][0]; dot.y = pts[0][1]; dot.down = true; dot.age = 0;
    await touch('touchStart', [pts[0]]); await wait(DT);
    for (const q of pts.slice(1)) { dot.x = q[0]; dot.y = q[1]; await touch('touchMove', [q]); if (FINAL) await frame(); else await p.waitForTimeout(16); }
    for (let i = 0; i < holdEnd; i++) await wait(DT);
    await touch('touchEnd', []); dot.down = false; dot.age = 0;
  };
  const scroll = async (dy, x = 374, y0 = 460, after = 600) => {
    const N = Math.max(12, Math.round(Math.abs(dy) / 18)), pts = [];
    for (let i = 0; i <= N; i++) { const t = i / N, e = t < .5 ? 2 * t * t : 1 - Math.pow(-2 * t + 2, 2) / 2; pts.push([x, y0 - dy * e]); }
    await drag(pts, 6); await wait(after);
  };
  // jalankan aksi dengan jam nyata (dipakai untuk ekspor tanda tangan yang tidak stabil di jam palsu)
  const realtime = async (fn, ms) => {
    await fn();
    if (!FINAL) return p.waitForTimeout(ms);
    for (let t = 0; t < ms; t += 100) { await p.clock.runFor(100); await p.waitForTimeout(100); }
  };
  const unfocus = async () => { await p.evaluate(() => document.activeElement?.blur()); };

  try {
    // ===== 1. Pembuka / onboarding
    await mark('S01_onboarding', 'Layar Panduan Memulai muncul saat pertama buka aplikasi');
    await wait(2500);

    // ===== 2. Buat Akun Surat
    await mark('S02_akun_buka', 'Tap "Buat Akun Surat"');
    await tapText(/^Buat Akun Surat$/, 1300);
    await mark('S02_akun_data', 'Isi tab Akun: nama, TTL, jenis kelamin, agama, status');
    await fill(/^Nama Lengkap/, 'Budi Santoso');
    await fill(/^Tempat & Tanggal/, 'Surabaya, 12 Mei 1998');
    await fill(/^Jenis Kelamin/, 'Laki-laki');
    await fill(/^Agama/, 'Islam');
    await fill(/^Status Perkawinan/, 'Belum Menikah');
    await wait(500);
    await mark('S02_akun_pendidikan', 'Tab Pendidikan: pendidikan terakhir');
    await tapText(/^Pendidikan$/, 900);
    await fill(/^Pendidikan Terakhir/, 'S1 Manajemen');
    await wait(400);
    await mark('S02_akun_lainnya', 'Tab Lainnya: no. telp, email, kota, alamat');
    await tapText(/^Lainnya$/, 900);
    await fill(/^No\. Telp/, '0812 3456 7890');
    await fill(/^Email/, 'budi.santoso@email.com');
    await fill(/^Kota tempat/, 'Surabaya');
    await fill(/^Alamat$/, 'Jl. Kenanga No. 5, Surabaya');
    await wait(400);
    await mark('S02_akun_ttd', 'Tab Tanda Tangan: gambar tanda tangan langsung di layar');
    await tapText(/^Tanda Tangan$/, 1000);
    for (const s of sig(192, 355)) { await drag(s); await wait(120); }
    await wait(900);
    await mark('S02_akun_simpan', 'Tap "Simpan Akun" -> akun tersimpan');
    const sv = await find(/^Simpan Akun$/);
    await realtime(async () => { dot.x = sv.x; dot.y = sv.y; dot.down = true; dot.age = 0; await touch('touchStart', [[sv.x, sv.y]]); await p.waitForTimeout(80); await touch('touchEnd', []); dot.down = false; dot.age = 0; }, 3000);
    await wait(1200);

    // ===== 3. Kop surat
    await mark('S03_kop_buka', 'Langkah 2: Atur Kop Surat (opsional, Premium)');
    await tapText(/^Atur Kop Surat$/, 1300);
    await mark('S03_kop_logo', 'Upload logo instansi');
    await tapText(/^Upload Logo$/, 1800);
    await scroll(250);
    await mark('S03_kop_identitas', 'Isi identitas instansi');
    await fill(/^Nama Instansi/, 'PT Maju Bersama');
    await fill(/^Alamat$/, 'Jl. Merdeka No. 17, Surabaya');
    await fill(/^No\. Telepon/, '(031) 1234567');
    await unfocus(); await wait(300);
    await scroll(400);
    await mark('S03_kop_desain', 'Pilih desain kop surat');
    await tapText(/^Desain Kop Surat/, 1300);
    await scroll(330, 374, 470);
    await tapText(/Tengah Biru/, 900);
    await tapText(/^Simpan Desain$/, 1500);
    await mark('S03_kop_simpan', 'Simpan kop surat');
    await tapText(/^Simpan Kop Surat$/, 2600);
    await wait(1200);

    // ===== 4. Langkah 3 onboarding -> beranda
    await mark('S04_template_step', 'Langkah 3: pilih kategori & template');
    await tapText(/^Lanjut$/, 1800);
    await mark('S04_selesai', 'Tap "Selesai" -> masuk Beranda');
    await tapText(/^Selesai$/, 2200);

    // ===== 5. Beranda & cari template
    await mark('S05_beranda', 'Beranda: kategori surat & pencarian');
    await wait(1200);
    await mark('S05_cari', 'Cari template "lamaran"');
    await fill(/^Cari template surat/, 'lamaran', 1200);
    await mark('S05_pilih', 'Pilih "Surat Lamaran Pekerjaan"');
    await tapText(/^Surat Lamaran Pekerjaan$/, 2200, true);

    // ===== 6. Detail template
    await mark('S06_detail', 'Pratinjau template + opsi kop surat & bookmark');
    await scroll(280, 192, 480, 900);
    await mark('S06_gunakan', 'Tap "Gunakan Template"');
    await tapText(/^Gunakan Template$/, 1500);

    // ===== 7. Isi data surat
    await mark('S07_isi_data', 'Isi Data Surat: perusahaan, alamat, posisi');
    await fill(/^Nama Perusahaan$/, 'PT Sinar Digital Nusantara');
    await fill(/^Alamat$/, 'Jl. Raya Darmo No. 88, Surabaya');
    await fill(/^Jabatan$/, 'Staff Administrasi');
    await unfocus(); await wait(500);
    await tapText(/^Lanjut/, 1500);

    // ===== 8. Pilih akun
    await mark('S08_pilih_akun', 'Pilih Akun Surat yang dipakai');
    await tapText(/Budi Santoso/, 1300);
    await mark('S08_ttd', 'Pakai tanda tangan? -> "Ya, Gunakan"');
    await tapText(/^Ya, Gunakan/, 4000);

    // ===== 9. Editor
    await mark('S09_editor', 'Editor: surat sudah terisi otomatis');
    await wait(1500);
    await scroll(330, 192, 500, 900);
    await mark('S09_edit', 'Edit bebas: tambah satu baris lampiran');
    await scroll(170, 192, 500, 700);
    const li = await p.evaluate(() => { let res = null;
      for (const f of document.querySelectorAll('iframe')) { const fr = f.getBoundingClientRect(); if (fr.width < 50) continue; let d; try { d = f.contentDocument; } catch (e) { continue; } if (!d) continue;
        const lis = [...d.querySelectorAll('li')].filter(l => l.getBoundingClientRect().height > 0); const l = lis[lis.length - 1]; if (!l) continue;
        const r = d.createRange(); r.selectNodeContents(l); const rb = r.getBoundingClientRect(); const b = l.getBoundingClientRect();
        res = { x: fr.x + Math.min(rb.right, b.right) - 3, y: fr.y + b.y + b.height / 2 }; }
      return res; });
    if (li && li.y > 70 && li.y < 600) { await tap(li.x, li.y, 500); await p.keyboard.press('End'); await p.keyboard.press('Enter'); await typeText('Sertifikat Pelatihan Komputer'); await wait(800); }
    else console.log('lewati edit li', li);
    await scroll(300, 192, 500, 1200);
    await mark('S09_simpan', 'Tap "Simpan Surat", beri nama file');
    await tapText(/^Simpan Surat$/, 1200);
    await fill(/^Nama File/, 'Lamaran Staff Admin - Budi', 600);
    await mark('S09_download', 'Tap "SIMPAN & DOWNLOAD" -> PDF dibuat');
    await tapText(/^SIMPAN & DOWNLOAD$/, 2500);

    // ===== 10. File Saya
    await mark('S10_file_saya', 'File Saya: surat tersimpan');
    await wait(2000);
    await tapText(/^Lamaran Staff Admin/, 1500);
    await mark('S10_opsi', 'Opsi file: preview, edit, ubah nama, berbagi, download, hapus');
    await wait(1500);
    await tapText(/^Preview Surat$/, 3000);
    await mark('S10_preview', 'Preview surat jadi (lengkap dengan tanda tangan)');
    await scroll(420, 192, 520, 1500);
    await scroll(-420, 192, 100, 900);
    await tap(28, 28, 1500);

    // ===== 11. Penutup
    await mark('S11_beranda', 'Kembali ke Beranda (Surat Dibuat: 1)');
    await tap(54, 638, 1800);
    await wait(2000);
    await mark('END', 'Selesai');
  } catch (e) {
    console.log('ERROR', e.message);
    await p.screenshot({ path: 'dry/zz_error.png' });
  }

  fs.writeFileSync(FINAL ? 'out/timeline.json' : 'dry/timeline.json', JSON.stringify(timeline, null, 2));
  if (ff) { ff.stdin.end(); await new Promise(r => ff.on('close', r)); }
  await browser.close();
  console.log('done frames', frameNo);
})();
