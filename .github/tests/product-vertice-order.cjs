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
        await page.route('https://vertice.test/**', route => route.fulfill({contentType: 'text/html', body: '<div class="eora-product-info"><form><button class="js-addtocart">Comprar</button></form></div>'}));
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
        const renderedPaths = () => page.locator('.eora-bolsa-var-item').evaluateAll(nodes => nodes.map(node => node.getAttribute('data-href-path')));
        for (const width of [1440, 390]) {
            await page.setViewportSize({width, height: 900});
            for (const current of catalog) {
                await page.evaluate(({items, currentPath}) => {
                    history.replaceState({}, '', currentPath);
                    const before = JSON.stringify(items);
                    window.renderVariants(items);
                    if (JSON.stringify(items) !== before) throw new Error('Não alterar os dados recebidos do catálogo');
                }, {items, currentPath: productPath(current)});
                assert.deepEqual(await renderedPaths(), expected.map(productPath), 'Pares de cor juntos, inclusive após trocar o produto ativo');
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
        // Catálogo parcial e novas cores continuam visíveis, sem depender das tags.
        const partial = [items[0], {name: 'VÉRTICE', href: '/produtos/nova-cor/', url: 'https://images.test/nova.webp'}, items[2], items[8]];
        await page.evaluate(items => window.renderVariants(items), partial);
        assert.deepEqual(await renderedPaths(), ['vertice', 'nova-cor', 'vertice3', 'vertice-marrom-avela-mix'].map(productPath));
        await page.evaluate(items => window.renderVariants(items), [items[4], items[3], items[1]]);
        assert.deepEqual(await renderedPaths(), ['vertice6', 'vertice1', 'vertice4'].map(productPath), 'Preservar ordem relativa dentro de cada cor');
        assert.deepEqual(errors, []);
        console.log('PASS Vértice: bordô, preto e marrom juntos; 18 renderizações desktop/mobile; seleção, fotos, cliques, catálogo parcial e novas cores preservados.');
    } finally {
        await browser.close();
    }
})().catch(error => {console.error(error); process.exitCode = 1;});
