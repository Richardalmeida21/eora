// Preserve editor image links when legacy product scripts rebuild description blocks.
// Loaded after template_content, before DOMContentLoaded can remove the source tables.
(function () {
    'use strict';
    var readyAttribute = 'data-eora-description-image-links-ready';
    if (document.documentElement.hasAttribute(readyAttribute)) return;
    document.documentElement.setAttribute(readyAttribute, '');

    var definitions = [
        {keys: ['clientes_eora'], selector: '.eora-clientes-section, .clientes-eora-section'},
        {keys: ['banners_experiencia_eora'], selector: '.js-banners-experiencia-eora'},
        {keys: ['banners_alternados'], selector: '.js-banners-alternados-product'},
        {keys: ['banner_imagem_full', 'banner foto full'], selector: '.eora-banner-imagem-full'},
        {keys: ['banner_produto', 'banner foto ou video'], selector: '.eora-banner-produto'},
        {keys: ['banners_3_videos', '3 banners videos', '3 banners video'], selector: '.eora-banners-3-videos'}
    ];
    var blockSelector = definitions.map(function (definition) { return definition.selector; }).join(', ');
    var ownedSelector = 'a[data-eora-description-image-link]';
    var links = new Map();
    var observedBlocks = new WeakSet();
    var observedParents = new WeakSet();
    var loadedBlocks = new WeakSet();

    function imageKey(value) {
        if (!value) return '';
        try {
            var url = new URL(value, document.baseURI);
            return /^https?:$/.test(url.protocol) ? url.href : '';
        } catch (error) { return ''; }
    }

    function imageKeys(image) {
        var values = [image.currentSrc, image.getAttribute('data-src'), image.getAttribute('src')];
        ['data-srcset', 'srcset'].forEach(function (attribute) {
            (image.getAttribute(attribute) || '').split(',').forEach(function (candidate) {
                values.push(candidate.trim().replace(/\s+\d+(?:\.\d+)?[wx]$/, ''));
            });
        });
        return values.map(imageKey).filter(Boolean);
    }

    function readLink(image, table) {
        var anchor = image.closest('a[href]');
        if (!anchor || !table.contains(anchor)) return null;
        var href = (anchor.getAttribute('href') || '').trim();
        if (!href) return null;
        try {
            if (!/^(https?:|mailto:|tel:)$/.test(new URL(href, document.baseURI).protocol)) return null;
        } catch (error) { return null; }
        var target = anchor.getAttribute('target') || '';
        var rel = (anchor.getAttribute('rel') || '').split(/\s+/).filter(Boolean);
        if (target === '_blank') {
            ['noopener', 'noreferrer'].forEach(function (value) {
                if (rel.indexOf(value) === -1) rel.push(value);
            });
        }
        return {href: href, target: target, rel: rel.join(' '), title: anchor.getAttribute('title') || ''};
    }

    function capture(sources) {
        var next = new Map();
        sources.forEach(function (source) {
            // Product cards, quickshop and cloned forms are not the current description.
            if (source.closest('.js-item-product, .js-quickshop-container, .eora-product-info')) return;
            source.querySelectorAll('table').forEach(function (table) {
                // Some legacy tables put a title row before the actual block key.
                var keys = Array.from(table.querySelectorAll('tr > td:first-child')).map(function (cell) {
                    return cell.textContent.replace(/[\u00a0\s]+/g, ' ').trim().toLowerCase()
                        .normalize('NFD').replace(/[\u0300-\u036f]/g, '');
                });
                var definition = definitions.find(function (entry) {
                    return entry.keys.some(function (key) { return keys.indexOf(key) !== -1; });
                });
                if (!definition) return;
                var map = next.get(definition) || new Map();
                table.querySelectorAll('img').forEach(function (image) {
                    var link = readLink(image, table);
                    imageKeys(image).forEach(function (url) {
                        // If one image has competing destinations in the same block, do not guess.
                        if (map.has(url) && JSON.stringify(map.get(url)) !== JSON.stringify(link)) map.set(url, null);
                        else if (!map.has(url)) map.set(url, link);
                    });
                });
                next.set(definition, map);
            });
        });
        links = next;
    }

    function setLink(anchor, link) {
        ['href', 'target', 'rel', 'title'].forEach(function (attribute) {
            if (link[attribute]) anchor.setAttribute(attribute, link[attribute]);
            else anchor.removeAttribute(attribute);
        });
    }

    function restoreBlock(block) {
        var definition = definitions.find(function (entry) { return block.matches(entry.selector); });
        var map = links.get(definition);
        block.querySelectorAll('img').forEach(function (image) {
            if (image.closest('.js-product-description-base, .product-image-column, button, form, [data-fancybox]')) return;
            var anchor = image.closest('a');
            if (anchor && !anchor.matches(ownedSelector)) return;
            var link = null;
            var keys = imageKeys(image);
            for (var i = 0; map && i < keys.length; i++) {
                if (map.has(keys[i])) { link = map.get(keys[i]); break; }
            }
            if (!link) {
                if (anchor) anchor.replaceWith.apply(anchor, Array.from(anchor.childNodes));
                return;
            }
            if (!anchor) {
                var visual = image.closest('picture') || image;
                anchor = document.createElement('a');
                anchor.setAttribute('data-eora-description-image-link', '');
                anchor.style.display = 'block';
                // Keep the same containing block and focus area for absolutely positioned photos.
                if (getComputedStyle(visual).position === 'absolute') {
                    anchor.style.position = 'absolute';
                    anchor.style.inset = '0';
                }
                visual.parentNode.insertBefore(anchor, visual);
                anchor.appendChild(visual);
            }
            setLink(anchor, link);
        });
    }

    function watchParent(parent) {
        if (!parent || observedParents.has(parent)) return;
        observedParents.add(parent);
        // Structural changes only: no observer on the entire body subtree.
        observer.observe(parent, {childList: true});
    }

    function watchBlock(block) {
        watchParent(block.parentNode);
        if (!loadedBlocks.has(block)) {
            loadedBlocks.add(block);
            // currentSrc can change with a picture's media query without changing img attributes.
            var refreshImage = function (event) {
                if (event.target.tagName === 'IMG') restoreBlock(block);
            };
            block.addEventListener('load', refreshImage, true);
            block.addEventListener('error', refreshImage, true);
        }
        if (!observedBlocks.has(block)) {
            observedBlocks.add(block);
            observer.observe(block, {childList: true, subtree: true, attributes: true,
                attributeFilter: ['src', 'srcset', 'data-src', 'data-srcset']});
        }
        restoreBlock(block);
    }

    function discover(node) {
        if (node.nodeType !== 1 || !node.isConnected) return;
        if (node.matches(blockSelector)) watchBlock(node);
        node.querySelectorAll(blockSelector).forEach(watchBlock);
    }

    function watchPage() {
        watchParent(document.body);
        var product = document.getElementById('single-product');
        if (product) watchParent(product.parentNode);
        document.querySelectorAll('.js-product-description-base').forEach(function (source) {
            if (!source.closest('.js-item-product, .js-quickshop-container, .eora-product-info')) watchParent(source.parentNode);
        });
        // Legacy blocks are inserted next to these stable anchors, sometimes inside a container.
        document.querySelectorAll('.js-product-video, [data-store="home-institutional-message"], .js-texto-campanha-produto')
            .forEach(function (anchor) { watchParent(anchor.parentNode); });
        document.querySelectorAll(blockSelector).forEach(watchBlock);
    }

    var observer = new MutationObserver(function (records) {
        var pending = new Set();
        var refreshSources = false;
        var added = [];
        records.forEach(function (record) {
            record.addedNodes.forEach(function (node) {
                if (node.nodeType !== 1 || !node.isConnected || node.matches(ownedSelector)) return;
                added.push(node);
                if (node.id === 'single-product' || node.matches('.js-product-description-base')) refreshSources = true;
            });
            var block = record.target.nodeType === 1 && record.target.closest(blockSelector);
            if (block && block.isConnected && (record.type === 'attributes' || !record.target.closest(ownedSelector))) pending.add(block);
        });
        if (refreshSources) {
            // Full-width descriptions are siblings of #single-product, not children of it.
            capture(Array.from(document.querySelectorAll('.js-product-description-base')));
            // Release detached product sections instead of retaining old DOM across navigation.
            observer.disconnect();
            observedBlocks = new WeakSet();
            observedParents = new WeakSet();
            watchPage();
        }
        added.forEach(discover);
        pending.forEach(restoreBlock);
    });

    capture(Array.from(document.querySelectorAll('.js-product-description-base')));
    watchPage();
})();
