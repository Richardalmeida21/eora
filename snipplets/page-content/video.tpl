{# {% set video_link = settings.product_video_embed %} #}
{% set video_link = attribute(settings,"#{settings_name}_video_embed") %}
{# {% set video_link_mobile = settings.product_video_embed_mobile %} #}
{% set video_link_mobile = attribute(settings,"#{settings_name}_video_embed_mobile") %}


{% if (video_link or video_link_mobile) %}
    {% set video_title = attribute(settings,"#{settings_name}_video_button_title") %}
    {% set video_description = attribute(settings,"#{settings_name}_video_button_description") %}

    {# {% set has_video_text = settings.product_video_button_text_title or settings.product_video_button_text_description %} #}
    {% set has_video_text = video_title or video_description %}
    
    <section class="js-section-footer-video-horizontal section-footer-video-horizontal position-relative section-home" data-store="footer-video-horizontal" data-transition="fade-in-up">
        <div class="footer-video-horizontal {% if attribute(settings,"#{settings_name}_video_size_option") == 'zoomm' %}-video-zoom{% elseif attribute(settings,"#{settings_name}_video_size_option") == 'originall' %}-video-original{% else %}-video-original{% endif %}">
            <figure class="image -custom d-none d-md-block">
                {% if video_link %}
                    <div class="js-video home-video embed-responsive embed-responsive-30by9 position-relative" data-video-type="desktop">
                        {% if attribute(settings,"#{settings_name}_video_type") == 'sound' %}
                            <a href="javascript:void(0)" class="js-play-button video-player">
                                <div class="video-player-icon">
                                    <svg class="icon-inline icon-3x svg-icon-text"><use xlink:href="#play"/></svg>
                                </div>
                            </a>
                        {% endif %}
                        
                        {# Video thumbnail #}
                        <div class="js-video-image">
                            {% set video_url = video_link %}
                            {% set video_id = '' %}
                            {% set video_platform = '' %}
                            
                            {# YouTube detection #}
                            {% if '/watch?v=' in video_link %}
                                {% set video_id = video_url|split('/watch?v=')|last|split('&')|first %}
                                {% set video_platform = 'youtube' %}
                            {% elseif '/youtu.be/' in video_link %}
                                {% set video_id = video_url|split('/youtu.be/')|last|split('?')|first %}
                                {% set video_platform = 'youtube' %}
                            {% elseif '/shorts/' in video_link %}
                                {% set video_id = video_url|split('/shorts/')|last|split('?')|first %}
                                {% set video_platform = 'youtube' %}
                            {# Vimeo detection #}
                            {% elseif 'vimeo.com/' in video_link %}
                                {% set video_id = video_url|split('vimeo.com/')|last|split('?')|first|split('/')[0] %}
                                {% set video_platform = 'vimeo' %}
                            {% endif %}
                            
                            {% if video_platform == 'youtube' %}
                                {% set video_image_src = 'https://img.youtube.com/vi/' ~ video_id ~ '/maxresdefault.jpg' %}
                            {% elseif video_platform == 'vimeo' %}
                                {% set video_image_src = 'https://vumbnail.com/' ~ video_id ~ '.jpg' %}
                            {% endif %}
                            
                            <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ video_image_src }}" class="lazyload video-image fade-in" alt="{{ 'Video de' | translate }} {{ store.name }}" />
                            <div class="placeholder-fade"></div>
                        </div>

                        {# Empty iframe component: will be filled with JS on play button click #}
                        <div class="js-video-iframe embed-responsive embed-responsive-30by9" style="display: none;" data-video-color="{{ settings.accent_color | trim('#') }}" data-video-url="{{ video_link }}">
                        </div>

                        {# Overlays para esconder controles do YouTube #}
                        <div class="video-overlay-blocker"></div>
                        <div class="video-controls-mask top"></div>
                        <div class="video-controls-mask bottom"></div>
                        <div class="video-controls-mask left"></div>
                        <div class="video-controls-mask right"></div>

                        {% if has_video_text %}
                            <div class="banner-floating-button">
                                <div class="banner-floating-button-content">
                                    <div class="banner-floating-title">{{ video_title }}</div>
                                    <svg class="banner-floating-icon" viewbox="0 0 10 10" fill="none" style="transform: scaleX(-1)">
                                        <use xlink:href="#chevron-diagonal"></use>
                                    </svg>
                                </div>
                                {% if video_description %}
                                    <div class="banner-floating-description">{{ video_description }}</div>
                                {% endif %}
                            </div>
                        {% endif %}
                    </div>
                {% endif %}
            </figure>

            <figure class="image -custom d-md-none">
                <div class="js-video home-video embed-responsive embed-responsive-30by9 position-relative">
                    {% if attribute(settings,"#{settings_name}_video_type") == 'sound' %}
                        <a href="javascript:void(0)" class="js-play-button video-player">
                            <div class="video-player-icon">
                                <svg class="icon-inline icon-3x svg-icon-text"><use xlink:href="#play"/></svg>
                            </div>
                        </a>
                    {% endif %}
                    
                    {# Video thumbnail #}
                    <div class="js-video-image">
                        <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ video_image_src }}" class="lazyload video-image fade-in" alt="{{ 'Video de' | translate }} {{ store.name }}" />
                        <div class="placeholder-fade"></div>
                    </div>

                    {# Empty iframe component: will be filled with JS on play button click #}
                    <div class="js-video-iframe embed-responsive embed-responsive-30by9" style="display: none;" data-video-color="{{ settings.accent_color | trim('#') }}" data-video-url="{{ video_link }}">
                    </div>

                    {# Overlays para esconder controles do YouTube #}
                    <div class="video-overlay-blocker"></div>
                    <div class="video-controls-mask top"></div>
                    <div class="video-controls-mask bottom"></div>
                    <div class="video-controls-mask left"></div>
                    <div class="video-controls-mask right"></div>
                </div>
            </figure>

            {# {% if settings.product_video_url != '' %}
                </a>
            {% endif %} #}
        </div>
    </section>

    <script>
        document.addEventListener('DOMContentLoaded', function() {
            var videoContainers = document.querySelectorAll('.js-section-footer-video-horizontal .js-video');
            var videoUrl = '{{ video_link }}';
            var videoType = '{{ attribute(settings,"#{settings_name}_video_type") }}';
            var videoSizeOption = '{{ attribute(settings,"#{settings_name}_video_size_option") }}';
            
            if (videoContainers.length && videoUrl) {
                // Detectar plataforma e extrair ID do vídeo
                var videoId = '';
                var videoPlatform = '';
                
                if (videoUrl.includes('/watch?v=')) {
                    videoId = videoUrl.split('/watch?v=')[1].split('&')[0];
                    videoPlatform = 'youtube';
                } else if (videoUrl.includes('/youtu.be/')) {
                    videoId = videoUrl.split('/youtu.be/')[1].split('?')[0];
                    videoPlatform = 'youtube';
                } else if (videoUrl.includes('/shorts/')) {
                    videoId = videoUrl.split('/shorts/')[1].split('?')[0];
                    videoPlatform = 'youtube';
                } else if (videoUrl.includes('vimeo.com/')) {
                    videoId = videoUrl.split('vimeo.com/')[1].split('?')[0].split('/')[0];
                    videoPlatform = 'vimeo';
                }
                
                if (videoId && videoPlatform) {
                    videoContainers.forEach(function(videoContainer) {
                        var iframeContainer = videoContainer.querySelector('.js-video-iframe');
                        var videoImage = videoContainer.querySelector('.js-video-image');
                        var playButton = videoContainer.querySelector('.js-play-button');
                        
                        // Função para criar e carregar iframe
                        function loadVideo(autoplay) {
                            var iframe = document.createElement('iframe');
                            var params = [];
                            var embedUrl = '';
                            
                            if (videoPlatform === 'youtube') {
                                embedUrl = 'https://www.youtube.com/embed/' + videoId;
                                
                                if (autoplay) {
                                    params.push('autoplay=1', 'mute=1');
                                }
                                
                                if (videoType === 'autoplay') {
                                    params.push('controls=0', 'showinfo=0', 'rel=0', 'loop=1', 'playlist=' + videoId, 'modestbranding=1', 'playsinline=1', 'iv_load_policy=3', 'fs=0', 'disablekb=1', 'cc_load_policy=0', 'enablejsapi=1', 'start=0', 'end=0', 'version=3', 'wmode=transparent', 'origin=' + window.location.origin);
                                } else {
                                    params.push('rel=0', 'modestbranding=1', 'playsinline=1');
                                }
                            } else if (videoPlatform === 'vimeo') {
                                embedUrl = 'https://player.vimeo.com/video/' + videoId;
                                var accentColor = '{{ settings.accent_color | trim('#') }}';
                                
                                if (autoplay) {
                                    params.push('autoplay=1', 'muted=1');
                                }
                                
                                if (videoType === 'autoplay') {
                                    params.push('background=1', 'loop=1', 'controls=0');
                                } else {
                                    params.push('title=0', 'byline=0', 'portrait=0');
                                }
                                
                                if (accentColor) {
                                    params.push('color=' + accentColor);
                                }
                                
                                params.push('dnt=1', 'playsinline=1');
                            }
                            
                            iframe.src = embedUrl + (params.length ? '?' + params.join('&') : '');
                            iframe.width = '100%';
                            iframe.height = '100%';
                            iframe.frameBorder = '0';
                            iframe.allowFullscreen = true;
                            iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
                            
                            if (videoType === 'autoplay') {
                                iframe.style.pointerEvents = 'none';
                            }
                            
                            // Aplicar estilos baseados na opção de tamanho selecionada
                            // O CSS já aplica as transformações via classes, então apenas definimos position e border
                            iframe.style.border = 'none';
                            
                            // Limpar container e adicionar iframe
                            iframeContainer.innerHTML = '';
                            iframeContainer.appendChild(iframe);
                            
                            // Mostrar iframe e esconder imagem
                            iframeContainer.style.display = 'block';
                            if (videoImage) {
                                videoImage.style.display = 'none';
                            }
                            if (playButton) {
                                playButton.style.display = 'none';
                            }
                            
                            // API do YouTube para controlar o loop no autoplay
                            if (videoPlatform === 'youtube' && videoType === 'autoplay') {
                                window.addEventListener('message', function(event) {
                                    if (event.origin !== 'https://www.youtube.com') return;
                                    
                                    var data = {};
                                    try {
                                        data = JSON.parse(event.data);
                                    } catch (e) {
                                        return;
                                    }
                                    
                                    // Quando o vídeo termina, reinicia imediatamente
                                    if (data.event === 'video-progress' && data.info && data.info.currentTime) {
                                        var duration = data.info.duration;
                                        var currentTime = data.info.currentTime;
                                        
                                        // Se chegou perto do fim (últimos 0.1 segundos), reinicia
                                        if (duration && currentTime >= duration - 0.1) {
                                            iframe.contentWindow.postMessage('{"event":"command","func":"seekTo","args":[0,true]}', '*');
                                        }
                                    }
                                });
                            }
                        }
                        
                        // Se for autoplay, carregar automaticamente
                        if (videoType === 'autoplay') {
                            setTimeout(function() {
                                loadVideo(true);
                            }, 500);
                        }
                        
                        // Se for sound, carregar quando clicar no play
                        if (playButton && videoType === 'sound') {
                            playButton.addEventListener('click', function(e) {
                                e.preventDefault();
                                loadVideo(true);
                            });
                        }
                    });
                }
            }
        });
    </script>
{% endif %}
