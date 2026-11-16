/* Retire campaign announcements without changing Nuvemshop's checkout rules. */
(function () {
    'use strict';
    var selector = '.js-product-promo-container, .eora-cart-promotion-label, .announcement-bar[id^="banner-alert-"]';
    var campaignName = /\beorablack\b|\bblack\s+friday\s+2026\b/i;

    function hideCampaignNotices() {
        document.querySelectorAll(selector).forEach(function (notice) {
            notice.classList.toggle('eora-retired-campaign-notice', campaignName.test(notice.textContent));
        });
    }

    function start() {
        hideCampaignNotices();
        var pending = false;
        new MutationObserver(function (records) {
            if (pending || !records.some(function (record) {
                var target = record.target.nodeType === 1 ? record.target : record.target.parentElement;
                return (target && target.closest(selector)) || Array.from(record.addedNodes).some(function (node) {
                    return node.nodeType === 1 && (node.matches(selector) || node.querySelector(selector));
                });
            })) return;
            pending = true;
            requestAnimationFrame(function () {
                pending = false;
                hideCampaignNotices();
            });
        }).observe(document.body, { childList: true, characterData: true, subtree: true });
    }

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', start, { once: true });
    else start();
})();
