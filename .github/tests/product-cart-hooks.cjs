const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {chromium} = require('playwright');
const Twig = require('twig');

// Real Twig templates plus the real public app's stock check and the platform's
// DOM wrapper. Network cart/checkout endpoints are not mocked or called here.
const root = path.resolve(__dirname, '../..');
const artifacts = process.env.PRODUCT_CART_VALIDATION_DIR || 'C:/Temp/eora-product-cart-validation';
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';
const platformUrl = 'https://acdn-us.mitiendanube.com/assets/stores/js/linkedstore-v2-4df80ab5f3b4c281f6d175aa1c36fb0930.js?v=47328529';
const appUrl = 'https://apps-scripts.tiendanube.com/cheguei-avise-me/cheguei-alert-form/5.js?versionId=rNinLr8tTuAYnTzI1ozaWMaY7Te9OXnX&store=6201247';
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
// Native Twig accepts with{...}; twig.js requires whitespace before the map.
const compile = (id, data) => Twig.twig({id, data: data.replace(/\bwith\{/g, 'with {'), rethrow: true, allowInlineIncludes: true});
Twig.extendFilter('translate', value => value);
Twig.extendFilter('t', value => value);
Twig.extendFilter('a_tag', value => '<a>' + value + '</a>');
Twig.extendFilter('static_url', value => '/static/' + value);
Twig.extendFilter('settings_image_url', value => value);
Twig.extendFilter('product_image_url', value => typeof value === 'string' ? value : value.url);
Twig.extendFilter('money', value => (Number(value) / 100).toLocaleString('pt-BR', {style: 'currency', currency: 'BRL'}));
Twig.extendFilter('add_param', value => value);
Twig.extendFilter('has_custom_image', () => false);
Twig.extendFunction('component', () => '');
// Unrelated product option, shipping and navigation contents are fixtures; item,
// labels, header modals and their modal shell are the original theme templates.
for (const id of ['snipplets/selo-brand.tpl', 'snipplets/placeholders/button-placeholder.tpl', 'snipplets/product/product-variants.tpl', 'snipplets/product/product-quantity.tpl', 'snipplets/grid/item-colors.tpl', 'snipplets/header/header-search.tpl', 'snipplets/navigation/navigation-panel.tpl', 'snipplets/cart-panel.tpl', 'snipplets/notification-cart.tpl']) compile(id, '');
compile('snipplets/labels.tpl', read('snipplets/labels.tpl'));
compile('snipplets/modal.tpl', read('snipplets/modal.tpl'));
const item = compile('cart-hook-item', process.env.PRODUCT_CART_ITEM_SOURCE ? fs.readFileSync(process.env.PRODUCT_CART_ITEM_SOURCE, 'utf8') : read('snipplets/grid/item.tpl'));
const header = compile('cart-hook-header', (process.env.PRODUCT_CART_HEADER_SOURCE ? fs.readFileSync(process.env.PRODUCT_CART_HEADER_SOURCE, 'utf8') : read('snipplets/header/header-modals.tpl')).replace(/{%\s*snipplet\s+["']([^"']+)["']\s*%}/g, '{% include "snipplets/$1" %}'));

async function asset(file, url) {
    const destination = path.join(artifacts, file);
    if (!fs.existsSync(destination)) {
        const response = await fetch(url);
        assert(response.ok, 'public asset should be downloadable');
        fs.writeFileSync(destination, await response.text());
    }
    return fs.readFileSync(destination, 'utf8');
}
function renderItem(reduced, stock) {
    return item.render({template: 'product', reduced_item: reduced, slide_item: reduced, settings: {grid_columns_desktop: 4, grid_columns_mobile: 2, quick_shop: false, product_installments: false}, store: {cart_url: '/cart/'}, cart: {free_shipping: {cart_has_free_shipping: false, min_price_free_shipping: {}}}, product: {id: 100, name: 'Maxi Vértice', has_stock: stock !== 0, stock, available: stock !== 0, display_price: true, price: 100000, url: '/produtos/maxi/', tags: [], featured_image: {url: '/maxi.jpg', alt: 'Maxi Vértice', dimensions: {width: 600, height: 800}}, images_count: 1}});
}

(async () => {
    fs.mkdirSync(artifacts, {recursive: true});
    const [platform, app] = await Promise.all([asset('linkedstore.js', platformUrl), asset('cheguei-app.js', appUrl)]);
    const bootstrapEnd = platform.indexOf('var __webpack_exports__=');
    const wrapperModule = platform.match(/(\d+):\(e,t,i\)=>\{Object\.defineProperty\(t,"__esModule",\{value:!0\}\),t\.jQueryNuvem=void 0/);
    assert(bootstrapEnd > 0 && wrapperModule, 'platform contains the real DOM wrapper');
    const wrapper = platform.slice(0, bootstrapEnd) + 'window.jQueryNuvem=__webpack_require__(' + wrapperModule[1] + ').jQueryNuvem;})();';
    const stockParser = app.match(/case 21:f=function\(t\)(\{[^{}]*\})/);
    const stockQuery = 'f(t.querySelector(".hidden[data-store]").getAttribute("data-store"))';
    assert(stockParser && app.includes(stockQuery), 'public app stock check is the original source');
    const stockCheck = 'window.chegueiIsOutOfStock=function(t){var f=function(t)' + stockParser[1] + ';return ' + stockQuery + ';};';
    const browser = await chromium.launch({headless: true, executablePath});
    const report = [];
    try {
        if (process.env.PRODUCT_CART_HOOKS_CASE !== 'counter') {
            for (const reduced of [false, true]) for (const stock of [0, 7, null]) {
                const page = await browser.newPage();
                await page.route('**/*', route => route.abort());
                const errors = [];
                page.on('pageerror', error => errors.push(error.message));
                await page.setContent('<style>.hidden{display:none}</style>' + renderItem(reduced, stock));
                await page.addScriptTag({content: stockCheck});
                const result = await page.locator('[data-product-type="list"]').evaluate(card => window.chegueiIsOutOfStock(card));
                assert.equal(result, stock === 0, 'app interprets actual stock correctly');
                const marker = page.locator('[data-product-type="list"] .hidden[data-store]');
                assert.equal(await marker.count(), 1, 'each card has exactly one native stock marker');
                assert.equal(await marker.getAttribute('data-store'), 'stock-product-100-' + (stock === null ? 'infinite' : stock));
                assert.equal(await marker.isVisible(), false);
                assert.equal(await page.locator('.labels').count(), reduced ? 0 : 1, 'reduced card keeps its compact presentation');
                assert.deepEqual(errors, []);
                report.push({scenario: (reduced ? 'reduced' : 'normal') + ' card: stock ' + stock, passed: true});
                await page.close();
            }
        }
        if (process.env.PRODUCT_CART_HOOKS_CASE !== 'stock') {
            const page = await browser.newPage();
            const errors = [];
            page.on('pageerror', error => errors.push(error.message));
            const rendered = header.render({template: 'product', settings: {ajax_cart: true, search_big_desktop: true}, cart: {items_count: 0}, store: {is_catalog: false, cart_url: '/cart/', customer_accounts: 'optional'}, customer: {name: 'Cliente'}});
            await page.setContent('<header><span class="js-cart-widget-amount">0</span></header>' + rendered);
            await page.addScriptTag({content: wrapper});
            const counter = page.locator('#modal-cart .modal-header p');
            assert.equal(await counter.textContent(), '(0)');
            for (const count of [1, 2, 0]) {
                // This is the exact selector/API used in LS.updateCartEnhanced,
                // and in the platform's quantity/remove response updates.
                await page.evaluate(value => window.jQueryNuvem('.js-cart-widget-amount').html(value), count);
                assert.equal(await page.locator('header .js-cart-widget-amount').textContent(), String(count));
                assert.equal(await counter.textContent(), '(' + count + ')', 'modal follows native cart updates and preserves parentheses');
                assert.equal(await page.locator('#modal-cart .js-cart-widget-amount').count(), 1);
                assert.deepEqual(errors, []);
                report.push({scenario: 'native cart count update: ' + count, passed: true});
            }
            await page.close();
        }
        fs.writeFileSync(path.join(artifacts, 'product-cart-hooks-regression.json'), JSON.stringify({platformUrl, appUrl, checkoutTested: false, scenarios: report}, null, 2));
        console.log('PASS: ' + report.length + ' cenarios: estoque real do app em cards normais/reduzidos e contador do modal com jQueryNuvem real.');
    } finally {
        await browser.close();
    }
})().catch(error => {console.error(error); process.exitCode = 1;});
