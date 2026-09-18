{# Card exclusivo desta campanha; nenhuma dependencia de quickshop ou sliders globais. #}
{% set be_product_tags = [] %}
{% for product_tag in product.tags %}
    {% set be_product_tags = be_product_tags | merge([product_tag.tag | default(product_tag)]) %}
{% endfor %}
<article class="be-product" data-be-product="{{ product.id }}" data-be-tags="{{ be_product_tags | json_encode | escape }}" data-store="product-item-{{ product.id }}" data-component="product-list-item" data-component-value="{{ product.id }}">
    <a class="be-product__image" href="{{ product.url | escape }}" aria-label="{{ product.name | escape }}" data-store="product-item-image-{{ product.id }}">
        {% if product.featured_image %}
            <img src="{{ product.featured_image | product_image_url('huge') }}" srcset="{{ product.featured_image | product_image_url('medium') }} 320w, {{ product.featured_image | product_image_url('large') }} 480w, {{ product.featured_image | product_image_url('huge') }} 640w, {{ product.featured_image | product_image_url('original') }} 1024w" sizes="(max-width: 767px) 50vw, 25vw" alt="{{ product.featured_image.alt | default(product.name) | escape }}" loading="lazy" decoding="async" width="{{ product.featured_image.dimensions.width | default(600) }}" height="{{ product.featured_image.dimensions.height | default(800) }}">
            {% if settings.product_hover and product.other_images %}
                <img class="be-product__secondary" src="{{ product.other_images | first | product_image_url('huge') }}" srcset="{{ product.other_images | first | product_image_url('medium') }} 320w, {{ product.other_images | first | product_image_url('large') }} 480w, {{ product.other_images | first | product_image_url('huge') }} 640w, {{ product.other_images | first | product_image_url('original') }} 1024w" sizes="(max-width: 767px) 50vw, 25vw" alt="" loading="lazy" decoding="async" aria-hidden="true">
            {% endif %}
        {% endif %}
        {% if not product.available %}<span class="be-product__badge">Esgotado</span>{% endif %}
    </a>
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
