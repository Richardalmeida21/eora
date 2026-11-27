const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const Twig=require('twig');
const {JSDOM,VirtualConsole}=require('jsdom');
const fixture=require('./best-sellers-harness.cjs');
const read=p=>fs.readFileSync(p,'utf8');
Twig.twig({id:'snipplets/campaign/catalog.tpl',data:read('snipplets/campaign/catalog.tpl'),allowInlineIncludes:true,rethrow:true});
const models=[{image:'/a.jpg',link:'bolsasverao',title:'Bolsas'},{image:'/b.jpg',link:'oculosverao',title:'Óculos'},{image:'/c.jpg',link:'extra',title:'Extra'}];
function render(overrides={}) {
 const data=fixture.context({noCommunity:true});
 return Twig.twig({ref:'snipplets/campaign/catalog.tpl'}).render({...data,page:{name:'Verão'},settings:{...data.settings,campaign_page_10_catalog_title:'Verão',campaign_page_10_catalog_url:'/verao-produtos/',campaign_page_10_models:models,campaign_page_10_filters_enabled:true,...overrides}});
}
test('banner responsivo precede os dois filtros e usa a categoria configurada',()=>{
 const html=render({campaign_page_10_catalog_banner_enabled:true,campaign_page_10_catalog_banner:[{image:'/desktop.jpg'}],campaign_page_10_catalog_banner_mobile:[{image:'/mobile.jpg'}]});
 const dom=new JSDOM(html); const d=dom.window.document;
 assert.equal(d.querySelectorAll('.bs-macro').length,2);
 assert.deepEqual([...d.querySelectorAll('[data-bs-tag]')].map(x=>x.dataset.bsTag),['bolsasverao','oculosverao']);
 assert.match(html,/desktop.jpg/);assert.match(html,/mobile.jpg/);
 assert.ok(html.indexOf('campaign10-hero')<html.indexOf('<nav class="bs-macros"'));
 assert.equal(d.querySelector('[data-bs-page]').dataset.bsCategoryUrl,'/verao-produtos/');
 assert.ok(d.querySelector('[data-bs-filter-form]'));dom.window.close();
});
test('banner e painel de filtros podem ser desativados',()=>{
 const d=new JSDOM(render({campaign_page_10_catalog_banner_enabled:false,campaign_page_10_filters_enabled:false})).window.document;
 assert.equal(d.querySelector('section.campaign10-hero'),null);assert.equal(d.querySelector('[data-bs-filter-form]'),null);
});
function card(id,tag){return '<article data-be-product="'+id+'" data-be-name="Produto '+id+'" data-be-price="10000" data-be-tags=\x27'+JSON.stringify([tag])+'\x27>Produto '+id+'</article>';}
async function until(fn){for(let i=0;i<200;i++){if(fn())return;await new Promise(r=>setTimeout(r,10));}throw Error('Tempo limite');}
async function setup(category='/verao-produtos/',fail=false){
 const errors=[];const vc=new VirtualConsole();vc.on('jsdomError',e=>errors.push(e.message));
 const dom=new JSDOM(render({campaign_page_10_catalog_url:category,campaign_page_10_filters_enabled:false}),{url:'https://eora.test/verao/',runScripts:'outside-only',pretendToBeVisual:true,virtualConsole:vc});
 const w=dom.window,d=w.document,calls=[];w.matchMedia=()=>({matches:false,addEventListener(){}});w.scrollTo=()=>{};w.HTMLElement.prototype.scrollTo=function(){};
 w.fetch=async value=>{let u=new URL(value);calls.push(u.href);assert.equal(u.pathname,'/search/');assert.ok(['"bolsasverao"','"oculosverao"'].includes(u.searchParams.get('q')));assert.equal(u.searchParams.get('campaign10_feed'),'1');if(fail){fail=false;throw Error('offline');}return {ok:true,url:u.href,text:async()=>'<template data-bs-category-feed data-last="1">'+card(1,'bolsasverao')+card(2,'oculosverao')+'</template>'};};
 for(const p of ['bolsas-eora-filters.js','oculos-eora-filters.js','best-sellers-eora.js'])w.eval(read('static/js/'+p));
 d.dispatchEvent(new w.Event('DOMContentLoaded'));
 return {w,d,calls,errors,close:()=>w.close()};
}
test('filtra as tags mesmo com categoria configurada e permite voltar para todos',async()=>{
 const b=await setup();try{
 await until(()=>b.d.querySelectorAll('[data-bs-grid] [data-be-product]').length===2);
 b.d.querySelector('[data-bs-category="1"]').click();
 await until(()=>b.d.querySelectorAll('[data-bs-grid] [data-be-product]').length===1);
 assert.equal(b.d.querySelector('[data-bs-grid] [data-be-product]').dataset.beProduct,'1');
 b.d.querySelector('[data-bs-reset]').click();await until(()=>b.d.querySelectorAll('[data-bs-grid] [data-be-product]').length===2);
 assert.deepEqual(b.errors,[]);
 }finally{b.close();}
});
test('sem categoria busca somente as duas tags da campanha',async()=>{const b=await setup('');try{await until(()=>b.calls.length===2&&b.d.querySelectorAll('[data-bs-grid] [data-be-product]').length===2);assert.ok(b.calls.every(u=>new URL(u).pathname==='/search/'));assert.deepEqual(b.errors,[]);}finally{b.close();}});
test('erro de catálogo oferece nova tentativa',async()=>{const b=await setup('/verao-produtos/',true);try{await until(()=>!b.d.querySelector('[data-bs-retry]').hidden);b.d.querySelector('[data-bs-retry]').click();await until(()=>b.d.querySelectorAll('[data-bs-grid] [data-be-product]').length===2);}finally{b.close();}});
