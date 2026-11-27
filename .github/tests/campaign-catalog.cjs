const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const Twig=require('twig');
const {JSDOM}=require('jsdom');
const read=p=>fs.readFileSync(p,'utf8');
Twig.extendFilter('static_url',v=>'/static/'+v);
Twig.extendFilter('settings_image_url',v=>v);
Twig.extendFilter('setting_url',v=>v);
Twig.twig({id:'snipplets/best-sellers/filters.tpl',data:read('snipplets/best-sellers/filters.tpl'),allowInlineIncludes:true,rethrow:true});
const template=Twig.twig({data:read('snipplets/campaign/catalog.tpl'),allowInlineIncludes:true,rethrow:true});
const settings={campaign_page_10_catalog_title:'Verão',campaign_page_10_catalog_url:'/verao-produtos/',campaign_page_10_catalog_types_enabled:true,campaign_page_10_catalog_filters_enabled:true};
const render=s=>template.render({page:{name:'Verão'},settings:{...settings,...s}});
test('editor schema and campaign rendering',()=>{
const names=[...read('config/settings.txt').matchAll(/^\s*name = (\S+)/gm)].map(m=>m[1]);
assert.equal(names.length,new Set(names).size);
assert.match(read('config/settings.txt'),/Página de campanha 10 com filtros/);
assert.match(render(),/data-bs-category-url="\/verao-produtos\/"/);
assert.doesNotMatch(render({campaign_page_10_catalog_filters_enabled:false}),/data-bs-filter-form/);
const html=render({campaign_page_10_catalog_banner_enabled:true,campaign_page_10_catalog_banner:[{image:'desktop.jpg',title:'Campanha'}],campaign_page_10_catalog_banner_mobile:[{image:'mobile.jpg'}]});
assert.match(html,/desktop.jpg/);assert.match(html,/mobile.jpg/);
assert.doesNotMatch(render({campaign_page_10_catalog_banner_enabled:false}),/<picture>/);
for(const p of ['templates/page.tpl','snipplets/templates/page.tpl']) assert.ok(read(p).indexOf("include 'snipplets/campaign/catalog.tpl'")<read(p).indexOf('{% elseif is_on_page %}'));
});
function card(id,name,tags,price){return '<article data-be-product="'+id+'" data-be-name="'+name+'" data-be-price="'+price+'" data-be-tags=\''+JSON.stringify(tags)+'\'><h3><a href="/produto/">'+name+'</a></h3></article>';}
async function browser(overrides={},fail=false){
const dom=new JSDOM(render(overrides),{url:'https://eora.test/verao/',runScripts:'outside-only',pretendToBeVisual:true});
const w=dom.window;w.matchMedia=()=>({matches:false,addEventListener(){}});
w.HTMLDialogElement.prototype.showModal=function(){this.open=true;};
w.HTMLDialogElement.prototype.close=function(){this.open=false;};
let calls=[];
w.fetch=async url=>{calls.push(String(url));if(fail){fail=false;throw Error('offline');}return {ok:true,url:String(url),text:async()=>'<template data-bs-category-feed data-last="1">'+card(1,'Bolsa Vértice',['bolsa','vertice'],20000)+card(2,'Óculos Luma',['oculos','luma'],10000)+'</template>'};};
w.eval(read('static/js/bolsas-eora-filters.js'));
w.eval(read('static/js/oculos-eora-filters.js'));
w.eval(read('static/js/best-sellers-eora.js'));
w.document.dispatchEvent(new w.Event('DOMContentLoaded'));
await new Promise(r=>setTimeout(r,40));
return {w,d:w.document,calls,close:()=>dom.window.close()};
}
test('exclusive collection source, type, price, sort and custom models',async()=>{
const b=await browser({campaign_page_10_catalog_models:[{link:'luma',title:'Luma'}]});const {w,d}=b;
try {
const count=()=>d.querySelectorAll('[data-bs-grid] article').length;
assert.equal(count(),2);assert.equal(b.calls.length,1);assert.match(b.calls[0],/\/verao-produtos\/\?bs_category_feed=1/);
d.querySelector('[data-bs-category="eyewear"]').click();assert.equal(count(),1);
assert.equal(d.querySelector('[data-bs-grid] article').dataset.beProduct,'2');
d.querySelector('[data-bs-open-filters]').click();
assert.ok([...d.querySelectorAll('[name="bs_model"] option')].some(x=>x.value==='luma'));
d.querySelector('[name="min_price"]').value='150';
d.querySelector('[data-bs-filter-form]').dispatchEvent(new w.Event('submit',{cancelable:true}));assert.equal(count(),0);
d.querySelector('[data-bs-reset]').click();assert.equal(count(),2);
const sort=d.querySelector('[data-bs-sort]');sort.value='price-ascending';sort.dispatchEvent(new w.Event('change'));
assert.equal(d.querySelector('[data-bs-grid] article').dataset.beProduct,'2');
}finally{b.close();}
});
test('unconfigured collection does not request a catalog',async()=>{
const b=await browser({campaign_page_10_catalog_url:'',campaign_page_10_catalog_filters_enabled:false});
try{assert.equal(b.calls.length,0);assert.equal(b.d.querySelector('[data-bs-status]').textContent,'Em breve.');}finally{b.close();}
});
test('load error can be retried; disabled filters and default sort work',async()=>{
const b=await browser({campaign_page_10_catalog_filters_enabled:false,campaign_page_10_catalog_sort:'price-ascending'},true);
try{assert.equal(b.d.querySelector('[data-bs-retry]').hidden,false);
b.d.querySelector('[data-bs-retry]').click();await new Promise(r=>setTimeout(r,40));
assert.equal(b.d.querySelector('[data-bs-grid] article').dataset.beProduct,'2');
assert.equal(b.d.querySelector('[data-bs-retry]').hidden,true);
}finally{b.close();}
});
