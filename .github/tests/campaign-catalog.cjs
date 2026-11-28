const {test}=require('node:test');
const assert=require('node:assert/strict');
const fs=require('node:fs');
const Twig=require('twig');
const {JSDOM,VirtualConsole}=require('jsdom');
const fixture=require('./best-sellers-harness.cjs');
const read=p=>fs.readFileSync(p,'utf8');
test('busca interna da campanha dispensa o layout completo como bolsas e oculos',()=>{
 const condition=read('layouts/layout.tpl').match(/{% if [^\n]+%}/)[0];
 const route=Twig.twig({data:condition+'feed{% else %}loja inteira{% endif %}',rethrow:true});
 for(const params of [{campaign10_feed:'1'},{be_feed:'4'},{oe_feed:'4'}]) {
  assert.equal(route.render({template:'search',params}),'feed');
 }
 assert.equal(route.render({template:'search',params:{}}),'loja inteira');
});
test('resposta interna da campanha nao inclui a grade normal da busca',()=>{
 const header=Twig.twig({id:'snipplets/page-header.tpl',data:'<header>Busca normal</header>',allowInlineIncludes:true});
 Twig.twig({id:'snipplets/product_grid.tpl',data:'GRADE NORMAL'});
 Twig.twig({id:'snipplets/grid/pagination.tpl',data:'PAGINACAO NORMAL'});
 const search=Twig.twig({data:read('templates/search.tpl').replace(/{% paginate by \d+ %}/g,''),allowInlineIncludes:true,rethrow:true});
 const data=fixture.context({noCommunity:true});
 const html=search.render({...data,params:{campaign10_feed:'1'},query:'"bolsasverao"',products:data.category_products.slice(0,1),pages:{is_last:true},settings:{...data.settings,campaign_page_10_models:[{image:'/a.jpg',link:'bolsasverao'}]}});
 assert.match(html,/data-bs-category-feed/);
 assert.doesNotMatch(html,/js-product-table|GRADE NORMAL|Busca normal/);
});
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
async function setup(category='/verao-produtos/',fail=false,paginate=false){
 const errors=[];const vc=new VirtualConsole();vc.on('jsdomError',e=>errors.push(e.message));
 const dom=new JSDOM(render({campaign_page_10_catalog_url:category,campaign_page_10_filters_enabled:false}),{url:'https://eora.test/verao/',runScripts:'outside-only',pretendToBeVisual:true,virtualConsole:vc});
 const w=dom.window,d=w.document,calls=[];w.matchMedia=()=>({matches:false,addEventListener(){}});w.scrollTo=()=>{};w.HTMLElement.prototype.scrollTo=function(){};
 w.fetch=async value=>{let u=new URL(value);calls.push(u.href);assert.ok(u.pathname==='/search/'||(paginate&&u.pathname==='/search/page/2/'));assert.ok(['"bolsasverao"','"oculosverao"'].includes(u.searchParams.get('q')));assert.equal(u.searchParams.get('campaign10_feed'),'1');if(fail){fail--;throw Error('offline');}if(paginate&&u.searchParams.get('q')==='"oculosverao"'){const last=u.pathname.includes('/page/2/');return {ok:true,url:u.href,text:async()=>'<template data-bs-category-feed data-last="'+(last?'1':'0')+'" data-next="'+(last?'':'/search/page/2/?q=%22oculosverao%22&amp;campaign10_feed=1')+'">'+card(last?3:2,'oculosverao')+'</template>'};}return {ok:true,url:u.href,text:async()=>'<template data-bs-category-feed data-last="1">'+card(1,'bolsasverao')+card(2,'oculosverao')+'</template>'};};
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
test('erro de catálogo oferece nova tentativa',async()=>{const b=await setup('/verao-produtos/',3);try{await until(()=>!b.d.querySelector('[data-bs-retry]').hidden);b.d.querySelector('[data-bs-retry]').click();await until(()=>b.d.querySelectorAll('[data-bs-grid] [data-be-product]').length===2);}finally{b.close();}});

test('carrega a segunda pagina nativa antes de filtrar os oculos',async()=>{
const b=await setup('/categoria-configurada/',false,true);
try{await until(()=>b.d.querySelector('[data-bs-page]').dataset.bsCatalogReady==='1');assert.ok(b.calls.some(u=>new URL(u).pathname==='/search/page/2/'));b.d.querySelector('[data-bs-category="2"]').click();assert.equal(b.d.querySelectorAll('[data-bs-grid] [data-be-product]').length,2);assert.deepEqual(b.errors,[]);}finally{b.close();}
});

test('falha temporaria recupera automaticamente sem perder produtos',async()=>{const b=await setup('/verao-produtos/',1);try{await until(()=>b.d.querySelector('[data-bs-page]').dataset.bsCatalogReady==='1');assert.equal(b.d.querySelectorAll('[data-bs-grid] [data-be-product]').length,2);assert.equal(b.d.querySelector('[data-bs-retry]').hidden,true);}finally{b.close();}});
