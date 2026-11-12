const assert = require('node:assert/strict');
const fs = require('node:fs');
const vm = require('node:vm');
const Twig = require('twig');
const {chromium} = require('playwright');
const read = file => fs.readFileSync(file, 'utf8');
Twig.extendFilter('product_image_url', value => value);
Twig.extendFilter('get_products', value => value || []);
Twig.extendFilter('shuffle', value => value);
Twig.extendFilter('take', (value, amount) => value.slice(0, amount));
Twig.extendFilter('translate', value => value);
const calls = [];
Twig.extendFunction('component', (name, options) => {
    calls.push(options);
    return `<section class="${options.section_classes.section}" data-products="${options.products_array.map(p => p.id).join(',')}"></section>`;
});
Twig.twig({id: 'snipplets/cart-related-products.tpl', data: read('snipplets/cart-related-products.tpl'), allowInlineIncludes: true, rethrow: true});
const related = Twig.twig({data: read('snipplets/product/product-related.tpl'), allowInlineIncludes: true, rethrow: true});
const feed = Twig.twig({data: read('snipplets/product/product-variant-feed.tpl'), rethrow: true});
const nova = {id: 1, name: 'NOVA', url: '/produtos/nova/', tags: [{tag: 'modelo:nova'}], featured_image: '/nova.webp', stock: 4};
const nova2 = {...nova, id: 2, url: '/produtos/nova2/'};
const astra = {id: 3, name: 'ASTRA', url: '/produtos/astra/', tags: [{tag: 'modelo:astra'}], featured_image: '/astra.webp', stock: 2};
const nova3 = {...nova, id: 4, url: '/produtos/nova3/'};
const context = {
    product: {...nova, metafields: {related_products: {related_products_ids: [astra]}}},
    complementary_product_list: [nova2], source_alternative: 'manual', category: {products: []},
    settings: {products_complementary_title: 'Para comprar com esse produto'}
};
const rendered = related.render(context);
assert.equal(calls.length, 2);
assert.deepEqual(calls[0].products_array.map(p => p.id), [3], 'popup usa alternativa cadastrada');
assert.deepEqual(calls[1].products_array.map(p => p.id), [2], 'fim da pagina usa complementares');
calls.length = 0;
related.render({...context, product: {...nova, metafields: {}}, related_tag: true, related_products_from_controller: [astra]});
assert.deepEqual(calls[0].products_array.map(p => p.id), [3], 'alternativas fornecidas pelo controller');
calls.length = 0;
related.render({...context, product: {...nova, metafields: {}}, source_alternative: 'default', category: {products: [astra]}});
assert.equal(calls.length, 1, 'sem alternativas cadastradas, nao usar categoria no popup');

const feed1 = feed.render({products: [nova, nova2, astra], pages: {next: '/search/?page=2', is_last: false}});
const feed2 = feed.render({products: [nova3], pages: {is_last: true}});
const source = read('static/js/eora-variations.js.tpl');
new vm.Script(source);
const store = read('static/js/store.js.tpl');
const resolver = store.slice(store.indexOf('    function getCartAlternatives('), store.indexOf('    jQueryNuvem(document).on("click", ".js-addtocart', store.indexOf('    function getCartAlternatives(')));
new vm.Script(resolver);

(async () => {
    const browser = await chromium.launch({executablePath: 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe', headless: true});
    try {
        const page = await browser.newPage();
        const errors = [];
        page.on('pageerror', error => errors.push(error.message));
        await page.route('https://relationships.eora.test/**', route => {
            const url = new URL(route.request().url());
            let body = '';
            if (url.pathname === '/search/') body = url.searchParams.get('page') === '2' ? feed2 : feed1;
            else if (url.pathname === '/produtos/astra/') body = rendered;
            else body = '<div id="single-product"><div class="js-color-variants-container" data-eora-model-tag="modelo:nova"><a href="/produtos/nova/" data-eora-variant-product-id="1" class="btn-variant-thumb selected">NOVA</a><a href="/produtos/astra/" data-eora-variant-product-id="3" class="btn-variant-thumb">ASTRA contaminado</a></div></div>';
            return route.fulfill({body, contentType: 'text/html'});
        });
        await page.goto('https://relationships.eora.test/produtos/nova/');
        await page.addScriptTag({content: source});
        await page.waitForFunction(() => document.querySelectorAll('#single-product a[data-eora-variant-product-id]').length === 3, null, {timeout: 5000}).catch(async error => {
            console.error(await page.locator('#single-product').innerHTML(), errors, feed1, feed2);
            throw error;
        });
        const ids = await page.locator('#single-product a[data-eora-variant-product-id]').evaluateAll(nodes => nodes.map(n => n.dataset.eoraVariantProductId).sort());
        assert.deepEqual(ids, ['1', '2', '4'], 'tag exata e paginacao excluem ASTRA mesmo no prefetch');
        await page.addScriptTag({content: resolver});
        await page.evaluate(html => {
            document.body.insertAdjacentHTML('beforeend', html + '<form id="cart-test" data-eora-product-url="/produtos/astra/"><input name="add_to_cart" value="1"></form>');
        }, rendered);
        assert.match(await page.evaluate(() => getCartAlternatives(document.querySelector('#cart-test'))), /data-products="3"/);
        await page.evaluate(() => document.querySelector('template[data-eora-cart-alternatives]').remove());
        assert.match(await page.evaluate(() => getCartAlternatives(document.querySelector('#cart-test'))), /data-products="3"/, 'compra pelo card busca alternativas do produto');
        await page.evaluate(() => document.body.insertAdjacentHTML('beforeend', '<template data-eora-cart-alternatives="1"></template>'));
        assert.equal(await page.evaluate(() => getCartAlternatives(document.querySelector('#cart-test'))), null, 'lista vazia nao reutiliza complementares');
        assert.deepEqual(errors, []);
        console.log('PASS: fontes independentes, alternativas manuais/controller, lista vazia, tag exata, paginacao, prefetch e popup por pagina/card.');
    } finally { await browser.close(); }
})().catch(error => {console.error(error); process.exitCode = 1;});
