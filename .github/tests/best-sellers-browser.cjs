const assert = require('node:assert/strict');
const fs = require('node:fs');
const {chromium} = require('playwright');
const temp = process.env.BS_VALIDATION_DIR || 'C:/Temp/eora-best-sellers-validation';
const baseUrl = 'http://127.0.0.1:4176/best-sellers1/';
const url = baseUrl + '?fixture_demo=1';
async function assertMacroSelection(page, selected) {
    const macros = await page.locator('[data-bs-category]').evaluateAll(elements => elements.map(element => {
        const selection = element.querySelector('.bs-macro__selection');
        const style = getComputedStyle(selection);
        const titleStyle = getComputedStyle(element.querySelector('.bs-macro__title'));
        return {id: element.dataset.bsCategory, current: element.getAttribute('aria-current') === 'true', expanded: element.getAttribute('aria-expanded') === 'true', borderColor: style.borderTopColor, borderWidth: parseFloat(style.borderTopWidth), pictureOnly: selection.children.length === 1 && selection.firstElementChild.tagName === 'PICTURE', titleAlignment: titleStyle.textAlign, titleDecoration: titleStyle.textDecorationLine, descriptionAlignment: getComputedStyle(element.querySelector('.bs-macro__description')).textAlign};
    }));
    for (const macro of macros) {
        const active = macro.id === String(selected);
        assert.equal(macro.current, active, 'filtro selecionado identificado por aria-current');
        assert.equal(macro.expanded, active, 'descricao acompanha o filtro selecionado');
        assert(macro.borderWidth > 0, 'borda reserva espaco e evita deslocar a imagem');
        assert.equal(macro.pictureOnly, true, 'contorno envolve somente a foto');
        const transparent = macro.borderColor === 'transparent' || /rgba\([^)]*,\s*0\)/.test(macro.borderColor);
        assert.equal(transparent, !active, 'borda visivel somente na foto selecionada');
        assert.equal(macro.titleAlignment, 'center', 'titulo centralizado');
        assert.equal(macro.descriptionAlignment, 'center', 'legenda centralizada');
        assert.equal(macro.titleDecoration.includes('underline'), active, 'sublinhado acompanha a selecao existente');
    }
}
(async () => {
    fs.mkdirSync(temp, {recursive: true});
    const browser = await chromium.launch({executablePath: 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe', headless: true});
    const errors = [];
    try {
        for (const width of [320, 390, 767, 768, 1440, 1920]) {
            const page = await browser.newPage({viewport: {width, height: 1000}, deviceScaleFactor: 1, reducedMotion: 'reduce'});
            page.on('pageerror', error => errors.push(error.message));
            await page.goto(url);
            await page.waitForSelector('[data-bs-page][data-bs-catalog-ready="1"]');
            const mobile = width < 768;
            const count = 24;
            assert.equal(await page.locator('[data-bs-grid] > article').count(), count);
            await assertMacroSelection(page, null);
            const geometry = await page.evaluate(() => {
                const measure = selector => { const track = document.querySelector(selector); const card = track.firstElementChild; return {width: track.clientWidth, card: card.getBoundingClientRect().width, gap: parseFloat(getComputedStyle(track).gap)}; };
                return {overflow: document.documentElement.scrollWidth > innerWidth, columns: getComputedStyle(document.querySelector('[data-bs-grid]')).gridTemplateColumns.split(' ').length, macros: measure('.bs-macros__track'), community: measure('[data-bs-community] .be-track'), categories: measure('.bs-categories .be-track')};
            });
            assert.equal(geometry.overflow, false, width + ': sem overflow');
            assert.equal(geometry.columns, mobile ? 2 : 4);
            const fits = track => (track.width + track.gap) / (track.card + track.gap);
            assert(Math.abs(fits(geometry.macros) - 4) < 0.03, width + ': quatro filtros dividem toda a largura');
            assert(Math.abs(fits(geometry.community) - (mobile ? 1.12 : 5.2)) < 0.03, width + ': Quem usa com parte da proxima foto');
            assert(Math.abs(fits(geometry.categories) - (mobile ? 1.12 : 4.2)) < 0.03, width + ': banners com parte do proximo');
            for (const selector of ['[data-bs-community] .be-gallery', '.bs-categories .be-gallery']) {
                const carousel = page.locator(selector);
                await carousel.locator('[data-be-dots] button').nth(1).click();
                await page.waitForFunction(selector => {
                    const track = document.querySelector(selector + ' .be-track');
                    const card = track.children[1];
                    return Math.abs(card.getBoundingClientRect().left - track.getBoundingClientRect().left) < 2;
                }, selector);
                await carousel.locator('[data-be-dots] button').last().click();
                await page.waitForFunction(selector => {
                    const track = document.querySelector(selector + ' .be-track');
                    const card = track.lastElementChild.getBoundingClientRect();
                    const box = track.getBoundingClientRect();
                    return Math.abs(card.left + card.width / 2 - box.left - box.width / 2) < 2 && document.querySelector(selector + ' [data-be-next]').disabled;
                }, selector);
                assert.equal(await carousel.locator('[data-be-next]').isDisabled(), true, width + ': ultimo item centralizado');
                if ([390, 1440].includes(width)) {
                    await carousel.locator('img').evaluateAll(async images => { for (const image of images) image.loading = 'eager'; await Promise.all(images.map(image => image.decode())); });
                    await carousel.screenshot({path: temp + '/best-sellers-' + (selector.includes('community') ? 'community' : 'banners') + '-last-' + width + '.png'});
                }
                await carousel.locator('[data-be-dots] button').first().click();
                await page.waitForFunction(selector => document.querySelector(selector + ' .be-track').scrollLeft < 2, selector);
            }
            if ([390, 1440].includes(width)) {
                await page.locator('img[src]').evaluateAll(async images => {
                    for (const image of images) image.loading = 'eager';
                    await Promise.all(images.map(image => image.decode()));
                });
                await page.screenshot({path: temp + '/best-sellers-' + width + '.png', fullPage: true});
            }
            await page.locator('[data-bs-category="1"]').click();
            await assertMacroSelection(page, 1);
            assert.equal(await page.locator('.bs-macro__description:visible').count(), 1);
            assert.equal(await page.locator('[data-bs-grid] > article').count(), count);
            assert(await page.locator('[data-bs-community] a.be-banner').first().getAttribute('href').then(href => href.includes('onyx')));
            assert.equal(await page.locator('[data-bs-community] .be-gallery__item').count(), 15);
            await page.locator('[data-bs-category="2"]').click();
            await assertMacroSelection(page, 2);
            assert.equal(await page.locator('.bs-macro__description:visible').count(), 1);
            assert.equal(await page.locator('[data-bs-category="1"]').getAttribute('aria-expanded'), 'false');
            assert(await page.locator('[data-bs-community] a.be-banner').first().getAttribute('href').then(href => href.includes('prism')));
            await page.locator('[data-bs-more]').click();
            assert.equal(await page.locator('[data-bs-grid] > article').count(), 30, 'Mostrar mais exibe os restantes da categoria em lote de ate 24');
            await page.locator('[data-bs-sort]').selectOption('price-descending');
            const prices = await page.locator('[data-bs-grid] > article').evaluateAll(cards => cards.map(card => Number(card.dataset.bePrice)));
            assert.deepEqual(prices, [...prices].sort((a, b) => b - a));
            await page.locator('[data-bs-open-filters]').click();
            assert.equal(await page.locator('#bs-filter-dialog').evaluate(dialog => dialog.open), true);
            const form = page.locator('[data-bs-filter-form]');
            assert.equal(await form.locator('[data-be-facet="be_color"]').count(), 0, 'atributos de bolsas fora da categoria de oculos');
            assert.equal(await form.locator('[data-be-facet="oe_shape"]').count(), 1);
            await form.locator('[name="min_price"]').fill('400');
            await form.locator('[name="max_price"]').fill('800');
            await form.locator('[type="submit"]').click();
            assert.equal(await page.locator('#bs-filter-dialog').evaluate(dialog => dialog.open), false);
            const filtered = await page.locator('[data-bs-grid] > article').evaluateAll(cards => cards.map(card => Number(card.dataset.bePrice)));
            assert(filtered.length && filtered.every(price => price >= 40000 && price <= 80000));
            await page.reload();
            await page.waitForSelector('[data-bs-page][data-bs-catalog-ready="1"]');
            assert.equal(await page.locator('[data-bs-category="2"]').getAttribute('aria-expanded'), 'true');
            await assertMacroSelection(page, 2);
            assert.match(await page.locator('[data-bs-status]').textContent(), /produtos encontrados/);
            await page.locator('[data-bs-open-filters]').click();
            await page.keyboard.press('Escape');
            assert.equal(await page.locator('#bs-filter-dialog').evaluate(dialog => dialog.open), false);
            assert.equal(await page.locator('[data-bs-open-filters]').evaluate(button => button === document.activeElement), true);
            await page.locator('[data-bs-reset]').click();
            await assertMacroSelection(page, null);
            assert.equal(await page.locator('.bs-macro__description:visible').count(), 0);
            await page.goBack();
            assert.equal(await page.locator('[data-bs-category="2"]').getAttribute('aria-expanded'), 'true');
            await assertMacroSelection(page, 2);
            await page.locator('[data-bs-open-filters]').click();
            await form.locator('[name="min_price"]').fill('900');
            await form.locator('[name="max_price"]').fill('100');
            await form.locator('[type="submit"]').click();
            assert.equal(await form.locator('[name="max_price"]').evaluate(input => input.validity.valid), false);
            await page.keyboard.press('Escape');
            await page.locator('[data-bs-category="3"]').click();
            await page.locator('[data-bs-open-filters]').click();
            assert.equal(await form.locator('[data-be-facet="oe_shape"]').count(), 0);
            assert.equal(await form.locator('[data-be-facet="be_color"]').count(), 1);
            await form.locator('[name="be_color"][value="preta"]').check();
            await form.locator('[type="submit"]').click();
            assert.equal(await page.locator('[data-bs-grid] > article').count(), count);
            if (width === 390) {
                await page.locator('[data-bs-open-filters]').click();
                await page.screenshot({path: temp + '/best-sellers-filters-390.png'});
                await page.keyboard.press('Escape');
            }
            await page.locator('[data-bs-reset]').click();
            const gallery = page.locator('[data-bs-grid] > article').first().locator('[data-be-product-gallery]');
            await gallery.locator('[data-be-product-slides]').focus();
            await page.keyboard.press('ArrowRight');
            await page.waitForTimeout(80);
            assert.equal(await gallery.locator('[data-be-gallery-counter]').textContent(), '2 / 2');
            console.log('PASS: ' + width + 'px — parte do proximo item, ultimo centralizado, layout, categorias, comunidade, paginacao, filtros, preco, historico e galeria.');
            await page.close();
        }
        const page = await browser.newPage({viewport: {width: 1440, height: 1000}});
        page.on('pageerror', error => errors.push(error.message));
        for (const width of [320, 390, 767, 768, 1440]) {
            await page.setViewportSize({width, height: 1000});
            for (const amount of [1, 2, 3, 4, 6, 15]) {
                await page.goto(baseUrl + '?fixture_macros=' + amount);
                await page.waitForSelector('[data-bs-catalog-ready="1"]');
                assert.equal(await page.locator('[data-bs-category]').count(), amount);
                const geometry = await page.locator('.bs-macros__track').evaluate(track => {
                    const box = track.getBoundingClientRect();
                    const cards = Array.from(track.children).map(card => card.getBoundingClientRect());
                    const gap = parseFloat(getComputedStyle(track).gap);
                    return {fits: (box.width + gap) / (cards[0].width + gap), firstLeft: cards[0].left - box.left, lastRight: cards.at(-1).right - box.right, overflow: track.scrollWidth > track.clientWidth + 1};
                });
                const expected = amount <= 4 ? amount : width < 768 ? 2 : 3.2;
                assert(Math.abs(geometry.fits - expected) < 0.04, width + 'px / ' + amount + ': largura acompanha numero de filtros');
                await assertMacroSelection(page, null);
                if (amount <= 4) {
                    assert.equal(geometry.overflow, false, 'ate quatro filtros sem rolagem');
                    assert(Math.abs(geometry.firstLeft) < 2 && Math.abs(geometry.lastRight) < 2, 'filtros ocupam toda a largura, sem espaco sobrando');
                    assert.equal(await page.locator('.bs-macros--overflow').count(), 0);
                    assert.equal(await page.locator('.bs-macros [data-be-controls]').isVisible(), false);
                } else {
                    assert.equal(geometry.overflow, true, 'mais de quatro filtros preservam carrossel');
                    await page.locator('.bs-macros [data-be-next]').click();
                    await page.waitForFunction(() => document.querySelector('.bs-macros__track').scrollLeft > 0);
                }
            }
        }
        await page.goto(baseUrl + '?fixture_empty=1&fixture_macros=0&fixture_no_community=1');
        await page.waitForSelector('[data-bs-catalog-ready="1"]');
        assert.equal(await page.locator('[data-bs-grid] > article').count(), 0);
        assert.match(await page.locator('[data-bs-status]').textContent(), /Nenhum produto/);
        await page.goto(baseUrl + '?fixture_no_filters=1');
        assert.equal(await page.locator('[data-bs-open-filters]').count(), 0);
        for (const width of [390, 1440]) {
            await page.setViewportSize({width, height: 1000});
            await page.goto(baseUrl + '?fixture_gallery_items=1&fixture_banner_items=1');
            await page.waitForSelector('[data-bs-catalog-ready="1"]');
            for (const selector of ['[data-bs-community] .be-gallery', '.bs-categories .be-gallery']) {
                assert.equal(await page.locator(selector + ' [data-be-controls]').isVisible(), false);
                assert.equal(await page.locator(selector + '.bs-gallery--overflow').count(), 0);
                const centered = await page.locator(selector + ' .be-track').evaluate(track => { const card = track.firstElementChild.getBoundingClientRect(); const box = track.getBoundingClientRect(); return Math.abs(card.left + card.width / 2 - box.left - box.width / 2) < 2; });
                assert(centered, 'item unico centralizado sem controles vazios');
            }
        }
        assert.deepEqual(errors, []);
        await page.close();
        console.log('PASS: 1/2/3/4 filtros dividem a largura; 6/15 preservam carrossel; legendas, borda/sublinhado, historico, item unico, dados vazios e console sem erros.');
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
