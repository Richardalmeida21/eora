(function () {
    'use strict';
    if (window.eoraProductWhatsappReady) return;
    window.eoraProductWhatsappReady = true;

    function productUrl(link) {
        try {
            // The rendered form carries its own identity across reference-page clones.
            // During a swap, history and the visible form can briefly be different products.
            var rendered = new URL(link.getAttribute('data-product-url'), window.location.origin);
            if (rendered.origin !== window.location.origin || !/^https?:$/.test(rendered.protocol)) return null;
            if (/\/(?:comprar|cart|carrinho|checkout)(?:\/|$)/i.test(rendered.pathname)) return null;
            var current = new URL(window.location.href);
            var url = current.pathname === rendered.pathname ? current : rendered;
            var params = new URLSearchParams();
            // Only actual selection keys belong in a shared product link. Preview,
            // campaign and internal feed parameters must never leave the storefront.
            url.searchParams.forEach(function (value, key) {
                if (/^(?:vi|variant|variant_id|variation(?:\[[^\]]+\])?|option\d*|attribute\[[^\]]+\])$/i.test(key)) {
                    params.append(key, value);
                }
            });
            url.search = params.toString();
            url.hash = '';
            return url.href;
        } catch (error) {
            return null;
        }
    }

    function update(link) {
        var scope = link.closest('.eora-product-wrap, #single-product');
        if (!scope || link.closest('.js-quickshop-container, #quickshop-modal')) return;
        var title = scope.querySelector('.eora-product-name, .js-product-name');
        var name = ((title && title.textContent) || link.getAttribute('data-product-name') || '').trim();
        var url = productUrl(link);
        if (!name || !url) return;
        link.href = 'https://wa.me/5519999285508?text=' + encodeURIComponent('Olá! Eu gostaria de mais informações sobre: ' + name + ' - ' + url);
    }

    function updateFromEvent(event) {
        var target = event.target;
        var link = target && target.closest && target.closest('a.js-product-whatsapp');
        if (link) update(link);
        // Keep native anchor behavior, including keyboard, Ctrl/Cmd and middle click.
    }

    ['pointerdown', 'focusin', 'contextmenu', 'click', 'auxclick'].forEach(function (type) {
        document.addEventListener(type, updateFromEvent, true);
    });
    document.querySelectorAll('a.js-product-whatsapp').forEach(update);
})();
