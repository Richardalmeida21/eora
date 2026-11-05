// Product description players load near the viewport, including replacements on color changes.
(function () {
    'use strict';
    var selector = 'iframe[data-eora-video-src]';
    var observed = new WeakSet();
    function load(frame) {
        var src = frame.getAttribute('data-eora-video-src');
        if (!src) return;
        frame.removeAttribute('data-eora-video-src');
        frame.setAttribute('src', src);
    }
    var intersection = 'IntersectionObserver' in window ? new IntersectionObserver(function (entries) {
        entries.forEach(function (entry) {
            if (!entry.isIntersecting) return;
            intersection.unobserve(entry.target);
            load(entry.target);
        });
    }, {rootMargin: '200px 0px'}) : null;
    function scan(container) {
        container.querySelectorAll(selector).forEach(function (frame) {
            if (observed.has(frame)) return;
            observed.add(frame);
            if (intersection) intersection.observe(frame);
            else load(frame);
        });
    }
    function init() {
        document.querySelectorAll('.js-product-video').forEach(function (container) {
            scan(container);
            // Only the video block is watched, never the entire page or its attributes.
            new MutationObserver(function (records) {
                records.forEach(function (record) {
                    Array.prototype.forEach.call(record.removedNodes, function (node) {
                        if (node.nodeType !== 1 || !intersection) return;
                        if (node.matches(selector)) intersection.unobserve(node);
                        node.querySelectorAll(selector).forEach(function (frame) { intersection.unobserve(frame); });
                    });
                });
                scan(container);
            }).observe(container, {childList: true, subtree: true});
        });
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init, {once: true});
    else init();
})();
