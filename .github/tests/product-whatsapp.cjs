const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {test} = require('node:test');
const Twig = require('twig');
const {chromium} = require('playwright');
const {buildTemplate} = require('../scripts/build-portuguese-product-titles.cjs');
const root = path.resolve(__dirname, '../..');
const read = name => fs.existsSync(path.join(root, name)) ? fs.readFileSync(path.join(root, name), 'utf8') : '';
const source = read('static/js/product-whatsapp.js.tpl');
const snippet = read('snipplets/product/product-whatsapp.tpl');
const css = read('static/css/product-whatsapp.css');
const compile = (id, data) => Twig.twig({id, data, allowInlineIncludes: true, rethrow: true});
compile('snipplets/product-name-pt.tpl', read('snipplets/product-name-pt.tpl'));
compile('snipplets/product-name-pt-v2-data.tpl', buildTemplate([{id: 10, name: {pt: 'MAXI VÉRTICE & Prata'}}]));
const template = Twig.twig({data: snippet, allowInlineIncludes: true, rethrow: true});
function render(product = {}, extra = {}) {
    return template.render({template: 'product', home_main_product: false, product: {id: 10, name: 'FOREIGN', url: 'https://eora.test/produtos/maxi/', ...product}, languages: [{active: true, lang: 'en'}], ...extra});
}
function productHtml(product = {}, extra = {}) {
    return '<meta charset="utf-8"><section id="single-product"><h2 class="js-product-name">MAXI VÉRTICE &amp; Prata</h2><form id="product_form" action="/comprar/" method="post"><input name="add_to_cart" value="10" type="hidden"><input type="submit" class="js-addtocart" value="Comprar">' + render(product, extra) + '</form></section>';
}
async function fixture(browser, viewport) {
    const page = await browser.newPage({viewport});
    const requests = [];
    await page.route('https://eora.test/**', route => { requests.push(route.request().url()); return route.fulfill({contentType: 'text/html', body: productHtml()}); });
    // Keep every external composer local; observing its URL never sends a message.
    await page.context().route('https://wa.me/**', route => route.fulfill({contentType: 'text/html', body: '<title>Composer destination</title>'}));
    await page.goto('https://eora.test/produtos/maxi/?vi=123&utm_source=feed&fbclid=secret&preview=1&eora_variant_feed=1#details');
    assert.equal(await page.locator('.js-product-whatsapp').count(), 1, 'the detail form includes its inquiry anchor');
    if (css) await page.addStyleTag({content: css});
    if (source) await page.addScriptTag({content: source});
    await page.evaluate(() => {
        window.cartCalls = 0; window.chegueiCalls = 0; window.submits = 0;
        document.querySelector('form').addEventListener('submit', event => { event.preventDefault(); window.submits++; });
        document.querySelector('.js-addtocart').addEventListener('click', () => window.cartCalls++);
        document.querySelectorAll('button, input[type="submit"]').forEach(button => button.addEventListener('click', () => window.chegueiCalls++));
    });
    return {page, requests};
}
function message(href) {
    const url = new URL(href);
    assert.equal(url.origin + url.pathname, 'https://wa.me/5519999285508');
    return url.searchParams.get('text');
}
test('server output provides a translated, encoded composer link only on product details', () => {
    const html = render();
    const href = html.match(/href="([^"]+)"/);
    assert.ok(href, 'product details render a real anchor before JavaScript');
    assert.equal(message(href[1]), 'Olá! Eu gostaria de mais informações sobre: MAXI VÉRTICE & Prata - https://eora.test/produtos/maxi/');
    assert.equal(render({}, {template: 'home'}).trim(), '');
    assert.equal(render({}, {home_main_product: true}).trim(), '');
    assert.equal(render({}, {quickshop: true}).trim(), '');
});
test('native desktop and mobile activation opens composer without purchase or submission', async () => {
    const browser = await chromium.launch({executablePath: process.env.CHROMIUM_PATH || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe', headless: true});
    try {
        for (const viewport of [{width: 1280, height: 900}, {width: 390, height: 844}]) {
            const {page, requests} = await fixture(browser, viewport);
            const link = page.locator('.js-product-whatsapp');
            await link.focus();
            await page.keyboard.press('Escape');
            assert.equal(await page.locator('.js-product-whatsapp').count(), 1);
            const popupPromise = page.waitForEvent('popup');
            await page.keyboard.press('Enter');
            const popup = await popupPromise;
            await popup.waitForLoadState();
            assert.equal(message(popup.url()), 'Olá! Eu gostaria de mais informações sobre: MAXI VÉRTICE & Prata - https://eora.test/produtos/maxi/?vi=123');
            assert.deepEqual(await page.evaluate(() => [window.cartCalls, window.chegueiCalls, window.submits]), [0, 0, 0]);
            assert.equal(requests.length, 1);
            assert.equal(await link.getAttribute('target'), '_blank');
            assert.match(await link.getAttribute('rel'), /noopener/);
            const style = await link.evaluate(el => ({border: getComputedStyle(el).borderTopWidth, color: getComputedStyle(el).color}));
            assert.deepEqual(style, {border: '1px', color: 'rgb(50, 108, 72)'});
            const box = await link.boundingBox();
            assert.ok(box.width > 200 && box.width <= viewport.width && box.height >= 44);
            await page.close(); await popup.close();
        }
    } finally { await browser.close(); }
});
test('Maxi, Hobo and Vértice stockout clones keep WhatsApp independent of Cheguei and form submission', async () => {
    const browser = await chromium.launch({executablePath: process.env.CHROMIUM_PATH || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe', headless: true});
    try {
        for (const name of ['MAXI VÉRTICE', 'HOBO', 'VÉRTICE']) {
            const {page} = await fixture(browser, {width: 390, height: 844});
            await page.evaluate(name => {
                const native = document.querySelector('#single-product');
                native.style.display = 'none';
                const wrap = document.createElement('section'); wrap.className = 'eora-product-wrap';
                wrap.innerHTML = '<h2 class="eora-product-name"></h2>';
                wrap.querySelector('h2').textContent = name;
                const form = native.querySelector('form').cloneNode(true);
                form.className = 'eora-cloned-product-form'; form.removeAttribute('id');
                form.querySelector('input[type="submit"]').disabled = true;
                const cheguei = document.createElement('button'); cheguei.textContent = 'Avise-me'; form.appendChild(cheguei);
                // Existing custom product scripts forward precisely these controls.
                form.querySelectorAll('button, input[type="submit"]').forEach(button => button.addEventListener('click', event => {
                    event.preventDefault(); window.chegueiCalls++;
                }));
                form.addEventListener('submit', event => { event.preventDefault(); window.submits++; });
                wrap.appendChild(form); document.body.prepend(wrap);
            }, name);
            assert.equal(await page.locator('.js-product-whatsapp:visible').count(), 1);
            const popupPromise = page.waitForEvent('popup');
            await page.locator('.eora-product-wrap .js-product-whatsapp').click();
            const popup = await popupPromise; await popup.waitForLoadState();
            assert.equal(message(popup.url()), 'Olá! Eu gostaria de mais informações sobre: ' + name + ' - https://eora.test/produtos/maxi/?vi=123');
            assert.deepEqual(await page.evaluate(() => [window.cartCalls, window.chegueiCalls, window.submits]), [0, 0, 0]);
            await page.close(); await popup.close();
        }
    } finally { await browser.close(); }
});
test('cloned forms and reference swaps use scoped current identity, preserving normal modified-click behavior', async () => {
    const browser = await chromium.launch({executablePath: process.env.CHROMIUM_PATH || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe', headless: true});
    try {
        const {page} = await fixture(browser, {width: 1280, height: 900});
        await page.evaluate(() => {
            const wrap = document.createElement('section'); wrap.className = 'eora-product-wrap';
            wrap.innerHTML = '<div class="eora-product-info"><h2 class="eora-product-name">HOBO &lt;Especial&gt;</h2></div>';
            const clone = document.querySelector('form').cloneNode(true); clone.removeAttribute('id');
            clone.querySelector('input[name="add_to_cart"]').value = '20';
            const link = clone.querySelector('.js-product-whatsapp');
            link.dataset.productId = '20'; link.dataset.productUrl = 'https://eora.test/produtos/hobo/?variant=456&utm_campaign=discard';
            wrap.querySelector('div').appendChild(clone);
            document.querySelector('#single-product').style.display = 'none';
            document.body.prepend(wrap);
        });
        const link = page.locator('.eora-product-wrap .js-product-whatsapp');
        // History still points at Maxi while its replacement form has already arrived.
        const result = await link.evaluate(el => {
            const event = new MouseEvent('click', {bubbles: true, cancelable: true, ctrlKey: true});
            const allowed = el.dispatchEvent(event);
            return {href: el.href, allowed};
        });
        assert.equal(result.allowed, true);
        assert.equal(message(result.href), 'Olá! Eu gostaria de mais informações sobre: HOBO <Especial> - https://eora.test/produtos/hobo/?variant=456');
        await page.evaluate(() => history.replaceState(null, '', '/produtos/hobo/?variant=789&gclid=tracking&theme_preview=1'));
        await link.dispatchEvent('pointerdown');
        assert.equal(message(await link.getAttribute('href')), 'Olá! Eu gostaria de mais informações sobre: HOBO <Especial> - https://eora.test/produtos/hobo/?variant=789');
        // Re-running the globally included asset must remain harmless.
        await page.addScriptTag({content: source});
        assert.equal(await page.locator('.eora-product-wrap .js-product-whatsapp').count(), 1);
        assert.deepEqual(await page.evaluate(() => [window.cartCalls, window.chegueiCalls, window.submits]), [0, 0, 0]);
        await page.close();
    } finally { await browser.close(); }
});
