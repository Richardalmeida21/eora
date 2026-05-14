{# 1. PREPARAÇÃO DE CHAVES E LÓGICA #}
{% set base_hyphen = settings_name | replace('_', '-') %}
{% set base_underscore = settings_name | replace('-', '_') %}

{% set suffix_hyphen = '' %}
{% set suffix_underscore = '' %}

{% if campaign_banners_02 %}
    {% set suffix_hyphen = '-02' %}
    {% set suffix_underscore = '_02' %}
{% elseif campaign_banners_03 %}
    {% set suffix_hyphen = '-03' %}
    {% set suffix_underscore = '_03' %}
{% endif %}

{% set key_h = base_hyphen ~ suffix_hyphen %}
{% set key_u = base_underscore ~ suffix_underscore %}
{% set js_id = key_u ~ '-' ~ random(1000, 9999) %}

{# 2. BUSCA DE DADOS #}
{% set banners_desktop = attribute(settings, key_h ~ "-banner") %}
{% if not banners_desktop %}{% set banners_desktop = attribute(settings, key_u ~ "_banner") %}{% endif %}

{% set banners_mobile = attribute(settings, key_h ~ "-banner-mobile") %}
{% if not banners_mobile %}{% set banners_mobile = attribute(settings, key_u ~ "_banner_mobile") %}{% endif %}

{% set has_mobile_content = (banners_mobile and banners_mobile is not empty) %}

{# 3. CONFIGURAÇÕES #}
{% set section_title = attribute(settings, key_h ~ "-banner-title") %}
{% if not section_title %}{% set section_title = attribute(settings, key_u ~ "_banner_title") %}{% endif %}

{% set d_format_h = attribute(settings, key_h ~ "-banner-format-desktop") %}
{% set d_format_u = attribute(settings, key_u ~ "_banner_format_desktop") %}
{% set desktop_format = (d_format_h == 'slider' or d_format_u == 'slider') ? 'slider' : 'grid' %}

{% set m_format_h = attribute(settings, key_h ~ "-banner-format-mobile") %}
{% set m_format_u = attribute(settings, key_u ~ "_banner_format_mobile") %}
{% set mobile_format = (m_format_h == 'slider' or m_format_u == 'slider') ? 'slider' : 'grid' %}

{% set d_cols = attribute(settings, key_h ~ "-banner-columns-desktop") %}
{% if not d_cols %}{% set d_cols = attribute(settings, key_u ~ "_banner_columns_desktop") %}{% endif %}

{% set section_without_margins = attribute(settings, key_h ~ "-banner-without-margins") or attribute(settings, key_u ~ "_banner_without_margins") %}
{% set section_same_size = attribute(settings, key_h ~ "-banner-same-size") or attribute(settings, key_u ~ "_banner_same_size") %}

{% set container_classes = module ? 'container' : 'container-fluid' %}
{% set banner_classes = module ? 'mb-4 mb-md-5 pb-md-3' : (section_without_margins ? 'm-0' : 'mb-3') %}
{% set placeholder = 'data:image/gif;base64,R0lGODlhAQABAIAAAAAAAP///yH5BAEAAAAALAAAAAABAAEAAAIBRAA7' %}


{# === RENDERIZAÇÃO === #}
{% if (banners_desktop and banners_desktop is not empty) or has_mobile_content %}

<div class="banner-categorias {% if not module %}section-banners-campaign{% endif %} {{ container_classes }} position-relative {% if module %}mt-4 pt-3{% endif %}" data-banner-id="{{ js_id }}">
    
    {% if section_title and not module %}
        <h2 class="section-title-banners-scroll">{{ section_title }}</h2>
    {% endif %}

    {% if section_without_margins %}
        </div>
        <div class="banner-categorias {{ container_classes }} {% if not module %}p-0 overflow-none{% endif %}">
    {% endif %}

    {# ==================================================================
       1. DESKTOP
       ================================================================== #}
    {% if banners_desktop and banners_desktop is not empty %}
        
        {# Oculta no mobile se: há imagens mobile OU o formato mobile é diferente do desktop #}
        {% set hide_on_mobile = has_mobile_content or (mobile_format != desktop_format) %}
        {% set visibility_desktop = hide_on_mobile ? 'd-none d-md-block' : 'd-block' %}
        
        {% set col_class = 'col-md-12' %}
        {% if d_cols == 4 or d_cols == '4' %}{% set col_class = 'col-md-3' %}
        {% elseif d_cols == 3 or d_cols == '3' %}{% set col_class = 'col-md-4' %}
        {% elseif d_cols == 2 or d_cols == '2' %}{% set col_class = 'col-md-6' %}
        {% endif %}

        {% set w_d = attribute(settings, key_h ~ "-banner-width-desktop") %}
        {% if not w_d %}{% set w_d = attribute(settings, key_u ~ "_banner_width_desktop") %}{% endif %}
        
        {% set h_d = attribute(settings, key_h ~ "-banner-height-desktop") %}
        {% if not h_d %}{% set h_d = attribute(settings, key_u ~ "_banner_height_desktop") %}{% endif %}
        
        {% set pb_d = 100 %}
        {% if w_d > 0 and h_d > 0 %}{% set pb_d = (h_d / w_d) * 100 %}{% endif %}

        <div class="banner-wrapper-desktop {{ visibility_desktop }}">
            {% if desktop_format == 'slider' %}
                <div class="banners-scroll-wrapper banners-campaign-wrapper">
                <button type="button" class="banners-scroll-arrow banners-scroll-arrow-prev js-swiper-{{ js_id }}-prev" aria-label="Anterior">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
                </button>
                <div class="swiper js-swiper-{{ js_id }} banners-scroll-swiper">
                    <div class="swiper-wrapper">
            {% else %}
                <div class="row {% if section_without_margins %}no-gutters{% else %}px-2 row-grid{% endif %}">
            {% endif %}

            {% for slide in banners_desktop %}
                <div class="{% if desktop_format == 'slider' %}swiper-slide banners-scroll-slide{% endif %} col-grid {{ col_class }}">
                    {% if desktop_format == 'slider' %}
                        {% if slide.link %}
                            <a href="{{ slide.link }}" class="banners-scroll-link" aria-label="{{ slide.title }}">
                        {% endif %}
                        <div class="banners-scroll-image" style="padding-bottom: {{ pb_d }}%;">
                            {% if loop.first %}
                                <img src="{{ slide.image | static_url | settings_image_url('large') }}"
                                     srcset="{{ slide.image | static_url | settings_image_url('medium') }} 320w, {{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w"
                                     alt="{{ slide.title }}" />
                            {% else %}
                                <img src="{{ 'images/empty-placeholder.png' | static_url }}"
                                     data-src="{{ slide.image | static_url | settings_image_url('large') }}"
                                     data-srcset="{{ slide.image | static_url | settings_image_url('medium') }} 320w, {{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w"
                                     data-sizes="auto"
                                     class="lazyautosizes lazyload"
                                     alt="{{ slide.title }}" />
                            {% endif %}
                            {% if slide.title %}
                                <div class="banner-floating-button banners-scroll-button">
                                    <div class="banner-floating-button-content">
                                        <div class="banner-floating-title">{{ slide.title }}</div>
                                        <svg class="banner-floating-icon" viewbox="0 0 10 10" fill="none">
                                            <use xlink:href="#chevron-diagonal"></use>
                                        </svg>
                                    </div>
                                    {% if slide.description %}
                                        <div class="banner-floating-description mt-1">{{ slide.description }}</div>
                                    {% endif %}
                                </div>
                            {% endif %}
                        </div>
                        {% if slide.link %}
                            </a>
                        {% endif %}
                    {% else %}
                        {# Modo grid — mantém estrutura original #}
                        <div class="textbanner {{ banner_classes }}">
                            <div class="textbanner-image{% if not section_same_size %} p-0{% endif %} position-relative overflow-hidden">
                                <figure class="image -custom" style="--padding-bottom-banner: {{ pb_d }}%">
                                    {% if loop.first %}
                                        <img src="{{ slide.image | static_url | settings_image_url('original') }}" 
                                             class="img-fluid d-block w-100 {% if section_same_size %}textbanner-image-background{% endif %}" 
                                             style="width: 100%; display: block;" 
                                             alt="{{ slide.title }}" />
                                    {% else %}
                                        <img src="{{ placeholder }}" 
                                             data-srcset="{{ slide.image | static_url | settings_image_url('original') }}" 
                                             class="img-fluid d-block w-100 textbanner-image-effect lazyload fade-in {% if section_same_size %}textbanner-image-background{% endif %}" 
                                             alt="{{ slide.title }}" 
                                             style="width: 100%; display: block;" />
                                    {% endif %}
                                    {% if slide.title %}
                                        <div class="banner-floating-button">
                                            <div class="banner-floating-button-content">
                                                <div class="banner-floating-title">{{ slide.title }}</div>
                                                <svg class="banner-floating-icon" viewbox="0 0 10 10" fill="none" style="transform: scaleX(-1)">
                                                    <use xlink:href="#chevron-diagonal"></use>
                                                </svg>
                                            </div>
                                            {% if slide.description %}
                                                <div class="banner-floating-description mt-1">{{ slide.description }}</div>
                                            {% endif %}
                                        </div>
                                    {% endif %}
                                    {% if slide.link %}<a href="{{ slide.link }}" class="full-width-link"></a>{% endif %}
                                </figure>
                            </div>
                        </div>
                    {% endif %}
                </div>
            {% endfor %}

            {% if desktop_format == 'slider' %}
                    </div>
                </div>
                <button type="button" class="banners-scroll-arrow banners-scroll-arrow-next js-swiper-{{ js_id }}-next" aria-label="Próximo">
                    <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
                </button>
                </div>
            {% else %}
                </div>
            {% endif %}
        </div>
    {% endif %}

    {# ==================================================================
       2. MOBILE
       ================================================================== #}
    {# Usa imagens mobile se existirem; caso contrário, usa as imagens desktop com formato mobile #}
    {% set mobile_slides = has_mobile_content ? banners_mobile : banners_desktop %}
    {% set should_render_mobile = has_mobile_content or (mobile_format != desktop_format) %}

    {% if should_render_mobile %}
        {% if mobile or (not mobile) %}
            
            {% set w_m = attribute(settings, key_h ~ "-banner-width-mobile") %}
            {% if not w_m %}{% set w_m = attribute(settings, key_u ~ "_banner_width_mobile") %}{% endif %}
            
            {% set h_m = attribute(settings, key_h ~ "-banner-height-mobile") %}
            {% if not h_m %}{% set h_m = attribute(settings, key_u ~ "_banner_height_mobile") %}{% endif %}
            
            {# Se não há dimensões mobile, usa as do desktop #}
            {% set pb_m = pb_d %}
            {% if w_m > 0 and h_m > 0 %}{% set pb_m = (h_m / w_m) * 100 %}{% endif %}

            <div class="banner-wrapper-mobile d-block d-md-none">
                {% if mobile_format == 'slider' %}
                    <div class="js-swiper-{{ js_id }}-mobile swiper-container">
                        <div class="swiper-wrapper">
                {% else %}
                    <div class="row {% if section_without_margins %}no-gutters{% else %}px-2 row-grid{% endif %}">
                {% endif %}

                {% for slide in mobile_slides %}
                    <div class="{% if mobile_format == 'slider' %}swiper-slide{% endif %} col-grid col-12">
                        <div class="textbanner {{ banner_classes }}">
                            
                            <div class="textbanner-image{% if not section_same_size %} p-0{% endif %} position-relative overflow-hidden">
                                <figure class="image -custom" style="--padding-bottom-banner: {{ pb_m }}%">
                                    {% if loop.first %}
                                        <img src="{{ slide.image | static_url | settings_image_url('original') }}" 
                                             class="img-fluid d-block w-100 {% if section_same_size %}textbanner-image-background{% endif %}" 
                                             alt="{{ slide.title }}"
                                             style="width: 100%; display: block; opacity: 1 !important;" />
                                    {% else %}
                                        <img src="{{ placeholder }}" 
                                             data-srcset="{{ slide.image | static_url | settings_image_url('original') }}" 
                                             class="img-fluid d-block w-100 textbanner-image-effect lazyload fade-in {% if section_same_size %}textbanner-image-background{% endif %}" 
                                             alt="{{ slide.title }}"
                                             style="width: 100%; display: block;" />
                                    {% endif %}

                                    {# --- ESTRUTURA FLOATING BUTTON (MOBILE) --- #}
                                    {% if slide.title %}
                                        <div class="banner-floating-button">
                                            <div class="banner-floating-button-content">
                                                <div class="banner-floating-title">{{ slide.title }}</div>
                                                <svg class="banner-floating-icon" viewbox="0 0 10 10" fill="none" style="transform: scaleX(-1)">
                                                    <use xlink:href="#chevron-diagonal"></use>
                                                </svg>
                                            </div>
                                            {% if slide.description %}
                                                <div class="banner-floating-description mt-1">{{ slide.description }}</div>
                                            {% endif %}
                                        </div>
                                    {% endif %}

                                    {% if slide.link %}<a href="{{ slide.link }}" class="full-width-link"></a>{% endif %}
                                </figure>
                            </div>

                        </div>
                    </div>
                {% endfor %}

                {% if mobile_format == 'slider' %}
                        </div>
                    </div>
                {% else %}
                    </div>
                {% endif %}
            </div>
        {% endif %}
    {% endif %}

    {% if section_without_margins %}
        </div>
    {% endif %}
</div>

<script>
(function () {
    var jsId = '{{ js_id }}';
    var dCols = {{ d_cols | default(3) }};

    function initCampaignBanners() {
        if (typeof Swiper === 'undefined') return false;

        var deskEl = document.querySelector('.js-swiper-' + jsId);
        if (deskEl && !deskEl.dataset.swiperInit) {
            deskEl.dataset.swiperInit = '1';
            new Swiper(deskEl, {
                slidesPerView: 3,
                spaceBetween: 4,
                loop: false,
                observer: true,
                observeParents: true,
                centerInsufficientSlides: true,
                navigation: {
                    prevEl: '.js-swiper-' + jsId + '-prev',
                    nextEl: '.js-swiper-' + jsId + '-next'
                },
                breakpoints: {
                    0:   { slidesPerView: 1.12, spaceBetween: 4, centeredSlides: false },
                    768: { slidesPerView: dCols, spaceBetween: 4 },
                    992: { slidesPerView: dCols, spaceBetween: 4 }
                }
            });
        }

        var mobEl = document.querySelector('.js-swiper-' + jsId + '-mobile');
        if (mobEl && !mobEl.dataset.swiperInit) {
            mobEl.dataset.swiperInit = '1';
            new Swiper(mobEl, {
                slidesPerView: 1.12,
                spaceBetween: 4,
                loop: false
            });
        }

        return true;
    }

    if (!initCampaignBanners()) {
        document.addEventListener('DOMContentLoaded', function () {
            var tries = 0;
            var iv = setInterval(function () {
                tries++;
                if (initCampaignBanners() || tries > 20) clearInterval(iv);
            }, 250);
        });
    }
})();
</script>

<style>
.full-width-link { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 5; }
.textbanner-image img { min-height: 1px; }

/* Seção campanha — mesma margem da home */
.section-banners-campaign {
  margin: 40px 0;
  padding: 0;
}

/* Título igual ao carrossel da home */
.section-title-banners-scroll {
  text-align: center;
  font-size: 1.4rem;
  letter-spacing: 2px;
  text-transform: uppercase;
  font-weight: 800;
  color: #000;
  margin: 0 0 24px;
}

/* Hover nas imagens (modo grid) */
.banner-categorias .textbanner-image img {
  transition: transform .4s ease;
}
.banner-categorias .textbanner-image:hover img {
  transform: scale(1.03);
}

@media (max-width: 767px) {
  .section-banners-campaign { margin: 24px 0; }
  .section-title-banners-scroll { font-size: 1.1rem; margin-bottom: 16px; }
  .banner-categorias { overflow: hidden; }
}

/* CSS do Floating Button */
.banner-floating-button {
    position: absolute;
    left: 16px;
    bottom: 16px;
    display: flex;
    flex-direction: column;
    justify-content: center;
    align-items: flex-start;
    gap: 10px;
    padding: 16px;
    /* Usei variáveis padrão caso as suas não carreguem, mas as suas têm prioridade */
    background: var(--banner-floating-background, rgba(255, 255, 255, 0.8)); 
    backdrop-filter: blur(8px);
    -webkit-backdrop-filter: blur(8px);
    max-width: calc(100% - 32px);
    width: 440px;
    text-decoration: none;
    color: var(--banner-floating-text, #000);
    z-index: 4;
    cursor: pointer;
    pointer-events: none; /* Deixa o clique passar para o link full-width */
}

.banner-floating-button-content {
    display: flex;
    align-items: center;
    justify-content: space-between;
    width: 100%;
}

.banner-floating-title {
    color: var(--banner-floating-text, #000);
    font-size: 16px;
    font-weight: 500;
    letter-spacing: 3.2px;
    text-transform: uppercase;
    line-height: normal;
}

.banner-floating-description {
    color: var(--banner-floating-description, #333);
    opacity: 0.7;
    font-size: 12px;
    font-weight: 400;
    letter-spacing: 0.6px;
    line-height: normal;
}

.banner-floating-icon {
    width: 12px;
    height: 12px;
    fill: var(--banner-floating-text, #000);
    color: var(--banner-floating-text, #000);
    flex-shrink: 0;
}
</style>

{% endif %}