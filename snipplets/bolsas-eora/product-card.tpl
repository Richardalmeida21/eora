{# Card exclusivo desta campanha; nenhuma dependencia de quickshop ou sliders globais. #}
{% set be_product_url = product.url %}
{# Mesmas variantes de layouts/layout.tpl (home). Link direto tambem funciona
   em nova aba, nos feeds carregados depois e sem interceptar a galeria. #}
{% set be_luar_variant_links = {'luar4': 0, 'luar1': 1, 'luar-1rh88': 2, 'luar-copia': 3, 'luar3': 4, 'luar2': 5} %}
{% set be_product_slug = product.url | split('?') | first | split('#') | first | trim('/') | split('/') | last %}
{% if be_product_slug in be_luar_variant_links | keys %}
    {% set be_product_url = '/produtos/luar/?vi=' ~ be_luar_variant_links[be_product_slug] %}
{% endif %}
{% set be_product_tags = [] %}
{% for product_tag in product.tags %}
    {% set be_product_tags = be_product_tags | merge([product_tag.tag | default(product_tag)]) %}
{% endfor %}
{% set be_product_image_limit = be_product_image_limit | default(0) %}
{% set be_product_images = [] %}
{% if product.featured_image %}
    {% set be_product_images = be_product_images | merge([product.featured_image]) %}
{% endif %}
{% for product_image in product.other_images %}
    {% if be_product_image_limit == 0 or be_product_images | length < be_product_image_limit %}
        {% set be_product_images = be_product_images | merge([product_image]) %}
    {% endif %}
{% endfor %}
{% set be_product_image_count = be_product_images | length %}
{% set oe_product_variants = [] %}
{% if be_product_variants_enabled %}
    {# Apenas os nomes/opcoes necessarios aos filtros; sem dados de pagamento/estoque. #}
    {% for variant in product.variants_object %}
        {% if variant.is_visible is not defined or variant.is_visible %}
            {% set oe_variant_options = [] %}
            {% for variation in product.variations %}
                {% set oe_variant_options = oe_variant_options | merge([{name: variation.name, value: variant['option' ~ loop.index0]}]) %}
            {% endfor %}
            {% set oe_product_variants = oe_product_variants | merge([oe_variant_options]) %}
        {% endif %}
    {% endfor %}
{% endif %}
<article class="be-product" data-be-product="{{ product.id }}" data-be-tags="{{ be_product_tags | json_encode | escape }}"{% if oe_product_variants %} data-oe-variants="{{ oe_product_variants | json_encode | escape }}"{% endif %} data-be-price="{{ product.price | default(0) }}" data-be-name="{{ product.name | escape }}" data-be-created="{{ product.created_at | default(product.id) | escape }}" data-store="product-item-{{ product.id }}" data-component="product-list-item" data-component-value="{{ product.id }}">
    <div class="be-product__image" data-be-product-gallery role="group" aria-roledescription="carrossel" aria-label="Fotos de {{ product.name | escape }}">
        <div class="be-product__slides" data-be-product-slides tabindex="0">
            {% for product_image in be_product_images %}
                <a class="be-product__slide" data-be-product-slide href="{{ be_product_url | escape }}" aria-label="{{ product.name | escape }} — foto {{ loop.index }} de {{ be_product_image_count }}"{% if loop.first %} data-store="product-item-image-{{ product.id }}"{% endif %}>
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
        <h3 data-store="product-item-name-{{ product.id }}"><a href="{{ be_product_url | escape }}">{{ product.name | escape }}</a></h3>
        {% if product.display_price %}
            <div class="be-product__price" data-store="product-item-price-{{ product.id }}">
                {% if product.compare_at_price > product.price %}<del>{{ product.compare_at_price | money }}</del>{% endif %}
                <span>{{ product.price | money }}</span>
            </div>
        {% endif %}
    </div>
</article>
