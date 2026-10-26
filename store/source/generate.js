// Generates the Google Play store listing images in ../ from the raw app
// screenshots in ./screens. Run from anywhere with Playwright available:
//   node store/source/generate.js
const fs = require('fs');
const path = require('path');
const { chromium } = require('playwright');

const SRC = __dirname;
const OUT = path.join(SRC, '..');

const dataUri = (file) =>
  `data:image/png;base64,${fs.readFileSync(file).toString('base64')}`;
const screen = (name) => dataUri(path.join(SRC, 'screens', `${name}.png`));
const icon = (name) =>
  fs.readFileSync(path.join(SRC, 'icons', `${name}.svg`), 'utf8')
    .replace(/<!--[\s\S]*?-->/g, '')
    .replace(/width="24"/, 'width="100%"').replace(/height="24"/, 'height="100%"');
const LOGO = dataUri(path.join(SRC, '..', '..', 'assets', 'img', 'ic_launcher.png'));

const BASE_CSS = `
  * { margin: 0; padding: 0; box-sizing: border-box; }
  body { font-family: 'Poppins', sans-serif; overflow: hidden; position: relative; }
  .bg-dark { background: radial-gradient(120% 80% at 10% 0%, #6366F1 0%, #4F46E5 35%, #5B21B6 75%, #4C1D95 100%); color: #fff; }
  .bg-light { background: linear-gradient(180deg, #F5F3FF 0%, #EEF2FF 55%, #E0E7FF 100%); color: #1E293B; }
  .blob { position: absolute; border-radius: 50%; filter: blur(60px); }
  .ring { position: absolute; border-radius: 50%; border: 3px solid currentColor; opacity: .14; }
  .dots { position: absolute; background-image: radial-gradient(currentColor 3px, transparent 3.5px); background-size: 34px 34px; opacity: .18; }
  .wave { position: absolute; opacity: .22; }
  .phone { position: absolute; border-radius: 9.5%/4.4%; background: #0F172A; padding: 2.4%;
           box-shadow: 0 40px 80px rgba(15, 23, 42, .35), 0 12px 24px rgba(15, 23, 42, .25), inset 0 0 0 2px #334155; }
  .phone img { display: block; width: 100%; border-radius: 7.6%/3.5%; }
  .screen { border-radius: 7.6%/3.4%; overflow: hidden; background: #fff; }
  .screen img { border-radius: 0; }
  .status { position: relative; aspect-ratio: 412 / 26; display: flex; align-items: center; justify-content: space-between;
            padding: 0 6%; color: #fff; font-weight: 600; font-size: calc(var(--w) * 0.032); background: #4F46E5; }
  .status .cam { position: absolute; left: 50%; top: 50%; width: 4.4%; aspect-ratio: 1; transform: translate(-50%, -50%);
                 border-radius: 50%; background: #020617; box-shadow: 0 0 0 2px #1E293B; }
  .status .sys { display: flex; align-items: center; gap: calc(var(--w) * 0.012); }
  .status svg { height: calc(var(--w) * 0.034); width: auto; }
  .float { position: absolute; display: grid; place-items: center; border-radius: 28%; background: #fff;
           box-shadow: 0 18px 40px rgba(30, 27, 75, .28); }
  .float svg { width: 52%; height: 52%; }
  .chip { position: absolute; display: flex; align-items: center; gap: 14px; background: #fff; color: #1E293B;
          border-radius: 999px; padding: 18px 30px 18px 18px; font-weight: 600; font-size: 30px;
          box-shadow: 0 18px 40px rgba(30, 27, 75, .28); white-space: nowrap; }
  .chip .ic { width: 52px; height: 52px; border-radius: 50%; display: grid; place-items: center; }
  .chip .ic svg { width: 60%; height: 60%; }
`;

const COLORS = {
  indigo: ['#4F46E5', '#EEF2FF'], violet: ['#7C3AED', '#F5F3FF'], green: ['#10B981', '#ECFDF5'],
  orange: ['#F97316', '#FFF7ED'], pink: ['#EC4899', '#FDF2F8'], blue: ['#0EA5E9', '#F0F9FF'],
  amber: ['#D97706', '#FFFBEB'], red: ['#EF4444', '#FEF2F2'],
};

// Floating rounded tile with a colored lucide icon.
const float = ({ name, color, x, y, size, rot = 0 }) => {
  const [fg] = COLORS[color];
  return `<div class="float" style="left:${x}px;top:${y}px;width:${size}px;height:${size}px;transform:rotate(${rot}deg);color:${fg}">${icon(name)}</div>`;
};
const chip = ({ name, color, text, x, y, rot = 0 }) => {
  const [fg, bg] = COLORS[color];
  return `<div class="chip" style="left:${x}px;top:${y}px;transform:rotate(${rot}deg)"><span class="ic" style="background:${bg};color:${fg}">${icon(name)}</span>${text}</div>`;
};
const STATUS_ICONS = `
  <svg viewBox="0 0 18 12"><path fill="currentColor" d="M1 9h2v3H1zM5 6.5h2V12H5zM9 4h2v8H9zM13 1h2v11h-2z"/></svg>
  <svg viewBox="0 0 16 12"><path fill="currentColor" d="M8 12 0 3.6A11.4 11.4 0 0 1 8 0a11.4 11.4 0 0 1 8 3.6z"/></svg>
  <svg viewBox="0 0 24 12"><rect x=".75" y=".75" width="19.5" height="10.5" rx="2.5" fill="none" stroke="currentColor" stroke-width="1.5"/><rect x="2.5" y="2.5" width="13" height="7" rx="1" fill="currentColor"/><rect x="21.5" y="4" width="1.75" height="4" rx=".8" fill="currentColor"/></svg>`;
// Phone frame with a status bar whose color is sampled from the
// screenshot's app bar (see SAMPLE_SCRIPT), so the punch-hole camera sits
// in the status bar instead of over the app's title.
const phone = ({ img, x, y, w, rot = 0, z = 1, pad }) =>
  `<div class="phone" style="--w:${w}px;left:${x}px;top:${y}px;width:${w}px;transform:rotate(${rot}deg);z-index:${z}${pad ? `;padding:${pad}px` : ''}">
    <div class="screen"><div class="status"><span>09.41</span><span class="cam"></span><span class="sys">${STATUS_ICONS}</span></div><img src="${screen(img)}"></div></div>`;

const SAMPLE_SCRIPT = `<script>
  addEventListener('load', () => { for (const img of document.querySelectorAll('.screen img')) {
    const c = document.createElement('canvas');
    c.width = img.naturalWidth; c.height = 4;
    const g = c.getContext('2d');
    g.drawImage(img, 0, 0);
    const px = (x) => { const d = g.getImageData(x, 1, 1, 1).data; return 'rgb(' + d[0] + ',' + d[1] + ',' + d[2] + ')'; };
    img.previousElementSibling.style.background =
      'linear-gradient(90deg,' + px(2) + ',' + px(c.width - 3) + ')';
  } });
</script>`;

// Shared background decoration; `tone` picks colors that read on dark/light.
const decor = (tone, W, H) => {
  const dark = tone === 'dark';
  const blobA = dark ? 'rgba(167,139,250,.55)' : 'rgba(129,140,248,.45)';
  const blobB = dark ? 'rgba(56,189,248,.35)' : 'rgba(244,114,182,.30)';
  const line = dark ? '#fff' : '#4F46E5';
  return `
    <div class="blob" style="width:${W * 0.7}px;height:${W * 0.7}px;left:${-W * 0.25}px;top:${H * 0.45}px;background:${blobA}"></div>
    <div class="blob" style="width:${W * 0.6}px;height:${W * 0.6}px;right:${-W * 0.2}px;top:${-W * 0.15}px;background:${blobB}"></div>
    <div class="ring" style="color:${line};width:${W * 0.55}px;height:${W * 0.55}px;right:${-W * 0.18}px;top:${H * 0.38}px"></div>
    <div class="ring" style="color:${line};width:${W * 0.32}px;height:${W * 0.32}px;left:${-W * 0.1}px;top:${H * 0.2}px"></div>
    <div class="dots" style="color:${line};width:${W * 0.22}px;height:${W * 0.14}px;right:${W * 0.05}px;top:${H * 0.3}px"></div>
    <div class="dots" style="color:${line};width:${W * 0.18}px;height:${W * 0.18}px;left:${W * 0.04}px;bottom:${H * 0.06}px"></div>
    <svg class="wave" style="left:0;top:${H * 0.62}px" width="${W}" height="120" viewBox="0 0 1080 120" fill="none">
      <path d="M0 60 C 180 0, 360 120, 540 60 S 900 0, 1080 60" stroke="${line}" stroke-width="4"/>
      <path d="M0 90 C 180 30, 360 150, 540 90 S 900 30, 1080 90" stroke="${line}" stroke-width="2"/>
    </svg>`;
};

const page = (W, H, cls, body) => `<!doctype html><html><head><meta charset="utf-8">
  <link href="https://fonts.googleapis.com/css2?family=Poppins:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <style>${BASE_CSS} body{width:${W}px;height:${H}px}</style></head>
  <body class="${cls}">${body}${SAMPLE_SCRIPT}</body></html>`;

const headline = ({ title, sub, tone, top = 120, size = 84 }) => `
  <div style="position:absolute;left:80px;right:80px;top:${top}px;text-align:center;z-index:5">
    <h1 style="font-size:${size}px;line-height:1.12;font-weight:800;letter-spacing:-1px">${title}</h1>
    <p style="margin-top:26px;font-size:38px;line-height:1.45;font-weight:500;opacity:${tone === 'dark' ? 0.88 : 0.75}">${sub}</p>
  </div>`;

// ─── Phone screenshots (1080x1920) ───
const PW = 1080, PH = 1920;

const hero = () => page(PW, PH, 'bg-dark', `
  ${decor('dark', PW, PH)}
  ${headline({ tone: 'dark', top: 110, size: 76, title: 'Buat Surat Resmi<br>dalam Hitungan Menit', sub: '100+ template surat resmi siap pakai' })}
  ${phone({ img: 'home', x: 95, y: 640, w: 520, rot: -9, z: 2 })}
  ${phone({ img: 'editor', x: 470, y: 760, w: 520, rot: 7, z: 3 })}
  ${float({ name: 'file-text', color: 'indigo', x: 60, y: 520, size: 130, rot: -10 })}
  ${float({ name: 'pen-line', color: 'orange', x: 900, y: 560, size: 120, rot: 12 })}
  ${float({ name: 'stamp', color: 'pink', x: 40, y: 1420, size: 116, rot: 8 })}
  ${float({ name: 'signature', color: 'green', x: 905, y: 1560, size: 124, rot: -8 })}
  ${float({ name: 'sparkles', color: 'amber', x: 520, y: 600, size: 92, rot: 10 })}
  <div style="position:absolute;z-index:6">${chip({ name: 'file-check-2', color: 'green', text: 'Simpan sebagai PDF', x: 560, y: 1690, rot: -3 })}</div>
`);

const feature = ({ img, tone, title, sub, floats = [], chips = [] }) => page(PW, PH, tone === 'dark' ? 'bg-dark' : 'bg-light', `
  ${decor(tone, PW, PH)}
  ${headline({ tone, title, sub })}
  ${phone({ img, x: 215, y: 560, w: 650, z: 2 })}
  ${floats.map(float).join('')}
  <div style="position:absolute;z-index:6">${chips.map(chip).join('')}</div>
`);

const SCREENS = [
  ['01-buat-surat-resmi', hero()],
  ['02-template-surat', feature({
    img: 'template-list', tone: 'light', title: '100+ Template Surat',
    sub: 'Sekolah, pekerjaan, desa, bisnis, kesehatan, dan lainnya',
    floats: [
      { name: 'layout-template', color: 'indigo', x: 70, y: 700, size: 130, rot: -10 },
      { name: 'file-text', color: 'orange', x: 890, y: 980, size: 120, rot: 10 },
      { name: 'mail-check', color: 'green', x: 80, y: 1500, size: 116, rot: 8 },
    ],
  })],
  ['03-akun-surat', feature({
    img: 'akun-surat', tone: 'dark', title: 'Simpan Data Diri Sekali',
    sub: 'Nama, alamat, dan tanda tangan terisi otomatis di setiap surat',
    floats: [
      { name: 'signature', color: 'violet', x: 70, y: 760, size: 128, rot: -8 },
      { name: 'badge-check', color: 'green', x: 885, y: 1180, size: 118, rot: 10 },
    ],
    chips: [{ name: 'sparkles', color: 'amber', text: 'Terisi otomatis', x: 600, y: 1560, rot: -3 }],
  })],
  ['04-isi-data-surat', feature({
    img: 'isi-data-surat', tone: 'light', title: 'Isi Data Surat dengan Mudah',
    sub: 'Lengkapi detail surat lewat formulir sederhana',
    floats: [
      { name: 'clipboard-pen-line', color: 'blue', x: 75, y: 720, size: 128, rot: -9 },
      { name: 'pen-line', color: 'orange', x: 885, y: 1040, size: 116, rot: 10 },
      { name: 'sparkles', color: 'pink', x: 90, y: 1520, size: 104, rot: 6 },
    ],
  })],
  ['05-edit-surat', feature({
    img: 'editor', tone: 'dark', title: 'Edit Surat Sesukamu',
    sub: 'Ubah isi dan format teks sebelum surat disimpan',
    floats: [
      { name: 'pen-line', color: 'orange', x: 70, y: 760, size: 128, rot: -10 },
      { name: 'file-type-2', color: 'indigo', x: 890, y: 1120, size: 118, rot: 9 },
    ],
    chips: [{ name: 'badge-check', color: 'green', text: 'Format rapi otomatis', x: 90, y: 1580, rot: 3 }],
  })],
  ['06-kop-surat', feature({
    img: 'desain-kop', tone: 'light', title: 'Kop Surat Profesional',
    sub: 'Tambahkan logo dan identitas instansi dengan pilihan desain kop',
    floats: [
      { name: 'stamp', color: 'pink', x: 70, y: 740, size: 128, rot: -9 },
      { name: 'layout-template', color: 'indigo', x: 890, y: 1500, size: 116, rot: 10 },
    ],
    chips: [{ name: 'crown', color: 'amber', text: 'Fitur Premium', x: 690, y: 690, rot: 4 }],
  })],
  ['07-file-saya', feature({
    img: 'file-saya', tone: 'dark', title: 'Simpan & Bagikan PDF',
    sub: 'Semua surat tersimpan rapi di menu File Saya',
    floats: [
      { name: 'folder-open', color: 'amber', x: 70, y: 760, size: 128, rot: -9 },
      { name: 'share-2', color: 'blue', x: 890, y: 1100, size: 116, rot: 10 },
      { name: 'printer', color: 'violet', x: 80, y: 1500, size: 108, rot: 7 },
    ],
    chips: [{ name: 'download', color: 'green', text: 'Download PDF', x: 640, y: 1640, rot: -3 }],
  })],
  ['08-preview-surat', feature({
    img: 'preview-surat', tone: 'light', title: 'Lihat Preview Sebelum Dipakai',
    sub: 'Cek isi template lebih dulu, lalu gunakan dengan satu ketukan',
    floats: [
      { name: 'file-check-2', color: 'green', x: 70, y: 760, size: 128, rot: -9 },
      { name: 'mail-check', color: 'indigo', x: 890, y: 1180, size: 116, rot: 10 },
    ],
  })],
];

// ─── Feature graphic (1024x500) ───
const featureGraphic = () => page(1024, 500, 'bg-dark', `
  <div class="blob" style="width:520px;height:520px;left:-200px;top:120px;background:rgba(167,139,250,.55)"></div>
  <div class="blob" style="width:420px;height:420px;right:-120px;top:-180px;background:rgba(56,189,248,.35)"></div>
  <div class="ring" style="color:#fff;width:380px;height:380px;right:-60px;top:200px"></div>
  <div class="dots" style="color:#fff;width:150px;height:90px;left:40px;top:28px;background-size:22px 22px;background-image:radial-gradient(currentColor 2px, transparent 2.5px)"></div>
  <div style="position:absolute;left:64px;top:118px;width:470px;z-index:5">
    <div style="display:flex;align-items:center;gap:18px">
      <img src="${LOGO}" style="width:84px;height:84px;border-radius:22px;box-shadow:0 10px 24px rgba(15,23,42,.3)">
      <div>
        <div style="font-size:46px;font-weight:800;line-height:1">Terator</div>
        <div style="font-size:18px;font-weight:500;opacity:.85;margin-top:6px">Template Surat Generator</div>
      </div>
    </div>
    <div style="font-size:34px;font-weight:700;line-height:1.25;margin-top:30px">Buat surat resmi dalam hitungan menit</div>
    <div style="font-size:18px;font-weight:500;opacity:.85;margin-top:12px">100+ template · Kop surat · Simpan PDF</div>
  </div>
  ${phone({ img: 'home', x: 600, y: 70, w: 200, rot: -8, z: 2, pad: 6 })}
  ${phone({ img: 'editor', x: 745, y: 110, w: 200, rot: 7, z: 3, pad: 6 })}
  <div class="float" style="left:560px;top:330px;width:70px;height:70px;transform:rotate(-10deg);color:#F97316;z-index:4">${icon('pen-line')}</div>
  <div class="float" style="left:930px;top:40px;width:62px;height:62px;transform:rotate(10deg);color:#10B981;z-index:4">${icon('file-check-2')}</div>
  <div class="float" style="left:700px;top:22px;width:54px;height:54px;transform:rotate(8deg);color:#EC4899;z-index:4">${icon('stamp')}</div>
`);

(async () => {
  const browser = await chromium.launch({ args: ['--enable-unsafe-swiftshader'] });
  const render = async (html, w, h, file) => {
    const p = await browser.newPage({ viewport: { width: w, height: h } });
    await p.setContent(html, { waitUntil: 'networkidle' });
    await p.evaluate(() => document.fonts.ready);
    await p.screenshot({ path: file, type: 'png' });
    await p.close();
    console.log('wrote', path.relative(OUT, file));
  };
  for (const [name, html] of SCREENS) {
    await render(html, PW, PH, path.join(OUT, 'phone-screenshots', `${name}.png`));
  }
  await render(featureGraphic(), 1024, 500, path.join(OUT, 'feature-graphic', 'feature-graphic.png'));
  await render(
    `<!doctype html><style>*{margin:0}</style><img src="${LOGO}" style="display:block;width:512px;height:512px">`,
    512, 512, path.join(OUT, 'app-icon', 'app-icon-512.png'));
  await browser.close();
})();
