const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {chromium, expect} = require('@playwright/test');
const {oculosContext, render, product} = require('./bolsas-eora-harness.cjs');
const root = path.resolve(__dirname, '../..');
const routes = [
    ['luar4', 0, 'Dourado/Marrom'],
    ['luar1', 1, 'Preto Fosco/Preto'],
    ['luar-1rh88', 2, 'Prata/Cinza'],
    ['luar-copia', 3, 'Dourado/Preto'],
    ['luar3', 4, 'Prata/Rosa Fotocromática'],
    ['luar2', 5, 'Prata/Prata Fotocromática'],
];
const destination = index => '/produtos/luar/?vi=' + index;
const fakeProduct = ([slug, index]) => product(900 + index, 'luar', {name: 'LUAR', url: 'https://www.eoraeyewear.com/produtos/' + slug + '/', tags: ['luar']});

// Cada foto e o titulo devem trazer a URL correta ja no HTML do servidor.
for (const row of routes) {
    const [slug, index] = row;
    for (const url of ['/produtos/' + slug, '/produtos/' + slug + '/', 'https://www.eoraeyewear.com/produtos/' + slug + '/?preview=1#foto']) {
        const html = render('snipplets/bolsas-eora/product-card.tpl', {product: {...fakeProduct(row), url}});
        const links = [...html.matchAll(/<a\b[^>]*href="([^"]+)"/g)].map(match => match[1]);
        assert.deepEqual(links, Array(3).fill(destination(index)), slug);
    }
}
for (const url of ['/produtos/luar/', '/produtos/luar/?vi=4', '/produtos/luar-novo/', '/produtos/nova7/', '/produtos/bolsa/']) {
    const html = render('snipplets/bolsas-eora/product-card.tpl', {product: product(999, 'teste', {url})});
    assert([...html.matchAll(/<a\b[^>]*href="([^"]+)"/g)].every(match => match[1] === url), 'produto original/outros preservados: ' + url);
}
const home = fs.readFileSync(path.join(root, 'layouts/layout.tpl'), 'utf8');
for (const [slug, index] of routes.slice(1)) {
    assert(new RegExp("'" + slug + "':\\s*" + index + '\\b').test(home), 'mesma selecao da home: ' + slug);
}
console.log('PASS links: seis variantes, fotos/titulo, URL absoluta/relativa, indice zero e produtos nao relacionados preservados.');

(async () => {
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        const page = await browser.newPage({reducedMotion: 'reduce'});
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        const initial = oculosContext();
        const data = {...initial, settings: {...initial.settings,
            oculos_eora_models: [{link: 'luar', title: 'LUAR', image: '/fixtures/image-0.webp'}],
            oculos_eora_category_url: '', oculos_eora_best_enabled: false,
            oculos_eora_community_enabled: false, oculos_eora_categories_enabled: false,
        }};
        await page.context().route('**/*', async route => {
            const url = new URL(route.request().url());
            if (url.pathname.startsWith('/static/')) return route.fulfill({path: path.join(root, url.pathname.slice(1)), contentType: url.pathname.endsWith('.js') ? 'application/javascript' : 'text/css'});
            if (url.pathname.startsWith('/fixtures/')) return route.fulfill({path: path.join(process.env.BE_VALIDATION_DIR || 'C:/Temp/eora-bolsas-validation', 'assets', path.basename(url.pathname)), contentType: 'image/webp'});
            if (url.pathname === '/produtos/luar/') return route.fulfill({contentType: 'text/html; charset=utf-8', body: '<h1>LUAR original</h1>'});
            if (url.pathname === '/search/') {
                const second = url.searchParams.get('page') === '2';
                return route.fulfill({contentType: 'text/html; charset=utf-8', body: render('snipplets/oculos-eora/search-feed.tpl', {...data,
                    params: {oe_feed: '4'}, query: '"luar"', products: routes.slice(second ? 3 : 0, second ? 6 : 3).map(fakeProduct),
                    pages: {current: second ? 2 : 1, is_last: second, next: '/search/?q=%22luar%22&oe_feed=4&page=2'},
                })});
            }
            return route.fulfill({contentType: 'text/html; charset=utf-8', body: '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0;font-family:Arial}</style>' + render('snipplets/oculos-eora/index.tpl', data)});
        });
        const base = 'http://eora.test';
        const load = async () => {
            await page.goto(base + '/oculos-eora/?tag=luar');
            await expect(page.locator('[data-be-results]')).toHaveAttribute('aria-busy', 'false');
            await expect(page.locator('[data-be-results-grid] [data-be-product]')).toHaveCount(6);
        };
        for (const width of [1440, 390]) {
            await page.setViewportSize({width, height: 844});
            for (const [slug, index] of routes) {
                await load();
                const card = page.locator('[data-be-results-grid] [data-be-product="' + (900 + index) + '"]');
                await expect(card.locator('h3 a')).toHaveAttribute('href', destination(index));
                const before = page.url();
                if (width === 1440) await card.locator('[data-be-gallery-next]').click();
                else {
                    await expect(card.locator('[data-be-gallery-next]')).toBeHidden();
                    await card.locator('[data-be-product-slides]').focus();
                    await page.keyboard.press('ArrowRight');
                }
                await expect(card.locator('[data-be-gallery-counter]')).toHaveText('2 / 2');
                assert.equal(page.url(), before, 'seta troca a foto sem navegar: ' + slug);
                const link = width === 1440 ? card.locator('[data-be-product-slide]').nth(1) : card.locator('h3 a');
                await link.click();
                await expect(page).toHaveURL(base + destination(index));
            }
        }
        await load();
        const first = page.locator('[data-be-results-grid] [data-be-product="900"] h3 a');
        await first.evaluate(link => { link.target = '_blank'; });
        const [tab] = await Promise.all([page.context().waitForEvent('page'), first.click()]);
        await tab.waitForLoadState('domcontentloaded');
        assert.equal(tab.url(), base + destination(0), 'nova aba preserva a variante');
        await tab.close();
        assert.deepEqual(errors, []);
        console.log('PASS navegador desktop/mobile: seis links, segunda pagina do feed, foto/titulo, setas da galeria, nova aba e zero erros JS.');
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
