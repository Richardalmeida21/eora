const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const Twig=require('twig');
const {JSDOM,VirtualConsole}=require('jsdom');
const fixtures=require('./bolsas-eora-harness.cjs');
const read=p=>fs.readFileSync(p,'utf8');
for(const p of ['snipplets/campaign/banners.tpl','snipplets/campaign/catalog.tpl']) Twig.twig({id:p,data:read(p),allowInlineIncludes:true,rethrow:true});
const render=(settings={},sections={})=>{
const original=fixtures.oculosContext();
return Twig.twig({ref:'snipplets/campaign/catalog.tpl'}).render({...original,page:{name:'Verão'},settings:{...original.settings,...settings},sections:{...original.sections,...sections}});
};
const models=[{image:'/image.jpg',link:'iris',title:'IRIS'},{image:'/image.jpg',link:'vertice',title:'VÉRTICE'}];
const base={campaign_page_10_catalog_url:'/verao-produtos/',campaign_page_10_models:models,campaign_page_10_filters_enabled:true};
test('campaign editor mirrors every eyewear setting and keeps independent sections',()=>{
const schema=read('config/settings.txt');
const names=[...schema.matchAll(/^\s*name = (\S+)/gm)].map(m=>m[1]);
assert.equal(names.length,new Set(names).size);
const eyewear=schema.slice(schema.indexOf('\nÓculos Eora\n'),schema.indexOf('\nFavoritos da Marcela\n'));
for(const [,name] of eyewear.matchAll(/name = (oculos_eora_\S+)/g)){
const expected=name.replace('oculos_eora_','campaign_page_10_').replace('campaign_page_10_category_url','campaign_page_10_catalog_url');
assert.ok(names.includes(expected),expected);
}
assert.match(read('config/sections.txt'),/\ncampaign_page_10_best\n/);
for(const p of ['templates/page.tpl','snipplets/templates/page.tpl']) assert.ok(read(p).indexOf("include 'snipplets/campaign/catalog.tpl'")<read(p).indexOf('{% elseif is_on_page %}'));
});
test('same visual components and order as Óculos Eora; introduction is optional',()=>{
const data=fixtures.oculosContext();
const settings={...base};
const sections={};
for(const [k,v] of Object.entries(data.settings)) if(k.startsWith('oculos_eora_')) settings[k.replace('oculos_eora_','campaign_page_10_').replace('campaign_page_10_category_url','campaign_page_10_catalog_url')]=v;
for(const [k,v] of Object.entries(data.sections)) if(k.startsWith('oculos_eora_')) sections[k.replace('oculos_eora_','campaign_page_10_')]=v;
const original=new JSDOM(fixtures.render('snipplets/oculos-eora/index.tpl',data));
const campaign=new JSDOM(render(settings,sections));
try{
const classes=d=>[...d.window.document.querySelectorAll('main,main *')].map(n=>n.getAttribute('class')||'');
assert.deepEqual(classes(campaign),classes(original),'shared markup has the exact same class structure and order');
const html=render({...base,campaign_page_10_catalog_banner_enabled:true,campaign_page_10_catalog_banner:[{image:'desktop.jpg'}],campaign_page_10_catalog_banner_mobile:[{image:'mobile.jpg'}]});
assert.match(html,/desktop.jpg/);assert.match(html,/mobile.jpg/);
assert.ok(html.indexOf('be-campaign-intro')<html.indexOf('<nav class="be-models"'));
assert.doesNotMatch(html,/best-sellers-eora.css|campaign-catalog.css|data-bs-page/);
assert.doesNotMatch(render({...base,campaign_page_10_filters_enabled:false}),/data-be-filter-form/);
}finally{original.window.close();campaign.window.close();}
});
function card(i){
const eye=i%2===0;
const tags=eye?['iris','oculos','formato:aviador','tamanho:medio']:['vertice','bolsa','cor:preto','tamanho:media'];
return '<article data-be-product="'+i+'" data-be-name="'+(eye?'Óculos Iris':'Bolsa Vértice')+'" data-be-price="'+(10000+i*100)+'" data-be-tags=\''+JSON.stringify(tags)+'\'><h3><a href="/produto/">Produto '+i+'</a></h3></article>';
}
async function until(check){for(let i=0;i<150;i++){if(check())return;await new Promise(r=>setTimeout(r,10));}throw Error('Timed out');}
async function browser(settings={},isOriginal=false,fail=false){
const data=fixtures.oculosContext();
const markup=isOriginal?fixtures.render('snipplets/oculos-eora/index.tpl',data):render({...base,...settings});
const errors=[];
const console=new VirtualConsole();console.on('jsdomError',e=>errors.push(e.message));
const dom=new JSDOM(markup,{url:'https://eora.test/verao/',runScripts:'outside-only',pretendToBeVisual:true,virtualConsole:console});
const w=dom.window,d=w.document;
w.matchMedia=()=>({matches:false,addEventListener(){}});
w.scrollTo=()=>{};w.HTMLElement.prototype.scrollTo=function(){};
w.HTMLDialogElement.prototype.showModal=function(){this.open=true;};
w.HTMLDialogElement.prototype.close=function(){this.open=false;this.dispatchEvent(new w.Event('close'));};
const calls=[];
w.fetch=async url=>{
url=new URL(url);calls.push(url.href);
assert.ok(url.pathname.startsWith(isOriginal?'/categoria/oculos-eora':'/verao-produtos/'),'never search outside the collection');
if(fail){fail=false;throw Error('offline');}
const page=Number(url.searchParams.get('page')||1);
const last=page===2;
return {ok:true,url:url.href,text:async()=>'<template data-be-search-feed data-tag="__oculos_eora_category__" data-last="'+(last?'1':'0')+'" data-next="'+(last?'':url.pathname+'?page=2')+'">'+Array.from({length:last?6:24},(_,i)=>card(i+1+(last?24:0))).join('')+'</template>'};
};
for(const p of ['bolsas-eora-filters.js','oculos-eora-filters.js','campaign-filters.js','bolsas-eora.js'])w.eval(read('static/js/'+p));
d.dispatchEvent(new w.Event('DOMContentLoaded'));
await until(()=>d.querySelector('[data-be-results]').getAttribute('aria-busy')==='false');
return {w,d,calls,errors,close:()=>w.close()};
}
test('category-only pagination, model selection, facets, combined price and URL history',async()=>{
const b=await browser();const {w,d}=b;const cards=()=>[...d.querySelectorAll('[data-be-results-grid] [data-be-product]')];
try{
assert.equal(cards().length,24);d.querySelector('[data-be-more]').click();
await until(()=>cards().length===30&&d.querySelector('[data-be-results]').getAttribute('aria-busy')==='false');
d.querySelector('[data-be-tag="iris"]').click();
await until(()=>cards().length===15&&d.querySelector('[data-be-results]').getAttribute('aria-busy')==='false');
assert.ok(cards().every(c=>JSON.parse(c.dataset.beTags).includes('iris')));
d.querySelector('[data-be-open-filters]').click();
await until(()=>d.querySelector('[data-be-facet="oe_shape"]'));
assert.equal(d.querySelectorAll('[data-be-facet="oe_bag_color"]').length,0);
d.querySelector('[name="oe_shape"][value="aviador"]').checked=true;
d.querySelector('[name="min_price"]').value='110';
d.querySelector('[data-be-filter-form]').dispatchEvent(new w.Event('submit',{cancelable:true}));
await until(()=>d.querySelector('[data-be-results]').getAttribute('aria-busy')==='false');
assert.ok(cards().length>0&&cards().every(c=>Number(c.dataset.bePrice)>=11000));
assert.ok(new URL(w.location.href).searchParams.has('oe_filters'));
d.querySelector('[data-be-tag="vertice"]').click();
await until(()=>cards().length===15&&d.querySelector('[data-be-results]').getAttribute('aria-busy')==='false');
d.querySelector('[data-be-open-filters]').click();
await until(()=>d.querySelector('[data-be-facet="oe_bag_color"]'));
assert.equal(d.querySelectorAll('[data-be-facet="oe_shape"]').length,0);
d.querySelector('[name="oe_bag_color"][value="preta"]').checked=true;
d.querySelector('[data-be-filter-form]').dispatchEvent(new w.Event('submit',{cancelable:true}));
await until(()=>d.querySelector('[data-be-results]').getAttribute('aria-busy')==='false');
assert.equal(cards().length,15);
assert.ok(b.calls.every(u=>new URL(u).searchParams.get('oe_category_feed')==='1'));
assert.deepEqual(b.errors,[]);
}finally{b.close();}
});
test('no category never falls back to global model search',async()=>{
const b=await browser({campaign_page_10_catalog_url:''});
try{assert.equal(b.calls.length,0);b.d.querySelector('[data-be-tag="iris"]').click();assert.equal(b.calls.length,0);}finally{b.close();}
});
test('retry and disabled filters remain functional',async()=>{
const b=await browser({campaign_page_10_filters_enabled:false},false,true);
try{assert.match(b.d.querySelector('[data-be-status]').textContent,/Não foi possível/);b.d.querySelector('[data-be-more]').click();
await until(()=>b.d.querySelectorAll('[data-be-product]').length===30);
assert.deepEqual(b.errors,[]);}finally{b.close();}
});
test('original eyewear category keeps its runtime and layout',async()=>{
const b=await browser({},true);
try{assert.equal(b.d.querySelectorAll('[data-be-results-grid] [data-be-product]').length,24);assert.deepEqual(b.errors,[]);}finally{b.close();}
});
