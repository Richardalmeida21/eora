const assert=require('node:assert/strict');const fs=require('node:fs');const path=require('node:path');const Twig=require('twig');const {chromium}=require('playwright');
const root=path.resolve(__dirname,'../..');const read=f=>fs.readFileSync(path.join(root,f),'utf8');
Twig.extendFilter('static_url',s=>'/static/'+s);Twig.extendFilter('product_image_url',s=>s.url);Twig.extendFilter('translate',s=>s);
// Twig.js lacks the platform's arrow-comparator syntax. Adapt only this existing
// expression, using the same sort key; production templates keep native syntax.
Twig.extendFilter('reference_sort',items=>items.slice().sort((a,b)=>a.sort_key<b.sort_key?-1:a.sort_key>b.sort_key?1:0));
const compile=(id,data=read(id))=>Twig.twig({id,data,allowInlineIncludes:true,rethrow:true});
compile('snipplets/forms/form-select.tpl');
compile('snipplets/product/product-variants.tpl',read('snipplets/product/product-variants.tpl').replace('|sort(item => item.sort_key)','|reference_sort').replace(/with\{/g,'with {'));
const feed=compile('snipplets/product/product-variant-feed.tpl');
const product={id:17,name:'ONYX <modelo>',url:'/produtos/onyx/',tags:[{tag:'produto-gradiente:preto'}],images:[{url:'https://images.test/onyx.webp'}],description:'<script>throw new Error("must not render")</script>'+('heavy content '.repeat(100000)),variants_object:[{id:171,product_id:17,option0:'Preto',available:true}],selected_or_first_available_variant:{id:171},default_options:{0:1},variations:[{id:0,name:'Cor',options:[{id:1,name:'Preto'}]}]};
const other={...product,id:18,url:'/produtos/onyx-azul/',name:'ONYX Azul',tags:[{tag:'produto-gradiente:azul'}],variations:[],variants_object:[]};
const data={product,settings:{product_by_reference:true,product_by_reference_colors:true},complementary_product_list:[other]};
const html=feed.render(data);
assert(html.length<15000,'response excludes large product description');assert(!/<script|<iframe|must not render|heavy content/.test(html),'no players, scripts or description');
(async()=>{
const b=await chromium.launch({headless:true,executablePath:process.env.BE_BROWSER||'C:/Users/rcalmeida/AppData/Local/ms-playwright/chromium-1234/chrome-win64/chrome.exe'});
try{const p=await b.newPage();await p.setContent(html);
assert.deepEqual(await p.locator('.btn-variant-thumb').evaluateAll(es=>es.map(e=>e.getAttribute('href'))),['/produtos/onyx-azul/','/produtos/onyx/'],'reuse native reference ordering and links');
assert.equal(await p.locator('[name="variant_id"]').inputValue(),'171');assert.equal(await p.locator('.js-variation-option').inputValue(),'1');assert.equal(await p.locator('.js-product-name').textContent(),product.name);
assert.deepEqual(await p.locator('#single-product').evaluate(e=>JSON.parse(e.dataset.variants)),product.variants_object);
const raw=read('layouts/layout.tpl');const registered=new Set(['snipplets/product/product-variant-feed.tpl']);for(const m of raw.matchAll(/(?:include|snipplet)\s+["']([^"']+)["']/g)){const id=/^(static|snipplets)\//.test(m[1])?m[1]:'snipplets/'+m[1];if(!registered.has(id)){compile(id,'');registered.add(id);}}
const layout=Twig.twig({data:raw.replace(/{%\s*snipplet\s+(["'])(.*?)\1\s*%}/g,'{% include "snipplets/$2" %}').replace(/{%\s*head_content\s*%}/g,'{{ fixture_head }}').replace(/{%\s*template_content\s*%}/g,'{{ fixture_content }}'),allowInlineIncludes:true,rethrow:true});
Twig.extendFilter('static_inline',()=> '');Twig.extendFilter('script_tag',()=> '');Twig.extendFilter('add_param',s=>s);Twig.extendFilter('has_custom_image',()=>false);Twig.extendFilter('setting_url',s=>s);Twig.extendFilter('settings_image_url',s=>s);Twig.extendFunction('component',()=> '');
const context={...data,template:'product',params:{eora_variant_feed:'1'},page:{},cart:{},store:{},fixture_head:'HEAD_SENTINEL',fixture_content:'CONTENT_SENTINEL'};
const internal=layout.render(context);assert.equal(internal.trim(),html.trim(),'internal branch renders exact feed');
for(const [template,params] of [['product',{}],['home',{eora_variant_feed:'1'}]]){const normal=layout.render({...context,template,params});assert(normal.includes('HEAD_SENTINEL')&&normal.includes('CONTENT_SENTINEL'),'normal pages retain platform content and theme');}
console.log('PASS: real feed and native variant markup, selected options, escaping, payload budget and layout branch isolation.');
}finally{await b.close()}
})().catch(e=>{console.error(e);process.exitCode=1});
