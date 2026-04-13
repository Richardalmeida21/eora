(function() {
    function initVideoPlayers() {
        var players = document.querySelectorAll('.js-home-video-lado-player');
        if (!players.length) return;

        // Shared observer for efficiency
        var observer;
        if ('IntersectionObserver' in window) {
            observer = new IntersectionObserver(function(entries) {
                entries.forEach(function(entry) {
                    if (entry.isIntersecting) {
                        var player = entry.target;
                        // Delay loading heavily to prioritize LCP
                        setTimeout(function() {
                             if (player._loadVideoFn) player._loadVideoFn(true);
                        }, 800); 
                        if (observer) observer.unobserve(player);
                    }
                });
            }, { rootMargin: '0px' });
        }

        players.forEach(function(player) {
            if (player._videoInitialized) return;
            player._videoInitialized = true;

            var videoUrl = player.getAttribute('data-home-video-lado-url');
            var videoType = player.getAttribute('data-home-video-lado-type') || 'sound';
            var playButton = player.querySelector('.js-play-button');
            var iframeContainer = player.querySelector('.js-video-iframe');
            var videoImage = player.querySelector('.js-video-image');

            if (!videoUrl) return;

            // detect platform and id
            var videoId = '';
            var platform = '';
            if (videoUrl.indexOf('/watch?v=') !== -1) {
                videoId = videoUrl.split('/watch?v=')[1].split('&')[0];
                platform = 'youtube';
            } else if (videoUrl.indexOf('/youtu.be/') !== -1) {
                videoId = videoUrl.split('/youtu.be/')[1].split('?')[0];
                platform = 'youtube';
            } else if (videoUrl.indexOf('/shorts/') !== -1) {
                videoId = videoUrl.split('/shorts/')[1].split('?')[0];
                platform = 'youtube';
            } else if (videoUrl.indexOf('vimeo.com/') !== -1) {
                videoId = videoUrl.split('vimeo.com/')[1].split('?')[0].split('/')[0];
                platform = 'vimeo';
            }

            function loadVideo(autoplay) {
                var iframe = document.createElement('iframe');
                var params = [];
                var embedUrl = '';

                if (platform === 'youtube') {
                    embedUrl = 'https://www.youtube.com/embed/' + videoId;
                    if (autoplay) {
                        params.push('autoplay=1', 'mute=1');
                    }
                    if (videoType === 'autoplay') {
                        params.push('controls=0', 'rel=0', 'loop=1', 'playlist=' + videoId, 'modestbranding=1', 'playsinline=1');
                    } else {
                        params.push('rel=0', 'modestbranding=1', 'playsinline=1');
                    }
                } else if (platform === 'vimeo') {
                    embedUrl = 'https://player.vimeo.com/video/' + videoId;
                    if (autoplay) {
                        params.push('autoplay=1', 'muted=1', 'controls=0');
                    }
                    if (videoType === 'autoplay') {
                        params.push('background=1', 'loop=1', 'controls=0');
                    } else {
                        params.push('title=0', 'byline=0', 'portrait=0');
                    }
                    var accentColor = player.getAttribute('data-video-color') || '';
                    if (accentColor) params.push('color=' + accentColor);
                    params.push('dnt=1', 'playsinline=1');
                }

                iframe.src = embedUrl + (params.length ? '?' + params.join('&') : '');
                iframe.width = '100%';
                iframe.height = '100%';
                iframe.frameBorder = '0';
                iframe.setAttribute('allowfullscreen', '');
                iframe.setAttribute('allow', 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture; autoplay');

                if (videoType === 'autoplay') {
                    iframe.style.pointerEvents = 'none';
                }

                iframe.style.border = 'none';
                if (iframeContainer) {
                    iframeContainer.innerHTML = '';
                    iframeContainer.appendChild(iframe);
                    iframeContainer.style.display = 'block';
                }
                if (videoImage) videoImage.style.display = 'none';
                if (playButton) playButton.style.display = 'none';
            }
            
            player._loadVideoFn = loadVideo;

            if (videoType === 'autoplay') {
                if (observer) {
                    observer.observe(player);
                } else {
                    setTimeout(function() { loadVideo(true); }, 2500);
                }
            } else if (playButton) {
                playButton.addEventListener('click', function(e) {
                    e.preventDefault();
                    loadVideo(true);
                });
            }
        });
    }

    if (document.readyState === 'complete' || document.readyState === 'interactive') {
        initVideoPlayers();
    } else {
        document.addEventListener('DOMContentLoaded', initVideoPlayers);
    }
    window.addEventListener('load', initVideoPlayers);
})();

