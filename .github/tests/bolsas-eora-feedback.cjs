const {chromium, expect} = require('@playwright/test');
const assert = require('node:assert/strict');
const path = require('node:path');
const {render, context} = require('./bolsas-eora-harness.cjs');
const base = 'http://127.0.0.1:4175';
const output = process.env.BE_VALIDATION_DIR || 'C:/Temp/eora-bolsas-validation';
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';

(async () => {
    const browser = await chromium.launch({headless: true, executablePath});
    try {
        const page = await browser.newPage({viewport: {width: 1440, height: 1000}, deviceScaleFactor: 2});
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        const initial = context();
        await page.route(base + '/?feedback*', route => {
            const small = new URL(route.request().url()).searchParams.has('small');
            const data = {...initial, settings: {...initial.settings, bolsas_eora_2_split_enabled: true,
                bolsas_eora_community: small ? initial.settings.bolsas_eora_community.slice(0, 2) : initial.settings.bolsas_eora_community,
            }};
            return route.fulfill({contentType: 'text/html; charset=utf-8', body: '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0;padding-top:90px;font-family:Arial}.js-head-main{position:fixed;top:0;height:90px;width:100%;background:white;z-index:10}</style><header class="js-head-main">EORA</header>' + render('snipplets/bolsas-eora/index.tpl', data)});
        });
        const idle = () => expect(page.locator('[data-be-results]')).toHaveAttribute('aria-busy', 'false');
        for (const width of [320, 390, 767, 768, 1440, 1920]) {
            await page.setViewportSize({width, height: 1000});
            await page.goto(base + '/?feedback');
            await idle();
            assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'sem overflow em ' + width);
            if (width < 768) {
                await expect(page.locator('[data-be-mobile-banners] .be-split')).toHaveCount(2);
                await expect(page.locator('[data-be-catalog] > .be-split')).toHaveCount(0);
                for (const selector of ['.be-models', '.be-best', '.be-gallery--community', '.be-gallery--categories', '.be-mobile-banners']) {
                    const section = page.locator(selector);
                    assert(await section.locator('[data-be-track]').evaluate(track => {
                        const viewport = track.getBoundingClientRect();
                        return Array.from(track.children).some(item => {
                            const rect = item.getBoundingClientRect();
                            return rect.left < viewport.right - 8 && rect.right > viewport.right + 8;
                        });
                    }), selector + ': proxima imagem parcialmente visivel em ' + width);
                    await section.locator('[data-be-next]').click();
                    await expect.poll(() => section.locator('[data-be-track]').evaluate(track => {
                        const index = Number(getComputedStyle(track.parentElement).getPropertyValue('--be-visible'));
                        const rect = track.children[index].getBoundingClientRect();
                        const viewport = track.getBoundingClientRect();
                        return rect.left >= viewport.left - 2 && rect.right <= viewport.right + 2;
                    })).toBe(true);
                    await section.locator('.be-dot').last().click();
                    await expect(section.locator('[data-be-next]')).toBeDisabled();
                    await expect.poll(() => section.locator('[data-be-track]').evaluate(track => {
                        return Math.abs(track.lastElementChild.getBoundingClientRect().right - track.getBoundingClientRect().right);
                    })).toBeLessThan(3);
                    await section.locator('.be-dot').first().click();
                    await expect(section.locator('[data-be-prev]')).toBeDisabled();
                }
                const photo = await page.locator('.be-gallery--community .be-banner').first().boundingBox();
                assert(photo.width < width / 2 && Math.abs(photo.height - photo.width) < 1, 'comunidade compacta e quadrada');
                if (width === 390) {
                    await page.locator('.be-gallery--community').screenshot({path: path.join(output, 'feedback-community-mobile.png')});
                    await page.locator('.be-mobile-banners').screenshot({path: path.join(output, 'feedback-banners-mobile.png')});
                }
            } else {
                const model = await page.locator('.be-model img').first().boundingBox();
                assert(model.width <= 222.1, 'filtros compactos no desktop');
                await expect(page.locator('[data-be-mobile-banners]')).toBeHidden();
                await expect(page.locator('[data-be-catalog] > .be-split')).toHaveCount(2);
            }
            for (const motion of ['no-preference', 'reduce']) {
                await page.emulateMedia({reducedMotion: motion});
                await page.locator('[data-be-tag="maxivertice"]').click();
                await idle();
                await expect.poll(() => page.locator('[data-be-toolbar]').evaluate(el => el.getBoundingClientRect().top)).toBeGreaterThanOrEqual(100);
                await expect.poll(() => page.locator('[data-be-toolbar]').evaluate(el => el.getBoundingClientRect().top)).toBeLessThan(115);
                await expect(page.locator('[data-be-reset]')).toBeInViewport();
                await expect(page.locator('[data-be-result-title]')).toBeFocused();
                const images = page.locator('[data-be-results-grid] .be-product').first().locator('img');
                assert(await images.evaluateAll(nodes => nodes.every(img => getComputedStyle(img).objectFit === 'contain')), 'foto principal e hover sem corte');
                await expect.poll(() => images.first().evaluate(img => img.complete && img.naturalWidth > 0)).toBe(true);
            }
            console.log('PASS feedback em ' + width + 'px: layout, banners, carrosseis, rolagem e imagens.');
        }
        // A faixa deve voltar ao local original ao cruzar o breakpoint.
        await page.setViewportSize({width: 390, height: 844});
        await expect(page.locator('[data-be-mobile-banners] .be-split')).toHaveCount(2);
        await page.setViewportSize({width: 1440, height: 1000});
        await expect(page.locator('[data-be-catalog] > .be-split')).toHaveCount(2);
        await expect(page.locator('[data-be-mobile-banners] .be-split')).toHaveCount(0);

        // Sem mais fotos, a comunidade nao oferece uma navegacao vazia.
        await page.setViewportSize({width: 390, height: 844});
        await page.goto(base + '/?feedback&small');
        const community = page.locator('.be-gallery--community');
        await expect(community.locator('[data-be-controls]')).toBeHidden();
        assert.deepEqual(errors, []);
    } finally { await browser.close(); }
})().catch(error => { console.error(error); process.exitCode = 1; });
