const assert=require('node:assert/strict');
const {test}=require('node:test');
const fs=require('node:fs');
const path=require('node:path');
const Twig=require('twig');
const os=require('node:os');
const {once}=require('node:events');
const {publishTemplate}=require('../scripts/publish-portuguese-product-titles.cjs');
const {buildTemplate,readCatalog}=require('../scripts/build-portuguese-product-titles.cjs');
const product=(id,title)=>({id,name:{pt:title,en:'Foreign title',es:'Otro titulo'}});

test('builds a deterministic server template using only Portuguese titles',()=>{
    const result=buildTemplate([product(2,'HOBO'),product(1,'MAXI VÉRTICE')]);
    assert(result.includes("'1': 'MAXI VÉRTICE'"));
    assert(!result.includes('Foreign title'));
    assert.equal(result,buildTemplate([product(1,'MAXI VÉRTICE'),product(2,'HOBO')]));
    assert(result.includes("language starts with 'pt'"));
    assert(result.includes('default(fallback)'));
});
test('escapes Twig string delimiters while preserving exact title content',()=>{
    const result=buildTemplate([product(1,"D'ÁGUA \\ edição #{neverEvaluate} <em> & \"x\"")]);
    assert(result.includes("D\\'ÁGUA \\\\ edição #"));
});

function renderer(title, autoescape=false) {
    const id='title-fixture-'+Math.random();
    Twig.twig({id,data:buildTemplate([product(1,title)]),allowInlineIncludes:true,rethrow:true});
    return Twig.twig({data:'{% import "'+id+'" as titles %}{% set label = titles.get(product.id, product.name, current_language, languages) ~ "" %}<h2>{{ label | escape }}</h2><a title="{{ label | escape }}">{{ label | escape }}</a>',allowInlineIncludes:true,rethrow:true,autoescape});
}
const escape=value=>value.replace(/&/g,'&amp;').replace(/</g,'&lt;').replace(/>/g,'&gt;').replace(/"/g,'&quot;').replace(/'/g,'&#039;');
test('real Twig execution preserves arbitrary product names and escapes HTML sinks',()=>{
    // Twig.js does not decode escaped backslashes like native PHP Twig; their
    // literal encoding is covered above, without pretending this emulator does.
    for(const title of ["D'ÁGUA edição",'MAXI VÉRTICE','#{neverEvaluate} {% if true %} {{ x }} %}','<img src=x onerror=alert(1)> & "quote"', 'A\nB']){
        for(const autoescape of [false,true]){
            const html=renderer(title,autoescape).render({product:{id:1,name:'FOREIGN'},current_language:{code:'en_US'}});
            assert.equal(html.match(/<h2>([\s\S]*?)<\/h2>/)?.[1],escape(title),title+' was not preserved');
        }
    }
});
test('Portuguese uses the live original and foreign locales resolve through either documented language object',()=>{
    const template=renderer('SNAPSHOT');
    const current={product:{id:1,name:'JUST EDITED'}};
    assert(template.render({...current,current_language:{code:'pt_BR'}}).includes('JUST EDITED'));
    for(const context of [{current_language:{code:'en_US'}},{current_language:{id:'es_AR'}},{languages:[{active:true,lang:'en'}]},{languages:[{active:true,code:'es_AR'}]}])assert(template.render({...current,...context}).includes('SNAPSHOT'));
    assert(template.render({...current,languages:[{active:true,lang:'pt'}]}).includes('JUST EDITED'));
    assert(template.render({...current}).includes('JUST EDITED'));
    assert(template.render({product:{id:2,name:'NEW PRODUCT'},current_language:{code:'en_US'}}).includes('NEW PRODUCT'));
});
test('rejects empty, malformed or ambiguous catalogs instead of replacing the last good data',()=>{
    for(const rows of [[],[product(1,'')],[product(1,null)],[product(-1,'X')],[product(1,'X'),product(1,'Y')]]) assert.throws(()=>buildTemplate(rows));
});
test('reads all catalog pages and never makes a write request',async()=>{
    const rows=Array.from({length:205},(_,i)=>product(i+1,'NOVA'));
    const calls=[];
    const result=await readCatalog(async endpoint=>{
        calls.push(endpoint);
        const page=Number(new URL(endpoint,'https://fixture.test').searchParams.get('page'));
        return rows.slice((page-1)*200,page*200);
    });
    assert.equal(result.length,205);
    assert.equal(calls.length,2);
    assert(calls.every(endpoint=>endpoint.startsWith('/products?')));
});
test('new and renamed products produce the next snapshot without changing native language fields',()=>{
    const rows=[product(1,'OLD')];
    buildTemplate(rows);rows[0].name.pt='NOVO';rows.push(product(2,'NOVA'));
    const result=buildTemplate(rows);
    assert(result.includes("'1': 'NOVO'"));assert(result.includes("'2': 'NOVA'"));
    assert.equal(rows[0].name.en,'Foreign title');
});

test('publishes only after complete upload and byte verification, without deleting the live template',async()=>{
    const folder=fs.mkdtempSync(path.join(os.tmpdir(),'eora-title-test-'));
    const localPath=path.join(folder,'titles.tpl');
    const contents=Buffer.from(buildTemplate([product(1,'BEAM')]));fs.writeFileSync(localPath,contents);
    try {
        for(const failure of [null,'upload','verify','rename']){
            const calls=[];let live='OLD';
            const client={
                cd:async dir=>{assert.equal(dir,'/snipplets');calls.push('cd');},
                uploadFrom:async(file,name)=>{assert.equal(file,localPath);assert.equal(name,'.product-name-pt-data.pending.tpl');calls.push('upload');if(failure==='upload')throw new Error('Interrupted transfer');},
                downloadTo:async(target,name)=>{assert.equal(name,'.product-name-pt-data.pending.tpl');calls.push('verify');target.end(failure==='verify'?Buffer.from('truncated'):contents);await once(target,'finish');},
                rename:async(from,to)=>{assert.equal(from,'.product-name-pt-data.pending.tpl');assert.equal(to,'product-name-pt-data.tpl');calls.push('rename');if(failure==='rename')throw new Error('Rename rejected');live=contents.toString();}
            };
            if(failure){await assert.rejects(publishTemplate({client,localPath}));assert.equal(live,'OLD');}
            else {await publishTemplate({client,localPath});assert.equal(live,contents.toString());assert.deepEqual(calls,['cd','upload','verify','rename']);}
            if(failure==='upload'||failure==='verify')assert(!calls.includes('rename'));
        }
    }finally{fs.unlinkSync(localPath);fs.rmdirSync(folder);}
});
