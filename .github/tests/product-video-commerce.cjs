const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const vm = require('node:vm');
const {test} = require('node:test');
const source = fs.readFileSync(path.join(__dirname, '../../static/js/product-video-commerce.js.tpl'), 'utf8');
function fixture(withLoader = true, slugOnly = false) {
    let callback, reloads = 0, timerId = 0;
    const timers = new Map();
    let product = {isConnected:true};
    const old = 'https://www.eoraeyewear.com/produtos/vertice-bordo-mix/';
    const original = 'https://example.test/video-widget.js.php?store=6201247&url=' + encodeURIComponent(slugOnly ? 'vertice-bordo-mix' : old);
    const location = {href:old, reload(){ reloads++; }};
    const nodes = new Map();
    const loads = [];
    function addWidget() {
        for (const id of ['video-bolinha','video-modal','stories-modal']) nodes.set(id, {
            querySelectorAll(){return [{pause(){}}];},
            querySelector(){return {getAttribute(){return 'https://cdn.example.test/product.mp4';}};},
            remove(){nodes.delete(id);}
        });
    }
    addWidget();
    const document = {
        getElementById(id){return id === 'single-product' ? product : nodes.get(id);},
        querySelectorAll(){return withLoader ? [{src:original}] : [];},
        createElement(){return {remove(){}};},
        body:{appendChild(node){loads.push(node);}}
    };
    const window = {addEventListener(){},removeEventListener(){}};
    class MutationObserver {
        constructor(fn){callback=fn;}
        observe(){}
    }
    vm.runInNewContext(source,{window,document,location,URL,MutationObserver,console:{warn(){}},performance:{getEntriesByType(){return [];}},
        setTimeout(fn,ms){timers.set(++timerId,{fn,ms});return timerId;},clearTimeout(id){timers.delete(id);}});
    return {loads,nodes,location,addWidget,advance(){const entry=Array.from(timers.entries()).find(([,v])=>v.ms===150); if(entry){timers.delete(entry[0]);entry[1].fn();}},get reloads(){return reloads;},swap(slug){
        product.isConnected=false;
        product={isConnected:true};
        location.href='https://www.eoraeyewear.com/produtos/'+slug+'/';
        callback();
    },mutate(){callback();}};
}
test('updates only the widget and preserves store identifiers',()=>{
    const f=fixture();
    f.swap('vertice-preto-prata');
    assert.equal(f.loads.length,1);
    assert.equal(f.nodes.has('video-bolinha'),false);
    const next=new URL(f.loads[0].src);
    assert.equal(next.searchParams.get('store'),'6201247');
    assert.equal(next.searchParams.get('url'),f.location.href);
    f.addWidget();
    f.loads[0].onload();
    f.mutate();
    assert.equal(f.loads.length,1);
    assert.equal(f.reloads,0);
});
test('serializes rapid changes and targets the latest reference',()=>{
    const f=fixture();
    f.swap('vertice-preto-prata');
    f.swap('vertice-bordo-prata');
    f.swap('vertice-preto-dourado');
    assert.equal(f.loads.length,1);
    f.addWidget();
    f.loads[0].onload();
    assert.equal(f.nodes.has('video-bolinha'),false);
    assert.equal(f.loads.length,2);
    assert.equal(new URL(f.loads[1].src).searchParams.get('url'),f.location.href);
    f.loads[1].onload();
    assert.equal(f.reloads,0);
});
test('missing widget loader never reloads storefront',()=>{
    const f=fixture(false);
    f.swap('vertice-preto-prata');
    assert.equal(f.reloads,0);
    assert.equal(f.loads.length,0);
});
test('script network failure never reloads storefront',()=>{
    const f=fixture();
    f.swap('vertice-preto-prata');
    f.loads[0].onerror();
    assert.equal(f.reloads,0);
});

test('successful script download without video mount never reloads storefront',()=>{
    const f=fixture();
    f.swap('vertice-preto-prata');
    f.loads[0].onload();
    for(let i=0;i<20;i++) f.advance();
    assert.equal(f.reloads,0);
});

test('supports vendor URLs keyed by exact product slug',()=>{
    const f=fixture(true,true);
    f.swap('vertice-preto-prata');
    assert.equal(new URL(f.loads[0].src).searchParams.get('url'),'vertice-preto-prata');
    assert.equal(f.reloads,0);
});
