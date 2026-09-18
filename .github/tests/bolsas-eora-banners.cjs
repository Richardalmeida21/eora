const assert = require('node:assert/strict');
const path = require('node:path');
const {chromium, expect} = require('@playwright/test');
const {context, render} = require('./bolsas-eora-harness.cjs');
const base = 'http://127.0.0.1:4175';
const output = process.env.BE_VALIDATION_DIR || 'C:/Temp/eora-bolsas-validation';
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';

(async () => {
    const browser = await chromium.launch({headless: true, executablePath});
    try {
        const page = await browser.newPage();
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        const initial = context();
        const banners = [
            {link: 'maxivertice'},
            {image: '/fixtures/image-5.webp', link: 'minivertice', title: 'Primeiro banner'},
            {image: '/fixtures/image-4.webp', link: ' MAXIVERTICE ', title: 'Banner Maxi'},
            {image: '/fixtures/image-3.webp', link: 'maxivertice', title: 'Duplicado'},
        ];
        await page.route(base + '/**', route => {
            const url = new URL(route.request().url());
            if (url.pathname !== '/') return route.continue();
            const list = url.searchParams.has('no-banners') ? [] : url.searchParams.has('reordered') ? [banners[2], banners[1]] : banners;
            const data = {...initial, settings: {...initial.settings, bolsas_eora_banners: list}};
            return route.fulfill({contentType: 'text/html; charset=utf-8', body: '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0;font-family:Arial}</style>' + render('snipplets/bolsas-eora/index.tpl', data)});
        });
        const banner = page.locator('[data-be-results-grid] [data-be-catalog-banner]');
        const cards = page.locator('[data-be-results-grid] [data-be-product]');
        const idle = () => expect(page.locator('[data-be-results]')).toHaveAttribute('aria-busy', 'false');
        async function checkBanner(title) {
            await expect(banner).toHaveCount(1);
            await expect(banner.locator('img')).toHaveAttribute('alt', title);
            assert.equal(await banner.locator('a').count(), 0, 'tag do banner nao vira link');
        }
        async function checkLayout(width) {
            const geometry = await page.locator('[data-be-results-grid]').evaluate(grid => {
                const rect = el => {const r = el.getBoundingClientRect(); return {x:r.x,y:r.y,right:r.right,bottom:r.bottom,width:r.width,height:r.height};};
                return {grid:rect(grid), banner:rect(grid.querySelector('[data-be-catalog-banner]')), products:Array.from(grid.querySelectorAll('[data-be-product]')).map(rect)};
            });
            if (width >= 768) {
                assert(Math.abs(geometry.banner.x - geometry.products[2].x) < 2, 'banner nas duas colunas da direita');
                assert(Math.abs(geometry.banner.y - geometry.products[8].y) < 2, 'banner apos oito produtos');
                assert(Math.abs(geometry.banner.bottom - geometry.products[11].bottom) < 2, 'mesma altura que duas linhas de produtos');
                assert(geometry.products[9].right <= geometry.banner.x, 'produtos ao lado, sem sobreposicao');
            } else {
                assert(Math.abs(geometry.banner.width - geometry.grid.width) < 2, 'banner com largura da grade no celular');
                assert(geometry.banner.y >= geometry.products[3].bottom, 'banner depois dos primeiros quatro produtos');
                assert(geometry.products[4].y >= geometry.banner.bottom, 'produtos seguintes depois do banner');
            }
            assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'sem overflow');
        }
        for (const width of [1440, 390, 320, 768]) {
            await page.setViewportSize({width, height: 1000});
            await page.goto(base);
            await idle();
            await checkBanner('Primeiro banner');
            await page.locator('[data-be-tag="maxivertice"]').click();
            await idle();
            await checkBanner('Banner Maxi');
            await expect(cards).toHaveCount(width < 768 ? 6 : 12);
            await checkLayout(width);
            if (width === 1440 || width === 390) await page.locator('[data-be-results-grid]').screenshot({path:path.join(output, 'banners-by-model-' + width + '.png')});
            await page.locator('[data-be-more]').click();
            await idle();
            await checkBanner('Banner Maxi');
            const ids = await cards.evaluateAll(nodes => nodes.map(node => node.dataset.beProduct));
            assert.equal(new Set(ids).size, ids.length);
            await expect(page.locator('[data-be-status]')).toContainText(ids.length + ' produtos');
            await page.locator('[data-be-tag="minivertice"]').click();
            await idle();
            await checkBanner('Primeiro banner');
            await expect(cards).toHaveCount(1);
            await expect(page.locator('[data-be-status]')).toHaveText('1 produto encontrado');
            await page.goBack(); await idle(); await checkBanner('Banner Maxi');
            await page.locator('[data-be-reset]').click(); await idle(); await checkBanner('Primeiro banner');
            await page.goto(base + '/?tag=modelo-2'); await idle();
            await expect(banner).toHaveCount(0);
            await expect(page.locator('[data-be-status]')).toContainText('Nenhum produto');
            console.log('PASS banners ' + width + 'px: primeiro, tag normalizada, duplicado, sem correspondencia, grade dividida, paginacao, contagem e historico.');
        }
        await page.goto(base + '/?tag=maxivertice'); await idle(); await checkBanner('Banner Maxi');
        await page.setViewportSize({width:390,height:1000}); await checkLayout(390);
        await page.setViewportSize({width:1440,height:1000}); await checkLayout(1440);
        await page.locator('[data-be-open-filters]').click();
        await page.locator('[name="be_model"]').selectOption('minivertice');
        await page.locator('[data-be-filter-form] [type="submit"]').click();
        await idle(); await checkBanner('Primeiro banner');
        await page.goto(base + '/?no-banners&tag=maxivertice'); await idle();
        await expect(banner).toHaveCount(0); await expect(cards).toHaveCount(12);
        await page.goto(base + '/?reordered'); await idle(); await checkBanner('Banner Maxi');
        assert.deepEqual(errors, []);
        console.log('PASS link direto, resize, seletor do painel, galeria vazia, reordenacao e zero erros JS.');
    } finally { await browser.close(); }
})().catch(error => {console.error(error); process.exitCode = 1;});
