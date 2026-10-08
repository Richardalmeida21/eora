const assert = require('node:assert/strict');
const {chromium} = require('playwright');
const base = 'http://127.0.0.1:4176/best-sellers1/';
(async () => {
    const browser = await chromium.launch({executablePath: 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe', headless: true});
    try {
        const page = await browser.newPage({viewport: {width: 1440, height: 1000}, reducedMotion: 'reduce'});
        const requests = [];
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        await page.route('**/best-sellers/**', async route => {
            const url = new URL(route.request().url());
            requests.push(url);
            const response = await route.fetch();
            // Um HTML completo ou um aplicativo nao pode introduzir vitrines extras.
            const body = '<article data-be-product="888"></article><script>window.bsInjected=true</script>' + await response.text();
            await route.fulfill({response, body});
        });
        await page.goto(base + '?fixture_products=137');
        await page.waitForSelector('[data-bs-catalog-ready="1"]');
        assert.deepEqual(requests.map(url => Number(url.searchParams.get('page') || 1)), [1, 2, 3, 4, 5, 6]);
        assert(requests.every(url => url.pathname.replace(/\/$/, '') === '/best-sellers' && url.searchParams.get('bs_category_feed') === '1' && !url.searchParams.has('q')));
        assert.deepEqual(await page.locator('[data-bs-grid] > article').evaluateAll(cards => cards.map(card => Number(card.dataset.beProduct))), Array.from({length: 12}, (_, i) => i + 1));
        assert.equal(await page.evaluate(() => window.bsInjected), undefined);
        await page.locator('[data-bs-sort]').selectOption('price-descending');
        assert.equal(await page.locator('[data-bs-grid] > article').first().getAttribute('data-be-product'), '137', 'ordenacao usa todas as paginas, inclusive alem de 120 produtos');
        await page.locator('[data-bs-category="1"]').click();
        assert.equal(await page.locator('[data-bs-grid] > article').first().getAttribute('data-be-product'), '137', 'macro usa somente os membros da categoria');
        assert.equal(await page.locator('[data-be-product="888"],[data-be-product="889"],[data-be-product="890"]').count(), 0, 'mesma tag em outra vitrine nao entra no catalogo');
        await page.close();

        const pretty = await browser.newPage({viewport: {width: 390, height: 1000}});
        const prettyPages = [];
        pretty.on('request', request => { const url = new URL(request.url()); if (url.searchParams.get('bs_category_feed') === '1') prettyPages.push(url.pathname); });
        await pretty.goto(base + '?fixture_products=55&fixture_pretty_pages=1');
        await pretty.waitForSelector('[data-bs-catalog-ready="1"]');
        assert.deepEqual(prettyPages, ['/best-sellers/', '/best-sellers/page/2/', '/best-sellers/page/3/'], 'paginacao real da loja por caminho');
        await pretty.locator('[data-bs-sort]').selectOption('price-descending');
        assert.equal(await pretty.locator('[data-bs-grid] > article').first().getAttribute('data-be-product'), '55');
        await pretty.close();

        const retry = await browser.newPage({viewport: {width: 390, height: 1000}});
        const retryPages = [];
        let failed = false;
        await retry.route('**/best-sellers/**', async route => {
            const number = Number(new URL(route.request().url()).searchParams.get('page') || 1);
            retryPages.push(number);
            if (number === 2 && !failed) { failed = true; return route.fulfill({status: 503, body: 'temporary failure'}); }
            return route.continue();
        });
        await retry.goto(base + '?fixture_demo=1');
        await retry.locator('[data-bs-retry]').waitFor({state: 'visible'});
        assert.match(await retry.locator('[data-bs-status]').textContent(), /Não foi possível/);
        assert.equal(await retry.locator('[data-bs-grid] > article').count(), 6);
        await retry.locator('[data-bs-retry]').click();
        await retry.waitForSelector('[data-bs-catalog-ready="1"]');
        assert.deepEqual(retryPages, [1, 2, 2, 3, 4, 5], 'retoma a pagina com erro sem repetir produtos');
        await retry.locator('[data-bs-sort]').selectOption('price-descending');
        assert.equal(await retry.locator('[data-bs-grid] > article').first().getAttribute('data-be-product'), '120');
        await retry.close();

        const invalid = await browser.newPage();
        let escaped = false;
        invalid.on('request', request => { if (new URL(request.url()).pathname === '/search/') escaped = true; });
        await invalid.route('**/best-sellers/**', route => route.fulfill({contentType: 'text/html', body: '<template data-bs-category-feed data-last="0" data-next="/search/?q=onyx"><article data-be-product="888"></article></template>'}));
        await invalid.goto(base + '?fixture_demo=1');
        await invalid.locator('[data-bs-retry]').waitFor({state: 'visible'});
        assert.equal(await invalid.locator('[data-bs-grid] > article').count(), 0);
        assert.equal(escaped, false, 'paginacao nunca sai da categoria Best Sellers');
        await invalid.close();
        assert.deepEqual(errors, []);
        console.log('PASS: categoria exclusiva, 137 produtos/6 paginas, ordem nativa, filtros, HTML inerte, retomada de erros e rejeicao de outras fontes.');
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
