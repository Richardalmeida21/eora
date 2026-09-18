const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const {chromium, expect} = require('@playwright/test');
const Twig = require('twig');
require('./bolsas-eora-harness.cjs');

const root = path.resolve(__dirname, '../..');
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';
const compile = (id, data) => Twig.twig({id, data, rethrow: true, allowInlineIncludes: true});

Twig.extendFilter('static_inline', () => '');
Twig.extendFilter('script_tag', value => '<script src="' + value + '"></script>');
Twig.extendFilter('add_param', (value, [key, parameter]) => {
    const url = new URL(value, 'https://theme-preview.test');
    url.searchParams.set(key, parameter);
    return url.pathname + url.search;
});

// Platform components are fixtures; the complete layout and product card are real Twig.
const layoutSource = read('layouts/layout.tpl');
const cardSource = read('snipplets/grid/item.tpl');
const fixtureIds = new Set([...layoutSource.matchAll(/(?:include|snipplet)\s+["']([^"']+)["']/g)].map(match => match[1].startsWith('static/') || match[1].startsWith('snipplets/') ? match[1] : 'snipplets/' + match[1]));
for (const match of cardSource.matchAll(/include\s+["']([^"']+)["']/g)) fixtureIds.add(match[1]);
const fixtures = {
    'snipplets/martz-data-layer.tpl': read('snipplets/martz-data-layer.tpl'),
    'snipplets/header/header.tpl': '<header><a href="/search/">Buscar</a><button id="fixture-cart">Carrinho</button></header>',
    'snipplets/grid/quick-shop.tpl': '<div id="quickshop-modal">Compra rapida</div>',
    'snipplets/button-popup.tpl': '<script src="https://optin.myperfit.com/fixture.js" async></script>',
    'snipplets/home/home-popup.tpl': '<div id="newsletter-popup">Newsletter</div>',
    'static/js/store.js.tpl': 'window.fixtureFeatures.push("store");',
    'static/js/store-product.js.tpl': 'window.fixtureFeatures.push("quickshop");',
    'static/js/video-banner-image-side.js.tpl': 'window.fixtureFeatures.push("video");',
};
for (const id of fixtureIds) compile(id, fixtures[id] || '');
function platformTags(source) {
    return source.replace(/{%\s*snipplet\s+(["'])(.*?)\1\s*%}/g, '{% include "snipplets/$2" %}')
        .replace(/{%\s*head_content\s*%}/g, '{{ fixture_head }}')
        .replace(/{%\s*template_content\s*%}/g, '{{ fixture_content }}');
}
const layout = compile('preview-layout', platformTags(layoutSource));
const card = compile('preview-card', cardSource);
// Reproduce the former all-pages payload without relying on a moving Git HEAD.
const oldCard = compile('previous-card', cardSource.replace("template != 'home' and template != 'page' and ", ''));
const description = '<table><tbody><tr><td>descricao_curta</td><td><strong>Resumo do produto</strong></td></tr></tbody></table><div>' + 'Conteudo da pagina do produto. '.repeat(8000) + '</div>';
const product = {id: 11, name: 'Produto Eora', url: '/produtos/exemplo/', available: true, display_price: true, price: 10000, description, tags: [], featured_image: {url: '/fixture.png', dimensions: {width: 600, height: 800}}};
const settings = {quick_shop: true, grid_columns_desktop: 4, grid_columns_mobile: 2, product_installments: false};
const renderCard = (template, descriptionValue = description) => ({template, settings, product: {...product, description: descriptionValue}, store: {cart_url: '/cart/'}, section_columns_desktop: 4, section_columns_mobile: 2});

function renderLayout(preview, template = 'home') {
    return layout.render({template, params: preview === undefined ? {} : {preview}, settings, page: {handle: 'exemplo'},
        page_title: 'Eora', languages: [{active: true, lang: 'pt'}], cart: {}, customer: {id: 42, email: 'fixture@example.test'},
        fixture_content: card.render(renderCard(template)),
        fixture_head: '<script>window.fixtureFeatures=["native"];window.LS={ready:Promise.resolve()};window.fixtureApps=[];</script>',
        store: {cart_url: '/cart/', assorted_js: '<script src="https://fixtures.test/cheguei-app.js"></script><script src="https://fixtures.test/favorites-app.js"></script>'},
    });
}

(async () => {
    const browser = await chromium.launch({headless: true, executablePath});
    try {
        const page = await browser.newPage();
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        for (const template of ['home', 'page', 'category', 'search', 'product']) {
            const context = renderCard(template);
            const before = oldCard.render(context);
            const after = card.render(context);
            if (template === 'home' || template === 'page') {
                assert(!after.includes(description), template + ': sem a descricao completa inutilizada');
                assert.equal(after, card.render(renderCard(template, '')), template + ': nenhum outro conteudo alterado');
                await page.setContent(before);
                const visibleBefore = await page.locator('body').innerText();
                await page.setContent(after);
                assert.equal(await page.locator('body').innerText(), visibleBefore, template + ': mesmo texto visivel');
                assert(before.length - after.length > 200000, 'reducao medida no HTML');
            } else {
                assert.equal(after, before, template + ': card preservado byte a byte');
                await page.setContent(after);
                const source = read('static/js/store.js.tpl');
                const extraction = source.slice(source.indexOf('    {# /* // product card description */ #}'), source.indexOf('    {# /* // Secondary image on mouseover */ #}'));
                const script = compile('card-extraction-' + template, extraction).render({template});
                await page.addScriptTag({content: '(function() {' + script + '})();'});
                await expect(page.locator('.js-product-card-description-text')).toHaveText('Resumo do produto');
                await expect(page.locator('.js-product-card-description-text strong')).toHaveCount(1);
            }
        }
        console.log('PASS cards: home/pagina sem descricoes completas; texto visivel, nomes, precos e compra preservados; categoria/busca/produto identicos e resumo formatado funcionando.');

        for (const preview of [undefined, false, true, 'true']) {
            const html = renderLayout(preview);
            const context = await browser.newContext();
            const page = await context.newPage();
            page.on('pageerror', error => errors.push(error.message));
            const requests = [];
            await page.route('**/*', route => {
                const url = route.request().url();
                if (url === 'https://theme-preview.test/') return route.fulfill({contentType: 'text/html', body: html});
                requests.push(url);
                const app = url.includes('fixtures.test/') ? 'window.fixtureApps.push(' + JSON.stringify(url.split('/').pop()) + ');' : '';
                return route.fulfill({contentType: url.endsWith('.scss') ? 'text/css' : 'application/javascript', body: app});
            });
            await page.goto('https://theme-preview.test/');
            await page.mouse.move(100, 100);
            await expect.poll(() => page.evaluate(() => window.fixtureApps.length)).toBe(2);
            assert.deepEqual(await page.evaluate(() => window.fixtureFeatures), ['native', 'store', 'quickshop', 'video']);
            await expect(page.locator('#fixture-cart')).toHaveCount(1);
            await expect(page.locator('#quickshop-modal')).toHaveCount(1);
            await expect(page.locator('#newsletter-popup')).toHaveCount(1);
            assert(requests.some(url => url.includes('optin.myperfit.com')), 'popup funcional continua carregando');
            const trackerRequests = () => requests.filter(url => /clarity\.ms|analytics\.tiktok\.com|mtm\.martzapis\.com\.br/.test(url));
            if (preview) {
                await page.waitForTimeout(300);
                assert.deepEqual(trackerRequests(), [], 'rastreadores explicitos nao carregam na previa');
                assert.equal(await page.evaluate(() => typeof window.eoraLoadWhenIdle), 'function');
                assert.equal(await page.evaluate(() => typeof window.ttq), 'undefined');
                assert(!html.includes('martz_identity'));
            } else {
                await expect.poll(() => trackerRequests().length).toBe(3);
                assert.equal(await page.evaluate(() => window.dataLayer.some(event => event.event === 'martz_identity')), true);
                assert.equal(await page.evaluate(() => window.ttq.some(event => event[0] === 'page')), true);
            }
            await context.close();
        }
        assert.deepEqual(errors, []);
        console.log('PASS layout: previa boolean/textual sem Clarity/TikTok/Martz; loja publica com os 3 rastreadores; scripts nativos, aplicativos, quickshop, video e popups preservados; zero erros JS.');
    } finally {
        await browser.close();
    }
})().catch(error => { console.error(error); process.exitCode = 1; });
