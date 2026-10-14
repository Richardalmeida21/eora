const assert=require('node:assert/strict');
const {test}=require('node:test');
const fs=require('node:fs');
const path=require('node:path');
const Twig=require('twig');
const {buildTemplate}=require('../scripts/build-portuguese-product-titles.cjs');
const root=path.resolve(__dirname,'../..');
const compiled=(id,data)=>{Twig.cache(false);const template=Twig.twig({id,data,allowInlineIncludes:true,rethrow:true});Twig.cache(true);return template;};
compiled('snipplets/product-name-pt.tpl',fs.readFileSync(path.join(root,'snipplets/product-name-pt.tpl'),'utf8'));
compiled('snipplets/product-name-pt-v2-data.tpl',buildTemplate([{id:1,name:{pt:'MAXI VÉRTICE'}}]));
test('actual product, card and cart title expressions render with the shared lookup',()=>{
    for(const file of ['snipplets/product/product-form.tpl','snipplets/bolsas-eora/product-card.tpl','snipplets/grid/item.tpl','snipplets/cart-item-ajax.tpl']){
        const source=fs.readFileSync(path.join(root,file),'utf8');
        const setup=source.split('\n').slice(0,2).join('\n');
        const output=source.match(/{{ oe_product_(?:name|title) \| escape }}/)?.[0];
        assert(output,'a real visible title exists in '+file);
        const template=Twig.twig({data:setup+output,allowInlineIncludes:true,rethrow:true});
        assert.equal(template.render({product:{id:1,name:'FOREIGN'},item:{product:{id:1},short_name:'FOREIGN'},languages:[{active:true,lang:'en'}]}).trim(),'MAXI VÉRTICE');
    }
});
test('the previous complete snapshot renders during a data-file switch',()=>{
    compiled('snipplets/product-name-pt-v2-data.tpl','');
    compiled('snipplets/product-name-pt-v2-data.backup.tpl',buildTemplate([{id:1,name:{pt:'PREVIOUS PT TITLE'}}]));
    const template=Twig.twig({data:'{% import "snipplets/product-name-pt.tpl" as titles %}{{ titles.get(1,"FOREIGN",current_language,languages) }}',allowInlineIncludes:true,rethrow:true});
    assert.equal(template.render({languages:[{active:true,lang:'en'}]}),'PREVIOUS PT TITLE');
    compiled('snipplets/product-name-pt-v2-data.backup.tpl','');
    assert.equal(template.render({languages:[{active:true,lang:'en'}]}),'FOREIGN');
});
test('stock-error titles preserve the variant suffix and the Portuguese live title',()=>{
    compiled('snipplets/product-name-pt-v2-data.tpl',buildTemplate([{id:1,name:{pt:'MAXI VÉRTICE'}}]));
    const template=Twig.twig({data:'{% import "snipplets/product-name-pt.tpl" as titles %}{{ titles.full(1,"FOREIGN","FOREIGN (Marrom / Prata)",current_language,languages) }}',allowInlineIncludes:true,rethrow:true});
    assert.equal(template.render({languages:[{active:true,lang:'en'}]}),'MAXI VÉRTICE (Marrom / Prata)');
    assert.equal(template.render({languages:[{active:true,lang:'pt'}]}),'FOREIGN (Marrom / Prata)');
});
