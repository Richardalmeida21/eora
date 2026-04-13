
<section class="gift-guide-section pb-5" style="background: #fff;">
    
    {# --- HERO SLIDER SECTION --- #}
    <div class="gift-guide-hero-container my-4">
        
        {# --- Desktop Slider --- #}
        <div class="d-none d-md-block">
            <div class="swiper-container js-gift-hero-desktop" style="overflow: hidden;">
                <div class="swiper-wrapper">
                    {% for slide in settings.gift_guide_hero_slider %}
                        <div class="swiper-slide position-relative">
                            <a href="{{ slide.link | default('#') }}" class="text-decoration-none d-block">
                                {% if slide.image %}
                                    <img src="{{ slide.image | static_url }}" class="d-block w-100" style="height: auto; min-height: 300px; object-fit: cover;" alt="{{ slide.description }}">
                                {% else %}
                                    <div class="d-flex align-items-center justify-content-center" style="min-height: 400px; background: #f9f9f9; text-align: center;">
                                        <h1 class="display-4 text-uppercase" style="font-family: serif; letter-spacing: 3px; font-weight: 400; color: #000;">{{ slide.description | default('Presenteaveis Eora') }}</h1>
                                    </div>
                                {% endif %}
                                {% if slide.image and slide.description %}
                                    <div class="position-absolute w-100 h-100 d-flex align-items-center justify-content-center" style="top:0; left:0; background: rgba(0,0,0,0.1); pointer-events: none;">
                                        <h1 class="display-4 text-uppercase text-white text-shadow" style="font-family: serif; letter-spacing: 3px; font-weight: 400; text-shadow: 0 2px 4px rgba(0,0,0,0.5);">{{ slide.description }}</h1>
                                    </div>
                                {% endif %}
                            </a>
                        </div>
                    {% endfor %}
                </div>
                <!-- Add Pagination -->
                <div class="swiper-pagination"></div>
                <!-- Add Arrows -->
                <div class="swiper-button-next"></div>
                <div class="swiper-button-prev"></div>
            </div>
        </div>

        {# --- Mobile Slider --- #}
        <div class="d-block d-md-none">
            {% if settings.gift_guide_hero_mobile_active %}
                <div class="swiper-container js-gift-hero-mobile" style="overflow: hidden;">
                    <div class="swiper-wrapper">
                        {% for slide in settings.gift_guide_hero_slider_mobile %}
                            <div class="swiper-slide position-relative">
                                <a href="{{ slide.link | default('#') }}" class="text-decoration-none d-block">
                                    {% if slide.image %}
                                        <img src="{{ slide.image | static_url }}" class="d-block w-100" style="height: auto; min-height: 200px; object-fit: cover;" alt="{{ slide.description }}">
                                    {% else %}
                                        <div class="d-flex align-items-center justify-content-center" style="min-height: 250px; background: #f9f9f9; text-align: center;">
                                            <h2 class="h2 text-uppercase" style="font-family: serif; letter-spacing: 2px; font-weight: 400; color: #000;">{{ slide.description | default('Presenteaveis Eora') }}</h2>
                                        </div>
                                    {% endif %}
                                </a>
                            </div>
                        {% endfor %}
                    </div>
                    <div class="swiper-pagination"></div>
                </div>
            {% else %}
                {# Fallback to desktop first slide if mobile not active, or just hide? User said add mobile version. #}
                {# Let's reuse desktop first slide logic or just show desktop slider adapted? #}
                {# Since we are iterating separate gallery, if unchecked we fall back to Desktop Slider Logic but visible on mobile? #}
                <div class="swiper-container js-gift-hero-mobile-fallback" style="overflow: hidden;">
                     <div class="swiper-wrapper">
                        {% for slide in settings.gift_guide_hero_slider %}
                             <div class="swiper-slide position-relative">
                                <a href="{{ slide.link | default('#') }}" class="text-decoration-none d-block">
                                    {% if slide.image %}
                                        <img src="{{ slide.image | static_url }}" class="d-block w-100" style="height: auto; min-height: 200px; object-fit: cover;" alt="{{ slide.description }}">
                                    {% endif %}
                                </a>
                            </div>
                        {% endfor %}
                    </div>
                </div>
            {% endif %}
        </div>
    </div>

    {# --- BANNERS CAROUSEL SECTION --- #}
    <div class="container">
        
        {% set current_page_url = category.url %}
        {% set is_subcategory = false %}
        
        {% for banner in settings.gift_guide_banners %}
            {% if banner.link and banner.link in current_page_url %}
                {% set is_subcategory = true %}
            {% endif %}
        {% endfor %}

        {# --- INTRO TEXT (Only on Main Page) --- #}
        {% if not is_subcategory %}
        {% endif %}

        {# Desktop Carousel #}
        <div class="{% if settings.gift_guide_banners_mobile_active %}d-none d-md-block{% endif %} position-relative px-md-5">
            <div class="swiper-container js-gift-banners-desktop" style="overflow: hidden; padding-bottom: 40px; min-height: 200px;">
                <div class="swiper-wrapper">
                    {# 1. Render Active Banner First #}
                    {% for banner in settings.gift_guide_banners %}
                        {% set is_active_banner = current_page_url and banner.link and banner.link in current_page_url %}
                        {% if is_active_banner %}
                            <div class="swiper-slide">
                                <a href="{{ banner.link }}" class="text-decoration-none">
                                    <div class="gift-card text-center is-selected">
                                        <div class="gift-image-wrapper mb-3 position-relative" style="aspect-ratio: 1/1; overflow: hidden; background: #fff; display: flex; align-items: center; justify-content: center;">
                                            {% if banner.image %}
                                                <img src="{{ banner.image | static_url }}" class="w-100 h-100" style="object-fit: cover; display: block;" alt="{{ banner.title }}">
                                            {% else %}
                                                <span style="font-size: 24px; color: #000; font-weight: bold; letter-spacing: 2px;">{{ banner.title }}</span>
                                            {% endif %}
                                        </div>
                                        {% if banner.title %}
                                            <h3 class="h6 text-uppercase font-weight-bold text-primary" style="letter-spacing: 2px;">{{ banner.title }}</h3>
                                        {% endif %}
                                    </div>
                                </a>
                            </div>
                        {% endif %}
                    {% endfor %}

                    {# 2. Render Other Banners #}
                    {% for banner in settings.gift_guide_banners %}
                        {% set is_active_banner = current_page_url and banner.link and banner.link in current_page_url %}
                        {% if not is_active_banner %}
                            <div class="swiper-slide">
                                <a href="{{ banner.link }}" class="text-decoration-none">
                                    <div class="gift-card text-center">
                                        <div class="gift-image-wrapper mb-3 position-relative" style="aspect-ratio: 1/1; overflow: hidden; background: #fff; display: flex; align-items: center; justify-content: center;">
                                            {% if banner.image %}
                                                <img src="{{ banner.image | static_url }}" class="w-100 h-100" style="object-fit: cover; display: block;" alt="{{ banner.title }}">
                                            {% else %}
                                                <span style="font-size: 24px; color: #000; font-weight: bold; letter-spacing: 2px;">{{ banner.title }}</span>
                                            {% endif %}
                                        </div>
                                        {% if banner.title %}
                                            <h3 class="h6 text-uppercase font-weight-bold text-dark" style="letter-spacing: 2px;">{{ banner.title }}</h3>
                                        {% endif %}
                                    </div>
                                </a>
                            </div>
                        {% endif %}
                    {% endfor %}
                </div>
                <div class="swiper-pagination"></div>
            </div>
            <!-- Banners Navigation Arrows (Outside overflow container) -->
            <div class="swiper-button-next js-gift-banners-next swiper-control-custom d-none d-md-flex" style="right: 0;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 24px; height: 24px;"><path d="M9 18l6-6-6-6"/></svg>
            </div>
            <div class="swiper-button-prev js-gift-banners-prev swiper-control-custom d-none d-md-flex" style="left: 0;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 24px; height: 24px;"><path d="M15 18l-6-6 6-6"/></svg>
            </div>
        </div>

        {# Mobile Carousel #}
        {% if settings.gift_guide_banners_mobile_active %}
        <div class="d-block d-md-none position-relative px-4">
            <div class="swiper-container js-gift-banners-mobile" style="overflow: hidden; padding-bottom: 40px; min-height: 150px;">
                <div class="swiper-wrapper">
                    {# 1. Render Active Banner First #}
                    {% for banner in settings.gift_guide_banners_mobile %}
                        {% set is_active_banner = current_page_url and banner.link and banner.link in current_page_url %}
                        {% if is_active_banner %}
                            <div class="swiper-slide">
                                <a href="{{ banner.link }}" class="text-decoration-none">
                                    <div class="gift-card text-center is-selected">
                                        <div class="gift-image-wrapper mb-3 position-relative" style="aspect-ratio: 1/1; overflow: hidden; background: #fff; display: flex; align-items: center; justify-content: center;">
                                            {% if banner.image %}
                                                <img src="{{ banner.image | static_url }}" class="w-100 h-100" style="object-fit: cover; display: block;" alt="{{ banner.title }}">
                                            {% else %}
                                                <span style="font-size: 24px; color: #000; font-weight: bold; letter-spacing: 2px;">{{ banner.title }}</span>
                                            {% endif %}
                                        </div>
                                        {% if banner.title %}
                                            <h3 class="h6 text-uppercase font-weight-bold text-primary" style="letter-spacing: 2px;">{{ banner.title }}</h3>
                                        {% endif %}
                                    </div>
                                </a>
                            </div>
                        {% endif %}
                    {% endfor %}

                    {# 2. Render Other Banners #}
                    {% for banner in settings.gift_guide_banners_mobile %}
                        {% set is_active_banner = current_page_url and banner.link and banner.link in current_page_url %}
                        {% if not is_active_banner %}
                            <div class="swiper-slide">
                                <a href="{{ banner.link }}" class="text-decoration-none">
                                    <div class="gift-card text-center">
                                        <div class="gift-image-wrapper mb-3 position-relative" style="aspect-ratio: 1/1; overflow: hidden; background: #fff; display: flex; align-items: center; justify-content: center;">
                                            {% if banner.image %}
                                                <img src="{{ banner.image | static_url }}" class="w-100 h-100" style="object-fit: cover; display: block;" alt="{{ banner.title }}">
                                            {% else %}
                                                <span style="font-size: 24px; color: #000; font-weight: bold; letter-spacing: 2px;">{{ banner.title }}</span>
                                            {% endif %}
                                        </div>
                                        {% if banner.title %}
                                            <h3 class="h6 text-uppercase font-weight-bold text-dark" style="letter-spacing: 2px;">{{ banner.title }}</h3>
                                        {% endif %}
                                    </div>
                                </a>
                            </div>
                        {% endif %}
                    {% endfor %}
                </div>
                <div class="swiper-pagination"></div>
            </div>
            <!-- Banners Mobile Navigation Arrows -->
            <div class="swiper-button-next js-gift-banners-mobile-next swiper-control-custom" style="right: -5px; transform: scale(0.85); top: 22% !important;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 24px; height: 24px;"><path d="M9 18l6-6-6-6"/></svg>
            </div>
            <div class="swiper-button-prev js-gift-banners-mobile-prev swiper-control-custom" style="left: -5px; transform: scale(0.85); top: 22% !important;">
                <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" style="width: 24px; height: 24px;"><path d="M15 18l-6-6 6-6"/></svg>
            </div>
        </div>
        {% endif %}

        {# --- INTRO TEXT (Only on Main Page) --- #}
        {% if not is_subcategory %}
        <section class="gift-guide-intro text-center my-4 my-md-5">
            <div class="row justify-content-center">
                <div class="col-md-12 col-lg-10">
                    <div style="font-family: serif; letter-spacing: 1px; font-weight: 400; font-size: 1.1rem; line-height: 1.6;">
                        <p class="mb-3">
                            Criamos este guia para te ajudar a escolher o presente ideal com mais facilidade.<br>
                            Aqui, você pode navegar por estilos e categorias pensadas para diferentes perfis e ocasiões.
                        </p>
                        <p class="mb-3">
                            Para começar, basta clicar em um dos banners e explorar as sugestões de presentes de acordo com o tipo de pessoa que você quer presentear ou a categoria que faz mais sentido para você.
                        </p>
                        <p class="mb-0">
                            Simples, prático e pensado para te ajudar a acertar na escolha.
                        </p>
                    </div>
                </div>
            </div>
        </section>
        {% endif %}

    </div>
    
    <style>
        .gift-image-wrapper {
            transition: all 0.6s cubic-bezier(0.25, 0.46, 0.45, 0.94);
            border: 1px solid transparent;
        }
        .gift-card:hover .gift-image-wrapper {
            transform: scale(1.05);
            border-color: #000;
        }
        .gift-card.is-selected .gift-image-wrapper {
            border: 3px solid #000;
            transform: scale(1.02);
            box-shadow: 0 4px 15px rgba(0,0,0,0.1);
        }
        .gift-card.is-selected h3 {
            font-weight: 900 !important;
            text-decoration: underline;
        }
        .gift-card h3 {
            font-size: 0.85rem;
            margin-top: 15px;
            transition: all 0.3s ease;
        }
        /* Swiper Arrows Customization */
        .swiper-control-custom {
            color: #000 !important;
            background: rgba(255,255,255,0.9) !important;
            width: 44px !important;
            height: 44px !important;
            border-radius: 50% !important;
            top: 40% !important;
            z-index: 100 !important;
            display: flex !important;
            align-items: center !important;
            justify-content: center !important;
            box-shadow: 0 2px 8px rgba(0,0,0,0.15) !important;
            border: 1px solid #eee !important;
        }
        .swiper-control-custom:after {
            display: none !important; /* Remove Swiper default font icon */
        }
        .swiper-control-custom svg {
            width: 24px;
            height: 24px;
        }

        /* Prevent Layout Shift (Huge Images before init) */
        .swiper-container:not(.swiper-container-initialized) .swiper-wrapper {
            display: flex !important;
            overflow: hidden !important;
            flex-wrap: nowrap !important;
        }
        .js-gift-banners-desktop:not(.swiper-container-initialized) .swiper-slide {
            width: 80% !important;
            flex: 0 0 80% !important;
            max-width: 80% !important;
            padding-right: 15px;
            box-sizing: border-box;
        }
        @media (min-width: 576px) {
            .js-gift-banners-desktop:not(.swiper-container-initialized) .swiper-slide {
                width: 50% !important;
                flex: 0 0 50% !important;
                max-width: 50% !important;
            }
        }
        @media (min-width: 768px) {
            .js-gift-banners-desktop:not(.swiper-container-initialized) .swiper-slide {
                width: 33.33% !important;
                flex: 0 0 33.33% !important;
                max-width: 33.33% !important;
            }
        }
        @media (min-width: 1024px) {
            .js-gift-banners-desktop:not(.swiper-container-initialized) .swiper-slide {
                width: 25% !important;
                flex: 0 0 25% !important;
                max-width: 25% !important;
                padding-right: 50px;
            }
        }

        .js-gift-banners-mobile:not(.swiper-container-initialized) .swiper-slide {
            width: 80% !important;
            flex: 0 0 80% !important;
            max-width: 80% !important;
            padding-right: 15px;
            box-sizing: border-box;
        }
        @media (min-width: 576px) {
            .js-gift-banners-mobile:not(.swiper-container-initialized) .swiper-slide {
                width: 50% !important;
                flex: 0 0 50% !important;
                max-width: 50% !important;
            }
        }
        .gift-image-wrapper img {
            max-width: 100%;
            height: auto;
            display: block;
        }
    </style>

    {# Initialize Swiper #}
    <script>
        function initGiftGuideSwipers() {
            if (typeof Swiper === 'undefined') {
                console.log('Swiper not ready, retrying in 500ms');
                setTimeout(initGiftGuideSwipers, 500);
                return;
            }

            console.log('Initializing Gift Guide Swipers');
            
            // Helper to safely init swiper
            var initSwiper = function(selector, options) {
                var el = document.querySelector(selector);
                if (el && !el.classList.contains('swiper-container-initialized')) {
                    try {
                        if (window.createSwiper) {
                            window.createSwiper(el, options);
                        } else {
                            new Swiper(selector, options);
                        }
                    } catch (e) {
                        console.error('Error initializing Swiper for ' + selector, e);
                    }
                }
            };

            // Hero Sliders
            var configureHeroSlider = function(selector) {
                var el = document.querySelector(selector);
                if (!el) return;
                
                var slideCount = el.querySelectorAll('.swiper-slide').length;
                var hasMultipleSlides = slideCount > 1;

                var options = {
                    loop: hasMultipleSlides,
                    observer: true,
                    observeParents: true,
                    pagination: {
                        el: '.swiper-pagination',
                        clickable: true,
                    },
                    navigation: {
                        nextEl: '.swiper-button-next',
                        prevEl: '.swiper-button-prev',
                    }
                };

                if (hasMultipleSlides) {
                    options.autoplay = { delay: 5000 };
                } else {
                    // Hide controls if single slide
                    var next = el.querySelector('.swiper-button-next');
                    var prev = el.querySelector('.swiper-button-prev');
                    var pag = el.querySelector('.swiper-pagination');
                    if(next) next.style.display = 'none';
                    if(prev) prev.style.display = 'none';
                    if(pag) pag.style.display = 'none';
                }

                initSwiper(selector, options);
            };

            configureHeroSlider('.js-gift-hero-desktop');
            configureHeroSlider('.js-gift-hero-mobile');
            configureHeroSlider('.js-gift-hero-mobile-fallback');

            // Banners Carousel
            initSwiper('.js-gift-banners-desktop', {
                slidesPerView: 1.2,
                spaceBetween: 15,
                loop: false,
                observer: true,
                observeParents: true,
                watchOverflow: true,
                breakpointsInverse: true,
                navigation: {
                    nextEl: '.js-gift-banners-next',
                    prevEl: '.js-gift-banners-prev',
                },
                pagination: {
                    el: '.swiper-pagination',
                    clickable: true,
                },
                breakpoints: {
                    576: {
                        slidesPerView: 2,
                        spaceBetween: 20,
                    },
                    768: {
                        slidesPerView: 3,
                        spaceBetween: 30,
                    },
                    1024: {
                        slidesPerView: 4,
                        spaceBetween: 40,
                    }
                }
            });

            initSwiper('.js-gift-banners-mobile', {
                slidesPerView: 1.2,
                spaceBetween: 15,
                loop: true,
                observer: true,
                observeParents: true,
                watchOverflow: true,
                breakpointsInverse: true,
                navigation: {
                    nextEl: '.js-gift-banners-mobile-next',
                    prevEl: '.js-gift-banners-mobile-prev',
                },
                pagination: {
                    el: '.swiper-pagination',
                    clickable: true,
                },
                breakpoints: {
                    480: {
                        slidesPerView: 2,
                        spaceBetween: 20,
                    }
                }
            });
        }

        // Trigger initialization
        if (document.readyState === 'complete' || document.readyState === 'interactive') {
            initGiftGuideSwipers();
        } else {
            document.addEventListener("DOMContentLoaded", initGiftGuideSwipers);
        }
        
        // Backup trigger for Nuvemshop environment
        if (typeof LS !== 'undefined' && LS.ready) {
            LS.ready.then(initGiftGuideSwipers);
        }
    </script>
</section>
