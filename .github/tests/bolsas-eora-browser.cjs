const {chromium, expect} = require('@playwright/test');
const assert = require('node:assert/strict');
const path = require('node:path');
const {feed, render, context, product} = require('./bolsas-eora-harness.cjs');
const base = 'http://127.0.0.1:4175';
const output = process.env.BE_VALIDATION_DIR || 'C:/Temp/eora-bolsas-validation';
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';
(async () => {
    const browser = await chromium.launch({headless: true, executablePath});
    const page = await browser.newPage({viewport: {width: 1440, height: 1000}});
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    const cards = () => page.locator('[data-be-results-grid] [data-be-product]');
    const idle = () => expect(page.locator('[data-be-results]')).toHaveAttribute('aria-busy', 'false');
    const maxi = () => page.locator('[data-be-tag="maxivertice"]');
    try {
        await page.route(base + '/?without-models', route => route.fulfill({contentType: 'text/html', body: '<!doctype html><meta name="viewport" content="width=device-width,initial-scale=1">' + render('snipplets/bolsas-eora/index.tpl', {...context(), settings: {...context().settings, bolsas_eora_models: []}})}));
        await page.goto(base + '/?without-models');
        assert.equal(await page.locator('[data-be-paged]').first().locator('[data-be-product]:visible').count(), 12);
        assert.equal(await page.locator('[data-be-page-items]').first().evaluate(el => getComputedStyle(el).gridTemplateColumns.split(' ').length), 4);
        await page.locator('[data-be-paged]').first().locator('[data-be-next]').click();
        assert.equal(await page.locator('[data-be-paged]').first().locator('[data-be-product]:visible').count(), 6);
        await page.locator('[data-be-paged]').first().locator('[data-be-prev]').click();
        await page.setViewportSize({width: 390, height: 844});
        await expect(page.locator('[data-be-paged]').first().locator('[data-be-product]:visible')).toHaveCount(6);
        assert.equal(await page.locator('[data-be-page-items]').first().evaluate(el => getComputedStyle(el).gridTemplateColumns.split(' ').length), 2);
        await page.setViewportSize({width: 1440, height: 1000});
        console.log('PASS catalogos manuais: sem modelos configurados, desktop/mobile e paginacao preservados.');

        await page.goto(base);
        await expect(page.locator('[data-be-page]')).toHaveAttribute('data-be-ready', '1');
        await idle();
        await expect(page.locator('[data-be-results]')).toBeVisible();
        assert.equal(await page.locator('[data-be-tag]').count(), 20);
        assert.equal(await page.locator('.be-gallery--community .be-gallery__item').count(), 20);
        assert.equal(await page.locator('[data-be-results-grid]').evaluate(el => getComputedStyle(el).gridTemplateColumns.split(' ').length), 4);
        assert((await cards().count()) > 0, 'catalogo automatico aparece sem selecionar uma tag');
        await expect(page.locator('.be-models [data-be-dots] .be-dot')).toHaveCount(5);
        await expect(page.locator('.be-models .be-dot').first()).toHaveAttribute('aria-current', 'true');
        assert.equal(await page.locator('.be-models [data-be-track]').evaluate(el => getComputedStyle(el).scrollbarWidth), 'none');
        await page.locator('.be-models .be-dot').last().click();
        await expect(page.locator('.be-models .be-dot').last()).toHaveAttribute('aria-current', 'true');
        await expect(page.locator('.be-models [data-be-next]')).toBeDisabled();
        await page.locator('.be-models .be-dot').first().click();
        await expect(page.locator('.be-models .be-dot').first()).toHaveAttribute('aria-current', 'true');
        await page.evaluate(() => window.scrollTo(0, 0));
        await page.screenshot({path: path.join(output, 'desktop.png')});
        await page.locator('.be-split').first().screenshot({path: path.join(output, 'desktop-split.png')});
        console.log('PASS desktop: catalogo automatico em 4 colunas, modelos e galerias com 20 itens.');

        await maxi().click();
        await expect(page.locator('.be-catalog-block').first()).toBeHidden();
        await expect(page.locator('.be-split').first()).toBeVisible();
        await idle();
        await expect(cards()).toHaveCount(12);
        assert(!(await cards().evaluateAll(nodes => nodes.map(n => n.dataset.beProduct))).includes('1'));
        await page.locator('[data-be-more]').click();
        await idle();
        await expect(cards()).toHaveCount(24);
        await expect(page.locator('[data-be-more]')).toBeHidden();
        const ids = await cards().evaluateAll(nodes => nodes.map(n => n.dataset.beProduct));
        assert.equal(new Set(ids).size, 24);
        assert(ids.every(id => (Number(id) - 1) % 5 !== 0), 'somente tag exata; prefixo e titulo nao bastam');
        await page.locator('[data-be-tag="minivertice"]').click();
        await idle();
        await expect(cards()).toHaveCount(1);
        await expect(cards().first()).toHaveAttribute('data-be-product', '101');
        await page.goBack();
        await idle();
        await expect(cards()).toHaveCount(12);
        console.log('PASS tags: 6 paginas, correspondencia exata, sem duplicados, troca e voltar.');

        // Response shape observed in production before normalizing tags in the TPL.
        await page.route('**/search/**', async route => {
            const html = render('snipplets/bolsas-eora/search-feed.tpl', {
                ...context(), query: '"maxivertice"', products: [product(301), product(302), product(303)],
                pages: {current: 1, is_last: true, next: ''},
            });
            const body = await page.evaluate(html => {
                const doc = new DOMParser().parseFromString(html, 'text/html');
                const feed = doc.querySelector('template');
                const cards = feed.content.querySelectorAll('[data-be-product]');
                cards[0].dataset.beTags = JSON.stringify([{attributes: {tag: 'maxivertice'}}, {attributes: {tag: 'novo'}}]);
                cards[1].dataset.beTags = JSON.stringify([{attributes: {tag: 'maxivertice-extra'}}]);
                cards[2].dataset.beTags = JSON.stringify([null, {}]);
                return feed.outerHTML;
            }, html);
            await route.fulfill({contentType: 'text/html', body});
        });
        await page.goto(base + '/?tag=maxivertice');
        await idle();
        await expect(cards()).toHaveCount(1);
        await expect(cards().first()).toHaveAttribute('data-be-product', '301');
        await page.unroute('**/search/**');
        await page.goto(base + '/?tag=maxivertice');
        await idle();
        await expect(cards()).toHaveCount(12);
        console.log('PASS tags da plataforma: attributes.tag, correspondencia exata, dados vazios e TPL normalizado.');

        await page.locator('[data-be-open-filters]').click();
        await expect(page.locator('[data-be-filter-form] [type="submit"]')).toBeEnabled();
        await page.locator('input[name="be_color"][value="preto"]').check();
        await page.locator('input[name="max_price"]').fill('1780');
        await page.locator('[data-be-filter-form] [type="submit"]').click();
        await idle();
        await expect(page.locator('#be-filter-dialog')).not.toBeVisible();
        const filtered = await cards().evaluateAll(nodes => nodes.map(n => Number(n.dataset.beProduct)));
        assert(filtered.length > 0 && filtered.every(id => id % 2 === 1 && id <= 31 && (id - 1) % 5 !== 0));
        assert.equal(JSON.parse(new URL(page.url()).searchParams.get('be_filters')).be_color, 'preto');
        await page.locator('[data-be-sort]').selectOption('price-descending');
        await idle();
        const prices = await cards().evaluateAll(nodes => nodes.map(n => Number(n.dataset.beProduct)));
        assert.deepEqual(prices, [...prices].sort((a, b) => b - a));
        console.log('PASS filtros gerais: cor do couro, preco no servidor, tag preservada e ordenacao.');

        await page.goto(base + '/?tag=modelo-2');
        await idle();
        await expect(cards()).toHaveCount(0);
        await expect(page.locator('[data-be-status]')).toContainText('Nenhum produto');
        await expect(page.locator('[data-be-more]')).toBeHidden();

        let failed = false;
        await page.route('**/search/**', route => {
            if (!failed) { failed = true; return route.fulfill({status: 503, body: 'Unavailable'}); }
            return route.continue();
        });
        await maxi().click();
        await idle();
        await expect(page.locator('[data-be-status]')).toContainText('Não foi possível');
        await page.locator('[data-be-more]').click();
        await idle();
        await expect(cards()).toHaveCount(12);
        await page.unroute('**/search/**');
        console.log('PASS vazio e erro: mensagem correta, tentativa recupera os produtos.');

        await page.route('**/search/**', async route => {
            const url = new URL(route.request().url());
            const index = Number(url.searchParams.get('page') || 1);
            if (index <= 3) {
                url.searchParams.set('page', index + 1);
                return route.fulfill({contentType: 'text/html', body: render('snipplets/bolsas-eora/search-feed.tpl', {...context(), query: '"maxivertice"', products: [product(index, 'outra-tag')], pages: {current: index, is_last: false, next: url.pathname + url.search}})});
            }
            return route.continue();
        });
        await page.goto(base + '/?tag=maxivertice');
        await idle();
        await expect(cards()).toHaveCount(0);
        await expect(page.locator('[data-be-status]')).toContainText('Continue');
        await expect(page.locator('[data-be-more]')).toBeVisible();
        await page.locator('[data-be-more]').click();
        await idle();
        await expect(cards()).toHaveCount(12);
        await page.unroute('**/search/**');
        console.log('PASS resultado esparso: nao encerra busca antes das paginas restantes.');

        await page.route('**/search/**', async route => {
            if (new URL(route.request().url()).searchParams.get('q') === '"maxivertice"') {
                await new Promise(resolve => setTimeout(resolve, 250));
            }
            try { await route.continue(); } catch (_) { /* request cancelado ao mudar de modelo */ }
        });
        await page.goto(base);
        await maxi().click();
        await page.locator('[data-be-tag="minivertice"]').click();
        await idle();
        await expect(cards()).toHaveCount(1);
        await expect(cards().first()).toHaveAttribute('data-be-product', '101');
        await page.unroute('**/search/**');
        console.log('PASS concorrencia: resposta antiga nao substitui modelo mais recente.');

        await page.setViewportSize({width: 390, height: 844});
        await page.goto(base);
        await idle();
        assert((await cards().count()) > 0 && (await cards().count()) <= 6);
        assert.equal(await page.locator('[data-be-results-grid]').evaluate(el => getComputedStyle(el).gridTemplateColumns.split(' ').length), 2);
        await expect(page.locator('.be-split__products').first()).toBeHidden();
        assert.equal(await page.locator('.be-models').evaluate(el => getComputedStyle(el).getPropertyValue('--be-visible').trim()), '2');
        await expect(page.locator('.be-models .be-dot')).toHaveCount(10);
        const mobileModelRatio = await page.locator('.be-models [data-be-track]').evaluate(el => el.clientWidth / el.firstElementChild.getBoundingClientRect().width);
        assert(mobileModelRatio > 2.5 && mobileModelRatio < 2.7, 'mobile mostra dois filtros inteiros e metade do terceiro');
        const mobileComposition = await page.locator('.be-models [data-be-track]').evaluate(track => {
            const viewport = track.getBoundingClientRect();
            const cards = Array.from(track.children).slice(0, 3).map(card => card.getBoundingClientRect());
            return {
                firstFull: cards[0].left >= viewport.left && cards[0].right <= viewport.right,
                secondFull: cards[1].left >= viewport.left && cards[1].right <= viewport.right,
                thirdHalf: cards[2].left < viewport.right && cards[2].right > viewport.right,
            };
        });
        assert.deepEqual(mobileComposition, {firstFull: true, secondFull: true, thirdHalf: true});
        await page.locator('.be-models .be-dot').last().click();
        await expect(page.locator('.be-models .be-dot').last()).toHaveAttribute('aria-current', 'true');
        await expect(page.locator('.be-models [data-be-next]')).toBeDisabled();
        await page.locator('.be-models .be-dot').first().click();
        await expect(page.locator('.be-models .be-dot').first()).toHaveAttribute('aria-current', 'true');
        assert.equal(await page.locator('.be-gallery--community').evaluate(el => getComputedStyle(el).getPropertyValue('--be-visible').trim()), '2');
        assert.equal(await page.locator('.be-best').evaluate(el => getComputedStyle(el).getPropertyValue('--be-visible').trim()), '2');
        assert(await page.evaluate(() => document.documentElement.scrollWidth <= window.innerWidth));
        await page.screenshot({path: path.join(output, 'mobile.png'), fullPage: true});
        await page.locator('[data-be-open-filters]').click();
        await expect(page.locator('[data-be-filter-form] [type="submit"]')).toBeEnabled();
        await page.locator('input[name="be_color"][value="marrom"]').check();
        await page.screenshot({path: path.join(output, 'mobile-filters.png')});
        await page.keyboard.press('Escape');
        await expect(page.locator('#be-filter-dialog')).not.toBeVisible();
        await expect(page.locator('[data-be-open-filters]')).toBeFocused();
        assert.deepEqual(errors, []);
        console.log('PASS mobile: 2 colunas/6 produtos, carrosseis com proximo item visivel, comunidade compacta, sem overflow; modal e Escape.');
        console.log('PASS: nenhum erro JavaScript. Screenshots em ' + output);
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
