/* EORA - troca suave entre produtos usados como variacoes por referencia. */
(function () {
    if (window.__eoraGlobalVariations || window.location.pathname.indexOf('/produtos/') === -1) return;
    window.__eoraGlobalVariations = true;

    var variantSelector = '#single-product .js-color-variants-container > a.btn-variant-thumb[href]';
    var pageCache = {};
    var pendingFetches = {};
    var knownVariantNodes = {};
    var knownVariantOrder = [];
    var navigationId = 0;

    function normalizePath(url) {
        try {
            return new URL(url, window.location.origin).pathname.replace(/\/?$/, '/');
        } catch (e) { return ''; }
    }

    function isCustomProduct() {
        return !!document.querySelector('.eora-product-wrap');
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
        discovered.forEach(function (href) { prefetchPage(href); });
    }

    function fetchPage(href) {
        var path = normalizePath(href);
        if (!path) return Promise.reject(new Error('invalid-product-url'));
        if (pageCache[path]) return Promise.resolve(pageCache[path]);
        if (pendingFetches[path]) return pendingFetches[path];

        pendingFetches[path] = fetch(href, { credentials: 'same-origin' })
            .then(function (response) {
                if (!response.ok) throw new Error('product-fetch-failed');
                return response.text();
            })
            .then(function (html) {
                pageCache[path] = html;
                delete pendingFetches[path];
                discoverVariantsFromHtml(html);
                return html;
            })
            .catch(function (error) {
                delete pendingFetches[path];
                throw error;
            });
        return pendingFetches[path];
    }

    function prefetchPage(href) {
        fetchPage(href).catch(function () {});
    }

    function bindPrefetches() {
        if (isCustomProduct()) return;
        rememberVariants(document);
        renderKnownVariants(document, normalizePath(window.location.href));
        document.querySelectorAll(variantSelector).forEach(function (link) {
            if (!link.dataset.eoraPrefetched) {
                link.dataset.eoraPrefetched = 'true';
                prefetchPage(link.href);
            }
        });
    }

    function findDescriptionTable(doc, key) {
        var result = null;
        doc.querySelectorAll('.js-product-description-base table').forEach(function (table) {
            if (result) return;
            var firstCell = table.querySelector('tbody > tr:first-child > td:first-child, tr:first-child > td:first-child');
            if (firstCell && firstCell.textContent.trim().toLowerCase() === key) result = table;
        });
        return result;
    }

    function normalizeDescriptionFont(root) {
        if (!root) return;
        [root].concat(Array.prototype.slice.call(root.querySelectorAll('*'))).forEach(function (element) {
            element.style.removeProperty('font-size');
            element.style.removeProperty('line-height');
        });
    }

    function hydrateProductDescription(newDoc, newProduct) {
        var shortDescription = newProduct.querySelector('.js-product-description-short');
        var descriptionTable = findDescriptionTable(newDoc, 'descricao_curta');
        if (shortDescription) {
            var descriptionCell = descriptionTable && descriptionTable.querySelector('tr:first-child td:nth-child(2)');
            var currentDescription = document.querySelector('#single-product .js-product-description-short');
            shortDescription.innerHTML = descriptionCell
                ? descriptionCell.innerHTML
                : (currentDescription ? currentDescription.innerHTML : '');
            normalizeDescriptionFont(shortDescription);
        }

        var measurementsTable = findDescriptionTable(newDoc, 'medidas_do_oculos');
        var measurements = newProduct.querySelector('.js-glasses-measurements');
        var measurementsWrapper = newProduct.querySelector('.js-glasses-measurements-wrapper');
        if (measurements) {
            var measurementsCell = measurementsTable && measurementsTable.querySelector('tr:first-child td:nth-child(2)');
            measurements.innerHTML = measurementsCell ? measurementsCell.innerHTML : '';
            if (measurementsWrapper) measurementsWrapper.style.display = measurementsCell ? '' : 'none';
        }
        if (measurementsTable && measurementsWrapper) {
            var titleRow = measurementsTable.querySelector('tr:nth-child(2)');
            var titleKey = titleRow && titleRow.querySelector('td:first-child');
            var titleValue = titleRow && titleRow.querySelector('td:nth-child(2)');
            var titleTarget = measurementsWrapper.querySelector('.js-title-dropdown');
            if (titleKey && titleValue && titleTarget && titleKey.textContent.trim().toLowerCase() === 'titulo') {
                titleTarget.innerHTML = titleValue.innerHTML;
            }
        }
    }

    function initProductGallery(product) {
        if (!product) return;

        product.querySelectorAll('.product-detail-slider').forEach(function (gallery) {
            gallery.style.visibility = 'visible';
            gallery.style.height = 'auto';
        });

        var mobileGallery = product.querySelector('.js-swiper-product');
        if (!mobileGallery) return;
        mobileGallery.style.visibility = 'visible';
        mobileGallery.style.height = 'auto';

        if (typeof createSwiper !== 'function' || mobileGallery.classList.contains('swiper-container-initialized')) return;
        createSwiper(mobileGallery, {
            lazy: true,
            slidesPerView: 1.3,
            threshold: 5,
            centerInsufficientSlides: true,
            watchOverflow: true,
            spaceBetween: 16,
            pagination: {
                el: product.querySelector('.js-swiper-product-pagination'),
                clickable: true
            },
            navigation: {
                nextEl: product.querySelector('.js-swiper-product-next'),
                prevEl: product.querySelector('.js-swiper-product-prev')
            },
            breakpoints: { 768: { slidesPerView: 'auto' } }
        }, function (swiper) {
            window.__eoraCurrentProductSwiper = swiper;
        });

        if (window.LS && typeof window.LS.registerOnChangeVariant === 'function' && !window.__eoraVariantGalleryCallback) {
            window.__eoraVariantGalleryCallback = true;
            window.LS.registerOnChangeVariant(function (variant) {
                var currentGallery = document.querySelector('#single-product .js-swiper-product');
                var slide = currentGallery && currentGallery.querySelector('[data-image="' + variant.image + '"]');
                var position = slide && parseInt(slide.getAttribute('data-image-position'), 10);
                if (window.__eoraCurrentProductSwiper && !isNaN(position)) {
                    window.__eoraCurrentProductSwiper.slideTo(position);
                }
            });
        }
    }

    function replaceProduct(html, href, path, historyMode, expectedNavigationId) {
        var newDoc = new DOMParser().parseFromString(html, 'text/html');
        var newProduct = newDoc.querySelector('#single-product');
        var oldProduct = document.querySelector('#single-product');

        // Procura apenas dentro do produto. O proprio layout global tambem contem
        // esse nome de classe e nao pode fazer todos os destinos parecerem customizados.
        var targetUsesCustomLayout = newDoc.querySelector('.eora-product-wrap') ||
            (newProduct && newProduct.innerHTML.indexOf('eora-product-wrap') !== -1);
        if (!newProduct || !oldProduct || targetUsesCustomLayout || isCustomProduct()) return false;

        if (expectedNavigationId !== navigationId) return true;
        hydrateProductDescription(newDoc, newProduct);
        rememberVariants(newDoc);
        renderKnownVariants(newDoc, path);

        var currentProduct = document.querySelector('#single-product');
        if (!currentProduct || isCustomProduct()) return true;
        currentProduct.parentNode.replaceChild(newProduct, currentProduct);

        document.title = newDoc.title || document.title;
        if (historyMode === 'push') {
            history.pushState({ eoraGlobalPath: path }, '', href);
        } else if (historyMode === 'replace') {
            history.replaceState({ eoraGlobalPath: path }, '', href);
        }

        initProductGallery(newProduct);
        bindPrefetches();
        if (window.lazySizes && window.lazySizes.loader) window.lazySizes.loader.checkElems();
        return true;
    }

    function navigate(href, historyMode) {
        var path = normalizePath(href);
        if (!path) return;
        var thisNavigation = ++navigationId;

        fetchPage(href).then(function (html) {
            if (thisNavigation !== navigationId) return;
            if (!replaceProduct(html, href, path, historyMode, thisNavigation)) {
                window.location.href = href;
            }
        }).catch(function () {
            if (thisNavigation === navigationId) window.location.href = href;
        });
    }

    document.addEventListener('click', function (event) {
        var link = getVariationLink(event.target);
        if (!link || event.button > 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;

        var path = normalizePath(link.href);
        event.preventDefault();
        event.stopImmediatePropagation();

        if (path === normalizePath(window.location.href)) return;
        link.classList.add('selected');
        Array.prototype.forEach.call(link.parentNode.children, function (sibling) {
            if (sibling !== link) sibling.classList.remove('selected');
        });
        navigate(link.href, 'push');
    }, true);

    document.addEventListener('mouseover', function (event) {
        var link = getVariationLink(event.target);
        if (link) prefetchPage(link.href);
    }, { passive: true });

    document.addEventListener('focusin', function (event) {
        var link = getVariationLink(event.target);
        if (link) prefetchPage(link.href);
    });

    window.addEventListener('popstate', function (event) {
        if (event.state && event.state.eoraGlobalPath && !isCustomProduct()) {
            navigate(window.location.href, 'none');
        }
    });

    if (!isCustomProduct()) {
        history.replaceState({ eoraGlobalPath: normalizePath(window.location.href) }, '', window.location.href);
        bindPrefetches();
    }
})();
