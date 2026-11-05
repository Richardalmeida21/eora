const assert=require('node:assert/strict');const fs=require('node:fs');const path=require('node:path');const {chromium}=require('playwright');
const root=path.resolve(__dirname,'../..');
(async()=>{
const b=await chromium.launch({headless:true,executablePath:process.env.BE_BROWSER||'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
try{
for(const file of ['maxivertice.html','hobo.html','vertice.html']){
 const source=fs.readFileSync(path.join(root,file),'utf8');const start=source.indexOf('    function prefetchVariationPages(');const end=source.indexOf('    function reorganizeEoraProductInfo(',start);const requests=[];
 const p=await b.newPage();await p.route('https://custom.test/**',async route=>{
  const u=new URL(route.request().url());if(u.pathname==='/produtos/a/')return route.fulfill({contentType:'text/html',body:'<a class="eora-bolsa-var-item" data-href-path="/produtos/b/" href="/produtos/b/">Cor B</a>'});
  requests.push({path:u.pathname,feed:u.searchParams.get('eora_variant_feed')});
  if(!u.search)await new Promise(r=>setTimeout(r,100));
  return route.fulfill({contentType:'text/html',body:'<div id="single-product" data-name="Cor B do cadastro"></div>'});
 });
 await p.goto('https://custom.test/produtos/a/');await p.addScriptTag({content:'var eoraPageCache={};function normalizePathname(s){return new URL(s,location.href).pathname}function autoGetVariationName(doc){return doc.querySelector("#single-product").dataset.name;}\n'+source.slice(start,end)});
 await p.evaluate(()=>{prefetchVariationPages([{href:'/produtos/a/'},{href:'/produtos/b/'}]);prefetchVariationPages([{href:'/produtos/b/'}]);});
 await p.waitForTimeout(1500);
 assert(requests.every(r=>r.feed==='1'),file+': no complete pages before intent: '+JSON.stringify(requests));
 assert.equal(requests.length,1,file+': current product and duplicate metadata omitted');
 assert.equal(await p.locator('a').getAttribute('data-name'),'Cor B do cadastro');
 await p.locator('a').dispatchEvent('touchstart');await p.locator('a').dispatchEvent('mouseover');
 const value=await p.evaluate(()=>Promise.resolve(eoraPageCache['/produtos/b/']));
 assert(value.includes('single-product'),file+': click can await the prefetched full page');
 assert.equal(requests.filter(r=>r.feed===null).length,1,file+': touch/hover share one complete response');
 await p.close();console.log('PASS '+file+': metadata names, no initial full pages, deduplicated intent fetch and reusable navigation cache.');
}
}finally{await b.close()}
})().catch(e=>{console.error(e);process.exitCode=1});
