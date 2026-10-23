const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const {test} = require('node:test');
const Twig = require('twig');
const root = path.resolve(__dirname, '../..');
const widths = {medium: 320, large: 480, huge: 640, original: 1024, xlarge: 1400, '1080p': 1920};
Twig.extendFilter('static_url', name => '/assets/' + name);
Twig.extendFilter('settings_image_url', (url, size) => url + '?w=' + widths[size]);
Twig.extendFilter('has_custom_image', () => false);
Twig.extendFilter('translate', text => text);
Twig.extendFilter('setting_url', value => value);
// A plataforma também aceita replace(busca, substituição).
Twig.extendFilter('replace', (value, args) => {
    const [search, replacement] = args;
    if (typeof search === 'string') return String(value).split(search).join(replacement);
    for (const [key, next] of Object.entries(search)) value = String(value).split(key).join(next);
    return value;
});
const slide = {image: 'banner.jpg', width: 2560, height: 1440, link: '', title: ''};
const slides = [slide, {...slide, image: 'banner-next.jpg', width: undefined}];
const fixtures = [
    ['home/home-banner-duplo.tpl', {banner_duplo_show: true, banner_duplo_1_image: 'banner.jpg', banner_duplo_2_image: 'banner-next.jpg'}],
    ['home/home-banner-video-botao.tpl', {banner_video_botao_show: true, banner_video_botao_image: 'banner.jpg'}],
    ['product/product-banner-video-botao.tpl', {product_banner_show: true, product_banner_image: 'banner.jpg'}],
    ['home/home-slider.tpl', {slider: slides, slider_mobile: slides, toggle_slider_mobile: true}],
    ['home/home-banners-grid.tpl', {banner: slides, banner_mobile: slides}, {banner: true}],
    ['category-banners-grid.tpl', {category_banners_show: true, category_banners_images: slides}],
    ['campaign/banners-grid.tpl', {campaign_page_01_banner: slides, campaign_page_01_banner_mobile: slides, campaign_page_01_banner_columns_desktop: 4}, {settings_name: 'campaign_page_01'}],
    ['home/home-banners-scroll.tpl', {banners_scroll_show: true, banners_scroll: slides}],
    ['home/home-colecoes-kings.tpl', {colecoes_kings_show: true, colecoes_kings: slides, colecoes_kings_mobile: slides}],
    ['home/home-banners-links.tpl', {banner_links_show: true, banner_links: slides, banner_links_mobile: slides}],
    ['home/home-banner-imagem-horizontal.tpl', {}],
    ['bolsas-eora/gallery.tpl', {}, {gallery_items: slides, gallery_kind: 'categories'}]
];
Twig.twig({id: 'snipplets/bolsas-eora/controls.tpl', data: fs.readFileSync(path.join(root, 'snipplets/bolsas-eora/controls.tpl'), 'utf8'), allowInlineIncludes: true});
for (const [file, settings, extra] of fixtures) {
    for (const mobile of [false, true]) test(`${file}: candidatos corretos e resolução alta (${mobile ? 'mobile' : 'desktop'})`, () => {
        const template = Twig.twig({data: fs.readFileSync(path.join(root, 'snipplets', file), 'utf8'), allowInlineIncludes: true, rethrow: true});
        const html = template.render({settings, store: {name: 'EORA'}, mobile, ...extra});
        const images = html.match(/<img\b[\s\S]*?>/g) || [];
        assert(images.length, 'Fixture precisa exibir os banners de produção');
        if (file === 'campaign/banners-grid.tpl') assert(images[0].includes('25vw'), 'Primeiro banner deve considerar as quatro colunas ao escolher a resolução');
        for (const img of images) {
            const candidates = img.match(/(?:data-)?srcset=["']([^"']+)["']/)?.[1];
            assert(candidates, 'Banner precisa oferecer tamanhos ao navegador');
            assert(/(?:data-)?sizes=/.test(img), 'Banner precisa informar largura de exibição');
            assert(candidates.includes('1920w'), 'Não limitar fotos grandes a thumbnails de 640/1024 px');
            for (const entry of candidates.split(',')) {
                const [url, descriptor] = entry.trim().split(/\s+/);
                const query = new URL(url, 'http://localhost').searchParams;
                const actual = query.has('w') ? Number(query.get('w')) : url.endsWith('banner.jpg') ? 2560 : 0;
                assert.equal(parseInt(descriptor), actual, `Descritor ${descriptor} deve informar a largura real de ${url}`);
            }
        }
    });
}

test('Banner duplo: lazyload mede a largura real e carrega resolução para DPR 2', async () => {
    const {chromium} = require('playwright');
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        const [file, settings] = fixtures[0];
        const template = Twig.twig({data: fs.readFileSync(path.join(root, 'snipplets', file), 'utf8'), rethrow: true});
        const html = '<!doctype html><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0}</style>' + template.render({settings});
        const lazySizes = fs.readFileSync(path.join(root, 'static/js/external-no-dependencies.js.tpl'), 'utf8').split(/\r?\n/).find(line => line.startsWith('!function(e)'));
        assert(lazySizes, 'Usa a biblioteca de lazyload real do tema');
        for (const width of [390, 1440]) {
            const page = await browser.newPage({viewport: {width, height: 1200}, deviceScaleFactor: 2});
            await page.route('http://banner.test/**', route => {
                const url = new URL(route.request().url());
                if (url.pathname === '/') return route.fulfill({contentType: 'text/html', body: html});
                const pixels = Number(url.searchParams.get('w')) || 1;
                return route.fulfill({contentType: 'image/svg+xml', body: `<svg xmlns="http://www.w3.org/2000/svg" width="${pixels}" height="${pixels * 1.25}"><rect width="100%" height="100%" fill="#a2b5d6"/></svg>`});
            });
            await page.goto('http://banner.test/');
            await page.addScriptTag({content: lazySizes});
            for (const image of await page.locator('.banner-duplo-image img').all()) {
                await image.scrollIntoViewIfNeeded();
                await image.evaluate(img => { window.lazySizes.loader.unveil(img); });
                await page.waitForFunction(img => img.classList.contains('lazyloaded') && img.currentSrc.includes('?w=') && img.complete, await image.elementHandle());
                const selected = await image.evaluate(img => ({src: img.currentSrc, sizes: parseFloat(img.sizes), width: img.getBoundingClientRect().width}));
                assert(Math.abs(selected.sizes - selected.width) < 2, 'Lazysizes usa a largura do card');
                assert(Number(new URL(selected.src).searchParams.get('w')) >= selected.width * 2, 'Imagem selecionada cobre a largura em DPR 2');
            }
            assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'Banners não criam overflow');
            await page.close();
        }
    } finally { await browser.close(); }
});
