const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {chromium} = require('playwright');
const Twig = require('twig');

// Exercise the theme's actual delegated click handler and the platform's real
// jQueryNuvem DOM wrapper. LS is a contract fixture: these tests do not claim to
// create a server-side cart or to validate checkout/payment.
const root = path.resolve(__dirname, '../..');
const artifacts = process.env.PRODUCT_CART_VALIDATION_DIR || 'C:/Temp/eora-product-cart-validation';
const executablePath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';
const platformAsset = process.env.PRODUCT_CART_PLATFORM_ASSET || path.join(artifacts, 'linkedstore.js');
const platformAssetUrl = 'https://acdn-us.mitiendanube.com/assets/stores/js/linkedstore-v2-4df80ab5f3b4c281f6d175aa1c36fb0930.js?v=47328529';
const source = fs.readFileSync(process.env.PRODUCT_CART_SOURCE || path.join(root, 'static/js/store.js.tpl'), 'utf8');
const start = source.indexOf('{# /* // Add to cart */ #}');
const end = source.indexOf('{# /* // Cart quantitiy changes */ #}', start);
const handler = start < 0 ? source : source.slice(start, end < 0 ? undefined : end);
assert(start >= 0 || process.env.PRODUCT_CART_SOURCE, 'add-to-cart section must be present');
Twig.extendFilter('translate', value => value);
const template = Twig.twig({data: handler, rethrow: true});

function image(attrs = '', classes = '') {
    return '<img class="js-product-slide-img ' + classes + '" ' + attrs + '>';
}
function product({images = '', quick = false, cross = false, state = 'cart', disabled = false, id = '1528884304', formId = 'product_form', quantity = '2', variants = true} = {}) {
    return '<section class="js-product-container ' + (quick ? 'js-quickshop-container js-quickshop-has-variants' : '') + (cross ? ' js-cross-selling-container' : '') + '" data-quantity="3" data-add-to-cart-translation="Adicionar oferta">' + images +
        '<h2 class="js-product-name js-item-name js-cross-selling-product-name">Maxi Vértice</h2><span class="js-price-display js-cross-selling-promo-price">R$ 3.649,90</span>' +
        '<form id="' + formId + '" action="/cart/" method="post"><input name="add_to_cart" value="' + id + '" type="hidden">' +
        (variants ? '<select class="js-variation-option" name="variation[0]"><option selected>Berinjela</option></select><select class="js-variation-option" name="variation[1]"><option selected>Único</option></select><input type="hidden" name="variant_id" value="192837465">' : '') +
        '<input class="js-quantity-input" name="quantity" value="' + quantity + '" type="number">' +
        '<div class="js-item-submit-container"><input type="submit" class="js-addtocart ' + state + '" value="Comprar" ' + (disabled ? 'disabled' : '') + '></div>' +
        '<div class="js-addtocart-placeholder" style="display:none"><span class="js-addtocart-text">Comprar</span><span class="js-addtocart-adding">Adicionando</span><span class="js-addtocart-success">Adicionado</span></div>' +
        '<div class="js-added-to-cart-product-message"></div></form></section>';
}
const notification = '<img class="js-cart-notification-item-img"><span class="js-cart-notification-item-name"></span><span class="js-cart-notification-item-quantity"></span><span class="js-cart-notification-item-price"></span><div class="js-cart-notification-item-variant-container"><span class="js-cart-notification-item-variant"></span></div><span class="js-cart-widget-amount">2</span><span class="js-cart-widget-total">R$ 7.299,80</span><span class="js-cart-counts-plural"></span><span class="js-cart-counts-singular"></span><div class="js-related-products-notification-container"></div><div class="js-cross-selling-modal-body"></div><div id="quickshop-modal" class="modal-show"></div><div class="js-modal-overlay" data-modal-id="#quickshop-modal"></div>';

async function loadPlatformWrapper() {
    fs.mkdirSync(artifacts, {recursive: true});
    if (!fs.existsSync(platformAsset)) {
        const response = await fetch(platformAssetUrl);
        assert(response.ok, 'public platform asset should be downloadable');
        fs.writeFileSync(platformAsset, await response.text());
    }
    const bundle = fs.readFileSync(platformAsset, 'utf8');
    const bootstrapEnd = bundle.indexOf('var __webpack_exports__=');
    const module = bundle.match(/(\d+):\(e,t,i\)=>\{Object\.defineProperty\(t,"__esModule",\{value:!0\}\),t\.jQueryNuvem=void 0/);
    assert(bootstrapEnd > 0 && module, 'platform asset must contain the real jQueryNuvem webpack module');
    // Import only the DOM wrapper module, skipping LS setup and all tracking or
    // network entrypoints. Dependency modules remain the original public code.
    return bundle.slice(0, bootstrapEnd) + 'window.__eoraTestWebpackRequire=__webpack_require__;window.jQueryNuvem=__webpack_require__(' + module[1] + ').jQueryNuvem;})();';
}

async function fixture(browser, wrapper, options = {}) {
    const page = await browser.newPage({viewport: {width: options.width || 1440, height: 900}});
    const errors = [];
    page.on('pageerror', error => errors.push(error.message));
    await page.route('**/*', route => route.abort());
    await page.setContent('<!doctype html><html><head><base href="https://fixture.eora.test/"></head><body>' + (options.outside || '') + product(options) + (options.additional ? product(options.additional) : '') + notification + '</body></html>');
    await page.addScriptTag({content: wrapper});
    await page.evaluate(({restore, response}) => {
        window.cartCalls = [];
        window.pendingCallbacks = [];
        window.modalCalls = [];
        window.timerCalls = [];
        window.submitCalls = [];
        window.recommendationCalls = [];
        window.restoreCalls = 0;
        window.cleanHashCalls = 0;
        window.setTimeout = (callback, delay) => { window.timerCalls.push({callback, delay}); return window.timerCalls.length; };
        window.flushTimers = () => {
            let rounds = 0;
            while (window.timerCalls.length && ++rounds < 20) {
                const timers = window.timerCalls.splice(0).sort((a, b) => a.delay - b.delay);
                timers.forEach(timer => timer.callback());
            }
        };
        document.addEventListener('submit', event => {
            window.submitCalls.push({formId: event.target.id, fields: Array.from(new FormData(event.target).entries())});
            event.preventDefault();
        });
        window.cookieService = {get: () => null, set: () => {}};
        window.modalOpen = selector => window.modalCalls.push(selector);
        window.cleanURLHash = () => window.cleanHashCalls++;
        if (restore) window.restoreQuickshopForm = () => window.restoreCalls++;
        window.createSwiper = (selector, config) => window.recommendationCalls.push({selector, slidesPerView: config.slidesPerView});
        window.hideSwiperControls = () => {};
        window.itemSwiperSpaceBetween = 16;
        window.LS = {
            addToCartEnhanced: (form, copy, adding, stock, editable, success, error) => {
                const element = form.get()[0];
                window.cartCalls.push({formId: element.id, fields: Array.from(new FormData(element).entries()), copy, adding, stock, editable});
                window.pendingCallbacks.push({form: element, success, error});
                window.successCallback = success;
                window.errorCallback = error;
                // Native addToCartEnhanced awaits gateCartUpdate; a denied gate
                // may invoke the error callback in a microtask before the rAF.
                if (response === 'early-error') Promise.resolve().then(error);
            },
            fillCrossSelling: () => {},
        };
    }, {restore: options.restore !== false, response: options.response});
    await page.addScriptTag({content: template.render({settings: {ajax_cart: options.ajax !== false, quick_shop: options.restore !== false, add_to_cart_recommendations: !!options.recommendations}, store: {editable_ajax_cart_enabled: true}})});
    return {page, errors};
}
async function click(page, index = 0) {
    await page.locator('.js-product-container input.js-addtocart').nth(index).evaluate(button => button.click());
    await page.evaluate(() => new Promise(resolve => requestAnimationFrame(() => requestAnimationFrame(resolve))));
}
async function state(page) {
    return page.evaluate(() => {
        const button = document.querySelector('.js-product-container input.js-addtocart');
        const placeholder = document.querySelector('.js-product-container .js-addtocart-placeholder');
        return {calls: window.cartCalls, submits: window.submitCalls, buttonVisible: button.style.display !== 'none', placeholderVisible: placeholder.style.display !== 'none', image: document.querySelector('.js-cart-notification-item-img').getAttribute('srcset'), name: document.querySelector('.js-cart-notification-item-name').textContent, quantity: document.querySelector('.js-cart-notification-item-quantity').textContent, variant: document.querySelector('.js-cart-notification-item-variant').textContent, modals: window.modalCalls, restore: window.restoreCalls, cleanHash: window.cleanHashCalls, recommendationCalls: window.recommendationCalls, prodFormLeaked: Object.hasOwn(window, '$prod_form')};
    });
}

(async () => {
    const wrapper = await loadPlatformWrapper();
    const browser = await chromium.launch({headless: true, executablePath});
    const report = [];
    try {
        if (process.env.PRODUCT_CART_ONLY_TOTALS !== '1') {
        const images = [
            {label: 'produto sem imagem', images: '', expected: ''},
            {label: 'blur sem data-srcset antes da imagem real', images: image('src="/blur.jpg"', 'blur') + image('data-srcset="/maxi.jpg 480w, /maxi-large.jpg 1200w"'), expected: '/maxi.jpg'},
            {label: 'variante ativa sem atributos', images: image('', 'js-active-variant') + image('data-srcset="/maxi.jpg 480w"'), expected: '/maxi.jpg'},
            {label: 'variante ativa de outro produto', outside: '<section class="js-product-container">' + image('data-srcset="/outro.jpg 480w"', 'js-active-variant') + '</section>', images: image('data-srcset="/maxi.jpg 480w"'), expected: '/maxi.jpg'},
            {label: 'variante ativa local', images: image('data-srcset="/inicial.jpg 480w"') + image('data-srcset="/berinjela.jpg 480w"', 'js-active-variant'), expected: '/berinjela.jpg'},
            {label: 'srcset sem data-srcset', images: image('srcset="/maxi-srcset.jpg 480w, /large.jpg 1200w"'), expected: '/maxi-srcset.jpg'},
            {label: 'imagem com apenas data-src', images: image('data-src="/maxi-lazy.jpg"'), expected: '/maxi-lazy.jpg'},
            {label: 'imagem com apenas src', images: image('src="/maxi-src.jpg"'), expected: '/maxi-src.jpg'},
            {label: 'quickshop sem srcset', quick: true, images: '<img class="js-item-image" src="/quick.jpg">', expected: '/quick.jpg'},
            {label: 'quickshop sem nenhuma imagem', quick: true, images: '', expected: ''},
            {label: 'cross selling com imagem src', cross: true, images: '<img class="js-cross-selling-product-image" src="/oferta.jpg">', expected: '/oferta.jpg'},
        ];
        for (const scenario of images) {
            const {page, errors} = await fixture(browser, wrapper, scenario);
            await click(page);
            const before = await state(page);
            assert.deepEqual(errors, [], scenario.label + ': click sem erro JavaScript');
            assert.equal(before.calls.length, 1, scenario.label + ': encaminha a compra à plataforma');
            assert.equal(before.submits.length, 0, scenario.label + ': AJAX evita o submit nativo duplicado');
            assert.equal(before.calls[0].formId, 'product_form');
            const fields = Object.fromEntries(before.calls[0].fields);
            assert.equal(fields.add_to_cart, '1528884304');
            assert.equal(fields.variant_id, '192837465');
            assert.equal(fields['variation[0]'], 'Berinjela');
            assert.equal(fields.quantity, '2');
            assert.equal(before.calls[0].editable, true);
            assert.equal(before.prodFormLeaked, false, 'formulario permanece local ao handler');
            assert.equal(before.buttonVisible, false);
            await page.evaluate(() => { window.successCallback(null, null); window.flushTimers(); });
            const after = await state(page);
            if (scenario.expected) assert(after.image && after.image.includes(scenario.expected), scenario.label + ': imagem correta na notificacao');
            else assert(!after.image || !/undefined|null/.test(after.image), scenario.label + ': sem URL de imagem invalida');
            assert.equal(after.name, 'Maxi Vértice');
            assert.equal(after.quantity, scenario.cross ? '3' : scenario.quick ? '1' : '2');
            assert.equal(after.variant, 'Berinjela, Único');
            assert.equal(after.buttonVisible, true);
            assert.equal(after.placeholderVisible, false);
            assert(after.modals.includes('#modal-cart'));
            assert.deepEqual(errors, [], scenario.label + ': sucesso sem erro JavaScript');
            report.push({scenario: scenario.label, passed: true});
            await page.close();
        }
        for (const quick of [false, true]) {
            const {page, errors} = await fixture(browser, wrapper, {quick, images: '', width: 390});
            await click(page);
            await page.evaluate(() => window.errorCallback());
            const after = await state(page);
            assert.equal(after.calls.length, 1);
            assert.equal(after.buttonVisible, true, 'erro restaura o botao para tentar novamente');
            assert.equal(after.placeholderVisible, false);
            assert.equal(await page.locator('.js-addtocart-adding').evaluate(element => element.classList.contains('active')), false);
            assert.deepEqual(after.modals, [], 'erro nao abre uma confirmacao de compra');
            assert.deepEqual(errors, []);
            report.push({scenario: (quick ? 'quickshop' : 'produto') + ': recuperacao de erro no celular', passed: true});
            await page.close();
        }
        const quickWithoutRestore = await fixture(browser, wrapper, {quick: true, restore: false, width: 390});
        await click(quickWithoutRestore.page);
        await quickWithoutRestore.page.evaluate(() => { window.successCallback(null, null); window.flushTimers(); });
        assert.deepEqual(quickWithoutRestore.errors, [], 'quickshop funciona quando restauracao opcional nao existe');
        assert.equal((await state(quickWithoutRestore.page)).cleanHash, 1);
        report.push({scenario: 'quickshop sem helper de restauracao', passed: true});
        await quickWithoutRestore.page.close();

        for (const complete of ['success', 'error']) {
            const {page, errors} = await fixture(browser, wrapper);
            await click(page);
            // Dispatch another click while the platform request remains pending;
            // a rapid double click must not create a second request.
            await click(page);
            assert.equal((await state(page)).calls.length, 1, 'clique repetido durante a compra gera um unico pedido');
            await page.evaluate(result => {
                if (result === 'success') window.successCallback(null, null);
                else window.errorCallback();
                window.flushTimers();
            }, complete);
            await click(page);
            assert.equal((await state(page)).calls.length, 2, 'apos ' + complete + ' o formulario permite nova compra');
            assert.deepEqual(errors, []);
            report.push({scenario: 'clique duplicado e liberacao apos ' + complete, passed: true});
            await page.close();
        }

        const concurrent = await fixture(browser, wrapper, {additional: {id: '99887766', formId: 'second_product_form', quantity: '3'}});
        await click(concurrent.page, 0);
        await click(concurrent.page, 1);
        let concurrentState = await state(concurrent.page);
        assert.equal(concurrentState.calls.length, 2, 'um formulario pendente nao bloqueia outro produto');
        assert.equal(Object.fromEntries(concurrentState.calls[1].fields).add_to_cart, '99887766');
        assert.equal(Object.fromEntries(concurrentState.calls[1].fields).quantity, '3');
        await concurrent.page.evaluate(() => window.pendingCallbacks[0].error());
        await click(concurrent.page, 0);
        await click(concurrent.page, 1);
        concurrentState = await state(concurrent.page);
        assert.equal(concurrentState.calls.length, 3, 'liberar um formulario preserva a trava do outro');
        assert.equal(concurrentState.calls[2].formId, 'product_form');
        assert.deepEqual(concurrent.errors, []);
        report.push({scenario: 'duas compras independentes: lock por formulario', passed: true});
        await concurrent.page.close();

        const earlyError = await fixture(browser, wrapper, {response: 'early-error'});
        await click(earlyError.page);
        const earlyErrorState = await state(earlyError.page);
        assert.equal(earlyErrorState.calls.length, 1);
        assert.equal(earlyErrorState.buttonVisible, true, 'erro antes do primeiro frame nao deixa botao preso em carregamento');
        assert.equal(earlyErrorState.placeholderVisible, false);
        assert.deepEqual(earlyError.errors, []);
        report.push({scenario: 'erro da plataforma antes do primeiro frame', passed: true});
        await earlyError.page.close();

        for (const options of [{state: 'contact'}, {state: 'catalog'}, {state: 'nostock', disabled: true}, {ajax: false}]) {
            const {page, errors} = await fixture(browser, wrapper, options);
            await click(page);
            const after = await state(page);
            assert.equal(after.calls.length, 0, 'contato, esgotado e fluxo sem AJAX nao adicionam via LS');
            assert.equal(after.submits.length, options.disabled ? 0 : 1, 'submit nativo preservado quando permitido');
            assert.deepEqual(errors, [], 'estado alternativo funciona sem imagem');
            if (options.state) assert.equal(after.buttonVisible, true, 'estado sem compra nao exibe carregamento');
            report.push({scenario: options.state || 'submit nativo sem AJAX', passed: true});
            await page.close();
        }
        const recommendations = await fixture(browser, wrapper, {recommendations: true, images: image('data-srcset="/maxi.jpg 480w"')});
        await click(recommendations.page);
        await recommendations.page.evaluate(() => { window.successCallback('<div class="js-related-products-notification" data-related-amount="6">Recomendacoes</div>', null); window.flushTimers(); });
        const recommendationState = await state(recommendations.page);
        assert(recommendationState.modals.includes('#related-products-notification'));
        assert.equal(recommendationState.recommendationCalls.length, 1);
        assert(!recommendationState.modals.includes('#modal-cart'));
        assert.deepEqual(recommendations.errors, []);
        report.push({scenario: 'recomendacoes preservadas apos adicionar', passed: true});
        await recommendations.page.close();
        }

        // Reproduce the real native listener that was throwing null.style after
        // a successful cart response. Shipping snippets are irrelevant fixtures;
        // the complete actual cart totals template, including PIX script, renders.
        Twig.extendFilter('money', value => (Number(value) / 100).toLocaleString('pt-BR', {style: 'currency', currency: 'BRL'}));
        Twig.extendFilter('t', value => value);
        Twig.extendFunction('component', () => '');
        for (const id of ['snipplets/shipping/shipping-free-rest.tpl', 'snipplets/shipping/cart-fulfillment.tpl']) {
            Twig.twig({id, data: '', rethrow: true, allowInlineIncludes: true});
        }
        const totals = Twig.twig({data: fs.readFileSync(process.env.PRODUCT_CART_TOTALS_SOURCE || path.join(root, 'snipplets/cart-totals.tpl'), 'utf8'), rethrow: true, allowInlineIncludes: true});
        for (const cartPage of [false, true]) for (const showPrice of [false, true]) for (const filled of [false, true]) {
            const page = await browser.newPage();
            const errors = [];
            page.on('pageerror', error => errors.push(error.message));
            const total = filled ? 100000 : 0;
            await page.setContent('<div id="modal-cart">' + totals.render({cart_page: cartPage, settings: {show_price_and_subprice: showPrice, cart_minimum_value: 0}, store: {}, cart: {items_count: filled ? 1 : 0, subtotal: total, total, currency: 'BRL', checkout_enabled: filled, promotional_discount: {promotions_applied: []}, free_shipping: {cart_has_free_shipping: false, min_price_free_shipping: {}}, shipping_data: {}}}) + '</div>');
            await page.addScriptTag({content: wrapper});
            await page.evaluate(() => {
                window.hasMaxPaymentDiscountFixTag = false;
                window.LS = {data: {cart: {}}, formatToCurrency: value => value.toLocaleString('pt-BR', {style: 'currency', currency: 'BRL'})};
                window.__eoraTestWebpackRequire(8531).TotalWithPaymentDiscount.create();
            });
            for (const discounted of [false, true]) {
                const price = discounted ? Math.round(total * 0.95) : total;
                await page.evaluate(({total, price}) => {
                    window.LS.data.cart = {total, max_payment_discount: {price, combinesWithFreeShipping: true, paymentProviderName: 'PIX'}};
                    window.__eoraTestWebpackRequire(4912).CartTotalUpdated.trigger({totals: {}});
                }, {total, price});
                assert.deepEqual(errors, [], 'listener real de desconto nao falha apos atualizacao');
                const hook = page.locator('.js-payment-discount-price-cart-container');
                assert.equal(await hook.count(), 1, 'hook nativo sempre presente em todas as configuracoes');
                assert.equal(await hook.isVisible(), false, 'desconto nativo permanece oculto para manter PIX personalizado');
                if (discounted && filled) {
                    assert.equal(await page.locator('.js-payment-discount-price-cart').getAttribute('data-priceraw-without-shipping'), String(price));
                    assert.equal(await page.locator('.js-payment-discount-name-cart').textContent(), 'PIX');
                }
                report.push({scenario: 'desconto nativo: ' + (cartPage ? 'pagina' : 'popup') + ', total ' + showPrice + ', cheio ' + filled + ', desconto ' + discounted, passed: true});
            }
            await page.close();
        }
        fs.writeFileSync(path.join(artifacts, 'product-add-to-cart-regression.json'), JSON.stringify({platformAssetUrl, contractFixture: true, scenarios: report}, null, 2));
        console.log('PASS: ' + report.length + ' cenarios de add-to-cart com handler real, Twig e jQueryNuvem real. LS validado como contrato local, sem checkout real.');
    } finally {
        await browser.close();
    }
})().catch(error => { console.error(error); process.exitCode = 1; });
