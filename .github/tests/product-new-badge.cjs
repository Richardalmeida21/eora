const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {chromium} = require('playwright');
const Twig = require('twig');
const fixture = require('./bolsas-eora-harness.cjs');
const root = path.resolve(__dirname, '../..');
const card = product => fixture.render('snipplets/bolsas-eora/product-card.tpl', {...fixture.context(), product});
const hasNew = html => (html.match(/aria-label="Produto novo"/g) || []).length;
const platformTag = {attributes: {tag: 'NOVO'}, eager_where: null, dirty_attributes: []};
Object.defineProperty(platformTag, 'tag', {value: 'NOVO', enumerable: false});
const cases = [
    [[], false], [['bolsa'], false], [['renovo', 'novos'], false],
    [['novo'], true], [['NOVO'], true], [[' Novo '], true],
    [[{tag: 'novo'}], true], [[{tag: ' NOVO '}], true],
    [['novo', {tag: 'NOVO'}], true],
    [[platformTag], true],
];
for (const [index, [tags, expected]] of cases.entries()) {
    assert.equal(hasNew(card(fixture.product(900 + index, 'maxivertice', {tags}))), expected ? 1 : 0, 'Selo segue a tag novo, sem diferenciar caixa/espaços ou duplicar');
}
const fresh = fixture.product(999, 'maxivertice', {tags: [{tag: 'maxivertice'}, {tag: 'novo'}], available: false});
const both = card(fresh);
assert.equal(hasNew(both), 1);
assert.match(both, />Esgotado</, 'Preservar a indicação de estoque junto do selo novo');
const data = {...fixture.context(), products: [fresh], pages: {current: 1, is_last: true}, query: '"maxivertice"', params: {}};
assert.equal(hasNew(fixture.render('snipplets/bolsas-eora/search-feed.tpl', data)), 1, 'Produtos recebidos pela busca de Bolsas');
assert.equal(hasNew(fixture.render('snipplets/bolsas-eora/search-feed.tpl', {...data, products: [fresh, fixture.product(1000)]})), 1, 'O selo de um card não vaza para o produto seguinte');
assert.equal(hasNew(fixture.render('snipplets/oculos-eora/search-feed.tpl', {...data, query: '"iris"', params: {oe_feed: '4'}})), 1, 'Produtos recebidos pela busca de Óculos');
const bestFeed = Twig.twig({data: fs.readFileSync(path.join(root, 'snipplets/best-sellers/category-feed.tpl'), 'utf8'), allowInlineIncludes: true, rethrow: true});
assert.equal(hasNew(bestFeed.render({...data, params: {bs_category_feed: '1'}})), 1, 'Produtos recebidos pela categoria Best Sellers');

(async () => {
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        const page = await browser.newPage();
        await page.route('**/*', route => route.abort());
        const css = fs.readFileSync(path.join(root, 'static/css/bolsas-eora.css'), 'utf8');
        for (const width of [1440, 390]) {
            await page.setViewportSize({width, height: 900});
            await page.setContent('<style>' + css + '</style><main class="be-page"><div style="width:' + (width === 390 ? 175 : 320) + 'px">' + both + '</div></main>');
            const badge = page.locator('[aria-label="Produto novo"]');
            assert.equal(await badge.innerText(), 'NOVO');
            const appearance = await badge.evaluate(el => ({background: getComputedStyle(el).backgroundColor, color: getComputedStyle(el).color, pointerEvents: getComputedStyle(el).pointerEvents}));
            assert.deepEqual(appearance, {background: 'rgb(0, 0, 0)', color: 'rgb(255, 255, 255)', pointerEvents: 'none'});
            const box = await badge.boundingBox();
            const stock = await page.locator('.be-product__badge').filter({hasText: 'Esgotado'}).boundingBox();
            const counter = await page.locator('[data-be-gallery-counter]').boundingBox();
            const image = await page.locator('.be-product__image').boundingBox();
            assert(box.x >= image.x && box.y >= image.y && box.x + box.width <= image.x + image.width);
            assert(box.y + box.height <= stock.y, 'Novo e Esgotado não se sobrepõem');
            assert(box.x + box.width <= counter.x, 'Selo não cobre o contador da galeria');
            assert.equal(await page.locator('[data-be-product-slide]').count(), 2);
            assert.equal(await page.locator('h3 a').getAttribute('href'), fresh.url);
        }
        console.log('PASS NOVO: tags texto/objeto, caixa, espaços, duplicadas, ausência, estoque, feeds Bolsas/Óculos/Best Sellers; aparência e posição desktop/mobile.');
    } finally { await browser.close(); }
})().catch(error => {console.error(error); process.exitCode = 1;});
