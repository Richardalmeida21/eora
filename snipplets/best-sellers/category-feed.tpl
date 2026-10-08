{# Feed da categoria para a campanha. Nunca agrega produtos de outras fontes. #}
{% if params.bs_category_feed == '1' %}
    <template data-bs-category-feed data-next="{{ pages.next | escape }}" data-last="{{ not products or pages.is_last ? '1' : '0' }}" data-page="{{ pages.current }}">
        {% for product in products %}
            {% include 'snipplets/bolsas-eora/product-card.tpl' with {be_product_image_limit: 3, be_product_variants_enabled: true, be_product_high_quality: true} %}
        {% endfor %}
    </template>
{% endif %}
