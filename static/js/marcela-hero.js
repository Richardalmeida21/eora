(function () {
    'use strict';
    var hero = document.querySelector('[data-mf-media]');
    if (!hero || hero.dataset.mfMediaReady) return;
    var player = hero.querySelector('[data-mf-video-player]');
    if (!player) return;
    hero.dataset.mfMediaReady = '1';
    var mobile = matchMedia('(max-width: 767px)');
    var reduced = matchMedia('(prefers-reduced-motion: reduce)');
    var toggle = hero.querySelector('[data-mf-media-toggle]');
    var active = null, vimeoSdk, youtubeSdk, instance, timer, enabled = !reduced.matches;
    var connected = new Set();
    function connect(origin) {
        if (!origin || origin === location.origin || connected.has(origin)) return;
        connected.add(origin);
        var link = document.createElement('link');
        link.rel = 'preconnect'; link.href = origin;
        document.head.appendChild(link);
    }
    function source() {
        return mobile.matches ? hero.dataset.mfVideoMobile || hero.dataset.mfVideoDesktop : hero.dataset.mfVideoDesktop || hero.dataset.mfVideoMobile;
    }
    function mediaUrl(raw) {
        if (!raw || !raw.trim()) return null;
        try {
            var url = new URL(raw, location.href);
            if (!['http:', 'https:'].includes(url.protocol)) return null;
            if (/\.mp4$/i.test(url.pathname)) return {video: url.href, origin: url.origin};
            if (/^(?:www\.)?(?:player\.)?vimeo\.com$/.test(url.hostname)) {
                var match = url.pathname.match(/^\/(?:video\/)?(\d+)(?:\/([a-z0-9]+))?\/?$/i);
                if (!match) return null;
                var embed = new URL('https://player.vimeo.com/video/' + match[1]);
                var hash = url.searchParams.get('h') || match[2];
                if (hash) embed.searchParams.set('h', hash);
                Object.entries({autoplay:1, muted:1, loop:1, controls:0, title:0, byline:0, playsinline:1}).forEach(function (pair) { embed.searchParams.set(pair[0], pair[1]); });
                return {provider:'vimeo', embed:embed.href, origin:embed.origin};
            }
            var id = url.hostname === 'youtu.be' ? url.pathname.split('/')[1] : /^(?:(?:www|m)\.)?(?:youtube\.com|youtube-nocookie\.com)$/.test(url.hostname) ? url.searchParams.get('v') || url.pathname.split('/').filter(Boolean).pop() : null;
            if (id && /^[\w-]{11}$/.test(id)) {
                var yt = new URL('https://www.youtube-nocookie.com/embed/' + id);
                Object.entries({autoplay:1, mute:1, loop:1, playlist:id, controls:0, playsinline:1, enablejsapi:1, origin:location.origin}).forEach(function (pair) { yt.searchParams.set(pair[0], pair[1]); });
                return {provider:'youtube', embed:yt.href, origin:yt.origin};
            }
        } catch (_) {}
        return null;
    }
    function ratio(media) {
        var useMobile = !!hero.dataset.mfVideoMobile && (mobile.matches || !hero.dataset.mfVideoDesktop);
        var raw = useMobile ? hero.dataset.mfVideoRatioMobile : hero.dataset.mfVideoRatioDesktop;
        var p = String(raw || '').match(/^\s*(\d{1,4})\s*[:/]\s*(\d{1,4})\s*$/);
        return p && Number(p[2]) && Number(p[1])/Number(p[2]) >= .1 && Number(p[1])/Number(p[2]) <= 10 ? Number(p[1]) + ' / ' + Number(p[2]) : media.provider === 'vimeo' ? '3 / 1' : '16 / 9';
    }
    function valid(node) { return active && active.node === node && player.contains(node); }
    function updateRatio(node, w, h) {
        if (valid(node) && w > 0 && h > 0 && w/h >= .1 && w/h <= 10) hero.style.setProperty('--mf-video-ratio', w + ' / ' + h);
    }
    function button(show, label) {
        if (!toggle) return;
        toggle.hidden = !show;
        toggle.textContent = label || 'Reproduzir vídeo';
        toggle.setAttribute('aria-label', toggle.textContent);
    }
    function reveal(node) {
        if (!valid(node)) return;
        clearTimeout(timer);
        hero.classList.add('mf-hero--video-ready');
        button(true, 'Pausar vídeo');
    }
    function cleanup() {
        clearTimeout(timer);
        if (instance) { try { Promise.resolve(instance.destroy()).catch(function () {}); } catch (_) {} instance = null; }
        if (active && active.node.tagName === 'VIDEO') {
            active.node.pause(); active.node.removeAttribute('src'); active.node.load();
        }
        active = null;
        player.replaceChildren();
        hero.classList.remove('mf-hero--video-ready', 'mf-hero--video-active');
        hero.style.removeProperty('--mf-video-ratio');
    }
    function fail(node) {
        if (!valid(node)) return;
        cleanup();
        button(true, 'Reproduzir vídeo');
    }
    function loadSdk(url, get) {
        return new Promise(function (resolve) {
            if (get()) { resolve(get()); return; }
            var script = document.createElement('script');
            script.async = true; script.src = url;
            var attempts = 0, settled = false, poll;
            function finish(value) { if (settled) return; settled = true; clearInterval(poll); resolve(value); }
            script.onerror = function () { finish(null); };
            poll = setInterval(function () { var sdk = get(); if (sdk || ++attempts >= 200) finish(sdk || null); }, 100);
            document.head.appendChild(script);
        });
    }
    function vimeo(frame) {
        if (!vimeoSdk) vimeoSdk = loadSdk('https://player.vimeo.com/api/player.js', function () { return window.Vimeo && window.Vimeo.Player; });
        vimeoSdk.then(function (Player) {
            if (!valid(frame)) return;
            if (!Player) { vimeoSdk = null; return; }
            try {
                var p = new Player(frame); instance = p;
                p.on('playing', function () { reveal(frame); });
                p.on('timeupdate', function (event) { if (event.seconds > 0) reveal(frame); });
                p.on('error', function () { fail(frame); });
                Promise.all([p.getVideoWidth(), p.getVideoHeight()]).then(function (size) { updateRatio(frame, Number(size[0]), Number(size[1])); }).catch(function () {});
                if (typeof p.getCurrentTime === 'function') p.getCurrentTime().then(function (seconds) { if (seconds > 0) reveal(frame); }).catch(function () {});
            } catch (_) {}
        });
    }
    function youtube(frame) {
        if (!youtubeSdk) youtubeSdk = loadSdk('https://www.youtube.com/iframe_api', function () { return window.YT && window.YT.Player; });
        youtubeSdk.then(function (Player) {
            if (!valid(frame)) return;
            if (!Player) { youtubeSdk = null; return; }
            try {
                instance = new Player(frame, {events:{
                    onReady:function (event) { if (valid(frame)) { event.target.mute(); event.target.playVideo(); } },
                    onStateChange:function (event) { if (event.data === 1) reveal(frame); },
                    onError:function () { fail(frame); }
                }});
            } catch (_) {}
        });
    }
    function start(force) {
        var raw = source(), media = mediaUrl(raw);
        if (!media) { cleanup(); button(false); return; }
        if (!enabled) { cleanup(); button(true); return; }
        if (!force && active && active.raw === raw) return;
        cleanup();
        connect(media.origin);
        if (media.provider === 'vimeo') { connect('https://i.vimeocdn.com'); connect('https://f.vimeocdn.com'); }
        if (media.provider === 'youtube') { connect('https://www.youtube.com'); }
        hero.classList.add('mf-hero--video-active');
        hero.style.setProperty('--mf-video-ratio', ratio(media));
        button(false);
        var node = document.createElement(media.video ? 'video' : 'iframe');
        active = {raw:raw, node:node};
        // Do not discard an in-flight stream on a slow network. Offer a retry while keeping the cover.
        timer = setTimeout(function () { if (valid(node) && !hero.classList.contains('mf-hero--video-ready')) button(true, 'Tentar reproduzir vídeo'); }, 12000);
        if (media.video) {
            node.preload = 'auto'; node.defaultMuted = true; node.muted = true; node.autoplay = true; node.loop = true; node.playsInline = true;
            node.setAttribute('aria-label', 'Vídeo Favoritos da Marcela');
            node.addEventListener('loadedmetadata', function () { updateRatio(node, node.videoWidth, node.videoHeight); });
            node.addEventListener('playing', function () { reveal(node); });
            node.addEventListener('error', function () { fail(node); });
            node.src = media.video; player.appendChild(node);
            node.play().catch(function () { if (valid(node)) button(true, 'Reproduzir vídeo'); });
        } else {
            node.title = 'Vídeo Favoritos da Marcela'; node.allow = 'autoplay; fullscreen; picture-in-picture';
            node.tabIndex = -1; node.loading = 'eager';
            node.src = media.embed; player.appendChild(node);
            if (media.provider === 'vimeo') vimeo(node); else youtube(node);
        }
    }
    if (toggle) toggle.addEventListener('click', function () {
        if (hero.classList.contains('mf-hero--video-ready')) { enabled = false; cleanup(); button(true); }
        else { enabled = true; start(true); }
    });
    mobile.addEventListener('change', function () { start(false); });
    reduced.addEventListener('change', function () { enabled = !reduced.matches; start(false); });
    start(false);
}());
