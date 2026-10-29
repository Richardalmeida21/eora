(function () {
    'use strict';
    function init() {
        var desktopMedia = window.matchMedia('(min-width: 1200px)');
        document.querySelectorAll('[data-eora-menu]').forEach(function (root) {
            if (root.dataset.menuReady) return;
            root.dataset.menuReady = 'true';
            if (root.dataset.eoraMenu === 'desktop') {
                var toggle = root.querySelector('[data-menu-toggle]');
                var panel = root.querySelector('[data-menu-desktop]');
                var overlay = root.querySelector('[data-menu-overlay]');
                // The native header is transformed; fixed descendants must live outside it.
                var portal = document.createElement('div');
                portal.className = 'eora-menu eora-menu--desktop eora-menu--portal';
                portal.appendChild(overlay);
                portal.appendChild(panel);
                document.body.appendChild(portal);
                function position() {
                    var header = root.closest('header');
                    var bottom = header ? header.getBoundingClientRect().bottom : root.getBoundingClientRect().bottom;
                    portal.style.setProperty('--eora-menu-top', Math.max(0, bottom) + 'px');
                }
                function close(restore) {
                    if (panel.hidden) return;
                    panel.hidden = overlay.hidden = true;
                    toggle.setAttribute('aria-expanded', 'false');
                    document.body.classList.remove('eora-menu-open');
                    if (restore && desktopMedia.matches) toggle.focus();
                }
                toggle.addEventListener('click', function () {
                    if (!panel.hidden) return close(true);
                    position();
                    panel.hidden = overlay.hidden = false;
                    toggle.setAttribute('aria-expanded', 'true');
                    document.body.classList.add('eora-menu-open');
                    panel.querySelector('[data-menu-close]').focus();
                });
                panel.querySelector('[data-menu-close]').addEventListener('click', function () { close(true); });
                overlay.addEventListener('click', function () { close(true); });
                document.addEventListener('click', function (event) {
                    if (!root.contains(event.target) && !portal.contains(event.target)) close(false);
                });
                panel.addEventListener('keydown', function (event) {
                    if (event.key === 'Escape') { event.preventDefault(); event.stopPropagation(); close(true); }
                    if (event.key !== 'Tab') return;
                    var focusable = Array.from(panel.querySelectorAll('a[href], button:not([disabled])')).filter(function (node) { return node.getClientRects().length; });
                    var first = focusable[0], last = focusable[focusable.length - 1];
                    if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
                    else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
                });
                window.addEventListener('resize', function () { if (!desktopMedia.matches) close(false); else position(); });
            } else {
                var active = 'primary';
                var modal = root.closest('#nav-hamburger');
                var opener = null;
                function show(name, focus) {
                    var previous = active;
                    active = name;
                    root.querySelectorAll('[data-menu-screen]').forEach(function (screen) {
                        var selected = screen.dataset.menuScreen === name;
                        screen.hidden = !selected;
                        screen.classList.toggle('is-active', selected);
                    });
                    root.querySelectorAll('[data-menu-go][aria-expanded]').forEach(function (button) { button.setAttribute('aria-expanded', button.dataset.menuGo === name ? 'true' : 'false'); });
                    if (!focus) return;
                    var screen = root.querySelector('[data-menu-screen="' + name + '"]');
                    var target = screen.querySelector('[data-menu-go="' + previous + '"]') || screen.querySelector('button, a');
                    if (target) target.focus({preventScroll: true});
                    var scroller = root.closest('.modal-scrollable-area');
                    if (scroller) scroller.scrollTop = 0;
                }
                root.classList.add('is-ready');
                show('primary', false);
                root.addEventListener('click', function (event) {
                    var button = event.target.closest('[data-menu-go]');
                    if (!button || !root.contains(button)) return;
                    show(button.dataset.menuGo, true);
                });
                root.addEventListener('keydown', function (event) {
                    if (event.key !== 'Escape') return;
                    if (active !== 'primary') { event.preventDefault(); event.stopPropagation(); show(active === 'secondary' ? 'primary' : 'secondary', true); }
                });
                document.addEventListener('click', function (event) {
                    var control = event.target.closest('.js-modal-close, .js-modal-overlay, [data-toggle="#nav-hamburger"]');
                    if (!control) return;
                    if (control.matches('[data-toggle="#nav-hamburger"]')) {
                        opener = control;
                        opener.setAttribute('aria-expanded', 'true');
                        show('primary', false);
                        requestAnimationFrame(function () {
                            if (modal && !modal.hidden && window.getComputedStyle(modal).display !== 'none') root.querySelector('[data-menu-screen="primary"] button').focus({preventScroll: true});
                        });
                    } else if (modal && (modal.contains(control) || control.getAttribute('data-modal-id') === '#nav-hamburger')) {
                        show('primary', false);
                        if (opener) {
                            opener.setAttribute('aria-expanded', 'false');
                            requestAnimationFrame(function () { opener.focus({preventScroll: true}); });
                        }
                    }
                });
                if (modal) modal.addEventListener('keydown', function (event) {
                    if (event.key === 'Escape') {
                        event.preventDefault();
                        event.stopPropagation();
                        var closeControl = modal.querySelector('a.js-modal-close, button.js-modal-close') || modal.querySelector('.js-modal-close');
                        if (closeControl) closeControl.click();
                    }
                    if (event.key !== 'Tab') return;
                    var elements = Array.from(modal.querySelectorAll('a[href], button:not([disabled]), input, [tabindex="0"]')).filter(function (node) { return node.getClientRects().length; });
                    var first = elements[0], last = elements[elements.length - 1];
                    if (event.shiftKey && document.activeElement === first) { event.preventDefault(); last.focus(); }
                    else if (!event.shiftKey && document.activeElement === last) { event.preventDefault(); first.focus(); }
                });
            }
        });
        document.querySelectorAll('[data-search-discovery]').forEach(function (root) {
            if (root.dataset.searchReady) return;
            root.dataset.searchReady = 'true';
            var track = root.querySelector('[data-search-track]');
            var previous = root.querySelector('[data-search-prev]');
            var next = root.querySelector('[data-search-next]');
            function update() {
                previous.disabled = track.scrollLeft <= 2;
                next.disabled = track.scrollLeft + track.clientWidth >= track.scrollWidth - 2;
            }
            function move(direction) {
                var gap = parseFloat(window.getComputedStyle(track).columnGap) || 12;
                track.scrollBy({left: direction * (track.clientWidth + gap), behavior: window.matchMedia('(prefers-reduced-motion: reduce)').matches ? 'instant' : 'smooth'});
            }
            previous.addEventListener('click', function () { move(-1); });
            next.addEventListener('click', function () { move(1); });
            track.addEventListener('keydown', function (event) {
                if (event.key === 'ArrowRight' || event.key === 'ArrowLeft') { event.preventDefault(); move(event.key === 'ArrowRight' ? 1 : -1); }
            });
            track.addEventListener('scroll', update, {passive: true});
            document.addEventListener('click', function (event) {
                if (event.target.closest('[data-toggle="#nav-search"]')) {
                    track.scrollTo({left: 0, behavior: 'instant'});
                    update();
                }
            });
            new ResizeObserver(update).observe(track);
            update();
        });
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init, {once: true});
    else init();
})();
