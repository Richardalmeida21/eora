const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {chromium} = require('playwright');

const root = path.resolve(__dirname, '../..');
const source = fs.readFileSync(process.env.PRODUCT_VARIATION_NAME_SOURCE || path.join(root, 'maxivertice.html'), 'utf8');
const artifacts = process.env.PRODUCT_CART_VALIDATION_DIR || 'C:/Temp/eora-product-cart-validation';
function extract(startName, endMarker) {
    const start = source.indexOf('function ' + startName + '(');
    const end = source.indexOf(endMarker, start);
    assert(start >= 0 && end > start, 'actual helper exists: ' + startName);
    return source.slice(start, end).trim();
}
// Run the actual extraction/display/prefetch helpers, keeping product navigation
// and purchase APIs outside this fixture. No cart endpoint is mocked or called.
const helpers = [
    extract('getVariationNameFromLS', '\n    function criarBlocoTitulo'),
    extract('getOriginalProductRoot', '\n    function getProductTagsFromRoot'),
    extract('getOriginalProductForm', '\n    function getOriginalAddButton'),
    extract('readProductVariants', '\n    function setProductFieldValue'),
    extract('normalizePathname', '\n    function isVisibleProductPageByDocument'),
    extract('prefetchVariationPages', '\n    function reorganizeEoraProductInfo'),
].join('\n');
const escape = value => String(value).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const berinjela = {product_id: 345383409, id: 1528884304, option0: 'Berinjela / Prata', available: true, stock: 1};
const croco = {product_id: 345384573, id: 1533103416, option0: 'Croco Marrom / Prata', available: true, stock: 2};
const preto = {...croco, id: 1533103417, option0: 'Croco Preto / Prata'};
function productHtml({variants = [berinjela], selected, selects = true, manual = '', title = 'MAXI VÉRTICE', tags = [], productId, variantId} = {}) {
    selected = selected || variants[0] || {};
    productId = productId || selected.product_id || 12345;
    variantId = variantId || selected.id || '';
    return '<div id="single-product" data-variants="' + escape(JSON.stringify(variants)) + '" data-product-tags="' + escape(JSON.stringify(tags)) + '">' +
        '<h2 class="js-product-name">' + escape(title) + '</h2><form id="product_form" class="js-product-form" action="/comprar/" method="post">' +
        '<input type="hidden" name="add_to_cart" value="' + productId + '">' +
        '<input type="hidden" name="variant_id" value="' + variantId + '">' +
        '<input name="quantity" value="2">' +
        (selects ? '<select class="js-variation-option" name="variation[0]">' + variants.map(variant => '<option value="' + escape(variant.option0) + '" ' + (variant.id === selected.id ? 'selected' : '') + '>' + escape(variant.option0) + '</option>').join('') + '</select>' : '') +
        '<input type="submit" class="js-addtocart cart" value="Comprar"></form>' +
        (manual ? '<div class="js-product-description-base"><table><tbody><tr><td>nome_variacao</td><td>' + escape(manual) + '</td></tr></tbody></table></div>' : '') + '</div>';
}
const ui = '<div class="eora-product-info"><h2 class="eora-product-name">MAXI VÉRTICE</h2><div class="eora-nome-variacao"></div></div>';
async function fixture(browser, options = {}) {
    const page = await browser.newPage();
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.route('http://maxi.test/**', route => route.fulfill({contentType: 'text/html', body: '<!doctype html><title>MAXI VÉRTICE</title>' + (options.outside || '') + productHtml(options) + ui + (options.swatches || '')}));
    await page.goto('http://maxi.test/berinjela/');
    await page.addScriptTag({content: 'var eoraPageCache={};window.LS=' + JSON.stringify(options.platform || {product: {id: berinjela.product_id}, variants: [berinjela]}) + ';' + helpers});
    return {page, errors};
}
async function display(page) {
    return page.evaluate(() => {
        const element = document.querySelector('.eora-nome-variacao');
        return {text: element.textContent, hidden: element.style.display === 'none', children: element.children.length, cache: window.eoraActiveVariationName};
    });
}

(async () => {
    fs.mkdirSync(artifacts, {recursive: true});
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    const report = [];
    try {
        const scenarios = [
            {label: 'cadastro sem tabela manual', expected: berinjela.option0},
            {label: 'cadastro prevalece sobre tabela antiga incorreta', manual: 'Azul incorreto', expected: berinjela.option0},
            {label: 'selecao do produto atual ignora quickshop e outro formulario', outside: '<div class="js-quickshop-container"><input name="variant_id" value="' + croco.id + '"><select class="js-variation-option"><option>Cor de outro produto</option></select></div><form class="eora-cloned-product-form"><select class="js-variation-option"><option>Cor do clone antigo</option></select></form>', expected: berinjela.option0},
            {label: 'data-variants pelo ID selecionado quando nao ha select', variants: [croco, preto], selected: preto, selects: false, expected: preto.option0},
            {label: 'documento sem variantes usa tabela legada', variants: [], selects: false, manual: 'Chocolate / Dourado', platform: {product: {id: 12345}, variants: []}, expected: 'Chocolate / Dourado'},
            {label: 'documento sem variantes usa titulo legado', variants: [], selects: false, title: 'MAXI VÉRTICE - Oliva / Dourado', platform: {product: {id: 12345}, variants: []}, expected: 'Oliva / Dourado'},
            {label: 'documento sem variantes usa tags legadas', variants: [], selects: false, tags: ['maxivertice', 'bolsa', 'Marrom / Prata'], platform: {product: {id: 12345}, variants: []}, expected: 'Marrom / Prata'},
        ];
        for (const scenario of scenarios) {
            const {page, errors} = await fixture(browser, scenario);
            const result = await page.evaluate(() => {
                const before = Object.fromEntries(new FormData(document.querySelector('#single-product form')));
                const extracted = autoGetVariationName(document);
                updateVariationName(document);
                return {extracted, before, after: Object.fromEntries(new FormData(document.querySelector('#single-product form')))};
            });
            assert.equal(result.extracted, scenario.expected, scenario.label);
            assert.equal((await display(page)).text, scenario.expected);
            assert.deepEqual(result.after, result.before, 'exibir nome nao altera produto, variante ou quantidade da compra');
            assert.deepEqual(errors, []);
            report.push({scenario: scenario.label, passed: true});
            await page.close();
        }

        const stale = await fixture(browser, {variants: [croco, preto], selected: croco});
        await stale.page.evaluate(() => {window.eoraActiveVariationName = 'Berinjela / Prata';updateVariationName(document);});
        assert.equal((await display(stale.page)).text, croco.option0, 'nome recalculado ignora cache da referencia antiga');
        const fetchedName = await stale.page.evaluate(html => {
            const fetched = new DOMParser().parseFromString(html, 'text/html');
            return {automatic: autoGetVariationName(fetched), metadata: getVariationNameFromLS(fetched, fetched.querySelector('[name="variant_id"]').value)};
        }, '<!doctype html>' + productHtml({variants: [croco, preto], selected: preto, selects: false}));
        assert.equal(fetchedName.automatic, preto.option0, 'documento de Croco usa seus dados mesmo com LS antigo de Berinjela');
        assert.equal(fetchedName.metadata, preto.option0);
        report.push({scenario: 'cache antigo e documento fetched de outra referencia', passed: true});
        await stale.page.close();

        const noCurrentProduct = await fixture(browser);
        await noCurrentProduct.page.evaluate(() => {
            document.querySelector('#single-product').remove();
            document.body.insertAdjacentHTML('afterbegin', '<div class="js-quickshop-container"><select class="js-variation-option"><option>Cor do quickshop</option></select><input name="variant_id" value="1528884304"></div>');
            window.eoraActiveVariationName = 'Cache anterior';
            updateVariationName(document);
        });
        assert.equal(await noCurrentProduct.page.evaluate(() => autoGetVariationName(document)), '', 'sem produto atual nao usa quickshop nem LS antigo');
        assert.equal((await display(noCurrentProduct.page)).hidden, true);
        assert.deepEqual(noCurrentProduct.errors, []);
        report.push({scenario: 'ausencia de produto atual ignora quickshop e cache antigos', passed: true});
        await noCurrentProduct.page.close();

        const outsideLegacy = await fixture(browser, {variants: [], selects: false, platform: {product: {id: 12345}, variants: []}, outside: '<table><tbody><tr><td>nome_variacao</td><td>Nome de outro produto</td></tr></tbody></table>'});
        assert.equal(await outsideLegacy.page.evaluate(() => autoGetVariationName(document)), '', 'tabela fora do produto atual nao define sua variacao');
        assert.deepEqual(outsideLegacy.errors, []);
        report.push({scenario: 'tabela legada limitada ao produto atual', passed: true});
        await outsideLegacy.page.close();

        const changing = await fixture(browser, {variants: [croco, preto]});
        assert(source.includes('function bindVariationNameUpdates('), 'actual change binding exists');
        await changing.page.evaluate(() => {
            // Model only the native field synchronization; the tested name
            // listener and DOM formatting remain the actual production helpers.
            document.addEventListener('change', event => {
                if (!event.target.matches('#single-product .js-variation-option')) return;
                const product = document.querySelector('#single-product');
                const variant = JSON.parse(product.dataset.variants).find(value => value.option0 === event.target.value);
                if (variant) product.querySelector('[name="variant_id"]').value = variant.id;
            });
            bindVariationNameUpdates();
            updateVariationName(document);
        });
        await changing.page.locator('#single-product select').selectOption(preto.option0);
        await changing.page.waitForFunction(expected => document.querySelector('.eora-nome-variacao').textContent === expected, preto.option0);
        const fields = await changing.page.evaluate(() => Object.fromEntries(new FormData(document.querySelector('#single-product form'))));
        assert.equal(fields.add_to_cart, String(croco.product_id));
        assert.equal(fields.variant_id, String(preto.id));
        assert.equal(fields['variation[0]'], preto.option0);
        assert.equal(fields.quantity, '2');
        assert.deepEqual(changing.errors, []);
        report.push({scenario: 'change nativo atualiza nome e preserva payload da compra', passed: true});
        await changing.page.close();

        const prefetched = await fixture(browser, {swatches: '<div class="eora-bolsa-vars"><a class="eora-bolsa-var-item eora-active" data-href-path="/croco/" data-name="Nome antigo">Croco</a></div>'});
        await prefetched.page.route('http://maxi.test/croco/', route => route.fulfill({contentType: 'text/html', body: '<!doctype html>' + productHtml({variants: [croco]})}));
        await prefetched.page.evaluate(() => {updateVariationName(document);prefetchVariationPages([{href: '/croco/'}]);});
        await prefetched.page.waitForFunction(() => !!eoraPageCache['/croco/']);
        assert.equal((await display(prefetched.page)).text, berinjela.option0, 'prefetch de outra referencia nao altera produto atual mesmo com swatch ativo antigo');
        assert.equal(await prefetched.page.locator('[data-href-path="/croco/"]').getAttribute('data-name'), croco.option0);
        assert.deepEqual(prefetched.errors, []);
        report.push({scenario: 'prefetch de outra referencia preserva nome atual', passed: true});
        await prefetched.page.close();

        const literal = '<img src=x onerror="window.unsafeName=true"> / Prata';
        const safe = await fixture(browser, {variants: [{...berinjela, option0: literal}]});
        await safe.page.evaluate(() => updateVariationName(document));
        const safeDisplay = await display(safe.page);
        assert.equal(safeDisplay.text, literal);
        assert.equal(safeDisplay.children, 0, 'nome de cadastro permanece texto literal, sem inserir elementos HTML');
        assert.equal(await safe.page.evaluate(() => !!window.unsafeName), false);
        assert.deepEqual(safe.errors, []);
        report.push({scenario: 'nome de cadastro exibido como texto', passed: true});
        await safe.page.close();

        fs.writeFileSync(path.join(artifacts, 'product-maxi-variation-name-regression.json'), JSON.stringify({networkFixture: 'product HTML only', checkoutTested: false, scenarios: report}, null, 2));
        console.log('PASS: ' + report.length + ' cenarios de nome automatico: cadastro atual, scope, metadata, legados, troca nativa, prefetch e texto literal.');
    } finally {await browser.close();}
})().catch(error => {console.error(error);process.exitCode = 1;});
