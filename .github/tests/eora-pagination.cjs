const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const Twig = require('twig');
const {chromium, expect} = require('@playwright/test');
const {context, oculosContext, product, render} = require('./bolsas-eora-harness.cjs');
const base = 'http://127.0.0.1:4175';
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';
const output = process.env.BE_VALIDATION_DIR || 'C:/Temp/eora-bolsas-validation';

// Compila o layout inteiro, substituindo apenas as tags proprietarias da plataforma.
const layoutSource = fs.readFileSync(path.resolve(__dirname, '../../layouts/layout.tpl'), 'utf8');
const layout = Twig.twig({data: layoutSource.replace(/\{%\s*template_content\s*%\}/g, 'CAMPAIGN_FEED')
    .replace(/\{%\s*(?:head_content|snipplet)\b[^%]*%\}/g, ''), rethrow: true});
for (const [template, params] of [
    ['category', {be_category_feed: '1'}], ['category', {oe_category_feed: '1'}],
    ['search', {be_feed: '4'}], ['search', {oe_feed: '4'}],
]) assert.equal(layout.render({template, params}).trim(), 'CAMPAIGN_FEED', 'feed sem cabecalho, scripts ou rodape');
// A condicao do layout deve permanecer restrita as consultas internas certas.
const guard = Twig.twig({data: layoutSource.slice(0, layoutSource.indexOf('{# Slider and video')).replace(/\{%\s*template_content\s*%\}/g, 'CAMPAIGN_FEED') + 'FULL_LAYOUT{% endif %}', rethrow: true});
for (const template of ['home', 'product', 'page', 'category', 'search']) {
    assert.equal(guard.render({template, params: {}}).trim(), 'FULL_LAYOUT');
}
for (const template of ['home', 'product', 'page']) {
    assert.equal(guard.render({template, params: {be_feed: '4', oe_category_feed: '1'}}).trim(), 'FULL_LAYOUT');
}
console.log('PASS feeds: layout compilado, consultas compactas e paginas normais preservadas.');

(async () => {
    const browser = await chromium.launch({headless: true, executablePath});
    try {
        for (const campaign of ['bolsas-eora', 'oculos-eora']) {
            for (const width of [1440, 390]) {
                const prefix = campaign === 'oculos-eora' ? 'oe' : 'be';
                const setting = campaign.replace('-', '_');
                const initial = prefix === 'oe' ? oculosContext() : context();
                const data = {...initial, settings: {...initial.settings,
                    [setting + '_category_url']: '/categoria/pagination',
                    [setting + '_banners']: Array.from({length: 8}, (_, index) => ({
                        image: '/fixtures/image-' + (index % 6) + '.webp',
                        title: 'Banner ' + (index + 1), description: 'nova,todos', link: '/banner/' + index,
                    })),
                }};
                const page = await browser.newPage({viewport: {width, height: 900}});
                const errors = [];
                const requests = [];
                page.on('pageerror', error => errors.push(error.message));
                let releaseFirst, releaseThird;
                let firstGate = new Promise(resolve => { releaseFirst = resolve; });
                let thirdGate = new Promise(resolve => { releaseThird = resolve; });
                let failThird = false;
                let total = 96;
                await page.route(base + '/**', async route => {
                    const url = new URL(route.request().url());
                    if (url.pathname === '/pagination') return route.fulfill({contentType: 'text/html; charset=utf-8', body:
                        '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0;font-family:Arial}</style>' + render('snipplets/' + campaign + '/index.tpl', data)});
                    if (url.pathname !== '/categoria/pagination') return route.continue();
                    const index = Number(url.searchParams.get('page') || 1);
                    requests.push(index);
                    if (index === 1 && firstGate) await firstGate;
                    if (index === 3 && thirdGate) await thirdGate;
                    if (index === 3 && failThird) {
                        failThird = false;
                        return route.fulfill({status: 503, body: 'Unavailable'});
                    }
                    const items = Array.from({length: Math.max(0, Math.min(24, total - (index - 1) * 24))}, (_, offset) => product((index - 1) * 24 + offset + 1));
                    url.searchParams.set('page', index + 1);
                    return route.fulfill({contentType: 'text/html; charset=utf-8', body: render('snipplets/' + campaign + '/category-feed.tpl', {...data,
                        params: {[prefix + '_category_feed']: '1'}, products: items,
                        pages: {current: index, is_last: index * 24 >= total, next: url.pathname + url.search},
                    })});
                });
                const cards = page.locator('[data-be-results-grid] [data-be-product]');
                const banners = page.locator('[data-be-results-grid] [data-be-catalog-banner]');
                const more = page.locator('[data-be-more]');
                const idle = () => expect(page.locator('[data-be-results]')).toHaveAttribute('aria-busy', 'false');
                async function geometry() {
                    return page.locator('[data-be-results-grid]').evaluate(grid => {
                        const rect = el => {const r = el.getBoundingClientRect(); return {x:r.x, y:r.y + scrollY, bottom:r.bottom + scrollY, width:r.width};};
                        return {grid: rect(grid), products: Array.from(grid.querySelectorAll('[data-be-product]')).map(rect),
                            banners: Array.from(grid.querySelectorAll('[data-be-catalog-banner]')).map(rect)};
                    });
                }
                async function checkLayout(count) {
                    await expect(banners).toHaveCount(count);
                    const g = await geometry();
                    for (let index = 0; index < count; index++) {
                        const banner = g.banners[index];
                        const alongside = g.products.slice(4 + index * 8, 8 + index * 8);
                        assert.equal(alongside.length, 4, 'cada banner tem os quatro produtos correspondentes');
                        assert(banner.bottom <= Math.max(...g.products.map(p => p.bottom)) + 1, 'nenhum banner estende a grade vazia');
                        if (width >= 768) {
                            assert(Math.abs(banner.y - alongside[0].y) < 2, 'banner e produtos comecam juntos');
                            assert(banner.bottom <= alongside[3].bottom + 1, 'banner termina junto dos produtos');
                            assert.equal(g.products.filter(p => Math.abs(p.y - g.products[index * 8].y) < 2).length, 4, 'linha completa antes de cada banner');
                        } else {
                            assert(Math.abs(banner.width - g.grid.width) < 2);
                            assert(banner.y >= g.products[3 + index * 8].bottom);
                        }
                    }
                }
                await page.goto(base + '/pagination');
                await expect.poll(() => requests.length).toBe(1);
                await expect(cards).toHaveCount(0);
                await expect(banners).toHaveCount(0);
                releaseFirst(); firstGate = null;
                await idle();
                await expect(cards).toHaveCount(24);
                await checkLayout(3);
                const firstPositions = (await geometry()).products;
                await more.scrollIntoViewIfNeeded();
                await page.waitForTimeout(750); // Da tempo para detectar um disparo indevido por rolagem.
                assert.deepEqual(requests, [1]);
                await expect(cards).toHaveCount(24);
                await page.screenshot({path: path.join(output, campaign + '-pagination-' + width + '.png')});
                await more.click();
                await expect(cards).toHaveCount(48);
                await checkLayout(6);
                await expect(more).toBeDisabled();
                assert.deepEqual((await geometry()).products.slice(0, 24), firstPositions, 'primeiros produtos nao mudam de lugar');
                releaseThird(); thirdGate = null;
                await idle();
                await expect(cards).toHaveCount(total);
                await checkLayout(8);
                await expect(more).toBeHidden();
                assert.deepEqual(requests, [1, 2, 3, 4], 'um clique carrega o restante sem repetir paginas');
                assert.equal(new Set(await cards.evaluateAll(nodes => nodes.map(n => n.dataset.beProduct))).size, total);

                // Falha depois de um lote publicado: preserva produtos/banners e retoma.
                failThird = true;
                await page.goto(base + '/pagination'); await idle();
                await more.click(); await idle();
                await expect(cards).toHaveCount(48); await checkLayout(6);
                await expect(more).toHaveText('Tentar novamente');
                await more.click(); await idle();
                await expect(cards).toHaveCount(total); await checkLayout(8);
                assert.equal(new Set(await cards.evaluateAll(nodes => nodes.map(n => n.dataset.beProduct))).size, total);

                for (const count of [0, 3, 10]) {
                    total = count;
                    await page.goto(base + '/pagination'); await idle();
                    await expect(cards).toHaveCount(count);
                    await checkLayout(Math.floor(count / 8));
                    await expect(more).toBeHidden();
                }
                assert.deepEqual(errors, []);
                console.log('PASS ' + campaign + ' ' + width + 'px: 24/3 -> 48/6 -> 96/8, clique manual, sem lacunas, ordem estavel, erro/retomada e catalogo curto/vazio.');
                await page.close();
            }
        }
    } finally { await browser.close(); }
})().catch(error => {console.error(error); process.exitCode = 1;});
