// Offer uploaded originals to the custom Vertice gallery without changing its layout or thumbnails.
(function () {
    'use strict';
    var ready = 'data-eora-product-image-quality-ready';
    if (document.documentElement.hasAttribute(ready)) return;
    document.documentElement.setAttribute(ready, '');

    var gallerySelector = '.eora-product-wrap .eora-product-gallery';
    var imageSelector = '.eora-blg-slide img';
    var sources = new Map();
    var failedOriginals = new Set();
    var states = new WeakMap();
    var watchedGalleries = new WeakSet();
    var watchedParents = new WeakSet();
    var observedImages = new WeakSet();
    var visibleImages = new WeakMap();

    function urlKey(value) {
        try {
            var url = new URL(value, document.baseURI);
            return /^https?:$/.test(url.protocol) ? url.href : '';
        } catch (error) { return ''; }
    }

    function readSources() {
        sources = new Map();
        var node = document.querySelector('#single-product [data-eora-product-image-sources]');
        if (!node) return;
        try {
            var data = JSON.parse(node.content.textContent);
            if (!Array.isArray(data.tags) || data.tags.indexOf('vertice') === -1 || !Array.isArray(data.images)) return;
            data.images.forEach(function (entry) {
                var resized = new URL(entry.resized_url, document.baseURI);
                if (!/^https?:$/.test(resized.protocol) || !/^acdn(?:-us)?\.mitiendanube\.com$/i.test(resized.hostname)) return;
                if (!/^\/stores\/006\/201\/247\/products\/[^/]+$/.test(resized.pathname)) return;
                if (typeof entry.filename !== 'string' || !/^[^/\\]+\.(?:jpe?g|png|webp|avif)$/i.test(entry.filename)) return;
                var width = Number(entry.width), height = Number(entry.height);
                if (!(width > 0 && height > 0)) return;
                var original = new URL(resized.href);
                original.pathname = original.pathname.slice(0, original.pathname.lastIndexOf('/') + 1) + entry.filename;
                original.search = '';
                original.hash = '';
                var source = {base: resized.href, original: original.href, width: width, height: height,
                    baseWidth: Math.min(1024, width)};
                sources.set(source.base, source);
                sources.set(source.original, source);
            });
        } catch (error) { sources = new Map(); }
    }

    function fallback(image, state) {
        image.removeAttribute('srcset');
        image.removeAttribute('sizes');
        if (urlKey(image.getAttribute('src')) !== state.source.base) image.src = state.source.base;
    }

    function updateImage(image) {
        if (!image.isConnected || !image.closest(gallerySelector)) return;
        var key = urlKey(image.getAttribute('src'));
        var state = states.get(image);
        var source = sources.get(key);
        if (!source) {
            if (state) {
                image.removeAttribute('srcset');
                image.removeAttribute('sizes');
                states.delete(image);
            }
            return;
        }
        if (!state || state.source !== source) {
            state = {source: source};
            states.set(image, state);
            if (!observedImages.has(image)) {
                observedImages.add(image);
                image.addEventListener('error', function () {
                    var current = states.get(image);
                    if (!current || urlKey(image.currentSrc) !== current.source.original) return;
                    failedOriginals.add(current.source.original);
                    fallback(image, current);
                });
            }
        }
        if (resizeObserver) resizeObserver.observe(image);
        if (intersectionObserver) intersectionObserver.observe(image);
        if (source.width <= source.baseWidth || failedOriginals.has(source.original)) {
            fallback(image, state);
            return;
        }
        // The legacy track eagerly creates every slide. Wait for clipping/viewport visibility
        // before offering the large file, so a high-DPR visit does not download the entire shoot.
        if (intersectionObserver && !visibleImages.get(image)) return;
        var box = image.getBoundingClientRect();
        if (!box.width || !box.height) return;
        var fit = getComputedStyle(image).objectFit;
        var drawnWidth = fit === 'cover' ? Math.max(box.width, box.height * source.width / source.height) : box.width;
        if (fit === 'contain') drawnWidth = Math.min(box.width, box.height * source.width / source.height);
        var sizes = Math.ceil(drawnWidth) + 'px';
        var srcset = source.base + ' ' + source.baseWidth + 'w, ' + source.original + ' ' + source.width + 'w';
        if (image.getAttribute('sizes') !== sizes) image.setAttribute('sizes', sizes);
        if (image.getAttribute('srcset') !== srcset) image.setAttribute('srcset', srcset);
    }

    function watchParent(parent) {
        if (!parent || watchedParents.has(parent)) return;
        watchedParents.add(parent);
        observer.observe(parent, {childList: true});
    }

    function scan() {
        var product = document.getElementById('single-product');
        if (product) watchParent(product.parentNode);
        document.querySelectorAll(gallerySelector).forEach(function (gallery) {
            watchParent(gallery.closest('.eora-product-wrap').parentNode);
            if (!watchedGalleries.has(gallery)) {
                watchedGalleries.add(gallery);
                observer.observe(gallery, {childList: true, subtree: true, attributes: true, attributeFilter: ['src']});
            }
            gallery.querySelectorAll(imageSelector).forEach(updateImage);
        });
    }

    var resizeObserver = typeof ResizeObserver !== 'undefined' ? new ResizeObserver(function (entries) {
        entries.forEach(function (entry) {
            if (entry.target.isConnected) updateImage(entry.target);
            else resizeObserver.unobserve(entry.target);
        });
    }) : null;
    var intersectionObserver = typeof IntersectionObserver !== 'undefined' ? new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            // isIntersecting is also true for zero-area contact at the next slide's edge.
            var visible = entry.isIntersecting && entry.intersectionRatio >= 0.01;
            visibleImages.set(entry.target, visible);
            if (visible) updateImage(entry.target);
        });
    }, {threshold: 0.01}) : null;
    var observer = new MutationObserver(function (records) {
        var refreshSources = false;
        records.forEach(function (record) {
            record.addedNodes.forEach(function (node) {
                if (node.nodeType === 1 && (node.id === 'single-product' || node.querySelector('#single-product'))) refreshSources = true;
            });
            record.removedNodes.forEach(function (node) {
                if (node.nodeType !== 1) return;
                function release(image) {
                    if (image.isConnected) return;
                    if (resizeObserver) resizeObserver.unobserve(image);
                    if (intersectionObserver) intersectionObserver.unobserve(image);
                    visibleImages.delete(image);
                }
                if (node.matches(imageSelector)) release(node);
                node.querySelectorAll(imageSelector).forEach(release);
            });
        });
        if (refreshSources) readSources();
        scan();
    });

    readSources();
    // Legacy initialization inserts the gallery next to #single-product at DOMContentLoaded.
    watchParent(document.body);
    scan();
    window.addEventListener('resize', scan, {passive: true});
})();
