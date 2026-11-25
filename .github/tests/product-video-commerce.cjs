const assert = require('node:assert/strict');
const fs = require('node:fs');
const path = require('node:path');
const {test} = require('node:test');
const source = fs.readFileSync(path.join(__dirname, '../../static/js/product-video-commerce.js.tpl'), 'utf8');
function fixture() {
    let seq=0, product, nodes=new Map(), timers=new Map(), observers=[], microtasks=[];
    class Target {
        constructor(){this.events=[];}
        addEventListener(type,fn,options){this.events.push({type,fn,options});}
        removeEventListener(type,fn){this.events=this.events.filter(e=>e.type!==type||e.fn!==fn);}
    }
    class Node extends Target {
        constructor(name){super();this.nodeName=name.toUpperCase();this.style={};this.children=[];this.isConnected=true;this.classList={contains:()=>false,remove(){}};}
        appendChild(n){this.children.push(n);if(n.id)nodes.set(n.id,n);return n;}
        remove(){this.isConnected=false;if(this.id)nodes.delete(this.id);}
        querySelectorAll(){return [];}
    }
    class Observer {
        constructor(fn){this.fn=fn;this.active=true;observers.push(this);}
        observe(){}
        disconnect(){this.active=false;}
    }
    const location={href:'https://www.eoraeyewear.com/produtos/vertice-manteiga-mix/'};
    const document=new Target();
    document.body=new Node('body');
    document.head=new Node('head');
    document.readyState='complete';
    document.currentScript=null;
    document.getElementById=id=>nodes.get(id);
    document.querySelectorAll=()=>[];
    document.createElement=name=>new Node(name);
    const window=new Target();
    window.MutationObserver=Observer;
    window.setTimeout=(fn,ms)=>{timers.set(++seq,{fn,ms});return seq;};
    window.setInterval=window.setTimeout;
    window.clearTimeout=id=>timers.delete(id);
    window.clearInterval=window.clearTimeout;
    product=new Node('div');product.id='single-product';nodes.set(product.id,product);
    const nativeAdd=Target.prototype.addEventListener, nativeTimer=window.setInterval;
    new Function('window','document','location','EventTarget','Node','URL','queueMicrotask','console',source)(
        window,document,location,Target,Node,URL,fn=>microtasks.push(fn),{warn(){}}
    );
    function flush(){while(microtasks.length)microtasks.shift()();}
    function scriptFor(slug){
        const s=new Node('script');
        s.src='https://app.videocommerce.shop/eoraeyewear/video-widget.js.php?url='+encodeURIComponent('https://www.eoraeyewear.com/produtos/'+slug);
        return s;
    }
    function vendor(s,hasVideo=true){
        document.currentScript=s;
        try {
            if(!hasVideo||window.__videoWidgetLoaded)return false;
            window.__videoWidgetLoaded=true;
            const bubble=new Node('div');bubble.id='video-bolinha';document.body.appendChild(bubble);
            const style=new Node('style');style.textContent='#video-bolinha {}';document.head.appendChild(style);
            window.setInterval(()=>{},100);
            window.setTimeout(()=>{},800);
            window.addEventListener('pageshow',()=>{});
            new window.MutationObserver(()=>{}).observe(document.body,{subtree:true});
            return true;
        } finally {document.currentScript=null;flush();}
    }
    function swap(slug){
        product.isConnected=false;product=new Node('div');product.id='single-product';nodes.set(product.id,product);
        location.href='https://www.eoraeyewear.com/produtos/'+slug+'/';
        observers[0].fn();
        return document.body.children.filter(n=>n.nodeName==='SCRIPT').at(-1);
    }
    return {window,document,nodes,timers,observers,scriptFor,vendor,swap,nativeAdd,nativeTimer,Target};
}
test('initial native widget is captured and browser APIs are restored',()=>{
    const f=fixture();
    assert.equal(f.vendor(f.scriptFor('vertice-manteiga-mix')),true);
    assert.equal(f.window.setInterval,f.nativeTimer);
    assert.equal(f.Target.prototype.addEventListener,f.nativeAdd);
    assert.equal(f.window.events.length,1);
    assert.equal(f.timers.size,2);
});
test('switch disposes old widget listeners, timers and observer; only current video initializes',()=>{
    const f=fixture();
    f.vendor(f.scriptFor('vertice-manteiga-mix'));
    const next=f.swap('vertice-marrom-avela-mix');
    assert.equal(f.nodes.has('video-bolinha'),false);
    assert.equal(f.window.events.length,0);
    assert.equal(f.observers[1].active,false);
    assert.equal(f.timers.size,1);
    assert.equal(f.vendor(f.scriptFor('vertice-manteiga-mix')),false);
    assert.equal(f.vendor(next),true);
    next.onload();
    assert.equal(f.vendor(f.scriptFor('vertice-marrom-avela-mix')),false);
    assert.equal(f.nodes.has('video-bolinha'),true);
    assert.equal(f.window.events.length,1);
    assert.equal(f.timers.size,2);
});
test('unrelated listeners survive, and failure never navigates',()=>{
    const f=fixture();
    f.vendor(f.scriptFor('vertice-manteiga-mix'));
    f.window.addEventListener('unrelated',()=>{});
    const next=f.swap('vertice-preto-prata');
    next.onerror();
    assert.equal(f.window.events.length,1);
    assert.equal(f.window.events[0].type,'unrelated');
    assert.equal(f.nodes.has('video-bolinha'),false);
    assert.equal(f.timers.size,0);
});
test('rapid switches reject stale vendor responses and accept final reference',()=>{
    const f=fixture();
    f.vendor(f.scriptFor('vertice-manteiga-mix'));
    const a=f.swap('vertice-bordo-mix');
    const b=f.swap('vertice-preto-prata');
    assert.equal(f.vendor(a),false);
    assert.equal(f.vendor(b),true);
    b.onload();
    a.onload();
    assert.equal(f.window.events.length,1);
    assert.equal(f.nodes.has('video-bolinha'),true);
});
