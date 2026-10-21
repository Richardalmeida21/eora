(function () {
    'use strict';
    function init() {
        var root = document.querySelector('[data-se-page]');
        if (!root) return;
        var reducedMotion = window.matchMedia('(prefers-reduced-motion: reduce)');
        root.querySelectorAll('[data-se-carousel]').forEach(function (section) {
            if (section.dataset.seReady) return;
            section.dataset.seReady = '1';
            var track = section.querySelector('[data-se-track]');
            var cards = Array.from(track.querySelectorAll('[data-se-card]'));
            var controls = section.querySelector('[data-se-controls]');
            var previous = section.querySelector('[data-se-prev]');
            var next = section.querySelector('[data-se-next]');
            var dots = section.querySelector('[data-se-dots]');
            var count = section.querySelector('[data-se-count]');
            var active = 0;
            var scheduled = false;
            var positions = [];
            var pages = [];
            function go(index) {
                var target = Math.max(0, Math.min(index, pages.length - 1));
                track.scrollTo({left: pages[target], behavior: reducedMotion.matches ? 'auto' : 'smooth'});
            }
            function update() {
                scheduled = false;
                var left = track.scrollLeft;
                active = 0;
                pages.forEach(function (position, index) {
                    if (Math.abs(position - left) < Math.abs(pages[active] - left)) active = index;
                });
                previous.disabled = left < 2;
                next.disabled = left >= track.scrollWidth - track.clientWidth - 2;
                dots.querySelectorAll('button').forEach(function (dot, index) {
                    dot.setAttribute('aria-current', index === active ? 'true' : 'false');
                });
                count.textContent = (active + 1) + ' / ' + pages.length;
            }
            function measure() {
                var max = Math.max(0, track.scrollWidth - track.clientWidth);
                var origin = cards.length ? cards[0].getBoundingClientRect().left : 0;
                positions = cards.map(function (card) { return card.getBoundingClientRect().left - origin; });
                pages = [];
                positions.forEach(function (position) {
                    var clamped = Math.min(position, max);
                    if (!pages.length || Math.abs(clamped - pages[pages.length - 1]) > 2) pages.push(clamped);
                });
                if (!pages.length) pages = [0];
                dots.replaceChildren();
                pages.forEach(function (position, index) {
                    var dot = document.createElement('button');
                    dot.type = 'button';
                    dot.dataset.seDot = String(index);
                    dot.setAttribute('aria-label', 'Ir para a posição ' + (index + 1));
                    dot.setAttribute('aria-controls', track.id);
                    dot.addEventListener('click', function () { go(index); });
                    dots.appendChild(dot);
                });
                controls.hidden = max < 2;
                update();
            }
            previous.addEventListener('click', function () { go(active - 1); });
            next.addEventListener('click', function () { go(active + 1); });
            track.addEventListener('keydown', function (event) {
                if (event.target !== track || !['ArrowLeft', 'ArrowRight', 'Home', 'End'].includes(event.key)) return;
                event.preventDefault();
                go(event.key === 'Home' ? 0 : event.key === 'End' ? pages.length - 1 : active + (event.key === 'ArrowLeft' ? -1 : 1));
            });
            track.addEventListener('scroll', function () {
                if (scheduled) return;
                scheduled = true;
                window.requestAnimationFrame(update);
            }, {passive: true});
            if ('ResizeObserver' in window) new ResizeObserver(measure).observe(track);
            else window.addEventListener('resize', measure, {passive: true});
            measure();
        });
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init, {once: true});
    else init();
})();
