{% if params.oe_feed == '4' %}
{% set oe_search_tag = '' %}
{% for model in settings.oculos_eora_models %}
    {% set oe_model_tag = model.link | trim %}
    {% if model.image and oe_model_tag and query == '"' ~ oe_model_tag ~ '"' %}{% set oe_search_tag = oe_model_tag %}{% endif %}
{% endfor %}
{% if oe_search_tag %}
    <template data-be-search-feed data-tag="{{ oe_search_tag | escape }}" data-next="{{ pages.next | escape }}" data-last="{{ not products or pages.is_last ? '1' : '0' }}" data-page="{{ pages.current }}">
        <div data-be-feed-products>
            {% for product in products %}{% include 'snipplets/bolsas-eora/product-card.tpl' with {be_product_image_limit: 3} %}{% endfor %}
        </div>
    </template>
{% endif %}
{% endif %}
