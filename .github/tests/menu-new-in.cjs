const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const Twig = require('twig');
const {chromium} = require('playwright');
const fixture = require('./best-sellers-harness.cjs');
const root = path.resolve(__dirname, '../..');
const data = fixture.context({amount: 6, noCommunity: true});
const tagCases = [['novo'], ['renovo'], [' NOVO '], [], ['novos'], [{tag: ' Novo '}]];
data.category_products.forEach((product, i) => { product.tags = product.tags.concat(tagCases[i]); });
const feed = Twig.twig({ref: 'snipplets/best-sellers/category-feed.tpl'}).render({...data, products: data.category_products, params: {bs_category_feed: '1'}, pages: {current: 1, is_last: true, next: ''}});
const html = '<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"></head><body>' + fixture.render(data) + '</body></html>';
(async () => {
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        for (const width of [390, 1440]) {
            const page = await browser.newPage({viewport: {width, height: 1000}});
            const errors = [];
            page.on('pageerror', e => errors.push(e.message));
            await page.route('https://new-in.test/**', route => {
                const url = new URL(route.request().url());
                if (url.pathname.startsWith('/static/')) return route.fulfill({contentType: url.pathname.endsWith('.js') ? 'text/javascript' : 'text/css', body: fs.readFileSync(path.join(root, url.pathname))});
                if (url.pathname.startsWith('/fixtures/')) return route.fulfill({contentType: 'image/svg+xml', body: '<svg xmlns="http://www.w3.org/2000/svg" width="10" height="10"/>'});
                return route.fulfill({contentType: 'text/html', body: url.pathname === '/best-sellers/' ? feed : html});
            });
            await page.goto('https://new-in.test/best-sellers1/?bs_filters=%7B%22bs_new%22%3A%221%22%7D');
            await page.waitForSelector('[data-bs-catalog-ready="1"]');
            const ids = () => page.locator('[data-bs-grid] > [data-be-product]').evaluateAll(cards => cards.map(card => card.dataset.beProduct));
            assert.deepEqual(await ids(), ['1', '3', '6'], 'New in uses the exact novo tag across case, whitespace and object tags');
            await page.locator('[data-bs-open-filters]').click();
            assert.equal(await page.locator('[name="bs_new"]').isChecked(), true, 'URL selection is shown in the filter form');
            await page.locator('#bs-filter-dialog button[type="submit"]').click();
            assert.deepEqual(await ids(), ['1', '3', '6'], 'applying the form keeps New in selected');
            await page.locator('[data-bs-open-filters]').click();
            await page.locator('[name="bs_new"]').uncheck();
            await page.locator('#bs-filter-dialog button[type="submit"]').click();
            assert.equal((await ids()).length, 6);
            await page.goBack();
            assert.deepEqual(await ids(), ['1', '3', '6'], 'browser history restores New in');
            await page.locator('[data-bs-reset]').click();
            assert.equal((await ids()).length, 6, 'reset clears New in');
            assert.deepEqual(errors, []);
            await page.close();
        }
        console.log('PASS New in: exact novo tag, deep link, form/apply/uncheck, history/reset, desktop/mobile.');
    } finally { await browser.close(); }
})().catch(e => { console.error(e); process.exitCode = 1; });
