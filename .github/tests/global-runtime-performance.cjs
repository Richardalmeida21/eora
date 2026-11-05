const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const Twig = require('twig');
const {chromium} = require('playwright');
const source = fs.readFileSync(path.resolve(__dirname, '../../static/js/store.js.tpl'), 'utf8');
const transition = source.slice(source.indexOf('    const inViewport ='), source.indexOf('    applyMarqueeAnimation ='));
const scroll = source.slice(source.indexOf('        var didScroll;') >= 0 ? source.indexOf('        var didScroll;') : source.indexOf('        var headerScrollTimer'), source.indexOf('    {% if has_only_mobile_with_fixed_nav %}', source.indexOf('        function hasScrolled()')));
const renderScroll = template => Twig.twig({data:scroll,rethrow:true}).render({template});
(async () => {
 const browser = await chromium.launch({headless:true,executablePath:process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
 try {
  const page = await browser.newPage({viewport:{width:390,height:844}});
  await page.setContent('<header class="js-head-main" style="height:70px"></header><div class="js-adbar" style="height:20px"></div><main style="height:6000px">' + Array.from({length:100},()=>'<section data-transition style="height:60px">Conteúdo</section>').join('') + '</main>');
  await page.addScriptTag({content:`window.ioInstances=0;const NativeIO=IntersectionObserver;window.IntersectionObserver=class extends NativeIO{constructor(...args){super(...args);ioInstances++}};` + transition});
  assert.equal(await page.evaluate(()=>ioInstances),1,'shared transitions use one observer instead of one per element');
  await page.waitForFunction(()=>document.querySelector('[data-transition]').classList.contains('is-inViewport'));
  await page.locator('[data-transition]').last().scrollIntoViewIfNeeded();
  await page.waitForFunction(()=>Array.from(document.querySelectorAll('[data-transition]')).at(-1).classList.contains('is-inViewport'));
  await page.close();
  for(const template of ['home','category','page','product','search']){
   const p=await browser.newPage({viewport:{width:390,height:844}});
   await p.setContent('<header class="js-head-main" style="height:70px"></header><div class="js-adbar" style="height:20px"></div><main style="height:6000px"></main>');
   await p.addScriptTag({content:`
    window.periodicTimers=0;window.categoryOffsets=0;const nativeInterval=setInterval;window.setInterval=(...args)=>{periodicTimers++;return nativeInterval(...args)};
    window.offsetCategories=()=>categoryOffsets++;
    window.jQueryNuvem=selector=>{const el=document.querySelector(selector);return {outerHeight:()=>el?.getBoundingClientRect().height||0,addClass(c){el.classList.add(c);return this},removeClass(c){el.classList.remove(c);return this},css(k,v){el.style[k]=v;return this}}};
   `+renderScroll(template)});
   await p.waitForTimeout(550);
   assert.equal(await p.evaluate(()=>periodicTimers),0,template+': no header polling timers while idle');
   await p.evaluate(()=>scrollTo(0,500));await p.waitForFunction(()=>document.querySelector('header').classList.contains('compress'));
   assert.equal(await p.locator('header').evaluate(e=>e.style.top),'-20px');
   await p.evaluate(()=>scrollTo(0,100));await p.waitForFunction(()=>!document.querySelector('header').classList.contains('compress'));
   assert.equal(await p.locator('header').evaluate(e=>e.style.top),'0px');
   if(template==='category')await p.waitForFunction(()=>categoryOffsets>0);
   await p.close();
  }
  console.log('PASS global runtime: one shared transition observer, animations preserved, zero idle header polling, scroll direction and category offsets preserved on five templates.');
 }finally{await browser.close()}
})().catch(e=>{console.error(e);process.exitCode=1});
