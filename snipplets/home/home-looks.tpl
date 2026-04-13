{#  --------------------------------------------------------------------------
    LOOK DA VEZ – seção completa
    • abas sobre a foto (nav-tabs)
    • imagem principal + legenda (look-media + look-caption)
    • carrossel de produtos (Swiper)
    • tudo dentro de .container-fluid
---------------------------------------------------------------------------- #}
{% set padding_bottom_look =  100 %}

{% set look_image_height = settings.looks_width | default(false) %}
{% set look_image_width  = settings.looks_height  | default(false)  %}

{% if look_image_height and look_image_width %}
    {% set padding_bottom_look =  look_image_height / look_image_width * 100 %}
{% endif %}


{% set looks = [
    {
        key   : 'look_01',
        img   : 'looks_01.jpg',
        title : settings.looks_01_title | default('Look 1'),
        prods : sections.look_01.products
    },
    {
        key   : 'look_02',
        img   : 'looks_02.jpg',
        title : settings.looks_02_title | default('Look 2'),
        prods : sections.look_02.products
    },
    {
        key   : 'look_03',
        img   : 'looks_03.jpg',
        title : settings.looks_03_title | default('Look 3'),
        prods : sections.look_03.products
    }
] %}

<div class="container-fluid section-looks">
    <div class="row">
        <div class="col-12 col-lg-5  d-flex flex-lg-column flex-column-reverse mb-4 mb-lg-0" style="z-index: 2;">
            <div class="buttons-looks">
                <ul class="nav nav-tabs looks-tabs" role="tablist">
                    {% for look in looks %}
                        {% if look.prods != [] %}
                            <li class="nav-item" role="presentation">
                                <button class="looks-tab-button {% if loop.first %}active{% endif %}"
                                        data-button-look="{{ look.key }}"
                                        type="button"
                                        role="tab">
                                    {{ look.title }}
                                </button>
                            </li>
                        {% endif %}
                    {% endfor %}
                </ul>
            </div>
            <div class="images-looks">
                {% for look in looks  %}
                    {% if look.prods != [] %}
                        <figure class="image {% if loop.first %}d-flex{% else %}d-none{% endif %}" data-image-look="{{ look.key }}" style="--padding_bottom_look: {{ padding_bottom_look }}%">
                            <img class="lazyautosizes lazyload"
                                data-expand="-10"
                                alt="{{ look.title }}"
                                src="{{ 'images/empty-placeholder.png' | static_url }}"
                                data-srcset="
                                    {{ look.img | static_url | settings_image_url('large') }} 480w,
                                    {{ look.img | static_url | settings_image_url('huge') }} 640w,
                                    {{ look.img | static_url | settings_image_url('original') }} 1024w,
                                    {{ look.img | static_url | settings_image_url('1080p') }} 1920w"
                                sizes="(max-width: 992px) 100vw, 50vw" />
                        </figure>
                    {% endif %}
                {% endfor %}
            </div>
        </div>
        <div class="col-12 col-lg-7">
            <div class="looks-sliders pl-lg-4">
                {% for look in looks %}
                    {% if look.prods != [] %}
                        <div class="swiper flex-column js-swiper-{{ look.key }} {% if loop.first %}d-flex{% else %}d-none{% endif %}" data-slider-look="{{ look.key }}">
                            <h2 class="looks-title section-title-products-home w-100">{{ look.title }}</h2>
                            <div class="swiper-wrapper">
                                {% for product in look.prods %}
                                    <div class="swiper-slide" data-product-id="{{ product.id }}">
                                        {% include 'snipplets/grid/item.tpl' with {'look_item': true} %}
                                    </div>
                                {% endfor %}
                            </div>
                            <div class="swiper-button-prev-{{ look.key }} swiper-products-slider-buttons swiper-button-prev svg-icon-text">
                                <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
                            </div>
                            <div class="swiper-button-next-{{ look.key }} swiper-products-slider-buttons swiper-button-next svg-icon-text">
                                <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
                            </div>
                        </div>
                    {% endif %}
                {% endfor %}
            </div>
        </div>
    </div>
</div>