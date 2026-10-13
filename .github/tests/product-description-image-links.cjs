const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {chromium} = require('playwright');

const root = path.resolve(__dirname, '../..');
const file = 'static/js/product-description-image-links.js.tpl';
const source = fs.existsSync(path.join(root, file)) ? fs.readFileSync(path.join(root, file), 'utf8') : '';
const read = name => fs.readFileSync(path.join(root, name), 'utf8');
const libraries = read('static/js/external-no-dependencies.js.tpl');
const swiper = libraries.slice(libraries.indexOf('!function(e,t)'), libraries.indexOf('\nfunction createSwiper('));
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';
const image = (name, link, target = '') => `${link ? `<a href="${link}" ${target ? `target="${target}"` : ''} title="Ver produto">` : ''}<img src="/images/${name}.webp" alt="Foto ${name}" loading="lazy">${link ? '</a>' : ''}`;
const table = (key, content, leadingTitle = false) => `<table><tbody>${leadingTitle ? '<tr><td>titulo banners + texto</td><td colspan="3">Titulo</td></tr>' : ''}<tr><td>${key}</td>${content}</tr><tr><td>Texto</td><td>Detalhes</td><td>Mais detalhes</td></tr></tbody></table>`;
const clients = content => `<table><tbody><tr><td>clientes_eora</td></tr><tr>${content.map((_, i) => `<td>foto_${i + 1}</td>`).join('')}</tr><tr>${content.map(html => `<td>${html}</td>`).join('')}</tr></tbody></table>`;
const original = content => `<div id="single-product"><div class="js-product-description-base" style="display:none">${content}</div><form id="product_form"><input name="quantity" value="2"><button class="js-addtocart" type="button">Comprar</button></form></div>`;
const destinations = '<div data-store="home-institutional-message">Sobre a Eora</div><div class="product-sections"><section class="js-banners-alternados-product"></section><div class="js-swiper-banners-experiencia"><section class="js-banners-experiencia-eora"></section></div></div>';
const styles = 'body{margin:0}.eora-clientes-inner{width:100%}.eora-clientes-slide{width:220px;position:relative;padding-bottom:125%}.banner-img{position:relative;width:220px;height:160px}.banner-img img{position:absolute;inset:0;width:100%;height:100%;object-fit:cover}.plain{width:220px}.plain img{display:block;width:100%;height:160px}';
function helper(name, source) {
    const start = source.indexOf('    function ' + name + '(');
    const next = source.indexOf('\n    function ', start + 10);
    assert(start >= 0 && next > start, name);
    return source.slice(start, next);
}
function legacy(file) {
    const raw = read(file);
    return 'var eoraConfigTableCache=[];\n' + ['snapshotConfigTables', 'criarBlocoTitulo', 'normalizeConfigKey', 'isTitleKey', 'getTableTitleText', 'syncSectionTitleBefore', 'findConfigTable', 'buildClientesEora', 'buildBannersAlternadosProduct'].map(name => helper(name, raw)).join('\n');
}
const errors = [];
const requests = [];
async function fixture(browser, content, options = {}) {
    const page = await browser.newPage({viewport: {width: options.width || 1440, height: 900}, hasTouch: options.width === 390, isMobile: options.width === 390,
        ...(options.width === 390 ? {userAgent: 'Mozilla/5.0 (Linux; Android 13; Pixel 7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/134.0.0.0 Mobile Safari/537.36'} : {})});
    page.on('pageerror', e => errors.push(e.message));
    await page.context().route('**/*', route => {
        requests.push(route.request().url());
        if (route.request().isNavigationRequest()) return route.fulfill({contentType: 'text/html', body: '<title>Destino</title>'});
        if (route.request().resourceType() === 'image') return route.fulfill({contentType: 'image/png', body: Buffer.from('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/l9sAAAAASUVORK5CYII=', 'base64')});
        return route.abort();
    });
    await page.setContent('<!doctype html><html><head><meta name="viewport" content="width=device-width, initial-scale=1"><base href="https://fixture.eora.test/"><style>' + styles + '</style></head><body>' + original(content) + destinations + (options.extra || '') + '</body></html>');
    await page.addScriptTag({content: swiper});
    if (source && options.central !== false) await page.addScriptTag({content: source});
    return page;
}
async function link(page, selector, href, target = null) {
    await page.waitForFunction(({selector, href, target}) => {
        const a = document.querySelector(selector)?.closest('a');
        return a && a.getAttribute('href') === href && (target === null || a.getAttribute('target') === target);
    }, {selector, href, target}, {timeout: 2000});
}
const tick = page => page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve))));

(async () => {
    const browser = await chromium.launch({headless: true, executablePath, args: ['--touch-events=enabled']});
    const report = [];
    try {
        for (const name of ['maxivertice.html', 'hobo.html']) {
            for (const width of [1440, 390]) {
                const content = clients([image('same', '/produtos/nova2/', '_blank'), image('unlinked'), image('third'), image('fourth'), image('fifth')]) + table('banners_alternados', '<td>' + image('same', '/outro-destino/') + '</td><td>' + image('second', '/segunda/') + '</td>', name === 'hobo.html');
                const page = await fixture(browser, content, {width});
                await page.addScriptTag({content: legacy(name)});
                await page.evaluate(() => { snapshotConfigTables(); document.querySelector('.js-product-description-base').remove(); buildClientesEora(); buildBannersAlternadosProduct(); });
                await link(page, '.eora-clientes-slide img', '/produtos/nova2/', '_blank');
                await link(page, '.banner-alternado-item img', '/outro-destino/');
                assert.equal(await page.locator('.eora-clientes-slide').nth(1).locator('a').count(), 0, 'foto sem link preservada');
                assert.equal(await page.locator('a a').count(), 0, 'nenhum link aninhado');
                assert.equal(await page.locator('a[data-eora-description-image-link]').first().getAttribute('rel'), 'noopener noreferrer');
                const before = await page.locator('.banner-img img').first().boundingBox();
                await page.evaluate(() => buildBannersAlternadosProduct());
                await link(page, '.banner-alternado-item img', '/outro-destino/');
                assert.deepEqual(await page.locator('.banner-img img').first().boundingBox(), before, 'remontagem sem alterar dimensoes');
                const openPages = page.context().pages().length;
                const swipeBox = await page.locator('.eora-clientes-slide img').first().boundingBox();
                if (width === 390) {
                    const session = await page.context().newCDPSession(page);
                    const startX = swipeBox.x + swipeBox.width * .9;
                    const endX = swipeBox.x + 2;
                    await session.send('Input.dispatchTouchEvent', {type: 'touchStart', touchPoints: [{x: startX, y: swipeBox.y + 40}]});
                    for (let step = 1; step <= 12; step++) {
                        await session.send('Input.dispatchTouchEvent', {type: 'touchMove', touchPoints: [{x: startX + (endX - startX) * step / 12, y: swipeBox.y + 40}]});
                        await page.waitForTimeout(16);
                    }
                    await session.send('Input.dispatchTouchEvent', {type: 'touchEnd', touchPoints: []});
                    await session.detach();
                } else {
                    await page.mouse.move(swipeBox.x + swipeBox.width * .85, swipeBox.y + 40);
                    await page.mouse.down();
                    await page.mouse.move(swipeBox.x + 5, swipeBox.y + 40, {steps: 12});
                    await page.mouse.up();
                }
                await page.waitForTimeout(350);
                assert.equal(page.context().pages().length, openPages, 'arrastar uma foto vinculada nao abre o link');
                assert((await page.evaluate(() => document.querySelector('.js-eora-clientes-swiper').swiper.activeIndex)) > 0, 'carrossel realmente avanca ao arrastar ' + name + ' ' + width + ' ' + JSON.stringify(await page.evaluate(() => { const s = document.querySelector('.js-eora-clientes-swiper').swiper; return {translate:s.translate,active:s.activeIndex,events:s.touchEvents,size:s.size,slides:s.slides.length,locked:s.isLocked,width:window.innerWidth}; })));
                await page.evaluate(() => document.querySelector('.js-eora-clientes-swiper').swiper.slideTo(0, 0));
                await tick(page);
                const [popup] = await Promise.all([
                    page.waitForEvent('popup', {timeout: 5000}),
                    page.locator('.eora-clientes-slide img').first().click()
                ]);
                await popup.waitForLoadState();
                assert.equal(popup.url(), 'https://fixture.eora.test/produtos/nova2/');
                await popup.close();
                assert.equal(await page.locator('#product_form [name="quantity"]').inputValue(), '2');
                report.push(`${name} ${width}: link, nova janela, foto sem link, remontagem e dimensoes`);
                await page.close();
            }
        }

        const content = table('banners_experiencia_eora', '<td>' + image('shared', '/experiencia/') + '</td>') + table('banners_alternados', '<td>' + image('shared', '/alternado/', '_self') + '</td>');
        const shared = read('static/js/store.js.tpl');
        const start = shared.indexOf('    const extractors = {');
        const end = shared.indexOf('    function extrairPorPalavra(', start);
        const page = await fixture(browser, content);
        await page.addScriptTag({content: shared.slice(start, end).replace(/{#[\s\S]*?#}/g, '') + '\nwindow.fixtureExtractors=extractors;'});
        await page.evaluate(() => { const tables = document.querySelectorAll('.js-product-description-base table'); fixtureExtractors.banners_experiencia_eora(tables[0]); fixtureExtractors.banners_alternados(tables[1]); });
        await link(page, '.js-banners-experiencia-eora img', '/experiencia/');
        await link(page, '.js-banners-alternados-product img', '/alternado/', '_self');
        await page.evaluate(() => fixtureExtractors.banners_alternados(document.querySelectorAll('.js-product-description-base table')[1]));
        await link(page, '.js-banners-alternados-product img', '/alternado/');
        report.push('extratores reais compartilhados: links distintos da mesma imagem e remontagem');
        await page.close();

        const ambiguous = await fixture(browser, clients([image('duplicate', '/a/'), image('duplicate', '/b/'), image('unsafe', 'javascript:alert(1)'), image('existing', '/source/')]));
        await ambiguous.evaluate(() => {
            document.body.insertAdjacentHTML('beforeend', '<section class="eora-clientes-section"><div class="plain"><img src="/images/duplicate.webp"><img src="/images/unsafe.webp"><a href="/native/"><img src="/images/existing.webp"></a></div></section><div class="product-image-column"><img src="/images/existing.webp"></div>');
        });
        await tick(ambiguous);
        assert.equal(await ambiguous.locator('a[data-eora-description-image-link]').count(), 0, 'ambiguidade, URL invalida e links existentes nao sobrescritos');
        assert.equal(await ambiguous.locator('.eora-clientes-section a').getAttribute('href'), '/native/');
        report.push('links existentes, galeria de zoom, URLs invalidas e imagens ambiguas preservados');
        await ambiguous.close();

        const replacement = await fixture(browser, clients([image('replace', '/antigo/'), image('changed', '/foto-alterada/') , image('no-link')]));
        await replacement.evaluate(() => document.body.insertAdjacentHTML('beforeend', '<section class="eora-clientes-section"><div class="plain"><img src="/images/replace.webp" loading="lazy"></div></section>'));
        await link(replacement, '.eora-clientes-section img', '/antigo/');
        const count = await replacement.locator('[data-eora-description-image-link]').count();
        if (source) await replacement.addScriptTag({content: source});
        await tick(replacement);
        assert.equal(await replacement.locator('[data-eora-description-image-link]').count(), count, 'inicializacao repetida nao duplica');
        await replacement.evaluate(() => document.querySelector('.eora-clientes-section img').src = '/images/changed.webp');
        await link(replacement, '.eora-clientes-section img', '/foto-alterada/');
        await replacement.evaluate(() => document.querySelector('.eora-clientes-section img').src = '/images/no-link.webp');
        await replacement.waitForFunction(() => !document.querySelector('.eora-clientes-section img').closest('a'));
        await replacement.evaluate(() => document.querySelector('.eora-clientes-section img').src = '/images/replace.webp');
        await link(replacement, '.eora-clientes-section img', '/antigo/');
        await replacement.evaluate(html => { document.querySelector('#single-product').outerHTML = html; }, original(clients([image('replace', '/novo/', '_blank')])));
        await link(replacement, '.eora-clientes-section img', '/novo/', '_blank');
        await replacement.evaluate(() => document.querySelector('.eora-clientes-section .plain').innerHTML = '<img src="/images/replace.webp" loading="lazy">');
        await link(replacement, '.eora-clientes-section img', '/novo/', '_blank');
        report.push('troca dinamica de produto e reinicializacao sem links antigos ou duplicados');
        await replacement.close();

        const fullwidth = await fixture(browser, '', {extra: '<div class="js-product-description-base" style="display:none">' + clients([image('wide', '/wide-old/')]) + '</div>'});
        await fullwidth.evaluate(() => document.body.insertAdjacentHTML('beforeend', '<section class="eora-clientes-section"><div class="plain"><img src="/images/wide.webp"></div></section>'));
        await link(fullwidth, '.eora-clientes-section img', '/wide-old/');
        await fullwidth.evaluate(content => {
            document.querySelector('#single-product').outerHTML = '<div id="single-product"></div>';
            document.querySelectorAll('.js-product-description-base').forEach(node => node.remove());
            document.body.insertAdjacentHTML('beforeend', '<div class="js-product-description-base" style="display:none">' + content + '</div>');
        }, clients([image('wide', '/wide-new/')]));
        await link(fullwidth, '.eora-clientes-section img', '/wide-new/');
        await fullwidth.evaluate(() => {
            document.querySelector('#single-product').outerHTML = '<div id="single-product"></div>';
            document.querySelector('.js-product-description-base').remove();
        });
        await fullwidth.waitForFunction(() => !document.querySelector('.eora-clientes-section img').closest('a'));
        report.push('descricao de largura total fora do produto: troca de destino e produto sem descricao');
        await fullwidth.close();

        for (const width of [1440, 390]) {
            const geometry = await fixture(browser, clients([image('geometry', '/geometry/')]) + table('banners_alternados', '<td>' + image('geometry', '/details/') + '</td>'), {width, central: false});
            await geometry.addScriptTag({content: legacy('maxivertice.html')});
            await geometry.evaluate(() => { snapshotConfigTables(); buildClientesEora(); buildBannersAlternadosProduct(); });
            await tick(geometry);
            const fingerprint = () => geometry.locator('.eora-clientes-section img, .js-banners-alternados-product img').evaluateAll(images => images.map(image => ({attributes: image.getAttributeNames().map(name => [name, image.getAttribute(name)]), box: image.getBoundingClientRect().toJSON(), style: {position: getComputedStyle(image).position, objectFit: getComputedStyle(image).objectFit}})));
            const before = await fingerprint();
            await geometry.evaluate(() => { window.fixtureOriginalImage = document.querySelector('.eora-clientes-section img'); });
            if (source) await geometry.addScriptTag({content: source});
            await link(geometry, '.eora-clientes-section img', '/geometry/');
            assert.deepEqual(await fingerprint(), before, 'mesmas dimensoes, atributos, resolucao e estilo antes/depois ' + width);
            assert.equal(await geometry.evaluate(() => fixtureOriginalImage === document.querySelector('.eora-clientes-section img')), true, 'mesmo elemento de imagem');
            await geometry.locator('.eora-clientes-section a').focus();
            assert.equal(await geometry.evaluate(() => document.activeElement.getAttribute('href')), '/geometry/', 'link acessivel pelo teclado');
            await geometry.close();
        }
        report.push('antes/depois em 1440/390: mesmas imagens, dimensoes, lazy loading e foco por teclado');

        const responsiveSource = '<table><tbody><tr><td>banner_produto</td></tr><tr><td>imagem</td><td>' + image('desktop', '/desktop/') + '</td></tr><tr><td>imagem_mobile</td><td>' + image('mobile', '/mobile/', '_blank') + '</td></tr></tbody></table>';
        const responsive = await fixture(browser, responsiveSource);
        await responsive.evaluate(() => document.body.insertAdjacentHTML('beforeend', '<section class="eora-banner-produto plain"><picture><source media="(max-width: 768px)" srcset="/images/mobile.webp"><img src="/images/desktop.webp" alt="Banner responsivo"></picture></section>'));
        await link(responsive, '.eora-banner-produto img', '/desktop/');
        await responsive.setViewportSize({width: 390, height: 844});
        await link(responsive, '.eora-banner-produto img', '/mobile/', '_blank');
        await responsive.setViewportSize({width: 1440, height: 900});
        await link(responsive, '.eora-banner-produto img', '/desktop/');
        assert.equal(await responsive.locator('a a').count(), 0);
        await responsive.close();
        report.push('banner_produto e picture responsivo: destinos distintos no desktop/celular');

        const unlinked = await fixture(browser, clients([image('no-link')]));
        assert.equal(await unlinked.locator('[data-eora-description-image-link]').count(), 0);
        await unlinked.close();
        assert.deepEqual(errors, []);
        const output = process.env.IMAGE_LINK_VALIDATION_DIR || 'C:/Temp/eora-image-links-validation';
        fs.mkdirSync(output, {recursive: true});
        fs.writeFileSync(path.join(output, 'regression.json'), JSON.stringify({report, errors, requests: requests.length}, null, 2));
        console.log(report.map(line => 'PASS ' + line).join('\n'));
    } finally { await browser.close(); }
})().catch(e => { console.error(e); process.exitCode = 1; });
