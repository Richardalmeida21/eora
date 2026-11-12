(function () {
    'use strict';
    function init() {
        var root = document.querySelector('[data-mf-page]');
        if (!root || root.dataset.mfReady) return;
        root.dataset.mfReady = '1';
        var reduced = window.matchMedia('(prefers-reduced-motion: reduce)');
        root.querySelectorAll('[data-mf-carousel]').forEach(function (section) {
            var track = section.querySelector('[data-mf-track]');
            Array.from(track.children).sort(function (a, b) { return Number(a.dataset.mfOrder) - Number(b.dataset.mfOrder); }).forEach(function (item) { track.appendChild(item); });
            var controls = section.querySelector('[data-be-controls]');
            var previous = controls.querySelector('[data-be-prev]');
            var next = controls.querySelector('[data-be-next]');
            var dots = controls.querySelector('[data-be-dots]');
            var offsets = [0];
            var current = 0;
            function update() {
                current = offsets.reduce(function (closest, left, i) { return Math.abs(left - track.scrollLeft) < Math.abs(offsets[closest] - track.scrollLeft) ? i : closest; }, 0);
                previous.disabled = current === 0;
                next.disabled = current === offsets.length - 1;
                Array.from(dots.children).forEach(function (dot, i) { if (i === current) dot.setAttribute('aria-current', 'true'); else dot.removeAttribute('aria-current'); });
            }
            function go(i) { track.scrollTo({left: offsets[Math.max(0, Math.min(offsets.length - 1, i))], behavior: reduced.matches ? 'auto' : 'smooth'}); }
            function layout() {
                var visible = Number(getComputedStyle(section).getPropertyValue('--mf-visible')) || 1;
                section.classList.toggle('mf-carousel--overflow', track.children.length > visible);
                var max = Math.max(0, track.scrollWidth - track.clientWidth);
                var first = track.firstElementChild;
                offsets = [0];
                Array.from(track.children).slice(1).forEach(function (item) {
                    var left = item.offsetLeft - first.offsetLeft;
                    if (left < max - 2) offsets.push(left);
                });
                if (max > 2) offsets.push(max);
                dots.replaceChildren();
                offsets.forEach(function (_, i) {
                    var dot = document.createElement('button');
                    dot.type = 'button'; dot.className = 'be-dot';
                    dot.setAttribute('aria-label', 'Ir para posição ' + (i + 1));
                    dot.addEventListener('click', function () { go(i); }); dots.appendChild(dot);
                });
                controls.hidden = offsets.length < 2;
                update();
            }
            previous.addEventListener('click', function () { go(current - 1); });
            next.addEventListener('click', function () { go(current + 1); });
            track.addEventListener('scroll', update, {passive: true});
            track.addEventListener('keydown', function (event) {
                if (event.target !== track || !['ArrowLeft', 'ArrowRight'].includes(event.key)) return;
                event.preventDefault(); go(current + (event.key === 'ArrowRight' ? 1 : -1));
            });
            if (window.ResizeObserver) new ResizeObserver(layout).observe(track);
            else window.addEventListener('resize', layout);
            layout();
        });

        var dialog = root.querySelector('#mf-look-dialog');
        if (dialog) {
            var opener;
            root.querySelectorAll('[data-mf-look]').forEach(function (button) {
                button.addEventListener('click', function () {
                    var template = root.querySelector('template[data-mf-look-content="' + button.dataset.mfLook + '"]');
                    if (!template) return;
                    opener = button;
                    dialog.querySelector('[data-mf-dialog-body]').replaceChildren(template.content.cloneNode(true));
                    dialog.showModal();
                    dialog.querySelector('[data-mf-close-look]').focus();
                });
            });
            dialog.querySelector('[data-mf-close-look]').addEventListener('click', function () { dialog.close(); });
            dialog.addEventListener('click', function (event) {
                if (event.target !== dialog) return;
                var rect = dialog.getBoundingClientRect();
                if (event.clientX < rect.left || event.clientX > rect.right || event.clientY < rect.top || event.clientY > rect.bottom) dialog.close();
            });
            dialog.addEventListener('close', function () {
                dialog.querySelector('[data-mf-dialog-body]').replaceChildren();
                if (opener) opener.focus({preventScroll: true});
            });
        }

        var hero = root.querySelector('[data-mf-media]');
        if (hero) {
            var mobile = window.matchMedia('(max-width: 767px)');
            var player = hero.querySelector('[data-mf-video-player]');
            var toggle = hero.querySelector('[data-mf-media-toggle]');
            var playing = false;
            function source() { return mobile.matches ? hero.dataset.mfVideoMobile || hero.dataset.mfVideoDesktop : hero.dataset.mfVideoDesktop || hero.dataset.mfVideoMobile; }
            function mediaUrl(raw) {
                try {
                    var url = new URL(raw, window.location.origin);
                    if (!['http:', 'https:'].includes(url.protocol)) return null;
                    if (/\.mp4(?:$|\?)/i.test(url.href)) return {video: url.href};
                    var vimeo = /^(?:www\.)?(?:player\.)?vimeo\.com$/.test(url.hostname) && url.pathname.match(/\/(?:video\/)?(\d+)/);
                    if (vimeo) return {embed: 'https://player.vimeo.com/video/' + vimeo[1] + '?background=1&autoplay=1&loop=1&muted=1&title=0&byline=0'};
                    var youtube = null;
                    if (url.hostname === 'youtu.be') youtube = url.pathname.slice(1);
                    if (/^(?:www\.)?(?:youtube\.com|youtube-nocookie\.com)$/.test(url.hostname)) youtube = url.searchParams.get('v') || url.pathname.split('/').pop();
                    if (youtube && /^[\w-]{11}$/.test(youtube)) return {embed: 'https://www.youtube-nocookie.com/embed/' + youtube + '?autoplay=1&mute=1&loop=1&playlist=' + youtube + '&controls=0&playsinline=1'};
                } catch (_) {}
                return null;
            }
            function setPlaying(value) {
                player.replaceChildren();
                var media = mediaUrl(source());
                playing = !!value && !!media;
                if (playing) {
                    if (media.video) {
                        var video = document.createElement('video');
                        video.muted = true; video.autoplay = true; video.loop = true; video.playsInline = true;
                        video.setAttribute('aria-label', 'Vídeo Favoritos da Marcela');
                        video.src = media.video; player.appendChild(video);
                        video.play().catch(function () { setPlaying(false); });
                    } else {
                        var frame = document.createElement('iframe');
                        frame.title = 'Vídeo Favoritos da Marcela'; frame.allow = 'autoplay; fullscreen; picture-in-picture';
                        frame.tabIndex = -1; frame.src = media.embed; player.appendChild(frame);
                    }
                }
                if (toggle) {
                    toggle.hidden = !media;
                    toggle.setAttribute('aria-pressed', String(playing));
                    toggle.textContent = playing ? 'Pausar vídeo' : 'Reproduzir vídeo';
                }
            }
            if (toggle) toggle.addEventListener('click', function () { setPlaying(!playing); });
            mobile.addEventListener('change', function () { setPlaying(playing); });
            reduced.addEventListener('change', function () { setPlaying(!reduced.matches); });
            setPlaying(!reduced.matches);
        }
    }
    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', init, {once: true}); else init();
}());
