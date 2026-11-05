(function (window, document) {
    'use strict';
    function money(cents) {
        return (cents / 100).toLocaleString('pt-BR', { style: 'currency', currency: 'BRL' });
    }
    function nativeTerms(data) {
        if (typeof data === 'string') { try { data = JSON.parse(data); } catch (error) { return null; } }
        if (!data || typeof data !== 'object') return null;
        var best = {count: 0, cents: 0};
        Object.keys(data).forEach(function (method) {
            var terms = data[method];
            if (!terms || typeof terms !== 'object') return;
            Object.keys(terms).forEach(function (count) {
                var term = terms[count];
                var amount = Number(count);
                if (term && term.without_interests === true && amount > best.count && Number(term.installment_value) > 0) {
                    best = {count: amount, cents: Math.round(Number(term.installment_value) * 100)};
                }
            });
        });
        return best;
    }
    function update(root, variant) {
        root = root || document;
        if (window.LS && window.LS.currency && window.LS.currency.code !== 'BRL') return;
        if (root.jquery || (root.length && !root.nodeType)) {
            Array.prototype.forEach.call(root, function (node) { update(node, variant); });
            return;
        }
        if (!root.querySelectorAll) return;
        var summaries = Array.prototype.slice.call(root.querySelectorAll('[data-eora-payments]'));
        if (root.matches && root.matches('[data-eora-payments]')) summaries.unshift(root);
        summaries.forEach(function (summary) {
            var scope = summary.closest('.js-product-container, .js-item-product, .be-product, [data-search-product]') || root;
            var priceNode = scope.querySelector('.js-price-display');
            var cents = variant && variant.price_number_raw != null ? Number(variant.price_number_raw) :
                priceNode && priceNode.getAttribute('data-product-price') != null ? Number(priceNode.getAttribute('data-product-price')) : Number(summary.getAttribute('data-price-cents'));
            // The native variant callback supplies integer raw cents; never parse formatted currency text.
            var visible = variant && variant.display_price != null ? variant.display_price !== false : !(priceNode && (priceNode.hidden || priceNode.style.display === 'none'));
            summary.hidden = !visible || !Number.isFinite(cents) || cents <= 0;
            if (summary.hidden) return;
            cents = Math.round(cents);
            summary.setAttribute('data-price-cents', cents);
            summary.querySelector('[data-eora-pix-price]').textContent = money(Math.round(cents * 95 / 100));
            var fallback = summary.querySelector('[data-eora-fallback-installments]');
            var nativeContainer = summary.querySelector('[data-eora-native-installments]');
            var terms = variant && variant.installments_data != null ? nativeTerms(variant.installments_data) : null;
            var nativeAvailable = summary.getAttribute('data-native-installments') === 'true';
            var enabled = summary.getAttribute('data-installments-enabled') !== 'false';
            if (terms) {
                // Existing native components are updated by the platform. Cards without them use the same metadata.
                if (summary.getAttribute('data-external-native-installments') === 'true' || (nativeContainer && nativeContainer.children.length)) { fallback.hidden = true; return; }
                fallback.hidden = !enabled || terms.count < 2;
                fallback.textContent = !fallback.hidden ? terms.count + 'x de ' + money(terms.cents) + ' sem juros' : '';
            } else if (variant && variant.installments_data != null) {
                fallback.hidden = true;
                fallback.textContent = '';
            } else {
                var count = Math.min(10, Math.floor(cents / 11000));
                fallback.hidden = !enabled || nativeAvailable || count < 2;
                fallback.textContent = !fallback.hidden ? count + 'x de ' + money(Math.round(cents / count)) + ' sem juros' : '';
            }
        });
    }
    function openShipping() {
        var drops = document.querySelectorAll('.eora-shipping-dropdown, .shipping-dropdown');
        for (var i = 0; i < drops.length; i++) {
            var drop = drops[i], toggle = drop.querySelector('.dropdown-toggle');
            if (!toggle || !toggle.getClientRects().length) continue;
            if (!drop.classList.contains('open')) toggle.click();
            if (!drop.classList.contains('open')) return false;
            var input = drop.querySelector('.js-shipping-input, input[name="zipcode"]');
            drop.scrollIntoView({behavior: 'smooth', block: 'center'});
            if (input && input.getClientRects().length) input.focus({preventScroll: true});
            return true;
        }
        return false;
    }
    document.addEventListener('click', function (event) {
        var link = event.target.closest && event.target.closest('[data-eora-shipping-link]');
        if (!link || event.defaultPrevented || event.button !== 0 || event.metaKey || event.ctrlKey || event.shiftKey || event.altKey) return;
        var url = new URL(link.href, window.location.href);
        if (url.origin === window.location.origin && url.pathname.replace(/\/$/, '') === window.location.pathname.replace(/\/$/, '') && openShipping()) event.preventDefault();
    });
    window.addEventListener('hashchange', function () {
        if (window.location.hash !== '#shipping') return;
        if (window.LS && window.LS.ready && typeof window.LS.ready.then === 'function') window.LS.ready.then(openShipping);
        else openShipping();
    });
    if (window.location.hash === '#shipping') {
        var attempt = function () {
            if (openShipping()) return;
            var observer = new MutationObserver(function () { if (openShipping()) observer.disconnect(); });
            observer.observe(document.documentElement, {childList: true, subtree: true});
            window.setTimeout(function () { observer.disconnect(); }, 8000);
        };
        if (document.readyState === 'complete') attempt(); else window.addEventListener('load', attempt, {once: true});
    }
    function openQuickshop(source, modal) {
        if (!source || !modal) return;
        var original = source.querySelector('[data-eora-payments]');
        var current = modal.querySelector('[data-eora-payments]');
        if (!current) return;
        if (!original) { current.hidden = true; return; }
        var copy = original.cloneNode(true);
        var shipping = copy.querySelector('.eora-product-payments__shipping');
        var productLink = source.querySelector('a.item-link[href], a[href*="/produtos/"]');
        if (shipping && productLink) {
            var link = document.createElement('a');
            link.className = shipping.className;
            link.textContent = shipping.textContent;
            link.setAttribute('data-eora-shipping-link', '');
            var url = new URL(productLink.href, window.location.href);
            url.hash = 'shipping';
            link.href = url.href;
            shipping.replaceWith(link);
        }
        current.replaceWith(copy);
    }
    window.EoraProductPayments = {update: update, openQuickshop: openQuickshop};
}(window, document));
