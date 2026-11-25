(function () {
    'use strict';
    if (window.__eoraVideoCommerceBridge) return;
    window.__eoraVideoCommerceBridge = true;
    var endpoint = 'https://app.videocommerce.shop/eoraeyewear/video-widget.js.php';
    var guard = '__videoWidgetLoaded';
    var descriptor = Object.getOwnPropertyDescriptor(window, guard);
    // Do not take over an instance that was initialized before this bridge.
    if (descriptor || window[guard]) return;
    var active = null, loaded = false, lastPath = pathOf(location.href);
    var installed = false, requested = null, generation = 0, product = null;
    var nativeObserver = window.MutationObserver;
    var nativeAdd = EventTarget.prototype.addEventListener;
    var nativeRemove = EventTarget.prototype.removeEventListener;
    var nativeTimeout = window.setTimeout.bind(window);
    var nativeClearTimeout = window.clearTimeout.bind(window);
    var nativeClearInterval = window.clearInterval.bind(window);
    function pathOf(raw) {
        try { return new URL(raw, location.href).pathname.replace(/\/+$/, ''); } catch (_) { return ''; }
    }
    function vendorScript(script) {
        if (!script || !script.src) return null;
        try {
            var u = new URL(script.src);
            return u.origin + u.pathname === endpoint ? u : null;
        } catch (_) { return null; }
    }
    function matchesPage(u) {
        var raw = u && u.searchParams.get('url');
        return !!raw && pathOf(raw) === pathOf(location.href);
    }
    function widgetNode(id) { return document.getElementById(id); }
    function dispose(scope) {
        if (!scope || scope.dead) return;
        scope.dead = true;
        scope.restore();
        scope.timers.forEach(function (id) { nativeClearTimeout(id); nativeClearInterval(id); });
        scope.observers.forEach(function (o) { o.disconnect(); });
        scope.listeners.forEach(function (l) { nativeRemove.call(l.target, l.type, l.fn, l.options); });
        var modal = widgetNode('video-modal'), stories = widgetNode('stories-modal');
        var ownsScroll = (modal && modal.style.display === 'flex') || (stories && stories.classList.contains('active'));
        if (ownsScroll) {
            document.body.classList.remove('vc-stories-open');
            if (document.body.style.overflow === 'hidden') document.body.style.overflow = scope.bodyOverflow;
        }
        ['video-bolinha','video-modal','stories-modal'].forEach(function (id) {
            var node = widgetNode(id);
            if (!node) return;
            node.querySelectorAll('video').forEach(function (v) { v.pause(); v.removeAttribute('src'); v.load(); });
            node.remove();
        });
        document.querySelectorAll('.vc-highlights-wrapper,.vc-carousel-container').forEach(function (node) { node.remove(); });
        scope.styles.forEach(function (style) { style.remove(); });
    }
    function createScope(script, url) {
        var scope = {script:script, url:url, dead:false, timers:new Set(), observers:[], listeners:[], styles:[], bodyOverflow:document.body ? document.body.style.overflow : '', restore:function(){}};
        var depth = 0;
        function enter() {
            if (depth++) return;
            var undo = [];
            function patch(obj, key, make) {
                var old = obj[key], own = Object.prototype.hasOwnProperty.call(obj,key);
                var replacement = make(old);
                try { obj[key] = replacement; } catch (_) { return; }
                if (obj[key] !== replacement) return;
                undo.push(function () { if (obj[key] !== replacement) return; if (own) obj[key] = old; else delete obj[key]; });
            }
            function wrap(fn) {
                if (typeof fn !== 'function') return fn;
                return function () {
                    if (scope.dead) return;
                    enter();
                    try { return fn.apply(this,arguments); } finally { leave(); }
                };
            }
            ['setTimeout','setInterval'].forEach(function (key) {
                patch(window,key,function (original) {
                    return function (fn, delay) {
                        if (typeof fn !== 'function') return original.apply(this,arguments);
                        var args = Array.prototype.slice.call(arguments,2);
                        var callback = wrap(fn);
                        var id = original.apply(window,[function () {
                            if (key === 'setTimeout') scope.timers.delete(id);
                            return callback.apply(this,arguments);
                        },delay].concat(args));
                        scope.timers.add(id);
                        return id;
                    };
                });
            });
            patch(EventTarget.prototype,'addEventListener',function (original) {
                return function (type,fn,options) {
                    // Vendor's DOMContentLoaded handler modifies ALL page videos.
                    // Preserve native first-load behavior, but never replay it on swaps.
                    if (this === document && type === 'DOMContentLoaded' && document.readyState !== 'loading') return;
                    if (!fn) return original.call(this,type,fn,options);
                    var target = this;
                    var callback = typeof fn === 'function' ? wrap(fn) : fn;
                    scope.listeners.push({target:target,type:type,fn:callback,options:options});
                    return original.call(target,type,callback,options);
                };
            });
            patch(window,'MutationObserver',function (Original) {
                function ScopedObserver(fn) {
                    var observer = new Original(wrap(fn));
                    scope.observers.push(observer);
                    return observer;
                }
                ScopedObserver.prototype = Original.prototype;
                return ScopedObserver;
            });
            patch(Node.prototype,'appendChild',function (original) {
                return function (node) {
                    if (node && node.nodeName === 'STYLE' && /#video-bolinha/.test(node.textContent || node.innerHTML || '')) scope.styles.push(node);
                    return original.call(this,node);
                };
            });
            scope.restore = function () { depth = 0; undo.splice(0).reverse().forEach(function (fn) { fn(); }); };
        }
        function leave() { if (depth > 0 && --depth === 0) scope.restore(); }
        scope.start = function () {
            enter();
            // The vendor is a synchronous IIFE. Restore browser APIs before any
            // other task; callbacks re-enter only for their own execution.
            queueMicrotask(function () { leave(); });
        };
        return scope;
    }
    Object.defineProperty(window,guard,{
        configurable:true,
        get:function () {
            var u = vendorScript(document.currentScript);
            if (u && !matchesPage(u)) return true;
            return loaded;
        },
        set:function (value) {
            var script = document.currentScript, u = vendorScript(script);
            loaded = !!value;
            if (!value || !u || !matchesPage(u) || active) return;
            installed = true;
            active = createScope(script,u);
            window.__videoViewTracked = false;
            active.start();
        }
    });
    function request(page) {
        var token = ++generation;
        if (requested) { requested.remove(); requested = null; }
        if (active) { dispose(active); active = null; }
        loaded = false;
        window.__videoViewTracked = false;
        var url = new URL(endpoint);
        // HAR: official loader removes the final slash from the product URL.
        var target = new URL(page);
        target.hostname = 'www.eoraeyewear.com';
        target.pathname = target.pathname.replace(/\/+$/, '');
        target.hash = '';
        url.searchParams.set('url',target.href);
        var script = document.createElement('script');
        script.async = true; script.src = url.href;
        requested = script;
        var timer = nativeTimeout(function () { finish(false); },10000);
        function finish(ok) {
            nativeClearTimeout(timer);
            script.remove();
            if (requested === script) requested = null;
            if (token !== generation) return;
            if (!ok) console.warn('EORA: Video Commerce request failed; product navigation unchanged.');
        }
        script.onload = function () { finish(true); };
        script.onerror = function () { finish(false); };
        document.body.appendChild(script);
    }
    function ready() {
        product = widgetNode('single-product');
        if (!product || !nativeObserver) return;
        var observer = new nativeObserver(function () {
            if (product.isConnected) return;
            var next = widgetNode('single-product');
            if (!next || next === product) return;
            product = next;
            var nextPath = pathOf(location.href);
            if (nextPath === lastPath) return;
            lastPath = nextPath;
            // Only take over an installed, captured Video Commerce instance.
            // The official Nuvemshop loader can also run on reference changes;
            // the guard accepts exactly one script for the current URL.
            if (installed) request(location.href);
        });
        observer.observe(document.body,{childList:true,subtree:true});
    }
    if (document.readyState === 'loading') nativeAdd.call(document,'DOMContentLoaded',ready,{once:true});
    else ready();
}());
