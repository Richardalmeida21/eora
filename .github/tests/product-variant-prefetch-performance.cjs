const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {chromium} = require('playwright');
const root = path.resolve(__dirname, '../..');
const source = fs.readFileSync(path.join(root, 'static/js/eora-variations.js.tpl'), 'utf8');
const thumb = slug => `<a class="btn-variant-thumb" href="/produtos/${slug}/"><img data-src="https://images.test/${slug}.webp"></a>`;
const markup = slugs => '<div id="single-product"><div class="js-color-variants-container">' + slugs.map(thumb).join('') + '</div></div>';
(async () => {
 const browser = await chromium.launch({headless:true,executablePath:process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
 try {
  const page = await browser.newPage();const requests=[],errors=[];let failB=true;
  page.on('pageerror',e=>errors.push(e.message));
  await page.route('https://variants.test/**',route=>{
   const url=new URL(route.request().url());
   if(url.pathname==='/produtos/a/' && !url.search) return route.fulfill({contentType:'text/html',body:markup(['a','b'])});
   requests.push({path:url.pathname,feed:url.searchParams.get('eora_variant_feed')});
   if(url.pathname==='/produtos/b/' && failB){failB=false;return route.fulfill({status:503,body:'unavailable'});}
   return route.fulfill({contentType:'text/html',body:markup(url.pathname==='/produtos/b/'?['b','c']:['a','b','c'])});
  });
  await page.route('https://images.test/**',route=>route.fulfill({contentType:'image/svg+xml',body:'<svg xmlns="http://www.w3.org/2000/svg" width="1" height="1"/>'}));
  await page.goto('https://variants.test/produtos/a/');
  await page.addScriptTag({content:source});
  await page.waitForTimeout(100);
  assert(requests.length>0,'discovery still queries other references');
  assert(requests.every(r=>r.feed==='1'),'automatic discovery must fetch lightweight metadata, never full product pages: '+JSON.stringify(requests));
  await page.locator('a[href="/produtos/b/"]').dispatchEvent('mouseover');
  await page.waitForFunction(()=>document.querySelectorAll('#single-product a.btn-variant-thumb').length===3);
  assert.deepEqual(await page.locator('#single-product a').evaluateAll(es=>es.map(e=>e.getAttribute('href'))),['/produtos/a/','/produtos/b/','/produtos/c/'],'transitive family and canonical links preserved');
  assert(requests.every(r=>r.feed==='1'),'discovered references also use metadata');
  assert.equal(requests.filter(r=>r.path==='/produtos/b/').length,2,'failed metadata request can retry');
  const navigation=page.waitForURL('https://variants.test/produtos/c/');
  await page.locator('a[href="/produtos/c/"]').click();await navigation;
  assert(!new URL(page.url()).searchParams.has('eora_variant_feed'),'normal navigation never shows metadata response');
  assert.deepEqual(errors,[]);
  console.log('PASS: metadata-only discovery, transitive colors, retry, order and canonical product navigation.');
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exitCode=1});
