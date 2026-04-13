{# -------------------------------------------------------------------
   Home – Best-Seller Slider (somente slide)
------------------------------------------------------------------- #}

{% set featured_products = featured_products | default(false) %}
{% set new_products      = new_products      | default(false) %}
{% set sale_products     = sale_products     | default(false) %}

{# --- Seleciona qual lista exibir ---------------------------------- #}
{% if featured_products %}
    {% set sections_products        = sections.best_sellers.products %}
    {% set section_name             = 'Best Sellers' %}
    {% set section_slider_id        = 'featured-best-sellers' %}
    {% set section_title            = settings.featured_products_title %}
    {% set section_columns_desktop  = settings.featured_products_desktop %}
    {% set section_columns_mobile   = settings.featured_products_mobile %}
{% endif %}
{% if new_products %}
    {% set sections_products        = sections.favorites.products %}
    {% set section_name             = 'Favoritos' %}
    {% set section_slider_id        = 'new-best-sellers' %}
    {% set section_title            = settings.new_products_title %}
    {% set section_columns_desktop  = settings.new_products_desktop %}
    {% set section_columns_mobile   = settings.new_products_mobile %}
{% endif %}
{% if sale_products %}
    {% set sections_products        = sections.picks_kings.products %}
    {% set section_name             = 'Escolha daLoja' %}
    {% set section_slider_id        = 'sale-best-sellers' %}
    {% set section_title            = settings.sale_products_title %}
    {% set section_columns_desktop  = settings.sale_products_desktop %}
    {% set section_columns_mobile   = settings.sale_products_mobile %}
{% endif %}

{# --- Estrutura HTML / Swiper ------------------------------------- #}
<div class="slider-container-best-sellers {% if category %}mt-4{% endif %}">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12">
                {# Título da seção #}
                {% if section_title %}
                    <h2 class="section-title section-title-products-home">{{ section_title }}</h2>
                {% endif %}
            </div>
        </div>
    </div>

    {# Slider #}
    <div class="js-swiper-{{ section_slider_id }} swiper-container swiper-best-sellers">
        <div class="swiper-wrapper flex-nowrap">

            {% for product in sections_products %}
                {# =========================================================================
                Slider Item — versão simplificada
                • Envolve cada produto em um único .swiper-slide
                • Exibe apenas imagem + nome
                • Sem colunas, preços ou botões auxiliares
                =========================================================================== #}

                {% set img_width   = product.featured_image.dimensions['width']  %}
                {% set img_height  = product.featured_image.dimensions['height'] %}
                {% set img_srcset  = product.featured_image %}
                {% set img_alt     = product.featured_image.alt | default(product.name) %}
                
                
                <div class="swiper-slide item-product" data-product-id="{{ product.id }}">
                    <div class="item">
                        {# ---------- Imagem ---------- #}
                        <a href="{{ product.url }}" title="{{ product.name }}" aria-label="{{ product.name }}">

                            
                            <figure class="image -square">
                                {% set brand_product = product.brand %}
                                {% if brand_product %}
                                    {% include 'snipplets/selo-brand.tpl' with {'product_brand': brand_product} %}
                                {% endif %}
                                <img
                                    class="lazyautosizes lazyload"
                                    data-expand="-10"
                                    alt="{{ img_alt }}"
                                    width="{{ img_width }}" height="{{ img_height }}"
                                    src="{{ 'images/empty-placeholder.png' | static_url }}"
                                    data-srcset="
                                    {{ img_srcset | product_image_url('small')    }} 240w,
                                    {{ img_srcset | product_image_url('medium')   }} 320w,
                                    {{ img_srcset | product_image_url('large')    }} 480w,
                                    {{ img_srcset | product_image_url('huge')     }} 640w,
                                    {{ img_srcset | product_image_url('original') }} 1024w"
                                    sizes="(max-width: 768px) 80vw, 25vw"
                                />
                            </figure>
                        </a>    
                            {# ---------- Nome ---------- #}
                        <div class="item-description pt-2">
                            <a href="{{ product.url }}" class="item-link" title="{{ product.name }}" aria-label="{{ product.name }}">
                                <div class="item-name">{{ product.name }}</div>
                            </a>
                        </div>
                    </div>
                </div>

            {% endfor %}

        </div>
    </div>
</div>
