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
            {image: '/fixtures/image-5.webp', link: '/destino-mini', title: 'Banner Mini', description: 'minivertice,todos', button: 'Ver mini', color: 'light'},
            {image: '/fixtures/image-4.webp', link: '/destino-maxi-a?campanha=eora', title: 'Banner Maxi A', description: ' MAXIVERTICE '},
            {image: '/fixtures/image-3.webp', link: 'https://example.com/destino-maxi-b', title: 'Banner Maxi B', description: 'maxivertice'},
        ];
        await page.route(base + '/**', route => {
            const url = new URL(route.request().url());
            if (url.pathname !== '/') return route.continue();
            const list = url.searchParams.has('no-banners') ? [] : url.searchParams.has('reordered') ? [banners[1], banners[0]] : banners;
            const showAll = url.searchParams.has('all-multiple');
            const data = {...initial, settings: {
                ...initial.settings,
                bolsas_eora_banners: list.map(banner => ({...banner, description: showAll && !banner.description.includes(',todos') ? banner.description + ',todos' : banner.description})),
            }};
            return route.fulfill({contentType: 'text/html; charset=utf-8', body: '<!doctype html><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><style>body{margin:0;font-family:Arial}</style>' + render('snipplets/bolsas-eora/index.tpl', data)});
        });
        const catalogBanners = page.locator('[data-be-results-grid] [data-be-catalog-banner]');
        const cards = page.locator('[data-be-results-grid] [data-be-product]');
        const idle = () => expect(page.locator('[data-be-results]')).toHaveAttribute('aria-busy', 'false');
        async function checkBanners(titles, destinations) {
            await expect(catalogBanners).toHaveCount(titles.length);
            for (let index = 0; index < titles.length; index++) {
                await expect(catalogBanners.nth(index).locator('img')).toHaveAttribute('alt', titles[index]);
                await expect(catalogBanners.nth(index).locator('a')).toHaveAttribute('href', destinations[index]);
            }
        }
        async function checkLayout(width, bannerCount) {
            await page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve))));
            const geometry = await page.locator('[data-be-results-grid]').evaluate(grid => {
                const rect = el => {const r = el.getBoundingClientRect(); return {x:r.x,y:r.y,right:r.right,bottom:r.bottom,width:r.width,height:r.height};};
                return {
                    grid: rect(grid),
                    columnGap: parseFloat(getComputedStyle(grid).columnGap) || 0,
                    banners: Array.from(grid.querySelectorAll('[data-be-catalog-banner]')).map(rect),
                    products: Array.from(grid.querySelectorAll('[data-be-product]')).map(rect),
                    images: Array.from(grid.querySelectorAll('[data-be-product] .be-product__image')).map(rect),
                };
            });
            assert.equal(geometry.banners.length, bannerCount);
            if (width >= 768) {
                const productOffset = Math.max(0, 3 - bannerCount) * 4;
                geometry.banners.forEach((banner, index) => {
                    const productIndex = productOffset + index * 4;
                    const expectedX = index % 2 ? geometry.grid.x : geometry.grid.x + (geometry.grid.width + geometry.columnGap) / 2;
                    assert(Math.abs(banner.x - expectedX) < 2, 'banners alternam direita e esquerda');
                    if (geometry.products[productIndex] && geometry.images[productIndex + 2]) {
                        assert(Math.abs(banner.y - geometry.products[productIndex].y) < 2, 'banner alinhado ao inicio da linha de produtos');
                        assert(Math.abs(banner.bottom - geometry.images[productIndex + 2].bottom) < 2, 'banner termina com a segunda imagem, sem incluir o segundo preco');
                    }
                });
            } else {
                geometry.banners.forEach((banner, index) => {
                    assert(Math.abs(banner.width - geometry.grid.width) < 2, 'banner com largura da grade no celular');
                    if (index) assert(banner.y >= geometry.banners[index - 1].bottom, 'banners mantem a ordem no celular');
                });
                assert(geometry.banners[0].y >= geometry.products[Math.min(3, geometry.products.length - 1)].bottom, 'primeiro banner depois de quatro produtos');
            }
            assert(await page.evaluate(() => document.documentElement.scrollWidth <= innerWidth), 'sem overflow');
        }
        for (const width of [1440, 390, 320, 768]) {
            await page.setViewportSize({width, height: 1000});
            await page.goto(base);
            await idle();
            await checkBanners(['Banner Mini'], ['/destino-mini']);
            if (width === 1440) {
                const bannerImage = catalogBanners.first().locator('img');
                await expect(bannerImage).toHaveAttribute('src', '/fixtures/image-5.webp');
                await expect(bannerImage).not.toHaveAttribute('srcset', /.+/);
                await expect(bannerImage).not.toHaveAttribute('sizes', /.+/);
                assert.deepEqual(await bannerImage.evaluate(image => ({
                    objectFit: getComputedStyle(image).objectFit,
                    objectPosition: getComputedStyle(image).objectPosition,
                })), {objectFit: 'cover', objectPosition: '50% 50%'});
                const floatingButton = catalogBanners.first().locator('.be-catalog-banner__button');
                await expect(floatingButton).toHaveText(/Ver mini/);
                await expect(floatingButton.locator('svg use')).toHaveAttribute('xlink:href', '#chevron-diagonal');
                await expect(floatingButton.locator('svg use')).toHaveAttribute('href', '#chevron-diagonal');
                const buttonStyle = await floatingButton.evaluate(element => {
                    const style = getComputedStyle(element);
                    return {width: element.getBoundingClientRect().width, padding: style.padding, fontSize: style.fontSize, fontWeight: style.fontWeight, letterSpacing: style.letterSpacing, backdropFilter: style.backdropFilter || style.webkitBackdropFilter};
                });
                assert(buttonStyle.width <= 441, 'CTA respeita a largura maxima de 440px da home');
                assert.equal(buttonStyle.padding, '16px');
                assert.equal(buttonStyle.fontSize, '16px');
                assert.equal(buttonStyle.fontWeight, '500');
                assert.equal(buttonStyle.letterSpacing, '3.2px');
                assert(buttonStyle.backdropFilter.includes('blur(8px)'), 'CTA usa o mesmo blur da home');
            }
            await page.locator('[data-be-tag="maxivertice"]').click();
            await idle();
            await checkBanners(['Banner Maxi A', 'Banner Maxi B'], ['/destino-maxi-a?campanha=eora', 'https://example.com/destino-maxi-b']);
            await expect(cards).toHaveCount(24);
            await checkLayout(width, 2);
            if (width === 1440 || width === 390) await page.locator('[data-be-results-grid]').screenshot({path:path.join(output, 'banners-by-model-' + width + '.png')});
            await expect(page.locator('[data-be-more]')).toBeHidden();
            const ids = await cards.evaluateAll(nodes => nodes.map(node => node.dataset.beProduct));
            assert.equal(new Set(ids).size, ids.length);
            await expect(page.locator('[data-be-status]')).toContainText(ids.length + ' produtos');
            await page.locator('[data-be-tag="minivertice"]').click();
            await idle();
            await checkBanners(['Banner Mini'], ['/destino-mini']);
            await expect(cards).toHaveCount(1);
            await expect(page.locator('[data-be-status]')).toHaveText('1 produto encontrado');
            await page.goBack(); await idle(); await checkBanners(['Banner Maxi A', 'Banner Maxi B'], ['/destino-maxi-a?campanha=eora', 'https://example.com/destino-maxi-b']);
            await page.locator('[data-be-reset]').click(); await idle(); await checkBanners(['Banner Mini'], ['/destino-mini']);
            await page.goto(base + '/?tag=modelo-2'); await idle();
            await expect(catalogBanners).toHaveCount(0);
            await expect(page.locator('[data-be-status]')).toContainText('Nenhum produto');
            console.log('PASS banners ' + width + 'px: Todos configuravel, tags repetidas, alternancia, altura, carga automatica e historico.');
        }
        await page.setViewportSize({width:1440,height:1000});
        await page.goto(base + '/?all-multiple'); await idle();
        await checkBanners(['Banner Mini', 'Banner Maxi A', 'Banner Maxi B'], ['/destino-mini', '/destino-maxi-a?campanha=eora', 'https://example.com/destino-maxi-b']);
        await checkLayout(1440, 3);
        await page.goto(base + '/?tag=maxivertice'); await idle();
        await checkBanners(['Banner Maxi A', 'Banner Maxi B'], ['/destino-maxi-a?campanha=eora', 'https://example.com/destino-maxi-b']);
        await page.setViewportSize({width:390,height:1000}); await checkLayout(390, 2);
        await page.setViewportSize({width:1440,height:1000}); await checkLayout(1440, 2);
        await page.locator('[data-be-open-filters]').click();
        await page.locator('[name="be_model"]').selectOption('minivertice');
        await page.locator('[data-be-filter-form] [type="submit"]').click();
        await idle(); await checkBanners(['Banner Mini'], ['/destino-mini']);
        await page.goto(base + '/?no-banners&tag=maxivertice'); await idle();
        await expect(catalogBanners).toHaveCount(0); await expect(cards).toHaveCount(24);
        await page.goto(base + '/?reordered'); await idle(); await checkBanners(['Banner Mini'], ['/destino-mini']);
        assert.deepEqual(errors, []);
        console.log('PASS multiplos em Todos, link direto, resize, painel, galeria vazia, reordenacao e zero erros JS.');
    } finally { await browser.close(); }
})().catch(error => {console.error(error); process.exitCode = 1;});
