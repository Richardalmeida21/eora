const assert = require('node:assert/strict');
const fs = require('node:fs');
const {chromium} = require('playwright');
const base = 'http://127.0.0.1:4176/best-sellers1/';

function fixtureUrl(mode, category) {
    const url = new URL(base);
    url.searchParams.set('fixture_community_mode', mode);
    url.searchParams.set('fixture_gallery_items', '5');
    if (category) url.searchParams.set('bs_category', category);
    return url.href;
}
async function assertCommunity(page, source, amount) {
    const gallery = page.locator('[data-bs-community] > .be-gallery');
    assert.equal(await gallery.count(), 1, 'Quem usa permanece presente com Todos e com os filtros');
    assert.equal(await gallery.isVisible(), true);
    assert.equal(await gallery.locator('.be-gallery__item img').count(), amount, 'somente fotos validas da galeria efetiva');
    const links = await gallery.locator('.be-gallery__item a').evaluateAll(elements => elements.map(element => element.getAttribute('href')));
    assert(links.every(link => link.startsWith('/quem-usa/' + source + '-')), 'galeria geral ou especifica correta');
    assert.equal(await page.locator('[data-bs-grid] > article').count(), 24, 'fallback de fotos nao altera o lote de 24 produtos');
    assert.equal(await page.locator('[data-bs-grid] [data-be-product="888"], [data-bs-grid] [data-be-product="889"], [data-bs-grid] [data-be-product="890"]').count(), 0, 'galeria nao introduz produtos fora da categoria Best Sellers');
}
async function rememberCommunity(page) {
    await page.evaluate(() => {
        const container = document.querySelector('[data-bs-community]');
        window.bsRememberedCommunity = container.firstElementChild;
        window.bsRememberedTrack = container.querySelector('.be-track');
        window.bsRememberedPhoto = container.querySelector('img');
        window.bsRememberedScroll = window.bsRememberedTrack.scrollLeft;
    });
}
async function assertCommunityPreserved(page) {
    const kept = await page.evaluate(() => {
        const container = document.querySelector('[data-bs-community]');
        return {gallery: window.bsRememberedCommunity === container.firstElementChild, track: window.bsRememberedTrack === container.querySelector('.be-track'), photo: window.bsRememberedPhoto === container.querySelector('img'), scroll: Math.abs(window.bsRememberedScroll - container.querySelector('.be-track').scrollLeft)};
    });
    assert.equal(kept.gallery, true, 'trocar filtros com a mesma galeria preserva o mesmo DOM');
    assert.equal(kept.track, true, 'carrossel nao recriado');
    assert.equal(kept.photo, true, 'foto nao recriada');
    assert(kept.scroll < 2, 'posicao do carrossel preservada ao trocar/resetar filtros');
}

(async () => {
    const browser = await chromium.launch({executablePath: 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe', headless: true});
    const errors = [];
    try {
        for (const width of [390, 1440]) {
            const page = await browser.newPage({viewport: {width, height: 1000}, reducedMotion: 'reduce'});
            const requests = [];
            page.on('pageerror', error => errors.push(error.message));
            page.on('request', request => { if (new URL(request.url()).searchParams.get('bs_category_feed') === '1') requests.push(request.url()); });
            // Opcional: executar o mesmo teste contra um JS anterior, sem alterar a loja/tema.
            if (process.env.BS_COMMUNITY_SCRIPT) await page.route('**/best-sellers-eora.js*', route => route.fulfill({contentType: 'application/javascript', body: fs.readFileSync(process.env.BS_COMMUNITY_SCRIPT, 'utf8')}));
            for (const mode of ['general', 'imageless']) {
                const previousRequests = requests.length;
                await page.goto(fixtureUrl(mode));
                await page.waitForSelector('[data-bs-catalog-ready="1"]');
                await assertCommunity(page, 'todos', 5);
                const loadedRequests = requests.length;
                assert.equal(loadedRequests - previousRequests, 5, '120 produtos da categoria carregados em cinco paginas de 24');
                await page.evaluate(() => { window.bsCachedFirstCard = document.querySelector('[data-bs-grid]').firstElementChild; });
                const productGallery = page.locator('[data-bs-grid] > article').first().locator('[data-be-product-gallery]');
                await productGallery.locator('[data-be-product-slides]').focus();
                await page.keyboard.press('ArrowRight');
                await page.waitForFunction(() => document.querySelector('[data-bs-grid] [data-be-gallery-counter]').textContent === '2 / 2');
                if (width < 768) {
                    await page.locator('[data-bs-community] .be-track').focus();
                    await page.keyboard.press('ArrowRight');
                    await page.waitForFunction(() => document.querySelector('[data-bs-community] .be-track').scrollLeft > 0);
                }
                await rememberCommunity(page);
                for (const category of ['1', '2', '3']) {
                    await page.locator('[data-bs-category="' + category + '"]').click();
                    await assertCommunity(page, 'todos', 5);
                    await assertCommunityPreserved(page);
                    assert.equal(new URL(page.url()).searchParams.get('bs_category'), category);
                    assert.equal(requests.length, loadedRequests, 'troca de tag usa o catalogo em cache');
                    if (category === '1') {
                        assert.equal(await page.evaluate(() => window.bsCachedFirstCard === document.querySelector('[data-bs-grid]').firstElementChild), true, 'card reutilizado ao filtrar');
                        assert.equal(await page.locator('[data-bs-grid] [data-be-gallery-counter]').first().textContent(), '2 / 2', 'foto do produto preservada');
                    }
                }
                await page.locator('[data-bs-reset]').click();
                await assertCommunity(page, 'todos', 5);
                await assertCommunityPreserved(page);
                assert.equal(new URL(page.url()).searchParams.has('bs_category'), false);
                assert.equal(await page.evaluate(() => window.bsCachedFirstCard === document.querySelector('[data-bs-grid]').firstElementChild), true, 'reset recupera o mesmo card em cache');
                assert.equal(await page.locator('[data-bs-grid] [data-be-gallery-counter]').first().textContent(), '2 / 2');
                await page.goBack();
                assert.equal(new URL(page.url()).searchParams.get('bs_category'), '3');
                await assertCommunity(page, 'todos', 5);
                await assertCommunityPreserved(page);
                assert.equal(requests.length, loadedRequests, 'historico nao refaz requests do catalogo');
                await page.reload();
                await page.waitForSelector('[data-bs-catalog-ready="1"]');
                assert.equal(await page.locator('[data-bs-category="3"]').getAttribute('aria-current'), 'true');
                await assertCommunity(page, 'todos', 5);
                for (const category of ['1', '2', '3']) {
                    await page.goto(fixtureUrl(mode, category));
                    await page.waitForSelector('[data-bs-catalog-ready="1"]');
                    assert.equal(await page.locator('[data-bs-category="' + category + '"]').getAttribute('aria-current'), 'true');
                    await assertCommunity(page, 'todos', 5);
                }
                console.log('PASS: ' + width + 'px / ' + mode + ' — Quem usa geral5, filtros1/2/3, reset, historico, reload, URL direta, DOM/scroll e cards em cache.');
            }
            await page.goto(fixtureUrl('mixed'));
            await page.waitForSelector('[data-bs-catalog-ready="1"]');
            await assertCommunity(page, 'todos', 5);
            await rememberCommunity(page);
            await page.locator('[data-bs-category="1"]').click();
            await assertCommunity(page, 'todos', 5);
            await assertCommunityPreserved(page);
            await page.locator('[data-bs-category="2"]').click();
            await assertCommunity(page, 'prism', 3);
            assert.equal(await page.evaluate(() => window.bsRememberedCommunity === document.querySelector('[data-bs-community]').firstElementChild), false, 'galeria especifica valida substitui a geral');
            await page.locator('[data-bs-category="3"]').click();
            await assertCommunity(page, 'todos', 5);
            await rememberCommunity(page);
            await page.locator('[data-bs-reset]').click();
            await assertCommunity(page, 'todos', 5);
            await assertCommunityPreserved(page);
            await page.goto(fixtureUrl('mixed', '2'));
            await page.waitForSelector('[data-bs-catalog-ready="1"]');
            await assertCommunity(page, 'prism', 3);
            await page.reload();
            await page.waitForSelector('[data-bs-catalog-ready="1"]');
            await assertCommunity(page, 'prism', 3);
            await page.locator('[data-bs-category="1"]').click();
            await assertCommunity(page, 'todos', 5);
            console.log('PASS: ' + width + 'px / mixed — galeria especifica3 substitui geral5; filtro sem foto e reset retornam a geral.');
            await page.close();
        }
        assert.deepEqual(errors, [], 'nenhum erro de JavaScript');
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
