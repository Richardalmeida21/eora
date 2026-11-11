const {test} = require('node:test');
const assert = require('node:assert/strict');
const fs = require('node:fs');
const {chromium} = require('playwright');

test('campaign notices follow native product and cart promotion updates', async () => {
  const browser = await chromium.launch({headless: true, executablePath: process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
  try {
    const page = await browser.newPage({viewport: {width: 390, height: 844}});
    await page.setContent(`<style>body { margin: 28px; font-family: Arial, sans-serif; } .product-infos { max-width: 520px; } .js-ajax-cart-list, .js-total-promotions { max-width: 520px; margin-top: 32px; } .js-product-description-short { color: #888; line-height: 1.7; }</style><div class="product-infos">
      <h2>NOVA</h2><p>R$1.499,90</p><p style="color:#888">10 X DE R$149,99 SEM JUROS</p><p style="color:#315d4d">R$1.424,91 no Pix &nbsp; 5% OFF</p><u>Frete e prazo pelo CEP</u>
      <div class="js-product-promo-container px-0 mb-2 col-md-8" data-store="product-promotion-info" data-promotion-type="quantity-discounts">
        <div class="mb-1 mt-4 text-accent">10% OFF comprando 2 ou mais!</div>
        <p class="font-small mb-0">Válido para este produto e todos da categoria: Black friday 2026.</p>
        <p class="font-small mb-0">Nesta promoção você pode combinar este produto com outros da mesma categoria.</p>
        <p class="font-small opacity-60 mb-0">Não acumulável com algumas promoções</p>
      </div>
      <div class="js-product-description-short">Descrição do produto</div>
    </div><div class="js-ajax-cart-list"><article class="js-cart-item"><span class="eora-cart-promotion-label">10% OFF <span>Comprando 2 ou mais</span></span><span>Frete grátis</span></article>
    <article class="js-cart-item"><span class="eora-cart-promotion-label">20% OFF Comprando 3 ou mais</span></article></div>
    <div class="js-total-promotions"><span class="js-total-promotions-detail-row"><span class="col">10% OFF em Black friday 2026 <span>Comprando 2 ou mais</span>:</span><span class="col-auto">-R$399,97</span></span></div>`);
    await page.addStyleTag({content: fs.readFileSync('static/css/black-promotion.css', 'utf8')});
    await page.addScriptTag({content: fs.readFileSync('static/js/black-promotion.js.tpl', 'utf8')});
    await page.waitForFunction(() => document.querySelectorAll('.eora-black-notice').length === 3);
    assert(await page.locator('.js-product-description-short').evaluate(el => el.previousElementSibling.classList.contains('js-product-promo-container')));
    assert.equal(await page.locator('.eora-black-notice strong').first().innerText(), 'EORABLACK');
    assert.equal(await page.locator('.eora-black-notice__deadline').first().innerText(), 'CUPOM DISPONÍVEL ATÉ 23:59');
    assert(await page.getByText('20% OFF Comprando 3 ou mais').isVisible());
    assert(await page.getByText('Frete grátis').isVisible());
    assert(await page.getByText('-R$399,97').isVisible());
    assert.equal(await page.locator('.eora-black-notice__deadline').first().evaluate(el => getComputedStyle(el).color), 'rgb(247, 98, 101)');
    assert(await page.locator('.eora-black-notice').evaluateAll(nodes => nodes.every(el => el.getBoundingClientRect().right <= innerWidth)));
    fs.mkdirSync('C:/Temp/eora-black-promotion', {recursive: true});
    await page.screenshot({path: 'C:/Temp/eora-black-promotion/mobile.png', fullPage: true});
    await page.setViewportSize({width: 1440, height: 900});
    await page.screenshot({path: 'C:/Temp/eora-black-promotion/desktop.png', fullPage: true});
    // Native AJAX replaces the cart list and total rows; the new markup must be enhanced once.
    await page.evaluate(() => {
      document.querySelector('.js-ajax-cart-list').innerHTML = '<article class="js-cart-item"><span class="eora-cart-promotion-label">10% OFF Comprando 2 ou mais</span></article>';
      document.querySelector('.js-total-promotions').innerHTML = '';
    });
    await page.waitForFunction(() => document.querySelectorAll('.eora-black-notice').length === 2);
    await page.evaluate(() => document.querySelector('.js-product-promo-container').innerHTML = '<p>20% OFF comprando 3 ou mais!</p>');
    await page.waitForFunction(() => document.querySelectorAll('.eora-black-notice').length === 1);
    assert(await page.getByText('20% OFF comprando 3 ou mais!').isVisible());
  } finally { await browser.close(); }
});
