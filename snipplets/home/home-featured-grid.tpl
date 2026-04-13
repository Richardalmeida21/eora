{# /*============================================================================
  #Home featured grid
==============================================================================*/

#Properties

#Featured Slider

#}

{% set featured_products = featured_products | default(false) %}
{% set new_products = new_products | default(false) %}
{% set sale_products = sale_products | default(false) %}

{# Check if slider is used #}

{% set has_featured_products_and_slider = featured_products and (settings.featured_products_format_mobile == 'slider' or settings.featured_products_format_desktop == 'slider')  %}
{% set has_new_products_and_slider = new_products and (settings.new_products_format_mobile == 'slider' or settings.new_products_format_desktop == 'slider') %}
{% set has_sale_products_and_slider = sale_products and (settings.sale_products_format_mobile == 'slider' or settings.sale_products_format_desktop == 'slider') %}
{% set use_slider = has_featured_products_and_slider or has_new_products_and_slider or has_sale_products_and_slider %}

{% if featured_products %}
    {% set sections_products = sections.best_sellers.products %}
    {% set section_name = 'Best Sellers' %}
    {% set section_columns_desktop = settings.featured_products_desktop %}
    {% set section_columns_mobile = settings.featured_products_mobile %}
    {% set section_slider = settings.featured_products_format_mobile == 'slider' or settings.featured_products_format_desktop == 'slider' %}
    {% set section_slider_both = settings.featured_products_format_mobile == 'slider' and settings.featured_products_format_desktop == 'slider' %}
    {% set section_slider_mobile_only = settings.featured_products_format_mobile == 'slider' and settings.featured_products_format_desktop == 'grid' %}
    {% set section_slider_desktop_only = settings.featured_products_format_desktop == 'slider' and settings.featured_products_format_mobile == 'grid' %}
    {% set section_slider_id = 'featured' %}
    {% set section_title = settings.featured_products_title %}
{% endif %}
{% if new_products %}
    {% set sections_products = sections.favorites.products %}
    {% set section_name = 'Favoritos' %}
    {% set section_columns_desktop = settings.new_products_desktop %}
    {% set section_columns_mobile = settings.new_products_mobile %}
    {% set section_slider = settings.new_products_format_mobile == 'slider' or settings.new_products_format_desktop == 'slider' %}
    {% set section_slider_both = settings.new_products_format_mobile == 'slider' and settings.new_products_format_desktop == 'slider' %}
    {% set section_slider_mobile_only = settings.new_products_format_mobile == 'slider' and settings.new_products_format_desktop == 'grid' %}
    {% set section_slider_desktop_only = settings.new_products_format_desktop == 'slider' and settings.new_products_format_mobile == 'grid' %}
    {% set section_slider_id = 'new' %}
    {% set section_title = settings.new_products_title %}
{% endif %}
{% if sale_products %}
    {% set sections_products = sections.picks_kings.products %}
    {% set section_name = 'Escolha da Loja' %}
    {% set section_columns_desktop = settings.sale_products_desktop %}
    {% set section_columns_mobile = settings.sale_products_mobile %}
    {% set section_slider = settings.sale_products_format_mobile == 'slider' or settings.sale_products_format_desktop == 'slider' %}
    {% set section_slider_both = settings.sale_products_format_mobile == 'slider' and settings.sale_products_format_desktop == 'slider' %}
    {% set section_slider_mobile_only = settings.sale_products_format_mobile == 'slider' and settings.sale_products_format_desktop == 'grid' %}
    {% set section_slider_desktop_only = settings.sale_products_format_desktop == 'slider' and settings.sale_products_format_mobile == 'grid' %}
    {% set section_slider_id = 'sale' %}
    {% set section_title = settings.sale_products_title %}
{% endif %}
{% if product_showcase or product_showcase_02 or product_showcase_03 %}
    {% if product_showcase %}
        {% set sections_products = sections.showcase.products %}
    {% elseif product_showcase_02 %}
        {% set sections_products = sections.showcase_02.products %}
    {% elseif product_showcase_03 %}
        {% set sections_products = sections.showcase_03.products %}
    {% endif %}
    

    {% set section_name = 'Vitrine de produtos' %}
    {% set section_slider_id = attribute(settings,"#{settings_name}") %}

    {% set section_title = attribute(settings,"#{settings_name}_products_title") %}

    {% set section_columns_desktop = attribute(settings,"#{settings_name}_products_desktop") %}
    {% set section_columns_mobile = attribute(settings,"#{settings_name}_products_mobile") %}
    {% set section_products_format_desktop = attribute(settings,"#{settings_name}_products_format_desktop") %}
    {% set section_products_format_mobile = attribute(settings,"#{settings_name}_products_format_mobile") %}

    {% set use_slider = section_products_format_mobile == 'slider' and section_products_format_desktop == 'slider' %}
    {% set section_slider = section_products_format_mobile == 'slider' or section_products_format_desktop == 'slider' %}
    {% set section_slider_both = section_products_format_mobile == 'slider' and section_products_format_desktop == 'slider' %}

    {% set section_slider_mobile_only = section_products_format_mobile == 'slider' and section_products_format_desktop == 'grid' %}
    {% set section_slider_desktop_only = section_products_format_desktop == 'slider' and section_products_format_mobile == 'grid' %}
{% endif %}

<div class="container-fluid my-5">
    <div class="row">
        <div class="col-md-12">
            {# {% if use_slider %}
                {% set section_visibility_classes = section_slider_mobile_only ? 'd-block d-md-none' : section_slider_desktop_only ? 'd-none d-md-block' %}
                <div class="js-swiper-{{ section_slider_id }}-pagination swiper-pagination-fraction {{ section_visibility_classes }}"></div>
            {% endif %} #}
            {% if section_title %}
                <h2 class="section-title section-title-products-home">{{ section_title }}</h2>
            {% endif %}
            {# Exibe as variantes de cor de cada produto abaixo do título da seção, mas fora da imagem #}
            {# {% for product in sections_products %}
                {% if product.variations and product.variation_type == 'color' and not reduced_item %}
                    <div class="item-color-dots mb-2 d-flex flex-wrap gap-2">
                        {% for variation in product.variations %}
                            <div class="item-color-dot d-flex align-items-center justify-content-center" style="background: linear-gradient(135deg, {{ variation.color | default('#eee') }}, {{ variation.color | default('#ccc') }} 80%); color: #222; min-width: 32px; min-height: 32px; border-radius: 50%; font-size: 11px; font-weight: 600; text-align: center; padding: 0 4px;">
                                {{ variation.name }}
                            </div>
                        {% endfor %}
                    </div>
                {% endif %}
            {% endfor %} #}
        </div>
        <div class="col-md-12">
            {# {% if use_slider %}
                <div class="js-swiper-{{ section_slider_id }}-prev swiper-products-slider-buttons swiper-button-prev svg-icon-text">
                    <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
                </div>
                <div class="js-swiper-{{ section_slider_id }}-next swiper-products-slider-buttons swiper-button-next svg-icon-text">
                    <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
                </div>
            {% endif %} #}
            {% if use_slider %}
                {% set section_slider_classes = section_slider_both ? 'swiper-products-slider flex-nowrap' : section_slider_mobile_only ? 'swiper-mobile-only flex-nowrap flex-md-wrap' : section_slider_desktop_only ? 'swiper-desktop-only flex-wrap flex-md-nowrap ml-md-0' %}
                <div class="js-swiper-{{ section_slider_id }} swiper-container">
                    <div class="swiper-wrapper {{ section_slider_classes }} row row-grid">
            {% else %}
                <div class="row row-grid">
            {% endif %}

            {% set product_by_reference_setting = new_products ? settings.product_by_reference_new_products : settings.product_by_reference %}

            {% for product in sections_products %}
                {% if use_slider %}
                    {% include 'snipplets/grid/item.tpl' with {'slide_item': true, 'section_name': section_name, 'section_columns_desktop': section_columns_desktop, 'section_columns_mobile': section_columns_mobile, 'product_by_reference_setting': product_by_reference_setting } %}
                {% else %}
                    {% include 'snipplets/grid/item.tpl' with {'product_by_reference_setting': product_by_reference_setting} %}
                {% endif %}
            {% endfor %}

            {% if use_slider %}
                    </div>
                    <div class="js-swiper-{{ section_slider_id }}-prev swiper-products-slider-buttons swiper-button-prev svg-icon-text">
                        <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
                    </div>
                    <div class="js-swiper-{{ section_slider_id }}-next swiper-products-slider-buttons swiper-button-next svg-icon-text">
                        <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
                    </div>
                    <div class="js-swiper-{{ section_slider_id }}-pagination swiper-pagination swiper-pagination-bullets swiper-pagination-outside mt-4 d-md-none"></div>
                </div>
            {% else %}
                </div>
            {% endif %}
        </div>
    </div>
</div>
