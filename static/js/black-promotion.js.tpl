/* Presentation only: eligibility, coupon validation and totals stay with Nuvemshop. */
(function () {
    'use strict';
    if (window.eoraBlackPromotionInitialized) return;
    window.eoraBlackPromotionInitialized = true;

    var selectors = '.js-product-promo-container, .eora-cart-promotion-label, .js-total-promotions-detail-row';
    var noticeMarkup = '<span class="eora-black-notice">' +
        '<span class="eora-black-notice__line">10% OFF comprando 2 ou mais!</span>' +
        '<span class="eora-black-notice__line">Usando o cupom: <strong>EORABLACK</strong></span>' +
        '<span class="eora-black-notice__deadline">CUPOM DISPONÍVEL ATÉ 23:59</span></span>';

    function enhance(source, requireCampaignName) {
        var native = source.querySelector('.eora-black-native');
        var notice = source.querySelector('.eora-black-notice');
        var text = (native || source).textContent.replace(/\s+/g, ' ').trim();
        var eligible = /\b10%\s*OFF\b/i.test(text) && /\bcomprando\s+2\s+ou\s+mais\b/i.test(text);
        if (requireCampaignName) eligible = eligible && /black\s*friday\s+2026/i.test(text);
        if (!eligible) {
            if (notice) notice.remove();
            if (native) native.replaceWith.apply(native, Array.from(native.childNodes));
            source.classList.remove('eora-black-enhanced');
            return;
        }
        if (native && notice) return;
        if (!native) {
            native = document.createElement('span');
            native.className = 'eora-black-native';
            native.setAttribute('aria-hidden', 'true');
            while (source.firstChild) native.appendChild(source.firstChild);
            source.appendChild(native);
        }
        source.insertAdjacentHTML('beforeend', noticeMarkup);
        source.classList.add('eora-black-enhanced');
    }

    function update() {
        document.querySelectorAll('.js-product-promo-container').forEach(function (source) {
            enhance(source, true);
        });
        // This is the native label for the configured 10% / 2-item promotion.
        // Free shipping and other discount thresholds retain their original labels.
        document.querySelectorAll('.eora-cart-promotion-label').forEach(function (source) {
            enhance(source, false);
        });
        document.querySelectorAll('.js-total-promotions-detail-row').forEach(function (row) {
            var wording = row.querySelector('.col');
            if (wording) enhance(wording, true);
        });
    }

    function start() {
        update();
        var pending = false;
        new MutationObserver(function (records) {
            var relevant = records.some(function (record) {
                var target = record.target.nodeType === 1 ? record.target : record.target.parentElement;
                return (target && target.closest(selectors)) || Array.from(record.addedNodes).some(function (node) {
                    return node.nodeType === 1 && (node.matches(selectors) || node.querySelector(selectors));
                });
            });
            if (!relevant || pending) return;
            pending = true;
            requestAnimationFrame(function () { pending = false; update(); });
        }).observe(document.body, {childList: true, characterData: true, subtree: true});
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start, {once: true});
    else start();
})();
