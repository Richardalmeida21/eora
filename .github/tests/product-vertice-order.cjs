const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const {chromium} = require('playwright');

const source = fs.readFileSync(path.resolve(__dirname, '../../vertice.html'), 'utf8');
const start = source.indexOf('    function buildVariantSwatches(');
const end = source.indexOf('    function buildBannerImagemFull(', start);
assert(start >= 0 && end > start);
const builder = source.slice(start, end);
const themeScript = fs.readFileSync(path.resolve(__dirname, '../../static/js/eora-variations.js.tpl'), 'utf8');
const cssStart = source.indexOf('var css = [') + 'var css = '.length;
const cssEnd = source.indexOf("].join('');", cssStart) + "].join('')".length;
const css = vm.runInNewContext(source.slice(cssStart, cssEnd));
// Ordem atual do catálogo; os títulos públicos não incluem a cor.
const catalog = ['vertice', 'vertice1', 'vertice3', 'vertice4', 'vertice6', 'vertice-bordo-mix', 'vertice-croco-rato-mix', 'vertice-detog', 'vertice-marrom-avela-mix'];
const expected = ['vertice', 'vertice-bordo-mix', 'vertice1', 'vertice6', 'vertice3', 'vertice-marrom-avela-mix', 'vertice4', 'vertice-croco-rato-mix', 'vertice-detog'];
const productPath = slug => '/produtos/' + slug + '/';
const items = catalog.map(slug => ({name: 'VÉRTICE', href: 'https://vertice.test' + productPath(slug), url: 'https://images.test/' + slug + '.webp'}));

(async () => {
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        const page = await browser.newPage();
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        await page.route('https://vertice.test/**', route => route.fulfill({contentType: 'text/html', body: '<main><div id="single-product"></div><div class="eora-product-wrap"><div class="eora-product-info"><form><button class="js-addtocart">Comprar</button></form></div></div></main>'}));
        await page.route('https://images.test/**', route => route.fulfill({contentType: 'image/svg+xml', body: '<svg xmlns="http://www.w3.org/2000/svg" width="52" height="52"><rect width="52" height="52" fill="#888"/></svg>'}));
        await page.goto('https://vertice.test/produtos/vertice/');
        await page.addStyleTag({content: css + '.eora-product-info{width:calc(100vw - 40px)!important;max-width:560px!important;box-sizing:border-box}'});
        await page.addScriptTag({content: String.raw`
            var normalizePathname = value => new URL(value, location.href).pathname.replace(/\/+$/, '') + '/';
            var navigateToVariation = (itemPath, href) => { window.clickedVariant = {itemPath, href}; };
            var makePlaceholderThumb = () => 'https://images.test/placeholder.svg';
            ${builder}
            window.renderVariants = items => {
                document.querySelector('.eora-bolsa-vars')?.remove();
                buildVariantSwatches(document.querySelector('.eora-product-info'), items);
            };
        `});
        // O tema inicia antes de o HTML antigo criar a lista de variações.
        await page.addScriptTag({content: themeScript});
        const renderedPaths = () => page.locator('.eora-bolsa-var-item').evaluateAll(nodes => nodes.map(node => node.getAttribute('data-href-path')));
        const expectPaths = async expectedPaths => {
            await page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve))));
            assert.deepEqual(await renderedPaths(), expectedPaths);
        };
        for (const width of [1440, 390]) {
            await page.setViewportSize({width, height: 900});
            for (const current of catalog) {
                await page.evaluate(({items, currentPath}) => {
                    history.replaceState({}, '', currentPath);
                    const before = JSON.stringify(items);
                    window.renderVariants(items);
                    window.variantNodesBeforeSort = Array.from(document.querySelectorAll('.eora-bolsa-var-item'));
                    if (JSON.stringify(items) !== before) throw new Error('Não alterar os dados recebidos do catálogo');
                }, {items, currentPath: productPath(current)});
                await expectPaths(expected.map(productPath));
                assert(await page.evaluate(() => Array.from(document.querySelectorAll('.eora-bolsa-var-item')).every(node => window.variantNodesBeforeSort.includes(node))), 'Mover os elementos existentes preserva seus listeners');
                assert.equal(await page.locator('.eora-active').getAttribute('data-href-path'), productPath(current));
                for (const [first, second] of [['vertice', 'vertice-bordo-mix'], ['vertice1', 'vertice6'], ['vertice3', 'vertice-marrom-avela-mix']]) {
                    const a = await page.locator('[data-href-path="' + productPath(first) + '"]').boundingBox();
                    const b = await page.locator('[data-href-path="' + productPath(second) + '"]').boundingBox();
                    assert(Math.abs(a.y - b.y) < 1 && b.x > a.x, 'Mesmo par deve permanecer lado a lado nas quebras de linha');
                }
                for (const slug of expected) {
                    const swatch = page.locator('[data-href-path="' + productPath(slug) + '"]');
                    assert.equal(await swatch.locator('img').getAttribute('src'), 'https://images.test/' + slug + '.webp');
                    await swatch.click();
                    assert.deepEqual(await page.evaluate(() => window.clickedVariant), {itemPath: productPath(slug), href: 'https://vertice.test' + productPath(slug)});
                }
                assert.equal(await page.locator('.eora-bolsa-vars + form .js-addtocart').count(), 1);
            }
        }
        // Os mesmos produtos tiveram suas URLs alteradas no catálogo.
        const renamed = {
            vertice: 'vertice-bordo-prata', vertice1: 'vertice-preto-dourado',
            vertice3: 'vertice-tabaco-dourado', vertice4: 'vertice-manteiga-mix',
            vertice6: 'vertice-preto-prata', 'vertice-detog': 'vertice-alcaparra-prata'
        };
        const currentItems = items.map(item => ({...item, href: item.href.replace(/\/produtos\/([^/]+)\//, (_, slug) => productPath(renamed[slug] || slug))}));
        const currentOrder = expected.map(slug => productPath(renamed[slug] || slug));
        for (const width of [1440, 390]) {
            await page.setViewportSize({width, height: 900});
            for (const item of currentItems) {
                await page.evaluate(({items, path}) => { history.replaceState({}, '', path); window.renderVariants(items); }, {items: currentItems, path: new URL(item.href).pathname});
                await expectPaths(currentOrder);
                assert.equal(await page.locator('.eora-active').getAttribute('data-href-path'), new URL(item.href).pathname);
            }
        }
        // IDs da plataforma mantêm a ordem mesmo em uma próxima mudança de slug.
        const ids = [301013237, 301374832, 301374937, 301375238, 322659163, 374159103, 374170272, 374880742, 374154591];
        const futureItems = items.map((item, i) => ({...item, href: 'https://vertice.test/produtos/referencia-' + ids[i] + '/'}));
        await page.evaluate(({items, ids}) => {
            window.LS = {product: {id: 301013237}};
            const native = document.createElement('div');
            native.className = 'js-color-variants-container';
            native.innerHTML = items.map((item, i) => `<a href="${item.href}" data-eora-variant-product-id="${ids[i]}"></a>`).join('');
            document.querySelector('#single-product').appendChild(native);
            history.replaceState({}, '', new URL(items[0].href).pathname);
            window.renderVariants(items);
        }, {items: futureItems, ids});
        await expectPaths([301013237, 374159103, 301374832, 322659163, 301374937, 374154591, 301375238, 374170272, 374880742].map(id => '/produtos/referencia-' + id + '/'));
        await page.evaluate(() => { delete window.LS; document.querySelector('#single-product .js-color-variants-container').remove(); history.replaceState({}, '', '/produtos/vertice/'); });
        // Catálogo parcial e novas cores continuam visíveis, sem depender das tags.
        const partial = [items[0], {name: 'VÉRTICE', href: '/produtos/nova-cor/', url: 'https://images.test/nova.webp'}, items[2], items[8]];
        await page.evaluate(items => window.renderVariants(items), partial);
        await expectPaths(['vertice', 'vertice3', 'vertice-marrom-avela-mix', 'nova-cor'].map(productPath));
        await page.evaluate(items => window.renderVariants(items), [items[4], items[3], items[1]]);
        await expectPaths(['vertice1', 'vertice6', 'vertice4'].map(productPath));
        for (const slug of ['maxi-vertice', 'mini-vertice', 'hobo-vertice', 'clutch-vertice']) {
            await page.evaluate(({slug, items}) => {
                history.replaceState({}, '', '/produtos/' + slug + '/');
                window.renderVariants(items);
            }, {slug, items});
            await page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve))));
            assert.deepEqual(await renderedPaths(), catalog.map(productPath), 'Outras famílias não recebem a ordenação da Vértice');
        }
        assert.deepEqual(errors, []);
        console.log('PASS tema Vértice: HTML antigo, lista tardia e recriada; URLs antigas/atuais e IDs; pares na mesma linha, nós/listeners, seleção, fotos, links, catálogo parcial e escopo por família.');
    } finally {
        await browser.close();
    }
})().catch(error => {console.error(error); process.exitCode = 1;});
