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

<div class="banner-categorias {{ container_classes }} position-relative {% if module %}mt-4 pt-3{% endif %}" data-banner-id="{{ js_id }}">
    
    {% if section_title and not module %}
        <h2 class="section-title text-center h3 mb-4">{{ section_title }}</h2>
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
                <div class="js-swiper-{{ js_id }} swiper-container">
                    <div class="swiper-wrapper">
            {% else %}
                <div class="row {% if section_without_margins %}no-gutters{% else %}px-2 row-grid{% endif %}">
            {% endif %}

            {% for slide in banners_desktop %}
                <div class="{% if desktop_format == 'slider' %}swiper-slide{% endif %} col-grid {{ col_class }}">
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

                                {# --- ESTRUTURA FLOATING BUTTON (DESKTOP) --- #}
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

            {% if desktop_format == 'slider' %}
                    </div>
                    <div class="swiper-buttons d-none d-md-block">
                        <div class="js-swiper-{{ js_id }}-prev swiper-button-prev"><svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg></div>
                        <div class="js-swiper-{{ js_id }}-next swiper-button-next"><svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg></div>
                    </div>
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
document.addEventListener('DOMContentLoaded', function () {
    if (typeof Swiper !== 'undefined') {
        var jsId = '{{ js_id }}';
        var dCols = {{ d_cols | default(1) }};
        var space = {% if section_without_margins %}0{% else %}16{% endif %};

        var deskSelector = '.js-swiper-' + jsId;
        var deskEl = document.querySelector(deskSelector);
        if(deskEl) {
            createSwiper(deskEl, {
                lazy: true, 
                watchOverflow: true, 
                slidesPerView: 1,
                spaceBetween: space,
                navigation: { prevEl: deskSelector + '-prev', nextEl: deskSelector + '-next' },
                breakpoints: { 768: { slidesPerView: dCols } }
            });
        }

        var mobSelector = '.js-swiper-' + jsId + '-mobile';
        var mobEl = document.querySelector(mobSelector);
        if(mobEl) {
            createSwiper(mobEl, {
                lazy: true, 
                watchOverflow: true, 
                slidesPerView: 1,
                spaceBetween: space
            });
        }
    }
});
</script>

<style>
.full-width-link { position: absolute; top: 0; left: 0; width: 100%; height: 100%; z-index: 5; }
.textbanner-image img { min-height: 1px; }

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