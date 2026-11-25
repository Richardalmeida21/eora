(function () {
    'use strict';
    if (window.__eoraVideoCommerceBridge) return;
    window.__eoraVideoCommerceBridge = true;
    var product = document.getElementById('single-product');
    if (!product) return;
    var previousUrl = location.href;
    var pending = null, running = false, loader = null;
    var widgetIds = ['video-bolinha', 'video-modal', 'stories-modal'];
    function widgetPresent() { return !!document.getElementById('video-bolinha'); }
    function clearWidget() {
        widgetIds.forEach(function (id) {
            var node = document.getElementById(id);
            if (!node) return;
            node.querySelectorAll('video').forEach(function (video) { video.pause(); });
            node.remove();
        });
    }
    function asLoader(raw) {
        try {
            var url = new URL(raw, location.href);
            return url.protocol === 'https:' && /(?:^|\/)video-widget\.js\.php$/i.test(url.pathname) ? url : null;
        } catch (_) { return null; }
    }
    function findLoader() {
        var scripts = Array.from(document.querySelectorAll('script[src]')).map(function (node) { return node.src; });
        var resources = typeof performance.getEntriesByType === 'function' ? performance.getEntriesByType('resource').map(function (entry) { return entry.name; }) : [];
        return scripts.concat(resources).map(asLoader).filter(Boolean).pop() || null;
    }
    function productPath(raw) {
        try { return new URL(raw, location.href).pathname.replace(/\/+$/, ''); } catch (_) { return ''; }
    }
    function targetLoader(source, from, to) {
        var next = new URL(source.href);
        var oldPage = new URL(from), newPage = new URL(to);
        var matched = false;
        // Preserve all vendor/store identifiers; change only the page reference
        // actually present in the installed application's request.
        source.searchParams.forEach(function (value, key) {
            var candidate;
            try { candidate = new URL(value, oldPage.origin); } catch (_) { return; }
            if (candidate.hostname.replace(/^www\./, '') !== oldPage.hostname.replace(/^www\./, '') ||
                productPath(candidate.href) !== productPath(oldPage.href)) return;
            if (!/^https?:\/\//i.test(value) && value.charAt(0) !== '/') return;
            var replacement = value.charAt(0) === '/' ? newPage.pathname + newPage.search : newPage.origin + newPage.pathname + newPage.search;
            next.searchParams.set(key, replacement);
            matched = true;
        });
        // A URL-independent loader can read the new location itself.
        // If it still embeds the previous product in an unknown format, do not guess.
        if (!matched && (source.href.indexOf(oldPage.pathname) !== -1 ||
            source.href.indexOf(encodeURIComponent(oldPage.pathname)) !== -1)) return null;
        return next;
    }
    function fallback(job) {
        if (!pending && location.href === job.to) location.reload();
    }
    function run() {
        if (running || !pending) return;
        var job = pending; pending = null;
        var source = loader || findLoader();
        if (!source) {
            if (job.hadWidget) fallback(job);
            return;
        }
        var next = targetLoader(source, job.from, job.to);
        if (!next) { if (job.hadWidget) fallback(job); return; }
        running = true;
        clearWidget();
        var script = document.createElement('script');
        script.async = true;
        script.src = next.href;
        var settled = false, timeout;
        function finish(ok) {
            if (settled) return;
            settled = true;
            clearTimeout(timeout);
            window.removeEventListener('error', onError);
            script.remove();
            running = false;
            if (ok) loader = next;
            if (pending) { clearWidget(); run(); }
            else if (!ok && job.hadWidget) fallback(job);
        }
        function onError(event) {
            if (event.filename && asLoader(event.filename)) finish(false);
        }
        window.addEventListener('error', onError);
        script.onload = function () { finish(true); };
        script.onerror = function () { finish(false); };
        timeout = setTimeout(function () { finish(false); }, 8000);
        document.body.appendChild(script);
    }
    // The theme replaces #single-product after updating the URL and LS.product.
    // Observing that commit also handles Back/Forward without wrapping history
    // or triggering another page fetch.
    var observer = new MutationObserver(function () {
        if (product.isConnected) return;
        var nextProduct = document.getElementById('single-product');
        if (!nextProduct || nextProduct === product) return;
        product = nextProduct;
        var nextUrl = location.href;
        if (productPath(previousUrl) === productPath(nextUrl)) return;
        var hadWidget = widgetPresent() || !!(pending && pending.hadWidget);
        var from = pending ? pending.from : previousUrl;
        previousUrl = nextUrl;
        loader = loader || findLoader();
        if (!loader && !hadWidget && !running) return;
        clearWidget();
        pending = {from: from, to: nextUrl, hadWidget: hadWidget};
        run();
    });
    observer.observe(document.body, {childList: true, subtree: true});
}());
