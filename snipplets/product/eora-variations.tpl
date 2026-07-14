<script>
/* EORA - Lightweight variation switcher
   Objetivo: navegação suave entre variações sem pesar o site.
   Estratégia: prefetch leve (mouseenter), cache HTML, trocar apenas colunas
   `.product-image-column` e `.product-info-column` para minimizar reflows. */
(function () {
    if (window.__eora_variations_installed) return;
    window.__eora_variations_installed = true;

    var eoraPageCache = {};
    var prefetchQueue = {};

    function normalizePathname(url) {
        try { return new URL(url, window.location.origin).pathname.replace(/\/?$/, '/'); } catch (e) { return ''; }
    }

    function safeFetchHtml(url) {
        return fetch(url, { credentials: 'same-origin' }).then(function (r) { if (!r.ok) throw new Error('fetch-fail'); return r.text(); });
    }

    function prefetchVariation(href) {
        try {
            var full = href.indexOf('http') === 0 ? href : (new URL(href, window.location.origin)).href;
            var path = normalizePathname(full);
            if (!path || eoraPageCache[path] || prefetchQueue[path]) return;
            prefetchQueue[path] = true;

            var doFetch = function () {
                safeFetchHtml(full).then(function (html) {
                    eoraPageCache[path] = html;
                    delete prefetchQueue[path];
                }).catch(function () { delete prefetchQueue[path]; });
            };

            if (typeof requestIdleCallback === 'function') requestIdleCallback(doFetch, {timeout:3000}); else setTimeout(doFetch, 800);
        } catch (e) {}
    }

    function syncFormValues(fromForm, toForm) {
        if (!fromForm || !toForm) return;
        var fields = fromForm.querySelectorAll('input[name], select[name], textarea[name]');
        fields.forEach(function (src) {
            if (src.disabled) return;
            var name = src.getAttribute('name'); if (!name) return;
            var dstList = toForm.querySelectorAll('[name="' + name.replace(/"/g,'\\"') + '"]');
            if (!dstList.length) return;
            if (src.type === 'radio') { if (!src.checked) return; dstList.forEach(function(dst){ dst.checked = (dst.value===src.value); dst.dispatchEvent(new Event('change')); }); return; }
            if (src.type === 'checkbox') { dstList.forEach(function(dst){ dst.checked = src.checked; dst.dispatchEvent(new Event('change')); }); return; }
            dstList.forEach(function(dst){ dst.value = src.value; dst.dispatchEvent(new Event('change')); });
        });
    }

    function forwardToOriginal(freshForm) {
        var originalForm = document.querySelector('#single-product #product_form, #single-product .js-product-form, form[action*="/cart"]');
        if (!originalForm) return;
        syncFormValues(freshForm, originalForm);
        var addBtn = originalForm.querySelector('[name="commit"], input.js-addtocart, button.js-addtocart, .js-addtocart');
        if (addBtn) { addBtn.click(); return; }
        if (typeof originalForm.requestSubmit === 'function') { originalForm.requestSubmit(); return; }
        originalForm.submit();
    }

    function applyPartialSwap(html, fullUrl, path) {
        try {
            var parser = new DOMParser();
            var doc = parser.parseFromString(html, 'text/html');

            var newImageCol = doc.querySelector('.product-image-column');
            var newInfoCol = doc.querySelector('.product-info-column');
            var curImageCol = document.querySelector('.product-image-column');
            var curInfoCol = document.querySelector('.product-info-column');

            if (!newImageCol || !newInfoCol || !curImageCol || !curInfoCol) return false;

            // Preload main images from the new content (short wait) to avoid flicker
            var imgs = [];
            newImageCol.querySelectorAll('img').forEach(function(i){ if (i && i.src) imgs.push(i.src); });
            newInfoCol.querySelectorAll('img').forEach(function(i){ if (i && i.src) imgs.push(i.src); });
            imgs = imgs.filter(Boolean).slice(0,6); // limit

            function preloadImages(urls, timeout) {
                if (!urls.length) return Promise.resolve();
                var loaders = urls.map(function(u){ return new Promise(function(res){ var img=new Image(); img.onload = img.onerror = function(){ res(u); }; img.src = u; }); });
                return Promise.race([ Promise.allSettled(loaders), new Promise(function(res){ setTimeout(res, timeout); }) ]);
            }

            var wrap = document.querySelector('.eora-product-wrap') || document.querySelector('#single-product');
            if (wrap) wrap.style.transition = 'opacity 180ms ease';
            if (wrap) wrap.style.opacity = '0.45';

            // Wait briefly for images (non-blocking long)
            preloadImages(imgs, 450).then(function(){
                // Replace innerHTML (lightweight)
                try { curImageCol.innerHTML = newImageCol.innerHTML; curInfoCol.innerHTML = newInfoCol.innerHTML; } catch(e){}

                // Re-bind minimal behaviors on fresh form
                var freshForm = curInfoCol.querySelector('#product_form, .js-product-form, form[action*="/cart"]');
                if (freshForm) {
                    freshForm.classList.add('eora-cloned-product-form');
                    // intercept submit / buy buttons
                    freshForm.addEventListener('submit', function (e) { e.preventDefault(); e.stopPropagation(); forwardToOriginal(freshForm); });
                    freshForm.querySelectorAll('[name="commit"], input.js-addtocart, button.js-addtocart, .js-addtocart').forEach(function (btn) {
                        btn.classList.remove('js-addtocart','js-addtocart-btn');
                        btn.classList.add('eora-buy-btn');
                        btn.addEventListener('click', function (ev) { ev.preventDefault(); ev.stopPropagation(); forwardToOriginal(freshForm); });
                    });
                }

                // Update title and history
                document.title = doc.title || document.title;
                if (normalizePathname(window.location.href) !== path) history.pushState({ eoraPath: path }, '', fullUrl);

                // small fade-in
                setTimeout(function () { if (wrap) wrap.style.opacity = ''; }, 60);
            });
            return true;
        } catch (e) { return false; }
    }

    function navigateToVariation(href) {
        try {
            var full = href.indexOf('http') === 0 ? href : (new URL(href, window.location.origin)).href;
            var path = normalizePathname(full);
            if (!path) { window.location.href = full; return; }

            var wrap = document.querySelector('.eora-product-wrap'); if (wrap) wrap.classList.remove('eora-loaded');

            var htmlPromise = eoraPageCache[path] ? Promise.resolve(eoraPageCache[path]) : safeFetchHtml(full).then(function (h) { eoraPageCache[path] = h; return h; });

            htmlPromise.then(function (html) {
                var swapped = applyPartialSwap(html, full, path);
                if (!swapped) window.location.href = full;
                if (wrap) setTimeout(function () { wrap.classList.add('eora-loaded'); }, 80);
            }).catch(function () { window.location.href = full; });
        } catch (e) { try { window.location.href = href; } catch (e) {} }
    }

    // Prefetch on hover (mouseenter) and on focus (accessibility)
    document.addEventListener('mouseover', function (e) {
        var el = e.target && e.target.closest && e.target.closest('.eora-bolsa-var-item, .variante-item, a.variante-link');
        if (!el) return;
        var href = el.getAttribute('href') || el.getAttribute('data-href') || el.getAttribute('data-href-path');
        if (href) prefetchVariation(href);
    }, { passive: true });

    document.addEventListener('focusin', function (e) {
        var el = e.target && e.target.closest && e.target.closest('.eora-bolsa-var-item, .variante-item, a.variante-link');
        if (!el) return;
        var href = el.getAttribute('href') || el.getAttribute('data-href') || el.getAttribute('data-href-path');
        if (href) prefetchVariation(href);
    });

    // Intercept navigation early to avoid theme's native loading overlay.
    function isVariantEl(node) {
        return node && node.closest && !!node.closest('.eora-bolsa-var-item, .variante-item, a.variante-link');
    }

    // Prevent native navigation as early as possible (pointerdown / touchstart)
    ['pointerdown', 'touchstart'].forEach(function (evName) {
        document.addEventListener(evName, function (ev) {
            try {
                var el = ev.target && ev.target.closest && ev.target.closest('.eora-bolsa-var-item, .variante-item, a.variante-link');
                if (!el) return;
                var href = el.getAttribute('href') || el.getAttribute('data-href') || el.getAttribute('data-href-path');
                if (!href) return;
                // Prevent other handlers (theme overlays) from running
                ev.preventDefault();
                ev.stopImmediatePropagation();
            } catch (e) {}
        }, { passive: false, capture: true });
    });

    // Click handler: navigate via AJAX + partial swap (capture to run before theme handlers)
    document.addEventListener('click', function (e) {
        var el = e.target && e.target.closest && e.target.closest('.eora-bolsa-var-item, .variante-item, a.variante-link');
        if (!el) return;
        var href = el.getAttribute('href') || el.getAttribute('data-href') || el.getAttribute('data-href-path');
        if (!href) return;
        e.preventDefault(); e.stopImmediatePropagation();
        navigateToVariation(href);
    }, true);

    // Back/forward support
    window.addEventListener('popstate', function (ev) {
        if (ev.state && ev.state.eoraPath) {
            var full = ev.state.eoraPath;
            var html = eoraPageCache[full];
            if (html) { applyPartialSwap(html, window.location.href, full); }
            else { safeFetchHtml(window.location.href).then(function(h){ applyPartialSwap(h, window.location.href, normalizePathname(window.location.href)); }); }
        }
    });

})();
</script>
