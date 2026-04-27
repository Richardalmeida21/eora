{#
====================================================================
  BANNERS SCROLL — Seção de banners com scroll horizontal
--------------------------------------------------------------------
  Configurado via painel da Nuvemshop em:
  "Página inicial" → "Banners Scroll"

  Suporta até 6 banners (cadastrados na galeria `banners_scroll`).
  Mostra setas e scroll horizontal automaticamente quando há mais
  banners do que cabem na tela.
====================================================================
#}

{% if settings.banners_scroll_show and settings.banners_scroll and settings.banners_scroll is not empty %}

    {% set bs_width  = settings.banners_scroll_width  | default(310) %}
    {% set bs_height = settings.banners_scroll_height | default(465) %}
    {% set bs_padding_bottom = (bs_height / bs_width) * 100 %}

    <section class="section-home section-banners-scroll position-relative overflow-none"
             data-store="home-banners-scroll"
             data-transition="fade-in">
        <div class="container-fluid pr-0">

            {% if settings.banners_scroll_title %}
                <h2 class="section-title section-title-banners-scroll">
                    {{ settings.banners_scroll_title }}
                </h2>
            {% endif %}

            <div class="banners-scroll-wrapper">
                <button type="button"
                        class="banners-scroll-arrow banners-scroll-arrow-prev js-banners-scroll-prev"
                        aria-label="Anterior">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
                </button>

                <div class="swiper js-swiper-banners-scroll banners-scroll-swiper">
                    <div class="swiper-wrapper">
                        {% for slide in settings.banners_scroll %}
                            <div class="swiper-slide banners-scroll-slide">
                                {% if slide.link %}
                                    <a href="{{ slide.link | setting_url }}"
                                       class="banners-scroll-link js-home-category"
                                       aria-label="Banner {{ loop.index }}">
                                {% endif %}
                                    <div class="home-category h3-huge h2-huge-md">
                                        <div class="banners-scroll-image"
                                             style="padding-bottom: {{ bs_padding_bottom }}%;">
                                            <img src="{{ 'images/empty-placeholder.png' | static_url }}"
                                                 data-src="{{ slide.image | static_url | settings_image_url('large') }}"
                                                 data-srcset="{{ slide.image | static_url | settings_image_url('medium') }} 320w, {{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w"
                                                 data-sizes="auto"
                                                 class="lazyautosizes lazyload"
                                                 alt="Banner {{ loop.index }}">
                                        </div>
                                        {% if slide.link %}
                                            {% set category_handle = slide.link | trim('/') | split('/') | last %}
                                            {% include 'snipplets/home/home-categories-name.tpl' %}
                                        {% endif %}
                                    </div>
                                {% if slide.link %}
                                    </a>
                                {% endif %}
                            </div>
                        {% endfor %}
                    </div>
                </div>

                <button type="button"
                        class="banners-scroll-arrow banners-scroll-arrow-next js-banners-scroll-next"
                        aria-label="Próximo">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                </button>
            </div>

        </div>
    </section>

    <style>
        .section-banners-scroll {
            margin: 40px 0;
            padding: 0;
            box-sizing: border-box;
        }
        .section-banners-scroll *,
        .section-banners-scroll *::before,
        .section-banners-scroll *::after {
            box-sizing: border-box;
        }
        .section-title-banners-scroll {
            text-align: center;
            font-size: 1.4rem;
            letter-spacing: 2px;
            text-transform: uppercase;
            font-weight: 500;
            color: #000;
            margin: 0 0 24px;
        }
        .banners-scroll-wrapper {
            position: relative;
            width: 100%;
            padding: 0 56px;
        }
        .banners-scroll-swiper {
            position: relative;
            width: 100%;
            overflow: hidden;
        }
        .banners-scroll-swiper .swiper-wrapper {
            display: flex;
            align-items: stretch;
        }
        .banners-scroll-swiper .swiper-slide {
            height: auto;
            flex-shrink: 0;
        }
        .banners-scroll-link {
            display: block;
            text-decoration: none;
            color: inherit;
        }
        .banners-scroll-image {
            position: relative;
            width: 100%;
            overflow: hidden;
            background: #f5f5f5;
        }
        .banners-scroll-image img {
            position: absolute;
            top: 0;
            left: 0;
            width: 100%;
            height: 100%;
            object-fit: cover;
            display: block;
            transition: transform .4s ease;
        }
        .banners-scroll-link:hover .banners-scroll-image img {
            transform: scale(1.03);
        }
        /* Setas */
        .banners-scroll-arrow {
            position: absolute;
            top: 50%;
            transform: translateY(-50%);
            z-index: 5;
            width: 44px;
            height: 44px;
            border-radius: 50%;
            border: 1px solid #000;
            background: #fff;
            color: #000;
            cursor: pointer;
            display: flex;
            align-items: center;
            justify-content: center;
            padding: 0;
            transition: background .2s ease, color .2s ease, opacity .2s ease;
        }
        .banners-scroll-arrow:hover {
            background: #000;
            color: #fff;
        }
        .banners-scroll-arrow:focus { outline: none; }
        .banners-scroll-arrow.swiper-button-disabled {
            opacity: .35;
            cursor: default;
        }
        .banners-scroll-arrow-prev { left: 4px; }
        .banners-scroll-arrow-next { right: 4px; }

        @media (max-width: 991px) {
            .banners-scroll-wrapper { padding: 0 40px; }
            .banners-scroll-arrow { width: 38px; height: 38px; }
        }
        @media (max-width: 767px) {
            .section-banners-scroll { margin: 24px 0; }
            .section-title-banners-scroll { font-size: 1.1rem; margin-bottom: 16px; }
            .banners-scroll-wrapper { padding: 0 28px; }
            .banners-scroll-arrow { width: 28px; height: 28px; }
            .banners-scroll-arrow svg { width: 14px; height: 14px; }
            .banners-scroll-arrow-prev { left: 0; }
            .banners-scroll-arrow-next { right: 0; }
        }
    </style>

    <script>
        (function () {
            function initBannersScroll() {
                if (typeof Swiper === 'undefined') return false;
                var el = document.querySelector('.js-swiper-banners-scroll');
                if (!el || el.dataset.swiperInit === '1') return true;
                el.dataset.swiperInit = '1';
                new Swiper(el, {
                    slidesPerView: 3,
                    spaceBetween: 12,
                    loop: false,
                    observer: true,
                    observeParents: true,
                    centerInsufficientSlides: true,
                    navigation: {
                        prevEl: '.js-banners-scroll-prev',
                        nextEl: '.js-banners-scroll-next'
                    },
                    breakpoints: {
                        768: { slidesPerView: 3, spaceBetween: 16 },
                        992: { slidesPerView: 3, spaceBetween: 20 }
                    }
                });
                return true;
            }
            if (!initBannersScroll()) {
                document.addEventListener('DOMContentLoaded', function () {
                    var tries = 0;
                    var iv = setInterval(function () {
                        tries++;
                        if (initBannersScroll() || tries > 20) clearInterval(iv);
                    }, 250);
                });
            }
        })();
    </script>

{% endif %}
