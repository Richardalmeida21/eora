{# Busca paginada por tag; a correspondencia exata tambem e conferida no cliente. #}
<template data-eora-variant-feed data-next="{{ pages.next | escape }}" data-last="{{ not products or pages.is_last ? '1' : '0' }}">
{% for variant_product in products %}
    {% set variant_tags = [] %}
    {% set variant_color = '' %}
    {% for variant_tag in variant_product.tags %}
        {% set tag_value = variant_tag.tag | default(variant_tag) | trim | lower %}
        {% set variant_tags = variant_tags | merge([tag_value]) %}
        {% if tag_value starts with 'produto-gradiente:' %}{% set variant_color = tag_value | split(':') | last | split('-') | first %}{% endif %}
    {% endfor %}
    <a href="{{ variant_product.url | escape }}" data-eora-variant-product-id="{{ variant_product.id }}" data-eora-variant-tags="{{ variant_tags | json_encode | escape }}" data-eora-variant-sort="{{ (variant_color ~ '|' ~ variant_product.name ~ '|' ~ variant_product.id) | escape }}" target="_top" class="btn btn-variant btn-variant-color btn-variant-thumb" title="{{ variant_product.name | escape }}">
        <span class="btn-variant-content btn-variant-content-thumb" data-name="{{ variant_product.name | escape }}">
            <img src="{{ variant_product.featured_image | product_image_url('thumb') }}" alt="{{ variant_product.name | escape }}" loading="lazy" />
        </span>
    </a>
{% endfor %}
</template>
