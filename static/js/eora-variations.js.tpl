/* EORA - navegacao segura e suave entre produtos usados como variacoes por referencia. */
(function () {
    if (window.__eoraGlobalVariations || window.location.pathname.indexOf('/produtos/') === -1) return;
    window.__eoraGlobalVariations = true;

    var variantSelector = '#single-product .js-color-variants-container > a.btn-variant-thumb[href]';
    var prefetchedPaths = {};
    var pendingFetches = {};
    var knownVariantNodes = {};
    var knownVariantOrder = [];
    var isNavigating = false;
    var transitionStorageKey = 'eora-product-transition';
    var transitionDuration = 120;

    function normalizePath(url) {
        try {
            return new URL(url, window.location.origin).pathname.replace(/\/?$/, '/');
        } catch (e) { return ''; }
    }

    function installVerticeOrder() {
        // Referências da Vértice; esta lista não inclui Maxi, Mini, Hobo ou Clutch.
        var paths = [
            '/produtos/vertice/', '/produtos/vertice-bordo-mix/',
            '/produtos/vertice1/', '/produtos/vertice6/',
            '/produtos/vertice3/', '/produtos/vertice-marrom-avela-mix/',
            '/produtos/vertice4/', '/produtos/vertice-croco-rato-mix/', '/produtos/vertice-detog/'
        ];
        var positions = Object.create(null);
        paths.forEach(function (path, index) { positions[path] = index; });
        if (positions[normalizePath(window.location.href)] === undefined) return;

        var product = document.querySelector('#single-product, .eora-product-wrap');
        var root = product && product.parentNode || document.body;
        if (!root) return;
        var scheduled = false;

        function applyOrder() {
            scheduled = false;
            if (positions[normalizePath(window.location.href)] === undefined) return;
            root.querySelectorAll('.eora-product-wrap .eora-bolsa-vars').forEach(function (container) {
                var nodes = Array.prototype.slice.call(container.querySelectorAll('.eora-bolsa-var-item[data-href-path]'));
                var entries = nodes.map(function (node, index) {
                    var position = positions[normalizePath(node.getAttribute('data-href-path'))];
                    return {node: node, index: index, position: position === undefined ? paths.length : position};
                }).sort(function (a, b) { return a.position - b.position || a.index - b.index; });
                var pairs = Object.create(null);
                entries.forEach(function (entry) {
                    if (entry.position >= 6) return;
                    var pair = Math.floor(entry.position / 2);
                    if (!pairs[pair]) pairs[pair] = [];
                    pairs[pair].push(entry.node);
                });
                var missingPair = Object.keys(pairs).some(function (key) {
                    var pair = pairs[key];
                    if (pair.length < 2) return false;
                    var parent = pair[0].parentElement;
                    return !parent.classList.contains('eora-bolsa-var-pair') ||
                        pair.some(function (node) { return node.parentElement !== parent; }) ||
                        parent.querySelectorAll('.eora-bolsa-var-item').length !== pair.length;
                });
                if (!missingPair && entries.every(function (entry, index) { return entry.node === nodes[index]; })) return;

                var oldPairs = container.querySelectorAll('.eora-bolsa-var-pair');
                var fragment = document.createDocumentFragment();
                var pairContainers = Object.create(null);
                entries.forEach(function (entry) {
                    var pair = Math.floor(entry.position / 2);
                    if (entry.position < 6 && pairs[pair].length > 1) {
                        if (!pairContainers[pair]) {
                            var group = document.createElement('span');
                            group.className = 'eora-bolsa-var-pair';
                            group.style.cssText = 'display:inline-flex;flex-wrap:nowrap;gap:8px;flex:0 0 auto';
                            pairContainers[pair] = group;
                            fragment.appendChild(group);
                        }
                        pairContainers[pair].appendChild(entry.node);
                    } else {
                        fragment.appendChild(entry.node);
                    }
                });
                oldPairs.forEach(function (pair) { if (!pair.children.length) pair.remove(); });
                // Move os nós existentes para preservar seleção, fotos e listeners.
                container.appendChild(fragment);
            });
        }

        function scheduleOrder() {
            if (scheduled) return;
            scheduled = true;
            window.requestAnimationFrame(applyOrder);
        }

        new MutationObserver(function (records) {
            var relevant = records.some(function (record) {
                if (record.target.closest && record.target.closest('.eora-bolsa-vars')) return true;
                return Array.prototype.some.call(record.addedNodes, function (node) {
                    return node.nodeType === 1 && (node.matches('.eora-bolsa-vars') || node.querySelector('.eora-bolsa-vars'));
                });
            });
            if (relevant) scheduleOrder();
        }).observe(root, {childList: true, subtree: true});
        applyOrder();
    }

    function isCustomProduct() {
        return !!document.querySelector('.eora-product-wrap');
    }

    function prefersReducedMotion() {
        return !!(window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches);
    }

    function getVariationLink(target) {
        if (!target || !target.closest || isCustomProduct()) return null;
        var link = target.closest(variantSelector);
        if (!link || link.closest('.eora-product-wrap')) return null;
        try {
            var url = new URL(link.href, window.location.origin);
            if (url.origin !== window.location.origin || url.pathname.indexOf('/produtos/') === -1) return null;
        } catch (e) { return null; }
        return link;
    }

    function installTransitionStyles() {
        if (document.getElementById('eora-product-navigation-styles')) return;

        var style = document.createElement('style');
        style.id = 'eora-product-navigation-styles';
        style.textContent = [
            'html.eora-product-leaving #single-product{opacity:0!important;transform:translateY(4px)!important;pointer-events:none!important;transition:opacity 120ms ease,transform 120ms ease!important}',
            'html.eora-product-entering #single-product{animation:eoraProductEnter 180ms ease both}',
            '@keyframes eoraProductEnter{from{opacity:0;transform:translateY(4px)}to{opacity:1;transform:translateY(0)}}',
            '@media(prefers-reduced-motion:reduce){html.eora-product-leaving #single-product{transition:none!important;transform:none!important}html.eora-product-entering #single-product{animation:none!important}}'
        ].join('');
        document.head.appendChild(style);
    }

    function restorePageState() {
        document.documentElement.classList.remove('eora-product-leaving');
        document.documentElement.removeAttribute('aria-busy');
        isNavigating = false;
    }

    function runEntryTransition() {
        var shouldAnimate = false;
        try {
            shouldAnimate = window.sessionStorage.getItem(transitionStorageKey) === '1';
            window.sessionStorage.removeItem(transitionStorageKey);
        } catch (e) {}

        if (!shouldAnimate || prefersReducedMotion()) return;
        document.documentElement.classList.add('eora-product-entering');
        window.setTimeout(function () {
            document.documentElement.classList.remove('eora-product-entering');
        }, 220);
    }

    function rememberVariants(root) {
        if (!root || !root.querySelectorAll) return [];
        var newHrefs = [];

        root.querySelectorAll(variantSelector).forEach(function (link) {
            var path = normalizePath(link.href);
            if (!path || knownVariantNodes[path]) return;

            var clone = link.cloneNode(true);
            clone.removeAttribute('data-eora-prefetched');
            knownVariantNodes[path] = clone;
            knownVariantOrder.push(path);
            newHrefs.push(link.href);
        });
        return newHrefs;
    }

    function renderKnownVariants(root, activePath) {
        if (!root || !root.querySelector) return;
        var container = root.querySelector('#single-product .js-color-variants-container');
        if (!container || !knownVariantOrder.length) return;

        // A Mini Vertice descobre a familia completa pela tag e preserva uma
        // ordem canonica na sessao. Nao sobrescrever essa lista com a ordem
        // parcial recebida de outra pagina durante o prefetch global.
        if (container.classList.contains('eora-minivertice-tag-vars') ||
            container.closest('.eora-minivertice-product') ||
            window.__eoraMiniverticeVariantsLoaded) return;

        var fragment = document.createDocumentFragment();
        knownVariantOrder.forEach(function (path) {
            var source = knownVariantNodes[path];
            if (!source) return;

            var link = source.cloneNode(true);
            link.classList.toggle('selected', path === activePath);
            link.removeAttribute('data-eora-prefetched');
            link.querySelectorAll('img[data-src]').forEach(function (image) {
                image.src = image.getAttribute('data-src');
                image.removeAttribute('data-src');
                image.classList.remove('lazyload');
            });
            fragment.appendChild(link);
        });
        container.replaceChildren(fragment);
    }

    function discoverVariantsFromHtml(html) {
        var parsed = new DOMParser().parseFromString(html, 'text/html');
        var discovered = rememberVariants(parsed);
        var mainImage = parsed.querySelector('#single-product .product-image-column .js-product-slide-img[data-srcset]');
        if (mainImage) {
            var candidates = mainImage.getAttribute('data-srcset').split(',');
            var imageUrl = candidates[candidates.length - 1].trim().split(/\s+/)[0];
            if (imageUrl) (new Image()).src = imageUrl;
        }
        renderKnownVariants(document, normalizePath(window.location.href));
        discovered.forEach(prefetchPage);
    }

    function prefetchPage(href) {
        var path = normalizePath(href);
        if (!path || path === normalizePath(window.location.href) || prefetchedPaths[path]) return;
        if (pendingFetches[path]) return;

        pendingFetches[path] = fetch(href, {
            credentials: 'same-origin',
            cache: 'force-cache'
        }).then(function (response) {
            if (!response.ok) throw new Error('product-prefetch-failed');
            return response.text();
        }).then(function (html) {
            prefetchedPaths[path] = true;
            delete pendingFetches[path];
            discoverVariantsFromHtml(html);
        }).catch(function () {
            delete pendingFetches[path];
        });
    }

    function bindPrefetches() {
        if (isCustomProduct()) return;
        rememberVariants(document);
        renderKnownVariants(document, normalizePath(window.location.href));

        document.querySelectorAll(variantSelector).forEach(function (link) {
            if (link.dataset.eoraPrefetched) return;
            link.dataset.eoraPrefetched = 'true';
            prefetchPage(link.href);
        });
    }

    function navigateWithTransition(href) {
        if (isNavigating) return;
        isNavigating = true;

        try {
            window.sessionStorage.setItem(transitionStorageKey, '1');
        } catch (e) {}

        if (prefersReducedMotion()) {
            window.location.assign(href);
            return;
        }

        document.documentElement.classList.add('eora-product-leaving');
        document.documentElement.setAttribute('aria-busy', 'true');
        window.setTimeout(function () {
            window.location.assign(href);
        }, transitionDuration);
    }

    installVerticeOrder();
    installTransitionStyles();
    runEntryTransition();

    document.addEventListener('click', function (event) {
        var link = getVariationLink(event.target);
        if (!link || link.target === '_blank' || event.button > 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;

        var path = normalizePath(link.href);
        if (!path) return;

        if (path === normalizePath(window.location.href)) {
            event.preventDefault();
            return;
        }

        event.preventDefault();
        event.stopImmediatePropagation();
        navigateWithTransition(link.href);
    }, true);

    document.addEventListener('mouseover', function (event) {
        var link = getVariationLink(event.target);
        if (link) prefetchPage(link.href);
    }, { passive: true });

    document.addEventListener('focusin', function (event) {
        var link = getVariationLink(event.target);
        if (link) prefetchPage(link.href);
    });

    document.addEventListener('touchstart', function (event) {
        var link = getVariationLink(event.target);
        if (link) prefetchPage(link.href);
    }, { passive: true });

    window.addEventListener('pageshow', restorePageState);

    if (!isCustomProduct()) bindPrefetches();
})();
