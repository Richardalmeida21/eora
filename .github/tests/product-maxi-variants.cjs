const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {chromium} = require('playwright');

const source = fs.readFileSync(path.resolve(__dirname, '../../maxivertice.html'), 'utf8');
function extract(name, endMarker) {
    const start = source.indexOf('function ' + name + '(');
    const end = source.indexOf(endMarker, start);
    assert(start >= 0 && end > start, 'funcao real encontrada: ' + name);
    return source.slice(start, end).trim();
}
const helpers = [
    ['getOriginalProductRoot', '\n    function getProductTagsFromRoot'],
    ['getOriginalProductForm', '\n    function getOriginalAddButton'],
    ['getOriginalAddButton', '\n    function readProductVariants'],
    ['readProductVariants', '\n    function setProductFieldValue'],
    ['setProductFieldValue', '\n    function setFormVariants'],
    ['setFormVariants', '\n    function resolveProductVariant'],
    ['resolveProductVariant', '\n    function syncFormValues'],
    ['syncFormValues', '\n    function triggerOriginalBuy'],
    ['triggerOriginalBuy', '\n    function dropdownLooksLikeMeasurements'],
    ['navigateToVariation', "\n    window.addEventListener('popstate'"],
    ['submitVariant', '\n        function abrirPopup'],
    ['abrirPopup', '\n        if (floatBtn)'],
].map(([name, end]) => extract(name, end)).join('\n');

const berinjela = {product_id: 345383409, id: 1528884304, option0: 'Berinjela / Prata', stock: 1, available: true};
const croco = {product_id: 345384573, id: 1533103416, option0: 'Croco Marrom / Prata', stock: 2, available: true};
const crocoPreto = {...croco, id: 1533103417, option0: 'Croco Preto / Prata'};
const escaped = value => String(value).replace(/&/g, '&amp;').replace(/"/g, '&quot;').replace(/</g, '&lt;');
function productHtml(variants) {
    const selected = variants[0];
    return `<div id="single-product" data-variants="${escaped(JSON.stringify(variants))}">
        <span class="js-product-name">MAXI VERTICE</span><span class="js-price-display">R$ 3.649,90</span>
        <form id="product_form" class="js-product-form" action="/comprar/" method="post">
            <input name="add_to_cart" value="${selected.product_id}" type="hidden">
            <div class="js-product-variants"><select name="variation[0]" class="js-variation-option">${variants.map(variant => `<option value="${escaped(variant.option0)}">${escaped(variant.option0)}</option>`).join('')}</select></div>
            <input name="quantity" value="1" type="number">
            <input name="variant_id" value="${selected.id}" type="hidden">
            <input type="submit" class="js-addtocart ${selected.available ? 'cart' : 'nostock'}" value="Comprar" ${selected.available ? '' : 'disabled'}>
        </form></div>`;
}
const documentHtml = variants => `<!doctype html><title>MAXI VERTICE</title><script>LS.product = {id: ${variants[0].product_id}, name: 'MAXI VERTICE'};</script>${productHtml(variants)}`;
const combo = variant => ({variantId: variant.id, productId: variant.product_id, values: [variant.option0], name: variant.option0, lsIdx: 0});

(async () => {
    const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
    try {
        const page = await browser.newPage();
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        await page.route('http://maxi.test/**', route => route.fulfill({contentType: 'text/html', body:
            '<!doctype html>' + productHtml([berinjela]) + '<div class="eora-product-wrap"><div class="eora-product-info"><span class="eora-product-name"></span><span class="eora-price-display"></span><form class="eora-cloned-product-form"></form></div></div><div class="eora-bolsa-pu"><div id="eora-bolsa-pu-list"></div></div>'}));
        await page.goto('http://maxi.test/berinjela/');
        await page.addScriptTag({content: `
            var eoraPageCache = {};
            var popup = document.querySelector('.eora-bolsa-pu');
            var normalizePathname = value => new URL(value, location.href).pathname;
            var autoGetVariationName = () => '';
            var updateVariationName = () => {};
            var bindShippingCalculator = () => {};
            var bindShippingAccordion = () => {};
            var ensureMeasurementsAccordion = () => {};
            var reorganizeEoraProductInfo = () => {};
            var dropdownLooksLikeMeasurements = () => false;
            var normalizeUrl = value => value;
            var getSrc = image => image.src;
            var getVariantGroupTag = () => 'maxivertice';
            var fetchProductsFromTag = () => Promise.resolve([]);
            window.LS = {product: {id: ${berinjela.product_id}}, variants: ${JSON.stringify([berinjela])}};
            window.delegatedChanges = [];
            window.buyRequests = [];
            document.addEventListener('change', event => {
                const root = event.target.closest('#single-product');
                if (!root) return;
                delegatedChanges.push(event.target.name);
                if (!event.target.matches('.js-variation-option')) return;
                const variant = JSON.parse(root.dataset.variants).find(item => item.option0 === event.target.value);
                if (!variant) return;
                const button = root.querySelector('.js-addtocart');
                button.disabled = variant.available === false;
                button.classList.toggle('nostock', variant.available === false);
                button.classList.toggle('cart', variant.available !== false);
                root.querySelector('[name="variant_id"]').value = variant.id;
            });
            document.addEventListener('click', event => {
                if (!event.target.matches('#single-product .js-addtocart')) return;
                event.preventDefault();
                buyRequests.push(Object.fromEntries(new FormData(event.target.form)));
            });
            ${helpers}
        `});
        await page.evaluate(({html}) => {
            eoraPageCache['/croco/'] = html;
            navigateToVariation('/croco/', 'http://maxi.test/croco/');
        }, {html: documentHtml([croco, crocoPreto])});
        await page.waitForFunction(productId => LS.product.id === productId && document.querySelector('#single-product [name="add_to_cart"]').value === String(productId), croco.product_id);
        let state = await page.evaluate(() => ({variants: LS.variants, form: Object.fromEntries(new FormData(getOriginalProductForm())), changes: delegatedChanges, productHasVariants: 'variants' in LS.product}));
        assert.equal(state.productHasVariants, false, 'LS.product sem variantes, como o cadastro publico');
        assert.equal(state.variants[0].id, croco.id, 'troca usa data-variants do produto novo');
        assert.equal(state.form['variation[0]'], croco.option0);
        assert.equal(state.form.variant_id, String(croco.id));
        assert(state.changes.includes('variation[0]'), 'troca notifica o listener delegado do tema');

        const stale = await page.evaluate(staleCombo => {
            const form = getOriginalProductForm();
            const before = Object.fromEntries(new FormData(form));
            return {resolved: resolveProductVariant(staleCombo, getOriginalProductRoot()), submitted: submitVariant(staleCombo), before, after: Object.fromEntries(new FormData(form))};
        }, combo(berinjela));
        assert.equal(stale.resolved, null, 'indice anterior nao seleciona variante do produto novo');
        assert.equal(stale.submitted, false);
        assert.deepEqual(stale.after, stale.before);

        const synced = await page.evaluate(({variant}) => {
            const form = getOriginalProductForm();
            const source = form.cloneNode(true);
            source.querySelector('select').value = variant.option0;
            source.querySelector('[name="quantity"]').value = 2;
            const start = delegatedChanges.length;
            const ok = syncFormValues(source, form);
            return {ok, data: Object.fromEntries(new FormData(form)), changes: delegatedChanges.slice(start)};
        }, {variant: crocoPreto});
        assert.equal(synced.ok, true);
        assert.equal(synced.data['variation[0]'], crocoPreto.option0);
        assert.equal(synced.data.variant_id, String(crocoPreto.id), 'ID segue a selecao atual mesmo com hidden antigo no clone');
        assert.equal(synced.data.quantity, '2');
        assert(synced.changes.includes('variation[0]'));

        const rejected = await page.evaluate(({wrongVariant}) => {
            const form = getOriginalProductForm();
            const source = form.cloneNode(true);
            source.querySelector('select').innerHTML = '<option>Berinjela / Prata</option>';
            source.querySelector('[name="variant_id"]').value = wrongVariant.id;
            const before = Object.fromEntries(new FormData(form));
            return {sync: syncFormValues(source, form), selection: setFormVariants(form, {...wrongVariant, product_id: Number(form.querySelector('[name="add_to_cart"]').value)}), before, after: Object.fromEntries(new FormData(form))};
        }, {wrongVariant: berinjela});
        assert.equal(rejected.sync, false, 'opcao inexistente rejeitada antes de copiar os campos');
        assert.equal(rejected.selection, false);
        assert.deepEqual(rejected.after, rejected.before, 'selecao e ID preservados depois da rejeicao');

        const selected = await page.evaluate(({variant}) => {
            const start = delegatedChanges.length;
            const result = setFormVariants(getOriginalProductForm(), variant);
            return {result, data: Object.fromEntries(new FormData(getOriginalProductForm())), changes: delegatedChanges.slice(start)};
        }, {variant: croco});
        assert.equal(selected.result, true);
        assert.equal(selected.data['variation[0]'], croco.option0);
        assert.equal(selected.data.variant_id, String(croco.id));
        assert(selected.changes.includes('variation[0]'), 'setFormVariants propaga change');

        assert.equal(await page.evaluate(selectedCombo => submitVariant({...selectedCombo, lsIdx: 1}), combo(croco)), true);
        await page.waitForFunction(() => buyRequests.length === 1);
        const request = await page.evaluate(() => buyRequests[0]);
        assert.equal(request.add_to_cart, String(croco.product_id));
        assert.equal(request['variation[0]'], croco.option0);
        assert.equal(request.variant_id, String(croco.id), 'compra usa identidade atual, mesmo com indice diferente');

        const unavailable = {...croco, available: false, stock: 0};
        assert.equal(await page.evaluate(({html, selectedCombo}) => {
            window.eoraIsSubmittingCart = false;
            eoraPageCache['/croco-esgotado/'] = html;
            const scheduled = submitVariant(selectedCombo);
            navigateToVariation('/croco-esgotado/', 'http://maxi.test/croco-esgotado/');
            return scheduled;
        }, {html: documentHtml([unavailable, {...crocoPreto, available: false, stock: 0}]), selectedCombo: combo(croco)}), true);
        await page.waitForFunction(() => getOriginalAddButton().disabled);
        await page.waitForTimeout(250);
        assert.equal(await page.evaluate(() => buyRequests.length), 1, 'troca durante a espera cancela a compra agendada');
        await page.evaluate(() => { window.eoraIsSubmittingCart = false; abrirPopup(); });
        await page.locator('.eora-bolsa-pu-select').first().click();
        state = await page.evaluate(() => ({disabled: getOriginalAddButton().disabled, popupOpen: popup.classList.contains('eora-pu-open'), requests: buyRequests.length, triggered: triggerOriginalBuy()}));
        assert.equal(state.disabled, true);
        assert.equal(state.popupOpen, true, 'tentativa indisponivel conserva o popup');
        assert.equal(state.requests, 1, 'produto indisponivel nao envia nova compra');
        assert.equal(state.triggered, false);

        await page.evaluate(({html}) => {
            eoraPageCache['/croco-estoque-misto/'] = html;
            navigateToVariation('/croco-estoque-misto/', 'http://maxi.test/croco-estoque-misto/');
        }, {html: documentHtml([unavailable, crocoPreto])});
        await page.waitForFunction(() => LS.variants[1].available && getOriginalAddButton().disabled);
        await page.evaluate(() => abrirPopup());
        await page.locator('.eora-bolsa-pu-select').nth(1).click();
        await page.waitForFunction(() => buyRequests.length === 2);
        state = await page.evaluate(() => ({disabled: getOriginalAddButton().disabled, noStock: getOriginalAddButton().classList.contains('nostock'), popupOpen: popup.classList.contains('eora-pu-open'), request: buyRequests[1]}));
        assert.equal(state.disabled, false, 'change habilita a compra da outra variante disponivel');
        assert.equal(state.noStock, false);
        assert.equal(state.popupOpen, false);
        assert.equal(state.request['variation[0]'], crocoPreto.option0);
        assert.equal(state.request.variant_id, String(crocoPreto.id));
        assert.equal(state.request.add_to_cart, String(crocoPreto.product_id));

        const malformed = await page.evaluate(() => {
            const root = getOriginalProductRoot().cloneNode(true);
            root.setAttribute('data-variants', '{}');
            const object = readProductVariants(root);
            root.setAttribute('data-variants', '[{"id":1,"product_id":999}]');
            return {object, otherProduct: readProductVariants(root)};
        });
        assert.equal(malformed.object, null);
        assert.equal(malformed.otherProduct, null);
        assert.deepEqual(errors, []);
        console.log('PASS Maxi: troca Berinjela/Croco, identidade atual, selects protegidos, eventos delegados e variantes com estoques distintos.');
    } finally {
        await browser.close();
    }
})().catch(error => { console.error(error); process.exitCode = 1; });
