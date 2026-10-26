const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {chromium} = require('playwright');
const Twig = require('twig');
const {createCanvas} = require('@napi-rs/canvas');
const {spawnSync} = require('node:child_process');
const root = path.resolve(__dirname, '../..');
const read = file => fs.existsSync(path.join(root, file)) ? fs.readFileSync(path.join(root, file), 'utf8') : '';
const source = process.env.EORA_IMAGE_QUALITY_BASELINE ? '' : read('static/js/product-image-quality.js.tpl');
const base = 'https://acdn-us.mitiendanube.com/stores/006/201/247/products/';
const jpg = 'still-vertice-burgundy-mix-frente-slouch-2-0-69ad5cfe15b73d957317926966222609.jpg';
const png = '30-55a696314e00af225017927752414187.png';
const thumb = base + jpg.replace('.jpg', '-1024-1024.webp');
const nextThumb = base + png.replace('.png', '-1024-1024.webp');
const metadata = {product_id:374159103, tags:['bolsa', 'vertice'], images:[
    {filename:jpg, resized_url:thumb, width:2560, height:3472},
    {filename:png, resized_url:nextThumb, width:2400, height:1200}
]};
function bitmap(width, height, type) {
    const canvas = createCanvas(width, height);
    const ctx = canvas.getContext('2d'); ctx.fillStyle = '#8a123b'; ctx.fillRect(0, 0, width, height);
    return canvas.toBuffer(type);
}
const files = new Map([
    [thumb, {body:bitmap(1024,1389,'image/webp'), contentType:'image/webp'}],
    [nextThumb, {body:bitmap(1024,512,'image/webp'), contentType:'image/webp'}],
    [base+jpg, {body:bitmap(2560,3472,'image/jpeg'), contentType:'image/jpeg'}],
    [base+png, {body:bitmap(2400,1200,'image/png'), contentType:'image/png'}]
]);
const configuration = data => `<script type="application/json" data-eora-product-image-sources>${JSON.stringify(data)}</script>`;
const gallery = url => `<div class="eora-product-wrap"><div class="eora-product-gallery"><div class="eora-blg-thumb"><img src="${url}"></div><div class="eora-blg-track"><div class="eora-blg-slide"><img src="${url}"></div></div></div></div>`;
const browserPath = process.env.BE_BROWSER || 'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe';
async function fixture(browser, {dpr=2, width=607, height=607, data=metadata, failOriginal=false, url=thumb}={}) {
    const page = await browser.newPage({viewport:{width:1440,height:1100},deviceScaleFactor:dpr});
    const requests=[]; const errors=[];
    page.on('pageerror', e=>errors.push(e.message));
    await page.route('**/*', route=>{
        const requestUrl=route.request().url();requests.push(requestUrl);
        if (requestUrl==='https://quality.eora.test/') return route.fulfill({contentType:'text/html',body:`<!doctype html><meta name="viewport" content="width=device-width,initial-scale=1"><style>.eora-blg-slide{width:${width}px;height:${height}px}.eora-blg-slide img{width:100%;height:100%;object-fit:cover}.eora-blg-thumb img{width:80px;height:80px}</style><main><div id="single-product">${configuration(data)}<form><input value="preservado"></form></div>${gallery(url)}<div class="eora-bolsa-var-item"><img src="${thumb}"></div><section class="eora-banner-produto"><img src="${thumb}"></section></main>`});
        if (requestUrl===base+jpg && failOriginal) return route.fulfill({status:404,body:'missing'});
        return route.fulfill(files.get(requestUrl)||{status:404,body:'missing'});
    });
    await page.goto('https://quality.eora.test/');
    if(source)await page.addScriptTag({content:source});
    return {page,requests,errors};
}
const selected = page => page.locator('.eora-blg-slide img').evaluate(i=>i.currentSrc);
async function selection(page,url){
    try { await page.waitForFunction(url=>{const i=document.querySelector('.eora-blg-slide img');return i?.complete&&i.currentSrc===url},url,{timeout:2500}); }
    catch(error){assert.fail('Expected '+url+'; got '+JSON.stringify(await page.locator('.eora-blg-slide img').evaluate(i=>({src:i.src,currentSrc:i.currentSrc,srcset:i.srcset,sizes:i.sizes,complete:i.complete,naturalWidth:i.naturalWidth,dpr:devicePixelRatio}))));}
}

(async()=>{
 const browser=await chromium.launch({headless:true,executablePath:browserPath});
 try {
    // Fails if the helper leaves the original 1024 px cap on high density screens.
    for(const dpr of [2,3,1]){
        const f=await fixture(browser,{dpr});
        if(dpr===1){await selection(f.page,thumb);assert(!f.requests.includes(base+jpg),'DPR 1 does not download the full original');}
        else{await selection(f.page,base+jpg);assert.equal(await selected(f.page),base+jpg,'DPR '+dpr+' selects the real JPG original');}
        assert.equal(await f.page.locator('.eora-blg-thumb img').getAttribute('src'),thumb);
        assert.equal(await f.page.locator('.eora-blg-thumb img').getAttribute('srcset'),null,'thumbnails untouched');
        assert.equal(await f.page.locator('.eora-bolsa-var-item img').getAttribute('srcset'),null,'swatches untouched');
        assert.equal(await f.page.locator('.eora-banner-produto img').getAttribute('srcset'),null,'banners untouched');
        assert.equal(await f.page.locator('form input').inputValue(),'preservado');
        assert.deepEqual(f.errors,[]);await f.page.close();
    }
    // Portrait frames displaying a landscape original need sizes based on object-fit:cover.
    const cover=await fixture(browser,{url:nextThumb,width:350,height:437.5,dpr:2});
    await selection(cover.page,base+png);
    assert.equal(await cover.page.locator('.eora-blg-slide img').getAttribute('sizes'),'875px','cover accounts for cropped landscape width');
    await cover.page.evaluate(()=>document.querySelector('.eora-blg-slide').style.height='175px');
    await cover.page.waitForFunction(()=>document.querySelector('.eora-blg-slide img').sizes==='350px');
    await cover.page.close();

    const unknown=await fixture(browser,{url:thumb.replace('-1024-1024','-480-0')});
    assert.equal(await unknown.page.locator('.eora-blg-slide img').getAttribute('srcset'),null,'unassociated URLs are not guessed');
    await unknown.page.close();
    const excluded=await fixture(browser,{data:{...metadata,tags:['maxivertice','clutchvertice']}});
    assert.equal(await excluded.page.locator('.eora-blg-slide img').getAttribute('srcset'),null,'only exact vertice tag');
    await excluded.page.close();

    const deferred=await fixture(browser);
    await selection(deferred.page,base+jpg);
    await deferred.page.evaluate(url=>{
        const gallery=document.querySelector('.eora-product-gallery');
        gallery.style.cssText='position:relative;overflow:hidden;width:607px';
        document.querySelector('.eora-blg-track').insertAdjacentHTML('beforeend','<div class="eora-blg-slide distant" style="position:absolute;left:607px;top:80px"><img src="'+url+'"></div>');
        document.querySelector('.eora-blg-thumb').onclick=()=>document.querySelector('.distant').style.left='0px';
    },nextThumb);
    await deferred.page.waitForTimeout(150);
    assert(!deferred.requests.includes(base+png),'clipped adjacent slides do not download full originals');
    await deferred.page.locator('.eora-blg-thumb').click();
    await deferred.page.waitForFunction(url=>document.querySelector('.distant img').currentSrc===url,base+png);
    await deferred.page.close();

    const rebuild=await fixture(browser);
    await selection(rebuild.page,base+jpg);
    // Real legacy navigation replaces #single-product and repopulates/replaces the custom gallery.
    await rebuild.page.evaluate(({data,markup})=>{
        document.querySelector('#single-product').outerHTML='<div id="single-product"><script type="application/json" data-eora-product-image-sources>'+JSON.stringify(data)+'</'+'script></div>';
        document.querySelector('.eora-product-wrap').outerHTML=markup;
    },{data:{...metadata,product_id:301374832,images:[metadata.images[1]]},markup:gallery(nextThumb)});
    await selection(rebuild.page,base+png);
    await rebuild.page.locator('.eora-blg-thumb').click();
    await rebuild.page.evaluate(url=>document.querySelector('.eora-blg-track').innerHTML='<div class="eora-blg-slide"><img src="'+url+'"></div>',nextThumb);
    await selection(rebuild.page,base+png);
    assert.deepEqual(rebuild.errors,[]);await rebuild.page.close();

    const fallback=await fixture(browser,{failOriginal:true});
    await fallback.page.waitForFunction(url=>{const i=document.querySelector('.eora-blg-slide img');return i?.complete&&i.currentSrc===url&&!i.hasAttribute('srcset')},thumb,{timeout:2500});
    const count=fallback.requests.filter(u=>u===base+jpg).length;
    await fallback.page.evaluate(()=>{document.querySelector('.eora-blg-track').appendChild(document.createElement('span'));window.dispatchEvent(new Event('resize'));});
    await fallback.page.waitForTimeout(100);
    assert.equal(fallback.requests.filter(u=>u===base+jpg).length,count,'failed original is not retried by observers');
    await fallback.page.evaluate(markup=>document.querySelector('.eora-product-wrap').outerHTML=markup,gallery(thumb));
    await fallback.page.waitForTimeout(100);
    assert.equal(fallback.requests.filter(u=>u===base+jpg).length,count,'failed original is not retried after gallery replacement');
    assert.equal(count,1,'one failed request only');assert.deepEqual(fallback.errors,[]);await fallback.page.close();

    Twig.extendFilter('product_image_url',(image)=>base+image.image.replace(/\.[^.]+$/,'-1024-1024.webp'));
    // PHP json_encode(1) is JSON_HEX_TAG; Twig.js ignores the native filter option.
    Twig.extendFilter('json_encode',(value,args)=>{
        const json=JSON.stringify(value);
        return args?.[0]===1 ? json.replace(/</g,'\\u003C').replace(/>/g,'\\u003E') : json;
    });
    const template=Twig.twig({data:read('snipplets/product/product-image-sources.tpl'),rethrow:true});
    const rendered=template.render({product:{id:374159103,tags:['vertice'],images:[{image:jpg,dimensions:{width:2560,height:3472}},{image:png,dimensions:{width:2400,height:1200}}]}});
    const json=rendered.match(/<script[^>]*data-eora-product-image-sources[^>]*>([\s\S]*?)<\/script>/)?.[1];
    assert(json,'native template emits parseable inert metadata');
    assert.deepEqual(JSON.parse(json),{product_id:374159103,tags:['vertice'],images:metadata.images},'original filenames and dimensions survive template rendering');
    const objectTags=template.render({product:{id:374159103,tags:[{tag:'vertice'},{tag:'safe</script>'}],images:[]}});
    const tagJSON=objectTags.match(/<script[^>]*>([\s\S]*?)<\/script>/)?.[1];
    assert.deepEqual(JSON.parse(tagJSON).tags,['vertice','safe</script>'],'native tag objects become safe JSON strings');
    if(process.env.SOBRE_PHP_BIN && process.env.SOBRE_TWIG_AUTOLOAD){
        const program=String.raw`
error_reporting(E_ALL & ~E_DEPRECATED & ~E_USER_DEPRECATED);
require $argv[1];
Twig_Autoloader::register();
$twig=new Twig_Environment(new Twig_Loader_Filesystem($argv[2]), array('autoescape'=>false));
$twig->addFilter(new Twig_SimpleFilter('product_image_url', function($image){return 'https://acdn-us.mitiendanube.com/stores/006/201/247/products/'.preg_replace('/\.[^.]+$/','-1024-1024.webp',$image['image']);}));
echo $twig->render('snipplets/product/product-image-sources.tpl', json_decode(stream_get_contents(STDIN),true));
`;
        const input={product:{id:374159103,tags:[{tag:'vertice'},{tag:'safe</script>'}],images:[{image:jpg,dimensions:{width:2560,height:3472}}]}};
        const native=spawnSync(process.env.SOBRE_PHP_BIN,['-r',program,process.env.SOBRE_TWIG_AUTOLOAD,root],{input:JSON.stringify(input),encoding:'utf8'});
        assert.equal(native.status,0,native.stderr||native.error?.message);
        assert.equal(native.stderr,'','native PHP metadata has no warnings');
        const parsed=JSON.parse(native.stdout.match(/<script[^>]*>([\s\S]*?)<\/script>/)[1]);
        assert.deepEqual(parsed.tags,['vertice','safe</script>']);
        assert.deepEqual(parsed.images,[metadata.images[0]],'native PHP preserves original filename, derivative and dimensions');
    }
    console.log('PASS product-image-quality: DPR 1/2/3, JPG/PNG, cover/resize, exclusions, deferred slides, navigation/rebuild, fallback without loop, native metadata');
 }finally{await browser.close();}
})().catch(e=>{console.error(e);process.exitCode=1;});
