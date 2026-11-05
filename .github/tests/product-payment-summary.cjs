const fs = require('node:fs');
const assert = require('node:assert/strict');
const {chromium} = require('playwright');
const Twig = require('twig');
const root = require('node:path').resolve(__dirname, '../..');
const read = p => fs.readFileSync(root + '/' + p, 'utf8');
Twig.extendFilter('money', n => (Number(n)/100).toLocaleString('pt-BR', {style:'currency',currency:'BRL'}));
Twig.extendFunction('component', () => '<span class="js-max-installments-container">native terms</span>');
(async () => {
 assert(fs.existsSync(root+'/snipplets/product/payment-summary.tpl'), 'shared payment summary must exist');
 const tpl=Twig.twig({data:read('snipplets/product/payment-summary.tpl'),rethrow:true});
 const render=(price,other={})=>tpl.render({payment_product:{id:1,url:'/produtos/bolsa/',display_price:true,price,...other}});
 assert.match(render(274990), /2\.612,41/);
 assert.match(render(139990), /1\.329,91/);
 assert.match(render(29700), /2x/);
 assert.match(render(29700), /148,50/);
 assert.match(render(29700,{available:false}), /5% OFF/);
 assert.doesNotMatch(render(29700,{display_price:false}), /5% OFF|data-eora-payments/);
 assert.doesNotMatch(render(undefined), /5% OFF|data-eora-payments/);
 assert.doesNotMatch(render(29700,{show_installments:false}), /2x|sem juros/);
 assert.match(render(29700,{get_max_installments:{installment:3}}), /native terms/);
 assert.doesNotMatch(render(29700,{get_max_installments:{installment:1}}), /2x/);
 assert.match(render(29700), /\/produtos\/bolsa\/#shipping/);
 assert.doesNotMatch(render(29700), /Economize|Frete gr/);
 const browser=await chromium.launch({executablePath:process.env.BE_BROWSER||'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe',headless:true});
 try {
  const page=await browser.newPage();
  const fixture=require('./bolsas-eora-harness.cjs');
  const card=fixture.render('snipplets/bolsas-eora/product-card.tpl',{...fixture.context(),product:fixture.product(1)});
  for (const width of [1440,390]) {
   await page.setViewportSize({width,height:900});
   await page.setContent('<style>'+read('static/css/bolsas-eora.css')+read('static/css/product-commerce.css')+'</style><main class="be-page"><div style="width:180px">'+card+'</div></main>');
   const boxes=await page.evaluate(()=>({price:document.querySelector('.be-product__price').getBoundingClientRect().toJSON(),summary:document.querySelector('[data-eora-payments]').getBoundingClientRect().toJSON(),card:document.querySelector('.be-product').getBoundingClientRect().toJSON()}));
   assert(boxes.summary.y>=boxes.price.bottom,'payment summary must follow price vertically on campaign cards');
   assert(boxes.summary.right<=boxes.card.right,'payment summary must fit a narrow product card');
  }

  const external=tpl.render({payment_product:{display_price:true,price:29700,get_max_installments:{installment:2}},payment_native_installments:true});
  await page.setContent('<div id="native"><span class="js-max-installments-container">native terms</span>'+external+'</div>');
  await page.evaluate(()=>window.EoraProductPayments&&window.EoraProductPayments.update(document.querySelector('#native')));
  await page.addScriptTag({content:read('static/js/product-payment-summary.js.tpl')});
  await page.evaluate(()=>window.EoraProductPayments.update(document.querySelector('#native'),{price_number_raw:29700,display_price:true,installments_data:{card:{2:{without_interests:true,installment_value:148.5}}}}));
  assert(await page.locator('[data-eora-fallback-installments]').isHidden(),'external native component must not get duplicate installments');
  await page.setContent('<div id="card"><span class="js-price-display" data-product-price="29700">R$ 297,00</span>'+render(29700)+'</div>');
  await page.addScriptTag({content:read('static/js/product-payment-summary.js.tpl')});
  await page.evaluate(()=>window.EoraProductPayments.update(document.querySelector('#card'),{price_number_raw:139990,display_price:true}));
  assert.match(await page.locator('[data-eora-pix-price]').textContent(), /1\.329,91/);
  assert.match(await page.locator('[data-eora-fallback-installments]').textContent(), /10x/);
  await page.evaluate(()=>window.EoraProductPayments.update(document.querySelector('#card'),{price_number_raw:274990,display_price:true,installments_data:JSON.stringify({card:{3:{without_interests:true,installment_value:916.63},10:{without_interests:false,installment_value:300}}})}));
  assert.match(await page.locator('[data-eora-fallback-installments]').textContent(), /3x.*916,63/);
  await page.evaluate(()=>window.EoraProductPayments.update(document.querySelector('#card'),{price_number_raw:29700,display_price:true,installments_data:'invalid'}));
  assert(await page.locator('[data-eora-fallback-installments]').isHidden(), 'malformed native data must not fabricate fallback terms');
  await page.evaluate(()=>window.EoraProductPayments.update(document.querySelector('#card'),{price_number_raw:0,display_price:false}));
  assert(await page.locator('[data-eora-payments]').isHidden());
  await page.evaluate(()=>window.EoraProductPayments.update(document.querySelector('#card'),{price_number_raw:29700,display_price:true}));
  assert(await page.locator('[data-eora-payments]').isVisible());
  await page.evaluate(()=>{const old=document.querySelector('#card');const copy=old.cloneNode(true);copy.id='new-card';document.body.appendChild(copy);copy.querySelector('.js-price-display').dataset.productPrice='139990';window.EoraProductPayments.update(copy)});
  assert.match(await page.locator('#new-card [data-eora-pix-price]').textContent(),/1\.329,91/);
 } finally {await browser.close()}
 console.log('PASS payment summary: SSR cents, display guards, stock, native data, fallback, variant updates, cloned/new cards');
})().catch(e=>{console.error(e);process.exitCode=1});
