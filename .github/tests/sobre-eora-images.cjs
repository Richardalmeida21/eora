const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const http = require('node:http');
const {chromium} = require('playwright');
const Twig = require('twig');
const h = require('./sobre-eora-harness.cjs');
// Modelo dos thumbnails documentados pela plataforma. O browser recebe imagens
// com essas dimensões, permitindo observar a seleção real em diferentes DPRs.
const widths = {large: 480, huge: 640, original: 1024, xlarge: 1400, '1080p': 1920};
Twig.extendFilter('settings_image_url', (url, size) => url + '?w=' + widths[size]);
const keys = ['sobre_eora_founders', ...['press', 'sustainability', 'timeline'].flatMap(kind => Array.from({length: 10}, (_, i) => `sobre_eora_${kind}_${i + 1}`)), ...[1, 2, 3].map(i => `sobre_eora_values_${i}`)];

let document;
const server = http.createServer((req, res) => {
    const url = new URL(req.url, 'http://localhost');
    if (url.pathname.endsWith('.jpg')) {
        const width = Math.min(Number(url.searchParams.get('w')) || 1920, url.pathname.includes('_mobile') ? 1600 : 1920);
        res.setHeader('Content-Type', 'image/svg+xml');
        return res.end(`<svg xmlns="http://www.w3.org/2000/svg" width="${width}" height="${width * 1.25}"><rect width="100%" height="100%" fill="${url.pathname.includes('_mobile') ? '#d6b5a2' : '#a2b5d6'}"/></svg>`);
    }
    res.setHeader('Content-Type', 'text/html; charset=utf-8');
    res.end(document);
});
function fixture(mobile) {
    const data = h.context();
    data.settings.sobre_eora_founders_text = 'Fundadores';
    for (const key of keys) {
        h.uploaded.add(key + '.jpg');
        if (mobile) h.uploaded.add(key + '_mobile.jpg');
        data.settings[key + '_enabled'] = true;
        data.settings[key + '_title'] = key;
    }
    for (const kind of ['press', 'sustainability', 'timeline', 'values']) {
        const prefix = 'sobre_eora_' + kind;
        data.settings[prefix + '_images'] = keys.filter(key => key.startsWith(prefix + '_')).map(key => ({image: key + '.jpg', title: key}));
        if (mobile) data.settings[prefix + '_images_mobile'] = data.settings[prefix + '_images'].map(item => ({image: item.image.replace('.jpg', '_mobile.jpg')}));
    }
    const html = h.render(data);
    document = '<!doctype html><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0}' + fs.readFileSync(path.join(h.root, 'static/css/sobre-eora.css'), 'utf8') + '</style>' + html.replace(/<link[^>]+>|<script[\s\S]*?<\/script>/g, '');
}
(async () => {
    await new Promise(resolve => server.listen(0, '127.0.0.1', resolve));
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        for (const mobile of [true, false]) {
            fixture(mobile);
            for (const width of [320, 390, 767, 768, 1440, 1920]) {
                const page = await browser.newPage({viewport: {width, height: 950}, deviceScaleFactor: 2, javaScriptEnabled: false});
                await page.goto(`http://127.0.0.1:${server.address().port}`);
                await page.locator('.se-page img').evaluateAll(images => images.forEach(img => { img.loading = 'eager'; }));
                await page.evaluate(() => Promise.all([...document.images].map(img => img.decode())));
                const images = await page.locator('.se-page img').evaluateAll(images => images.map(img => ({src: img.currentSrc, natural: img.naturalWidth, width: img.getBoundingClientRect().width, sizes: img.sizes, candidates: img.srcset})));
                assert.equal(images.length, 34, 'Cada foto editorial possui sua imagem correspondente');
                for (const img of images) {
                    assert.equal(img.src.includes('_mobile.jpg'), mobile && width <= 767, `Seleciona upload mobile só até 767 px (${width}px)`);
                    assert(img.candidates.includes('1920w'), 'Oferece resolução suficiente para fotos editoriais em telas de alta densidade');
                    assert(img.sizes, 'Declara a largura de exibição para o browser');
                    const pixels = Math.min(Number(new URL(img.src).searchParams.get('w')), img.src.includes('_mobile') ? 1600 : 1920);
                    assert(pixels >= Math.ceil(img.width * 2) - 2, `${width}px: ${pixels}px insuficientes para ${img.width}px em DPR 2`);
                }
                assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'Sem overflow horizontal');
                if (mobile && [390, 1440].includes(width)) {
                    await page.locator('.se-page').screenshot({path: `C:/Temp/eora-sobre-preview/images-${width}.png`});
                }
                await page.close();
            }
        }
        // Somente o bloco único Fundadores precisa de suporte de upload fixo.
        const config = fs.readFileSync(path.join(h.root, 'config/settings.txt'), 'utf8');
        assert(config.includes('original = sobre_eora_founders_mobile.jpg'));
        assert(fs.existsSync(path.join(h.root, 'static/sobre_eora_founders_mobile.jpg')));
        console.log('PASS: galerias com 34 fotos, seleção/fallback em seis larguras, DPR 2, sem JS e sem overflow.');
    } finally { await browser.close(); server.close(); }
})().catch(error => { server.close(); console.error(error); process.exitCode = 1; });
