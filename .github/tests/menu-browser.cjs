const assert = require('node:assert/strict');
const fs = require('node:fs');
const {chromium} = require('playwright');
const {startServer} = require('./menu-harness.cjs');
(async () => {
    const server = await startServer(0);
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    const base = 'http://127.0.0.1:' + server.address().port;
    const errors = [];
    const page = await browser.newPage({viewport: {width: 1440, height: 1000}, reducedMotion: 'reduce'});
    page.on('pageerror', error => errors.push(error.message));
    const out = 'C:/Temp/eora-menu-preview';
    fs.mkdirSync(out, {recursive: true});
    async function decoded() { await page.locator('img:visible').evaluateAll(images => Promise.all(images.map(image => image.decode().catch(() => {})))); }
    try {
        await page.goto(base);
        // Native theme applies transform:scale(1) to .head-main, creating a fixed containing block.
        await page.locator('header').evaluate(el => { el.style.transform = 'scale(1)'; });
        await page.locator('[data-menu-toggle]').click();
        const panelTop = await page.locator('[data-menu-desktop]').evaluate(el => el.getBoundingClientRect().top);
        const headerBottom = await page.locator('header').evaluate(el => el.getBoundingClientRect().bottom);
        assert.ok(Math.abs(panelTop - headerBottom) < 1, 'desktop panel must start at the viewport header bottom even with a transformed header: ' + panelTop + ' vs ' + headerBottom);
        assert.equal(await page.locator('[data-menu-group]:visible').count(), 5);
        assert.equal(await page.locator('[data-menu-group] img:visible').count(), 5);
        assert.equal(await page.locator('[data-menu-toggle]').getAttribute('aria-expanded'), 'true');
        assert.ok(await page.locator('[data-menu-close]').evaluate(el => el === document.activeElement));
        await page.locator('[data-menu-desktop] a').last().focus();
        await page.keyboard.press('Tab');
        assert.ok(await page.locator('[data-menu-close]').evaluate(el => el === document.activeElement));
        await decoded();
        await page.screenshot({path: out + '/desktop.png'});
        await page.keyboard.press('Escape');
        assert.ok(await page.locator('[data-menu-desktop]').isHidden());
        assert.ok(await page.locator('[data-menu-toggle]').evaluate(el => el === document.activeElement));
        await page.getByRole('button', {name: 'Abrir busca', exact: true}).click();
        assert.equal(await page.locator('[data-search-product]').count(), 6);
        async function columns(want) {
            const sizes = await page.locator('[data-search-track]').evaluate(el => ({width: el.clientWidth, card: el.firstElementChild.getBoundingClientRect().width, gap: parseFloat(getComputedStyle(el).columnGap)}));
            assert.ok(Math.abs((sizes.width + sizes.gap) / (sizes.card + sizes.gap) - want) < .02, JSON.stringify(sizes));
        }
        await columns(3);
        await decoded();
        await page.screenshot({path: out + '/search-desktop.png'});
        await page.locator('[data-search-next]').click();
        await page.waitForFunction(() => document.querySelector('[data-search-track]').scrollLeft > 20);
        await page.waitForFunction(() => !document.querySelector('[data-search-prev]').disabled);
        await page.getByRole('button', {name: 'Fechar busca', exact: true}).click();
        for (const width of [320, 390, 768, 1199]) {
            await page.setViewportSize({width, height: 900});
            await page.getByRole('button', {name: 'Abrir menu', exact: true}).click();
            const primary = page.locator('[data-menu-screen="primary"]');
            await page.waitForFunction(() => document.activeElement.closest('[data-menu-screen="primary"]'));
            assert.ok(await primary.isVisible());
            assert.equal(await primary.locator('img').count(), 4);
            const defaults = await primary.locator('img').evaluateAll(images => images.map(i => i.getAttribute('src')));
            await primary.locator('[data-menu-go="secondary"]').click();
            const secondary = page.locator('[data-menu-screen="secondary"]');
            assert.deepEqual(await secondary.locator('img').evaluateAll(images => images.map(i => i.getAttribute('src'))), defaults);
            for (const key of ['shop', 'favorites', 'warranty', 'new', 'community']) {
                await secondary.locator('[data-menu-go="' + key + '"]').click();
                const screen = page.locator('[data-menu-screen="' + key + '"]');
                assert.ok(await screen.isVisible());
                assert.equal(await screen.locator('img').count(), 4);
                assert.equal(await page.locator('[data-menu-screen]:visible').count(), 1);
                assert.ok(await screen.locator('button').first().evaluate(el => el === document.activeElement));
                if (width === 390 && key === 'favorites') { await decoded(); await page.screenshot({path: out + '/mobile-favorites.png'}); }
                await page.keyboard.press('Escape');
                assert.ok(await secondary.isVisible());
                assert.ok(await secondary.locator('[data-menu-go="' + key + '"]').evaluate(el => el === document.activeElement));
            }
            assert.ok(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'no page overflow at ' + width);
            if (width === 390) { await decoded(); await page.screenshot({path: out + '/mobile.png'}); }
            await page.getByRole('button', {name: 'Fechar menu', exact: true}).click();
            await page.getByRole('button', {name: 'Abrir menu', exact: true}).click();
            assert.ok(await primary.isVisible(), 'reopens at primary level');
            await primary.locator('button').focus();
            await page.keyboard.press('Escape');
            assert.ok(await page.locator('#nav-hamburger').isHidden(), 'primary Escape invokes the native close control');
            await page.waitForFunction(() => document.activeElement.getAttribute('data-toggle') === '#nav-hamburger');
            await page.getByRole('button', {name: 'Abrir busca', exact: true}).click();
            assert.equal(await page.locator('[data-search-track]').evaluate(el => el.scrollLeft), 0, 'search reopens at the first selected product');
            await columns(2);
            if (width === 390) { await decoded(); await page.screenshot({path: out + '/search-mobile.png'}); }
            await page.getByRole('button', {name: 'Fechar busca', exact: true}).click();
        }
        await page.setViewportSize({width: 1440, height: 1000});
        await page.locator('[data-menu-toggle]').click();
        await page.setViewportSize({width: 390, height: 844});
        await page.waitForFunction(() => document.querySelector('[data-menu-desktop]').hidden);
        assert.ok(await page.locator('[data-menu-desktop]').isHidden(), 'resize releases the desktop panel');
        assert.ok(!await page.locator('body').evaluate(el => el.classList.contains('eora-menu-open')));
        await page.goto(base + '/?empty=1');
        await page.getByRole('button', {name: 'Abrir menu', exact: true}).click();
        assert.equal(await page.locator('[data-eora-menu="mobile"] img').count(), 0);
        assert.deepEqual(errors, []);
        console.log('PASS browser: desktop dialog/focus, 5 mobile sections, return/reopen, 320/390/768/1199/1440px, search 3/2 columns and paging, empty uploads, no JS errors.');
    } finally { await browser.close(); await new Promise(resolve => server.close(resolve)); }
})().catch(error => { console.error(error); process.exitCode = 1; });
