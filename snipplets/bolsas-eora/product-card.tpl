{# Card exclusivo desta campanha; nenhuma dependencia de quickshop ou sliders globais. #}
{% set be_product_tags = [] %}
{% for product_tag in product.tags %}
    {% set be_product_tags = be_product_tags | merge([product_tag.tag | default(product_tag)]) %}
{% endfor %}
{% set be_product_images = [] %}
{% if product.featured_image %}
    {% set be_product_images = be_product_images | merge([product.featured_image]) %}
{% endif %}
{% for product_image in product.other_images %}
    {% set be_product_images = be_product_images | merge([product_image]) %}
{% endfor %}
{% set be_product_image_count = be_product_images | length %}
<article class="be-product" data-be-product="{{ product.id }}" data-be-tags="{{ be_product_tags | json_encode | escape }}" data-be-price="{{ product.price | default(0) }}" data-be-name="{{ product.name | escape }}" data-be-created="{{ product.created_at | default(product.id) | escape }}" data-store="product-item-{{ product.id }}" data-component="product-list-item" data-component-value="{{ product.id }}">
    <div class="be-product__image" data-be-product-gallery role="group" aria-roledescription="carrossel" aria-label="Fotos de {{ product.name | escape }}">
        <div class="be-product__slides" data-be-product-slides tabindex="0">
            {% for product_image in be_product_images %}
                <a class="be-product__slide" data-be-product-slide href="{{ product.url | escape }}" aria-label="{{ product.name | escape }} — foto {{ loop.index }} de {{ be_product_image_count }}"{% if loop.first %} data-store="product-item-image-{{ product.id }}"{% endif %}>
                    <img{% if loop.first %} src="{{ product_image | product_image_url('huge') }}" srcset="{{ product_image | product_image_url('medium') }} 320w, {{ product_image | product_image_url('large') }} 480w, {{ product_image | product_image_url('huge') }} 640w, {{ product_image | product_image_url('original') }} 1024w" loading="lazy"{% else %} data-be-src="{{ product_image | product_image_url('huge') }}"{% endif %} sizes="(max-width: 767px) 50vw, 25vw" alt="{{ product_image.alt | default(product.name) | escape }}" decoding="async" width="{{ product_image.dimensions.width | default(600) }}" height="{{ product_image.dimensions.height | default(800) }}">
                </a>
            {% endfor %}
        </div>
        {% if be_product_image_count > 1 %}
            <span class="be-product__counter" data-be-gallery-counter aria-hidden="true">1 / {{ be_product_image_count }}</span>
            <button class="be-product__gallery-button be-product__gallery-button--prev" type="button" data-be-gallery-prev aria-label="Foto anterior" disabled><svg aria-hidden="true"><use xlink:href="#chevron"/></svg></button>
            <button class="be-product__gallery-button be-product__gallery-button--next" type="button" data-be-gallery-next aria-label="Próxima foto"><svg aria-hidden="true"><use xlink:href="#chevron"/></svg></button>
        {% endif %}
        {% if not product.available %}<span class="be-product__badge">Esgotado</span>{% endif %}
    </div>
    <div class="be-product__info">
        <h3 data-store="product-item-name-{{ product.id }}"><a href="{{ product.url | escape }}">{{ product.name | escape }}</a></h3>
        {% if product.display_price %}
            <div class="be-product__price" data-store="product-item-price-{{ product.id }}">
                {% if product.compare_at_price > product.price %}<del>{{ product.compare_at_price | money }}</del>{% endif %}
                <span>{{ product.price | money }}</span>
            </div>
        {% endif %}
    </div>
</article>
