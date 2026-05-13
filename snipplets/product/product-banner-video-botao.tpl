{#
====================================================================
  BANNER PRODUTO — Foto ou Vídeo + Botão sobreposto
--------------------------------------------------------------------
  Configurado via painel da Nuvemshop em:
  "Produto" → "Banner Vídeo/Foto + Botão"

  Suporta:
    - Vídeo do YouTube ou Vimeo (autoplay/loop/mudo)
    - Imagem (fallback ou modo principal)
  Exibe um botão estilizado sobreposto no canto inferior esquerdo.
====================================================================
#}

{% set pb_video       = settings.product_banner_video %}
{% set pb_image       = settings.product_banner_image %}
{% set pb_button      = settings.product_banner_button %}
{% set pb_title       = settings.product_banner_title %}
{% set pb_link        = settings.product_banner_link %}
{% set pb_has_media   = pb_video or pb_image %}

{% if settings.product_banner_show and pb_has_media %}

    {% set pb_id = 'pb-' ~ random() %}

    {# ── Detecta plataforma e ID do vídeo ── #}
    {% set pb_platform = '' %}
    {% set pb_video_id = '' %}
    {% if pb_video %}
        {% if '/watch?v=' in pb_video %}
            {% set pb_video_id = pb_video | split('/watch?v=') | last | split('&') | first %}
            {% set pb_platform = 'youtube' %}
        {% elseif 'youtu.be/' in pb_video %}
            {% set pb_video_id = pb_video | split('youtu.be/') | last | split('?') | first %}
            {% set pb_platform = 'youtube' %}
        {% elseif '/shorts/' in pb_video %}
            {% set pb_video_id = pb_video | split('/shorts/') | last | split('?') | first %}
            {% set pb_platform = 'youtube' %}
        {% elseif 'vimeo.com/' in pb_video %}
            {% set pb_video_id = pb_video | split('vimeo.com/') | last | split('?') | first | split('/') | first %}
            {% set pb_platform = 'vimeo' %}
        {% endif %}
    {% endif %}

    <section class="section-product-banner-video-botao position-relative my-4 my-md-5"
             data-store="product-banner-video-botao">

        {% if pb_link %}
            <a href="{{ pb_link | setting_url }}" class="product-banner-vb-link d-block">
        {% endif %}

        <div class="product-banner-vb-wrapper" id="{{ pb_id }}">

            {% if pb_video and pb_platform %}
                <div class="product-banner-vb-video"
                     data-platform="{{ pb_platform }}"
                     data-video-id="{{ pb_video_id }}">
                </div>
            {% elseif pb_image %}
                <img src="{{ 'images/empty-placeholder.png' | static_url }}"
                     data-src="{{ pb_image | static_url | settings_image_url('huge') }}"
                     data-srcset="{{ pb_image | static_url | settings_image_url('large') }} 768w, {{ pb_image | static_url | settings_image_url('huge') }} 1280w, {{ pb_image | static_url | settings_image_url('1080p') }} 1920w"
                     data-sizes="auto"
                     class="product-banner-vb-image lazyautosizes lazyload"
                     alt="{% if pb_title %}{{ pb_title }}{% else %}{{ store.name }}{% endif %}">
            {% endif %}

            {% if pb_button or pb_title %}
                <div class="banner-floating-button product-banner-vb-button">
                    <div class="banner-floating-button-content">
                        <div class="banner-floating-title">
                            {% if pb_button %}{{ pb_button }}{% else %}{{ pb_title }}{% endif %}
                        </div>
                        <svg class="banner-floating-icon" viewbox="0 0 10 10" fill="none">
                            <use xlink:href="#chevron-diagonal"></use>
                        </svg>
                    </div>
                    {% if pb_button and pb_title %}
                        <div class="banner-floating-description">{{ pb_title }}</div>
                    {% endif %}
                </div>
            {% endif %}

        </div>

        {% if pb_link %}
            </a>
        {% endif %}

    </section>

    <style>
        .section-product-banner-video-botao { box-sizing: border-box; }
        .product-banner-vb-link {
            text-decoration: none;
            color: inherit;
        }
        .product-banner-vb-wrapper {
            position: relative;
            width: 100%;
            overflow: hidden;
            background: #000;
        }
        .product-banner-vb-wrapper::before {
            content: '';
            display: block;
            padding-bottom: 42.857%; /* proporção 21:9 */
        }
        .product-banner-vb-video,
        .product-banner-vb-image {
            position: absolute;
            inset: 0;
            width: 100%;
            height: 100%;
            border: 0;
            object-fit: cover;
        }
        .product-banner-vb-video { overflow: hidden; }
        .product-banner-vb-video iframe {
            position: absolute;
            top: 50%;
            left: 50%;
            width: 177.78vh;
            height: 100vh;
            min-width: 100%;
            min-height: 100%;
            transform: translate(-50%, -50%);
            border: 0;
            pointer-events: none;
        }
        @media (min-aspect-ratio: 16/9) {
            .product-banner-vb-video iframe {
                width: 100vw;
                height: 56.25vw;
            }
        }
        @media (max-width: 767px) {
            .product-banner-vb-wrapper::before { padding-bottom: 100%; /* 1:1 no mobile */ }
            .product-banner-vb-video iframe {
                width: 177.78vh;
                height: 100vh;
            }
        }
        .product-banner-vb-button {
            position: absolute;
            bottom: 20px;
            left: 20px;
            z-index: 2;
        }
    </style>

    {% if pb_video and pb_platform %}
    <script>
        (function () {
            var wrapper = document.getElementById('{{ pb_id }}');
            if (!wrapper) return;
            var videoBox = wrapper.querySelector('.product-banner-vb-video');
            if (!videoBox) return;

            var platform = videoBox.dataset.platform;
            var videoId  = videoBox.dataset.videoId;
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
            iframe.setAttribute('title', 'Banner vídeo produto');
            videoBox.appendChild(iframe);
        })();
    </script>
    {% endif %}

{% endif %}
