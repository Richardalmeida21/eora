/* EORA - troca suave entre produtos usados como variacoes por referencia. */
(function () {
    if (window.__eoraGlobalVariations || window.location.pathname.indexOf('/produtos/') === -1) return;
    window.__eoraGlobalVariations = true;

    var variantSelector = '#single-product .js-color-variants-container > a.btn-variant-thumb[href]';
    var pageCache = {};
    var pendingFetches = {};
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
        document.querySelectorAll(variantSelector).forEach(function (link) {
            if (!link.dataset.eoraPrefetched) {
                link.dataset.eoraPrefetched = 'true';
                prefetchPage(link.href);
            }
        });
    }

    function getMainImageUrl(product) {
        var image = product && product.querySelector('.product-image-column .js-product-slide-img[data-srcset], .product-image-column img[data-src], .product-image-column img[src]');
        if (!image) return '';
        var srcset = image.getAttribute('data-srcset') || image.getAttribute('srcset') || '';
        if (srcset) {
            var candidates = srcset.split(',');
            return candidates[candidates.length - 1].trim().split(/\s+/)[0];
        }
        return image.getAttribute('data-src') || image.getAttribute('src') || '';
    }

    function preloadMainImage(product) {
        var url = getMainImageUrl(product);
        if (!url) return Promise.resolve();
        return Promise.race([
            new Promise(function (resolve) {
                var image = new Image();
                image.onload = image.onerror = resolve;
                image.src = url;
            }),
            new Promise(function (resolve) { setTimeout(resolve, 250); })
        ]);
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

    function isSoldOut(product) {
        if (!product) return false;
        var button = product.querySelector('input.js-addtocart, button.js-addtocart, .eora-buy-btn');
        return !!(button && (button.disabled || button.classList.contains('nostock')));
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
        if (isSoldOut(oldProduct) || isSoldOut(newProduct)) return false;

        preloadMainImage(newProduct).then(function () {
            if (expectedNavigationId !== navigationId) return;

            var currentProduct = document.querySelector('#single-product');
            if (!currentProduct || isCustomProduct()) return;

            newProduct.style.opacity = '0.72';
            newProduct.style.transition = 'opacity 140ms ease';
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

            requestAnimationFrame(function () {
                newProduct.style.opacity = '1';
                setTimeout(function () {
                    newProduct.style.removeProperty('transition');
                    newProduct.style.removeProperty('opacity');
                }, 160);
            });
        });
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
        if (document.readyState === 'complete') bindPrefetches();
        else window.addEventListener('load', bindPrefetches, { once: true });
    }
})();
