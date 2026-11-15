/* Presentation only: eligibility, coupon validation and totals stay with Nuvemshop. */
(function () {
    'use strict';
    if (window.eoraBlackPromotionInitialized) return;
    window.eoraBlackPromotionInitialized = true;

    var cartItemSelector = '.js-cart-item[data-store^="cart-item-"]';
    var selectors = '.js-product-promo-container, .eora-cart-promotion-label, ' + cartItemSelector;
    // Product IDs from all six pages of the Black Friday 2026 storefront category.
    var campaignProductIds = new Set([
        291392635, 291429190, 291429253, 291429281, 291429340, 291437203, 291438131, 291438661, 291439189,
        291440460, 291441431, 291441723, 291442075, 291442677, 291443327, 291443869, 291445589, 291447233,
        291449353, 291451039, 291452646, 291455621, 291459065, 291460964, 291461861, 291462540, 291463617,
        291464856, 291466475, 291474883, 291475938, 291476476, 291477152, 291479001, 291481271, 291482390,
        291483476, 291484661, 291486876, 291488057, 291488987, 291490183, 293942442, 296934597, 297066265,
        301013237, 301374832, 301374937, 301375238, 301452767, 301790824, 303073135, 309852356, 309853117,
        309853258, 309853536, 309853635, 309853858, 309854102, 309854929, 309855355, 309855653, 309856104,
        309856685, 309856762, 309856901, 310991202, 310999577, 310999689, 310999812, 310999899, 311000186,
        311445638, 321886522, 321923125, 321923653, 321923863, 321924030, 321924286, 321924448, 322659163,
        328200515, 328277555, 328277645, 328277795, 328277843, 328289846, 328290094, 332346047, 333931538,
        333938256, 333938592, 338231984, 338233386, 338235797, 338245820, 338248095, 338267711, 338547316,
        345186328, 345381092, 345381419, 345383150, 345383409, 345383803, 345383884, 345384167, 345384458,
        345384573, 345384706, 357931423, 357931464, 357931504, 357931536, 357931676, 357931728, 357967732,
        357967892, 363731725, 364677074, 364677284, 367905470, 369595139, 369595432, 369595857, 369596062,
        369966015, 374154591, 374159103, 374170272, 374880742, 377923251
    ]);
    var campaignStart = Date.parse('2026-11-14T00:00:00-03:00');
    var campaignEnd = Date.parse('2026-11-17T00:00:00-03:00');
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

    function updateProductAnnouncement() {
        var now = Date.now();
        document.querySelectorAll('[data-eora-black-product]').forEach(function (slot) {
            var eligible = now >= campaignStart && now < campaignEnd &&
                campaignProductIds.has(Number(slot.dataset.eoraBlackProduct));
            var nativeNotice = eligible &&
                slot.parentElement.querySelector('.js-product-promo-container.eora-black-enhanced');
            slot.hidden = !eligible || Boolean(nativeNotice);
            if (!slot.hidden && !slot.firstElementChild) slot.innerHTML = noticeMarkup;
        });
    }

    function updateCartAnnouncements() {
        var now = Date.now();
        document.querySelectorAll(cartItemSelector).forEach(function (item) {
            var productId = Number(item.getAttribute('data-store').slice('cart-item-'.length));
            var existing = item.querySelector('[data-eora-black-cart-notice]');
            var nativeNotice = Array.from(item.querySelectorAll('.eora-cart-promotion-label')).some(function (label) {
                return label.classList.contains('eora-black-enhanced') || /\bEORABLACK\b/i.test(label.textContent);
            });
            var show = now >= campaignStart && now < campaignEnd &&
                campaignProductIds.has(productId) && !nativeNotice;

            if (!show && existing) existing.remove();
            if (show && !existing) {
                var variant = item.querySelector('.short_variant_name');
                if (variant) variant.insertAdjacentHTML('afterend',
                    '<div class="col-12" data-eora-black-cart-notice>' + noticeMarkup + '</div>');
            }
        });
    }

    function updateAnnouncements() {
        updateProductAnnouncement();
        updateCartAnnouncements();
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
        updateAnnouncements();
    }

    function start() {
        update();
        var now = Date.now();
        if (now < campaignStart) setTimeout(updateAnnouncements, campaignStart - now);
        if (now < campaignEnd) setTimeout(updateAnnouncements, campaignEnd - now);
        var pending = false;
        new MutationObserver(function (records) {
            var relevant = records.some(function (record) {
                var target = record.target.nodeType === 1 ? record.target : record.target.parentElement;
                return (target && target.closest(selectors)) || Array.from(record.addedNodes).concat(Array.from(record.removedNodes)).some(function (node) {
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
