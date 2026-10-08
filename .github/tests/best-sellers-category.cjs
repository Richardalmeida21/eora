const assert = require('node:assert/strict');
const {chromium} = require('playwright');
const base = 'http://127.0.0.1:4176/best-sellers1/';
(async () => {
    const browser = await chromium.launch({executablePath: 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe', headless: true});
    try {
        for (const width of [390, 1440]) {
            const progressive = await browser.newPage({viewport: {width, height: 1000}, reducedMotion: 'reduce'});
            const progressiveErrors = [];
            let releaseSecond, releaseThird;
            let secondRequested = false, thirdRequested = false;
            const secondGate = new Promise(resolve => { releaseSecond = resolve; });
            const thirdGate = new Promise(resolve => { releaseThird = resolve; });
            progressive.on('pageerror', error => progressiveErrors.push(error.message));
            await progressive.route('**/best-sellers/**', async route => {
                const number = Number(new URL(route.request().url()).searchParams.get('page') || 1);
                if (number === 2) { secondRequested = true; await secondGate; }
                if (number === 3) { thirdRequested = true; await thirdGate; }
                return route.continue();
            });
            try {
                await progressive.goto(base + '?fixture_products=137');
                await progressive.waitForFunction(() => document.querySelector('[data-bs-grid]').children.length === 24);
                assert.equal(secondRequested, true, 'proxima pagina ja solicitada enquanto os primeiros 24 sao visiveis');
                assert.equal(await progressive.locator('[data-bs-page]').getAttribute('data-bs-catalog-ready'), null);
                assert.equal(await progressive.locator('[data-bs-sort]').isDisabled(), true, 'ordenacao aguarda todas as paginas');
                assert.equal(await progressive.locator('[data-bs-open-filters]').isDisabled(), true, 'filtros aguardam todas as paginas');
                assert.equal(await progressive.locator('.bs-catalog').getAttribute('aria-busy'), 'true');
                await progressive.evaluate(() => {
                    window.bsOriginalCards = Array.from(document.querySelector('[data-bs-grid]').children);
                    window.bsOriginalCommunity = document.querySelector('[data-bs-community]').firstElementChild;
                });
                const gallery = progressive.locator('[data-bs-grid] > article').first().locator('[data-be-product-gallery]');
                await gallery.locator('[data-be-product-slides]').focus();
                await progressive.keyboard.press('ArrowRight');
                await progressive.waitForFunction(() => document.querySelector('[data-bs-grid] [data-be-gallery-counter]').textContent === '2 / 2');
                await progressive.locator('[data-bs-more]').click();
                await progressive.locator('[data-bs-more]').dispatchEvent('click');
                assert.equal(await progressive.locator('[data-bs-grid] > article').count(), 24, 'Mostrar mais aguarda somente o lote seguinte');
                assert.equal(await gallery.locator('[data-be-gallery-counter]').textContent(), '2 / 2', 'galeria preservada ao pedir mais produtos');
                if (width === 1440) await progressive.locator('[data-bs-reset]').focus();
                releaseSecond();
                await progressive.waitForFunction(() => document.querySelector('[data-bs-grid]').children.length === 48);
                assert.equal(thirdRequested, true, 'pagina seguinte pre-carregada sem impedir a exibicao do segundo lote');
                assert.equal(await progressive.evaluate(() => window.bsOriginalCards.every((card, index) => document.querySelector('[data-bs-grid]').children[index] === card)), true, 'cards existentes preservam identidade durante carregamento');
                assert.equal(await gallery.locator('[data-be-gallery-counter]').textContent(), '2 / 2', 'pagina seguinte preserva foto selecionada');
                assert.equal(await progressive.evaluate(width => document.activeElement === (width === 1440 ? document.querySelector('[data-bs-reset]') : document.querySelector('[data-bs-grid]').children[24].querySelector('h3 a')), width), true, 'foco segue ao lote novo somente se usuario permanece no botao');
                assert.equal(await progressive.evaluate(() => window.bsOriginalCommunity === document.querySelector('[data-bs-community]').firstElementChild), true, 'carregamento nao recria Quem usa');
                releaseThird();
                await progressive.waitForSelector('[data-bs-catalog-ready="1"]');
                assert.equal(await progressive.locator('[data-bs-grid] > article').count(), 48, 'paginas em segundo plano e cliques duplicados respeitam um unico lote solicitado');
                assert.equal(await gallery.locator('[data-be-gallery-counter]').textContent(), '2 / 2');
                await progressive.locator('[data-bs-more]').click();
                assert.equal(await progressive.locator('[data-bs-grid] > article').count(), 72, 'Mostrar mais acrescenta 24 no celular e computador');
                assert.equal(await progressive.evaluate(() => window.bsOriginalCards.every((card, index) => document.querySelector('[data-bs-grid]').children[index] === card)), true, 'Mostrar mais preserva os cards anteriores');
                assert.equal(await progressive.evaluate(() => document.activeElement === document.querySelector('[data-bs-grid]').children[48].querySelector('h3 a')), true);
                assert.equal(await gallery.locator('[data-be-gallery-counter]').textContent(), '2 / 2');
                assert.deepEqual(progressiveErrors, []);
            } finally {
                releaseSecond(); releaseThird();
                await progressive.close();
            }
        }

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
        assert.deepEqual(await page.locator('[data-bs-grid] > article').evaluateAll(cards => cards.map(card => Number(card.dataset.beProduct))), Array.from({length: 24}, (_, i) => i + 1));
        assert.equal(await page.evaluate(() => window.bsInjected), undefined);
        await page.locator('[data-bs-more]').click();
        assert.equal(await page.locator('[data-bs-grid] > article').count(), 48);
        await page.evaluate(() => { window.bsCardsBeforeSort = new Map(Array.from(document.querySelector('[data-bs-grid]').children).map(card => [card.dataset.beProduct, card])); });
        for (const ordering of ['price-ascending', 'price-descending', 'alpha-ascending', 'created-descending', 'user']) {
            await page.locator('[data-bs-sort]').selectOption(ordering);
            const result = await page.locator('[data-bs-grid] > article').evaluateAll(cards => cards.map(card => ({id: Number(card.dataset.beProduct), price: Number(card.dataset.bePrice), name: card.dataset.beName, created: card.dataset.beCreated})));
            assert.equal(result.length, 24, ordering + ': ordenacao reinicia com 24 produtos');
            assert.equal(new Set(result.map(card => card.id)).size, 24, ordering + ': sem duplicatas');
            if (ordering === 'price-ascending') assert.deepEqual(result.map(card => card.price), [...result.map(card => card.price)].sort((a, b) => a - b));
            if (ordering === 'price-descending') assert.deepEqual(result.map(card => card.price), [...result.map(card => card.price)].sort((a, b) => b - a));
            if (ordering === 'alpha-ascending') assert.deepEqual(result.map(card => card.name), [...result.map(card => card.name)].sort((a, b) => a.localeCompare(b, 'pt-BR')));
            if (ordering === 'created-descending') assert.deepEqual(result.map(card => card.created), [...result.map(card => card.created)].sort((a, b) => String(b).localeCompare(a, 'pt-BR', {numeric: true})));
            if (ordering === 'user') assert.deepEqual(result.map(card => card.id), Array.from({length: 24}, (_, i) => i + 1));
            assert.equal(await page.evaluate(() => Array.from(document.querySelector('[data-bs-grid]').children).every(card => !window.bsCardsBeforeSort.has(card.dataset.beProduct) || window.bsCardsBeforeSort.get(card.dataset.beProduct) === card)), true, ordering + ': cards reutilizados ao reorganizar DOM');
        }
        await page.locator('[data-bs-sort]').selectOption('price-descending');
        assert.equal(await page.locator('[data-bs-grid] > article').first().getAttribute('data-be-product'), '137', 'ordenacao usa todas as paginas, inclusive alem de 120 produtos');
        await page.locator('[data-bs-category="1"]').click();
        assert.equal(await page.locator('[data-bs-grid] > article').first().getAttribute('data-be-product'), '137', 'macro usa somente os membros da categoria');
        assert.equal(await page.locator('[data-be-product="888"],[data-be-product="889"],[data-be-product="890"]').count(), 0, 'mesma tag em outra vitrine nao entra no catalogo');
        await page.close();

        const restored = await browser.newPage({viewport: {width: 390, height: 1000}});
        const restoredUrl = new URL(base);
        restoredUrl.searchParams.set('fixture_products', '137');
        restoredUrl.searchParams.set('bs_category', '1');
        restoredUrl.searchParams.set('bs_filters', JSON.stringify({min_price: '1400'}));
        restoredUrl.searchParams.set('bs_sort', 'price-descending');
        await restored.goto(restoredUrl.href);
        await restored.waitForSelector('[data-bs-catalog-ready="1"]');
        assert.equal(await restored.locator('[data-bs-category="1"]').getAttribute('aria-expanded'), 'true');
        assert.equal(await restored.locator('[data-bs-sort]').inputValue(), 'price-descending');
        assert.deepEqual(await restored.locator('[data-bs-grid] > article').evaluateAll(cards => cards.map(card => Number(card.dataset.beProduct))), [137, 133], 'filtros e ordem restaurados incluem paginas apos 120 produtos');
        await restored.close();

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
        retry.on('pageerror', error => errors.push(error.message));
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
        assert.equal(await retry.locator('[data-bs-grid] > article').count(), 24);
        await retry.evaluate(() => { window.bsRetryFirstCard = document.querySelector('[data-bs-grid]').firstElementChild; });
        const retryGallery = retry.locator('[data-bs-grid] > article').first().locator('[data-be-product-gallery]');
        await retryGallery.locator('[data-be-product-slides]').focus();
        await retry.keyboard.press('ArrowRight');
        await retry.waitForFunction(() => document.querySelector('[data-bs-grid] [data-be-gallery-counter]').textContent === '2 / 2');
        await retry.locator('[data-bs-retry]').click();
        await retry.waitForSelector('[data-bs-catalog-ready="1"]');
        assert.deepEqual(retryPages, [1, 2, 2, 3, 4, 5], 'retoma a pagina com erro sem repetir produtos');
        assert.equal(await retry.evaluate(() => window.bsRetryFirstCard === document.querySelector('[data-bs-grid]').firstElementChild), true, 'retomada preserva cards ja recebidos');
        assert.equal(await retryGallery.locator('[data-be-gallery-counter]').textContent(), '2 / 2', 'retomada preserva foto selecionada');
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
        console.log('PASS: primeiros 24 sem esperar o catalogo, lotes de 24, cards/galeria/foco preservados, categoria exclusiva, 137 produtos/6 paginas, ordem nativa, filtros, URL, HTML inerte, retomada de erros e rejeicao de outras fontes.');
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
