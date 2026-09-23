{% if params.oe_category_feed == '1' %}
    <template data-be-search-feed data-tag="__oculos_eora_category__" data-next="{{ pages.next | escape }}" data-last="{{ not products or pages.is_last ? '1' : '0' }}" data-page="{{ pages.current }}">
        <div data-be-feed-products>
            {% for product in products %}{% include 'snipplets/bolsas-eora/product-card.tpl' with {be_product_image_limit: 3} %}{% endfor %}
        </div>
    </template>
{% endif %}
