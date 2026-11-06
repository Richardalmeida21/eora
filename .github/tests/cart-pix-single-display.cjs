const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const Twig = require('twig');
const {JSDOM} = require('jsdom');
const source = fs.readFileSync(path.resolve(__dirname, '../../snipplets/cart-totals.tpl'), 'utf8');
Twig.extendFilter('translate', value => value);
Twig.extendFilter('t', value => value);
Twig.extendFilter('money', value => (value / 100).toLocaleString('pt-BR', {style: 'currency', currency: 'BRL'}));
for (const file of ['shipping-free-rest', 'cart-fulfillment']) {
    Twig.twig({id: 'snipplets/shipping/' + file + '.tpl', data: ''});
}
const template = Twig.twig({data: source, rethrow: true, allowInlineIncludes: true});

function render(cartPage, showTotals) {
    return template.render({cart_page: cartPage, settings: {show_price_and_subprice: showTotals},
        store: {}, cart: {subtotal: 274990, total: 274990, items_count: 1, checkout_enabled: true,
            currency: 'BRL', free_shipping: {}, promotional_discount: {promotions_applied: []}}});
}

for (const [cartPage, showTotals, expected] of [[false, true, 1], [false, false, 1], [true, true, 1], [true, false, 0]]) {
    test(`${cartPage ? 'cart page' : 'cart popup'}, totals ${showTotals}: one Pix quote per enabled summary`, () => {
        const dom = new JSDOM(render(cartPage, showTotals));
        try {
            assert.equal(dom.window.document.querySelectorAll('.eora-cart-pix-whole').length, expected);
            const hooks = dom.window.document.querySelector('.eora-cart-payment-discount-hooks');
            assert(hooks.hidden, 'native discount update hooks remain hidden');
            assert(hooks.querySelector('.js-payment-discount-price-cart'));
        } finally { dom.window.close(); }
    });
}
