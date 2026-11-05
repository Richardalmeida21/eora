const assert=require('node:assert/strict');const fs=require('node:fs');const path=require('node:path');const {chromium}=require('playwright');
const root=path.resolve(__dirname,'../..');
(async()=>{
const b=await chromium.launch({headless:true,executablePath:process.env.BE_BROWSER||'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
try{
for(const file of ['templates/product.tpl','static/js/store.js.tpl','maxivertice.html','hobo.html','vertice.html']){
 const source=fs.readFileSync(path.join(root,file),'utf8');const frames=[...source.matchAll(/<iframe\b[^>]*>/g)].map(m=>m[0]).filter(s=>file==='templates/product.tpl'||/embedUrl/.test(s));
 assert(frames.length>0,file+': actual video markup exists');
 assert(frames.every(s=>/data-eora-video-src="/.test(s)&&!/\ssrc="/.test(s)),file+': below-fold video players must wait for visibility');
 const frame=frames[0].replace(/data-eora-video-src="[^"]*"/,'data-eora-video-src="https://video.test/player"');const p=await b.newPage({viewport:{width:390,height:844}});const requests=[];
 await p.route('https://video.test/**',r=>{requests.push(r.request().url());return r.fulfill({contentType:'text/html',body:'<h1>Video fixture</h1>'})});
 await p.setContent('<div style="height:1800px"></div><div class="js-product-video">'+frame+'</iframe></div>');
 await p.addScriptTag({content:fs.readFileSync(path.join(root,'static/js/product-video-loading.js.tpl'),'utf8')});await p.waitForTimeout(200);
 assert.equal(requests.length,0,file+': player beyond the viewport is not fetched');const fetched=p.waitForResponse('https://video.test/player');await p.locator('iframe').scrollIntoViewIfNeeded();await fetched;
 assert.equal(requests.length,1,file+': video loads when reached');
 await p.evaluate(()=>{scrollTo(0,0);document.querySelector('.js-product-video').innerHTML='<iframe data-eora-video-src="https://video.test/next"></iframe>';});await p.waitForTimeout(100);assert.equal(requests.length,1,'replacement video also waits');
 const next=p.waitForResponse('https://video.test/next');await p.locator('iframe').scrollIntoViewIfNeeded();await next;assert.equal(requests.length,2,'replacement loads on approach');await p.close();
 console.log('PASS '+file+': video loads on approach, retains autoplay permissions and source.');
}
const fallback=await b.newPage();const fallbackRequests=[];
await fallback.route('https://video.test/fallback',r=>{fallbackRequests.push(r.request().url());return r.fulfill({contentType:'text/html',body:'Player'})});
await fallback.setContent('<div class="js-product-video"><iframe data-eora-video-src="https://video.test/fallback"></iframe></div>');
await fallback.evaluate(()=>delete window.IntersectionObserver);
const fallbackLoaded=fallback.waitForResponse('https://video.test/fallback');
await fallback.addScriptTag({content:fs.readFileSync(path.join(root,'static/js/product-video-loading.js.tpl'),'utf8')});await fallbackLoaded;
assert.equal(fallbackRequests.length,1,'unsupported IntersectionObserver falls back to immediate playback');await fallback.close();console.log('PASS fallback: player remains available without IntersectionObserver.');
}finally{await b.close()}
})().catch(e=>{console.error(e);process.exitCode=1});
