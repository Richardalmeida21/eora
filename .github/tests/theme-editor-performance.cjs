const fs = require('node:fs');
const path = require('node:path');
const assert = require('node:assert/strict');
const {chromium, expect} = require('@playwright/test');
const Twig = require('twig');
require('./bolsas-eora-harness.cjs');

const root = path.resolve(__dirname, '../..');
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';
const styles = `body{margin:0}figure{margin:0}.d-none{display:none}.embed-responsive{position:relative;height:220px}.js-video-image{height:220px}.js-play-button{display:block;height:40px}.spacer{height:1600px}@media(min-width:768px){.d-md-block{display:block}.d-md-none{display:none}}`;
const files = ['snipplets/home/home-franqueados.tpl', 'snipplets/home/home-banner-video-horizontal.tpl'];
Twig.twig({id: 'snipplets/banner-floating-button.tpl', data: read('snipplets/banner-floating-button.tpl'), allowInlineIncludes: true});
const templates = files.map(file => Twig.twig({data: read(file), allowInlineIncludes: true, rethrow: true}));
function render(index, mode, hidden = false) {
    return templates[index].render({store: {name: 'Eora'}, settings: {
        accent_color: '#000000', franqueados_show: !hidden,
        franqueados_gallery_video_embed: 'https://vimeo.com/1132299121',
        franqueados_gallery_video_embed_mobile: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        franqueados_gallery_video_type: mode, banner_video_horizontal: true,
        banner_video_horizontal_embed: 'https://vimeo.com/1132299121',
        banner_video_horizontal_embed_mobile: 'https://www.youtube.com/watch?v=dQw4w9WgXcQ',
        banner_video_horizontal_type: mode,
    }});
}
function fullscreenScript(source) {
    return source.slice(source.indexOf('    function forceSellyFullscreen()'), source.indexOf('    function interceptWishlistToNewsletter()'));
}

(async () => {
    const browser = await chromium.launch({headless: true, executablePath});
    const errors = [];
    const page = await browser.newPage({viewport: {width: 1440, height: 900}});
    page.on('pageerror', error => errors.push(error.message));
    await page.route('**/*', route => route.fulfill({contentType: 'text/html', body: '<!doctype html><title>Player fixture</title>'}));
    try {
        for (let index = 0; index < templates.length; index++) {
            await page.setViewportSize({width: 1440, height: 900});
            await page.setContent('<style>' + styles + '</style><div class="spacer"></div>' + render(index, 'autoplay'));
            await page.waitForTimeout(1200);
            assert.equal(await page.locator('iframe').count(), 0, 'fora da tela nao carrega players');
            await page.locator('[data-video-type="desktop"]').scrollIntoViewIfNeeded();
            await expect(page.locator('[data-video-type="desktop"] iframe')).toHaveCount(1);
            await expect(page.locator('[data-video-type="mobile"] iframe')).toHaveCount(0);
            assert.match(await page.locator('iframe').getAttribute('src'), /player\.vimeo\.com.*autoplay=1/);
            await page.setViewportSize({width: 390, height: 844});
            await page.locator('[data-video-type="mobile"]').scrollIntoViewIfNeeded();
            await expect(page.locator('[data-video-type="mobile"] iframe')).toHaveCount(1);
            assert.match(await page.locator('[data-video-type="mobile"] iframe').getAttribute('src'), /youtube\.com.*autoplay=1/);
            await page.evaluate(() => document.dispatchEvent(new Event('DOMContentLoaded')));
            await page.waitForTimeout(1200);
            assert.equal(await page.locator('iframe').count(), 2, 'reinicializar nao duplica os players');

            await page.setViewportSize({width: 1440, height: 900});
            await page.setContent('<style>' + styles + '</style>' + render(index, 'sound'));
            assert.equal(await page.locator('iframe').count(), 0, 'modo por clique preservado');
            await page.locator('[data-video-type="desktop"] .js-play-button').click();
            await expect(page.locator('[data-video-type="desktop"] iframe')).toHaveCount(1);
            await expect(page.locator('[data-video-type="mobile"] iframe')).toHaveCount(0);
            await page.setViewportSize({width: 390, height: 844});
            await page.locator('[data-video-type="mobile"] .js-play-button').click();
            await expect(page.locator('[data-video-type="mobile"] iframe')).toHaveCount(1);
        }
        await page.setViewportSize({width: 1440, height: 900});
        await page.setContent('<style>' + styles + '</style>' + render(0, 'autoplay', true));
        await page.waitForTimeout(650);
        assert.equal(await page.locator('iframe').count(), 0, 'secao desativada nao carrega players');
        await page.locator('.section-franqueados').evaluate(el => el.style.display = '');
        await expect(page.locator('[data-video-type="desktop"] iframe')).toHaveCount(1);
        console.log('PASS videos: visibilidade, desktop/mobile, Vimeo/YouTube, autoplay, clique e reinicializacao.');

        await page.evaluate(() => { delete window.IntersectionObserver; });
        await page.setContent('<style>' + styles + '</style><div class="spacer"></div>' + render(0, 'autoplay') + render(1, 'autoplay'));
        await page.waitForTimeout(3200);
        assert.equal(await page.locator('iframe').count(), 0);
        await page.locator('[data-video-type="desktop"]').first().scrollIntoViewIfNeeded();
        await expect(page.locator('[data-video-type="desktop"]').first().locator('iframe')).toHaveCount(1);
        await page.locator('[data-video-type="desktop"]').last().scrollIntoViewIfNeeded();
        await expect(page.locator('[data-video-type="desktop"]').last().locator('iframe')).toHaveCount(1);
        await expect(page.locator('[data-video-type="mobile"] iframe')).toHaveCount(0);
        console.log('PASS videos: fallback sem IntersectionObserver.');

        async function prepareWishlist() {
            await page.setContent('<h3>Produtos</h3><div id="noise"></div>');
            await page.evaluate(() => {
                window.headingScans = 0;
                document.getElementsByTagName = function(name) {
                    if (name === 'h3') window.headingScans++;
                    return Document.prototype.getElementsByTagName.call(this, name);
                };
            });
        }
        await page.goto('about:blank');
        await prepareWishlist();
        await page.addScriptTag({content: fullscreenScript(read('static/js/store.js.tpl'))});
        const initialScans = await page.evaluate(() => window.headingScans);
        await page.waitForTimeout(400);
        assert.equal(await page.evaluate(() => window.headingScans), initialScans, 'nenhuma varredura periodica');
        await page.locator('#noise').evaluate(el => {
            for (let i = 0; i < 100; i++) el.appendChild(document.createElement('span'));
        });
        await page.waitForTimeout(100);
        assert.equal(await page.evaluate(() => window.headingScans), initialScans, 'mudancas alheias ao modal nao varrem os titulos');
        await page.evaluate(() => {
            const modal = document.createElement('div');
            modal.id = 'main-modal';
            modal.innerHTML = '<div class="absolute max-w-[900px]"><div><h3>Lista de desejos</h3><div class="overflow-auto">Produto</div></div></div>';
            document.body.appendChild(modal);
        });
        const card = page.locator('#main-modal > div');
        await expect(card).toHaveCSS('position', 'fixed');
        assert.equal(await card.evaluate(el => el.style.width), '100vw');
        await card.evaluate(el => el.style.cssText = '');
        await expect(card).toHaveCSS('position', 'fixed');
        await page.locator('#main-modal').evaluate(el => el.remove());
        await page.evaluate(() => {
            const wrapper = document.createElement('div');
            wrapper.innerHTML = '<div class="absolute z-10"><h3>Lista de desejos</h3></div>';
            document.body.appendChild(wrapper);
        });
        await expect(page.locator('.absolute.z-10')).toHaveCSS('position', 'fixed');
        console.log('PASS favoritos: 0 varreduras periodicas com pagina parada, modal assincrono e fallback preservados.');

        await page.goto('about:blank');
        await page.setContent('<div class="block-actions-links"></div>');
        // Fixture for the DOM helper supplied by Nuvemshop in the real storefront.
        await page.evaluate(() => {
            window.jQueryNuvem = function query(value) {
                const nodes = typeof value === 'string' ? Array.from(document.querySelectorAll(value)) : Array.isArray(value) ? value : [value];
                return {
                    length: nodes.length,
                    find: selector => query(nodes.flatMap(node => Array.from(node.querySelectorAll(selector)))),
                    closest: selector => query(nodes.map(node => node.closest(selector)).filter(Boolean)),
                    hasClass: name => Boolean(nodes[0] && nodes[0].classList.contains(name)),
                    addClass: names => nodes.forEach(node => node.classList.add(...names.split(' '))),
                    attr: (name, value) => nodes.forEach(node => node.setAttribute(name, value)),
                    prepend: widget => nodes.forEach(node => node.prepend(widget.node)),
                    node: nodes[0],
                };
            };
        });
        const store = read('static/js/store.js.tpl');
        const moveWidget = store.slice(store.indexOf('    function moveWishlistWidget()'), store.indexOf('    // Nested Mega Menu Toggle (Desktop)'));
        await page.addScriptTag({content: moveWidget + '\nmoveWishlistWidget();'});
        await page.evaluate(() => {
            const wrapper = document.createElement('div');
            wrapper.innerHTML = '<button id="selly-wishlist-widget">Favoritos</button>';
            document.body.appendChild(wrapper);
        });
        await expect(page.locator('.block-actions-links > #selly-wishlist-widget')).toHaveCount(1);
        await page.locator('#selly-wishlist-widget').evaluate(el => el.remove());
        await page.evaluate(() => {
            document.querySelector('.block-actions-links').remove();
            const widget = document.createElement('button');
            widget.id = 'selly-wishlist-widget';
            document.body.appendChild(widget);
        });
        await page.waitForTimeout(100);
        await page.evaluate(() => {
            const header = document.createElement('div');
            header.className = 'block-actions-links';
            document.body.appendChild(header);
        });
        await expect(page.locator('.block-actions-links > #selly-wishlist-widget')).toHaveCount(1);
        await page.locator('#selly-wishlist-widget').evaluate(el => el.remove());
        await page.evaluate(() => document.body.appendChild(document.createElement('button')));
        await page.locator('body > button').evaluate(el => el.id = 'selly-wishlist-widget');
        await expect(page.locator('.block-actions-links > #selly-wishlist-widget')).toHaveCount(1);
        console.log('PASS widget favoritos: insercao aninhada, reinsercao, cabecalho e ID tardios.');
        assert.deepEqual(errors, []);
    } finally {
        await browser.close();
    }
})().catch(error => { console.error(error); process.exitCode = 1; });
