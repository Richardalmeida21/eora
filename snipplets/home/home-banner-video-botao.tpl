{#
====================================================================
  BANNER VÍDEO + BOTÃO — Seção independente do Banner Vídeo Horizontal
--------------------------------------------------------------------
  Configurado via painel da Nuvemshop em:
  "Página inicial" → "Banner Vídeo + Botão"

  Suporta vídeo do YouTube ou Vimeo (autoplay/loop/mute) ou
  fallback de imagem caso não haja URL de vídeo.
  Renderiza um botão estilizado sobreposto ao vídeo, opcional.
====================================================================
#}

{% set vb_video        = settings.banner_video_botao_embed %}
{% set vb_video_mobile = settings.banner_video_botao_embed_mobile | default(vb_video) %}
{% set vb_image        = settings.banner_video_botao_image %}
{% set vb_link         = settings.banner_video_botao_link %}
{% set vb_button       = settings.banner_video_botao_button %}
{% set vb_title        = settings.banner_video_botao_title %}

{% set vb_has_media = vb_video or vb_image %}

{% if settings.banner_video_botao_show and vb_has_media %}

    {% set vb_id = 'bvb-' ~ random() %}

    <section class="section-home section-banner-video-botao position-relative"
             data-store="home-banner-video-botao"
             data-transition="fade-in-up">
        <div class="container-fluid my-4 my-md-5">

            {% if vb_link %}
                <a href="{{ vb_link | setting_url }}" class="banner-video-botao-link">
            {% endif %}

            <div class="banner-video-botao-wrapper" id="{{ vb_id }}">

                {% if vb_video %}
                    {# Detecção da plataforma do vídeo desktop #}
                    {% set vb_platform = '' %}
                    {% set vb_video_id = '' %}
                    {% if '/watch?v=' in vb_video %}
                        {% set vb_video_id = vb_video | split('/watch?v=') | last | split('&') | first %}
                        {% set vb_platform = 'youtube' %}
                    {% elseif 'youtu.be/' in vb_video %}
                        {% set vb_video_id = vb_video | split('youtu.be/') | last | split('?') | first %}
                        {% set vb_platform = 'youtube' %}
                    {% elseif '/shorts/' in vb_video %}
                        {% set vb_video_id = vb_video | split('/shorts/') | last | split('?') | first %}
                        {% set vb_platform = 'youtube' %}
                    {% elseif 'vimeo.com/' in vb_video %}
                        {% set vb_video_id = vb_video | split('vimeo.com/') | last | split('?') | first | split('/') | first %}
                        {% set vb_platform = 'vimeo' %}
                    {% endif %}

                    {# Detecção da plataforma do vídeo mobile #}
                    {% set vb_platform_m = '' %}
                    {% set vb_video_id_m = '' %}
                    {% if '/watch?v=' in vb_video_mobile %}
                        {% set vb_video_id_m = vb_video_mobile | split('/watch?v=') | last | split('&') | first %}
                        {% set vb_platform_m = 'youtube' %}
                    {% elseif 'youtu.be/' in vb_video_mobile %}
                        {% set vb_video_id_m = vb_video_mobile | split('youtu.be/') | last | split('?') | first %}
                        {% set vb_platform_m = 'youtube' %}
                    {% elseif '/shorts/' in vb_video_mobile %}
                        {% set vb_video_id_m = vb_video_mobile | split('/shorts/') | last | split('?') | first %}
                        {% set vb_platform_m = 'youtube' %}
                    {% elseif 'vimeo.com/' in vb_video_mobile %}
                        {% set vb_video_id_m = vb_video_mobile | split('vimeo.com/') | last | split('?') | first | split('/') | first %}
                        {% set vb_platform_m = 'vimeo' %}
                    {% endif %}

                    <div class="banner-video-botao-video"
                         data-platform="{{ vb_platform }}"
                         data-video-id="{{ vb_video_id }}"
                         data-platform-mobile="{{ vb_platform_m }}"
                         data-video-id-mobile="{{ vb_video_id_m }}">
                    </div>
                {% elseif vb_image %}
                    <img src="{{ 'images/empty-placeholder.png' | static_url }}"
                         data-src="{{ vb_image | static_url | settings_image_url('huge') }}"
                         data-srcset="{{ vb_image | static_url | settings_image_url('large') }} 768w, {{ vb_image | static_url | settings_image_url('huge') }} 1280w, {{ vb_image | static_url | settings_image_url('1080p') }} 1920w"
                         data-sizes="auto"
                         class="banner-video-botao-image lazyautosizes lazyload"
                         alt="{% if vb_title %}{{ vb_title }}{% else %}{{ store.name }}{% endif %}">
                {% endif %}

                {% if vb_button or vb_title %}
                    <div class="banner-floating-button banner-video-botao-button">
                        <div class="banner-floating-button-content">
                            <div class="banner-floating-title">
                                {% if vb_button %}{{ vb_button }}{% else %}{{ vb_title }}{% endif %}
                            </div>
                            <svg class="banner-floating-icon" viewbox="0 0 10 10" fill="none">
                                <use xlink:href="#chevron-diagonal"></use>
                            </svg>
                        </div>
                        {% if vb_button and vb_title %}
                            <div class="banner-floating-description">{{ vb_title }}</div>
                        {% endif %}
                    </div>
                {% endif %}

            </div>

            {% if vb_link %}
                </a>
            {% endif %}
        </div>
    </section>

    <style>
        .section-banner-video-botao { box-sizing: border-box; }
        .section-banner-video-botao *,
        .section-banner-video-botao *::before,
        .section-banner-video-botao *::after { box-sizing: border-box; }
        .banner-video-botao-link {
            display: block;
            text-decoration: none;
            color: inherit;
        }
        .banner-video-botao-wrapper {
            position: relative;
            width: 100%;
            overflow: hidden;
            background: #000;
            aspect-ratio: 21 / 9;
        }
        @supports not (aspect-ratio: 21 / 9) {
            .banner-video-botao-wrapper { padding-bottom: 42.857%; }
        }
        .banner-video-botao-video,
        .banner-video-botao-image,
        .banner-video-botao-wrapper iframe {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            border: 0;
            object-fit: cover;
        }
        .banner-video-botao-video {
            overflow: hidden;
        }
        .banner-video-botao-video iframe {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%);
            border: 0;
            pointer-events: none;
            /* Desktop (wrapper 21:9): cobre pela largura, transborda no topo/baixo */
            width: 100%;
            height: auto;
            aspect-ratio: 16 / 9;
        }
        @supports not (aspect-ratio: 16 / 9) {
            .banner-video-botao-video iframe {
                width: 100%;
                height: 56.25%;
                min-height: 100%;
            }
        }
        @media (max-width: 767px) {
            .banner-video-botao-wrapper { aspect-ratio: 4 / 5; }
            @supports not (aspect-ratio: 4 / 5) {
                .banner-video-botao-wrapper { padding-bottom: 125%; }
            }
            /* Mobile (wrapper 4:5): cobre pela altura, transborda nas laterais */
            .banner-video-botao-video iframe {
                width: auto;
                height: 100%;
            }
        }
    </style>

    {% if vb_video %}
    <script>
        (function () {
            var wrapper = document.getElementById('{{ vb_id }}');
            if (!wrapper) return;
            var videoBox = wrapper.querySelector('.banner-video-botao-video');
            if (!videoBox) return;

            var isMobile = window.matchMedia('(max-width: 767px)').matches;
            var platform = isMobile && videoBox.dataset.platformMobile
                ? videoBox.dataset.platformMobile
                : videoBox.dataset.platform;
            var videoId = isMobile && videoBox.dataset.videoIdMobile
                ? videoBox.dataset.videoIdMobile
                : videoBox.dataset.videoId;

            if (!platform || !videoId) return;

            var src = '';
            if (platform === 'youtube') {
                src = 'https://www.youtube.com/embed/' + videoId
                    + '?autoplay=1&mute=1&controls=0&loop=1&playlist=' + videoId
                    + '&modestbranding=1&playsinline=1&rel=0&showinfo=0&iv_load_policy=3&disablekb=1';
            } else if (platform === 'vimeo') {
                src = 'https://player.vimeo.com/video/' + videoId
                    + '?autoplay=1&muted=1&loop=1&background=1&controls=0&playsinline=1&dnt=1';
            }
            if (!src) return;

            var iframe = document.createElement('iframe');
            iframe.src = src;
            iframe.setAttribute('frameborder', '0');
            iframe.setAttribute('allow', 'autoplay; encrypted-media; picture-in-picture');
            iframe.setAttribute('allowfullscreen', 'true');
            iframe.setAttribute('title', 'Banner vídeo');
            videoBox.appendChild(iframe);
        })();
    </script>
    {% endif %}

{% endif %}
