// Render the production header and all theme styles; Selly markup mirrors its public widget.
const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const os = require('node:os');
const Twig = require('twig');
const sass = require('sass');
const {chromium, webkit} = require('playwright');
const root = path.resolve(__dirname, '../..');
const read = file => fs.readFileSync(path.join(root, file), 'utf8');
const out = process.env.EORA_HEADER_OUTPUT || path.join(os.tmpdir(), 'eora-header-wishlist');
fs.mkdirSync(out, {recursive:true});
Twig.extendFilter('translate', (value, args) => args?.length ? String(args[0]) : value);
Twig.extendFilter('has_custom_image', () => false);
Twig.extendFunction('component', name => {
    const transparent = name.includes('transparent');
    const svg = '<svg xmlns="http://www.w3.org/2000/svg" width="126" height="30"><text x="0" y="26" font-family="serif" font-size="34" textLength="126" lengthAdjust="spacingAndGlyphs">EORA</text></svg>';
    return `<div class="logo-img-container" ${transparent ? '' : 'id="logo"'}><a href="/"><img alt="EORA" width="126" height="30" class="logo-img ${transparent ? 'logo-header-transparent logo-transparent-hover' : ''}" src="data:image/svg+xml,${encodeURIComponent(svg)}"></a></div>`;
});
for (const file of ['snipplets/notification.tpl', 'snipplets/navigation/navigation.tpl', 'snipplets/navigation/navigation-lang.tpl']) Twig.twig({id:file,data:''});
for (const file of ['snipplets/header/header-utilities.tpl','snipplets/header/header-logo.tpl']) Twig.twig({id:file,data:read(file),allowInlineIncludes:true,rethrow:true});
const headerSource = read('snipplets/header/header.tpl').split('</header>')[0] + '</header>';
const header = Twig.twig({data:headerSource.replace(/{% snipplet\s+["']([^"']+)["']\s*%}/g,'{% include "snipplets/$1" %}'),allowInlineIncludes:true,rethrow:true});
const styles = ['style_above','style-critical','style','style-async'].map(name => sass.compile(path.join(root,'static/css/'+name+'.scss'),{logger:sass.Logger.silent}).css).join('\n') + '\n' + (fs.existsSync(path.join(root,'static/css/eora-header.css')) ? read('static/css/eora-header.css') : '');
const nativeStore = read('static/js/store.js.tpl');
const moveWidget = nativeStore.slice(nativeStore.indexOf('    function moveWishlistWidget()'),nativeStore.indexOf('    // Nested Mega Menu Toggle (Desktop)'));
const widget = `<div id="selly-wishlist-widget" style="position:fixed;top:calc(5% + 15px);right:calc(3% + 191px);width:50px;height:50px;border:2.5px solid transparent;display:flex;align-items:center;justify-content:center">
 <svg width="20" height="20" viewBox="0 0 24 24"><path d="M12 21 2 11C-4 0 10-3 12 5 16-3 29 0 22 11Z"/></svg>
 <span id="heart-count-selly" style="width:16px;height:16px;display:flex;align-items:center;justify-content:center;border:1px solid transparent;font-size:12px;padding:9px;position:absolute;top:50%;right:50%;transform:translate3d(30px,-20px,0)">0</span></div>`;
function html(template = 'page', cartCount = 0, options = {}) {
 const settings = {logo_position_mobile:'center',logo_position_desktop:'center',head_fix_desktop:true,ajax_cart:true,head_transparent:true,head_transparent_type:'all',header_colors:true,...options};
 const data = {settings,template,store:{cart_url:'/cart/',customer_login_url:'/account/login/'},cart:{items_count:cartCount},languages:options.languages_header ? [{active:true,country:'BR'},{active:false,country:'US'}] : []};
 return `<!doctype html><html><head><meta name="viewport" content="width=device-width,initial-scale=1"><style>:root{--gutter:16px;--gutter-container:16px;--gutter-container-md:30px;--gutter-negative:-16px;--header-background:#fff;--header-foreground:#111;--main-foreground:#111;--main-background:#fff;--font-base:14px;--heading-font:Arial,sans-serif;--main-text-transform:uppercase;--border-solid:1px solid}body{margin:0}</style><style>${styles}</style></head><body class="template-${template}">${header.render(data)}<main style="height:1800px;background:#fff"></main><script>${readJquery()}</script><script>var jQueryNuvem=jQuery;${moveWidget}moveWishlistWidget();</script></body></html>`;
}
function readJquery() { return fs.readFileSync(require.resolve('jquery/dist/jquery.js'),'utf8'); }
async function boxes(page) {
 return page.evaluate(() => {
  const rect = el => {const r=el.getBoundingClientRect();return {x:r.x,y:r.y,right:r.right,bottom:r.bottom,width:r.width,height:r.height};};
  const visible = el => el.getBoundingClientRect().width > 0 && getComputedStyle(el).visibility !== 'hidden';
  return {logo:rect(document.querySelector('#logo img')),transparentLogo:rect(document.querySelector('.logo-header-transparent')),controls:[...document.querySelectorAll('.head-logo-row a.btn-utility,#selly-wishlist-widget')].filter(visible).map(rect),heart:rect(document.querySelector('#selly-wishlist-widget')),count:rect(document.querySelector('#heart-count-selly')),cart:rect(document.querySelector('#ajax-cart .badge')),overflow:document.documentElement.scrollWidth>innerWidth};
 });
}
function checkLayout(b,width) {
 assert.ok(b.heart.x >= b.logo.right+8-1,`wishlist clears the logo at ${width}px: ${JSON.stringify(b)}`);
 assert.ok(b.logo.width >= 90,`logo remains readable at ${width}px`);
 assert.ok(Math.abs(b.logo.y-b.transparentLogo.y)<1 && Math.abs(b.logo.x-b.transparentLogo.x)<1 && Math.abs(b.logo.width-b.transparentLogo.width)<1,`both logo variants align at ${width}px`);
 assert.ok(b.controls.every(r=>r.x>=12 && r.right<=width-12+1),`all controls stay inside the viewport at ${width}px`);
 assert.ok(b.controls.every(r=>r.width>=32 && r.height>=44),`controls retain usable touch targets at ${width}px`);
 for (const a of b.controls) {
  assert.ok(a.right<=b.logo.x+1 || a.x>=b.logo.right-1,`logo and controls do not overlap at ${width}px`);
  for (const other of b.controls) if (a!==other) assert.ok(a.right<=other.x+1 || a.x>=other.right-1,`click areas do not overlap at ${width}px`);
 }
 assert.ok(b.count.x>=b.heart.x && b.count.right<=b.heart.right+1 && b.count.y>=b.heart.y && b.count.bottom<=b.heart.bottom+1,`wishlist count stays with its button at ${width}px`);
 assert.ok(!b.overflow,`no horizontal scrolling at ${width}px`);
}
(async()=>{
 const engine = process.env.EORA_HEADER_ENGINE === 'webkit' ? webkit : chromium;
 const browser = await engine.launch({headless:true,executablePath:process.env.BE_BROWSER || undefined});
 try {
  for (const scale of [1,3]) {
   const page = await browser.newPage({viewport:{width:390,height:844},deviceScaleFactor:scale,isMobile:true});
   const errors=[];page.on('pageerror',e=>errors.push(e.message));
   for (const template of ['page','home']) {
    await page.setContent(html(template));
    const before = await page.locator('#logo img').boundingBox();
    await page.evaluate(markup=>{const wrapper=document.createElement('div');wrapper.innerHTML=markup;document.body.appendChild(wrapper);},widget);
    await page.waitForFunction(()=>document.querySelector('.block-actions-links #selly-wishlist-widget'));
    for (const width of [320,360,375,390,393,414,430,767,768,844,1024,1199]) {
     await page.setViewportSize({width,height:width===844 ? 390 : 844});
     const b = await boxes(page);checkLayout(b,width);
     if (width===390 && scale===1 && template==='page') {
      assert.ok(Math.abs(before.x-b.logo.x)<1,'async widget does not shift the logo');
      await page.screenshot({path:path.join(out,'header-390.png'),clip:{x:0,y:0,width,height:100}});
     }
    }
    await page.setViewportSize({width:390,height:844});
    for (const count of [1,12,99]) {
     await page.locator('#heart-count-selly').evaluate((el,n)=>{el.textContent=n;el.style.transform='translate3d(30px,-20px,0px) scale(1.3)';},count);
     checkLayout(await boxes(page),390);
    }
    await page.evaluate(()=>document.querySelector('.head-main').classList.add('compress'));
    checkLayout(await boxes(page),390);
    await page.locator('#selly-wishlist-widget').evaluate(el=>{window.wishlistClicks=0;el.addEventListener('click',()=>window.wishlistClicks++);});
    await page.locator('#selly-wishlist-widget').click();
    assert.equal(await page.evaluate(()=>window.wishlistClicks),1,'original widget click handler still runs once');
    await page.locator('#selly-wishlist-widget').evaluate(el=>el.remove());
    await page.evaluate(markup=>document.body.insertAdjacentHTML('beforeend',markup),widget);
    await page.waitForFunction(()=>document.querySelector('.block-actions-links #selly-wishlist-widget'));
    checkLayout(await boxes(page),390);
   }
   await page.setViewportSize({width:390,height:844});
   for (const options of [{head_fix_desktop:false},{languages_header:true}]) {
    await page.setContent(html('page',0,options));
    await page.evaluate(markup=>document.body.insertAdjacentHTML('beforeend',markup),widget);
    await page.waitForFunction(()=>document.querySelector('.block-actions-links #selly-wishlist-widget'));
    const optionalLayout=await boxes(page);checkLayout(optionalLayout,390);
    assert.ok(optionalLayout.controls.every(r=>Math.abs(r.y-optionalLayout.controls[0].y)<1),'optional grid children do not move actions to a second row');
    if (options.languages_header) assert.ok(await page.locator('.eora-header-languages').isVisible(),'optional language selector remains visible');
   }
   await page.setViewportSize({width:1440,height:900});
   await page.setContent(html());
   await page.evaluate(markup=>document.body.insertAdjacentHTML('beforeend',markup),widget);
   await page.waitForFunction(()=>document.querySelector('.block-actions-links #selly-wishlist-widget'));
   assert.equal(await page.locator('.eora-header-row').evaluate(el=>getComputedStyle(el).display),'flex','desktop retains native layout');
   assert.equal((await boxes(page)).heart.width,20,'desktop wishlist retains its previous size');
   assert.deepEqual(errors,[]);
   await page.close();
  }
  console.log('PASS wishlist header ('+engine.name()+'): 320–1199px, portrait/landscape, DPR 1/3, delayed widget/reinsertion, counts, scroll, click behavior and no overlap.');
 } finally {await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
