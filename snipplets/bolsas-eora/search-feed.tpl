{# Dados inertes: a busca normal permanece intacta. Somente tags configuradas geram o feed. #}
{% set be_search_tag = '' %}
{% for model in settings.bolsas_eora_models %}
    {% set be_model_tag = model.link | trim %}
    {% if model.image and be_model_tag and query == '"' ~ be_model_tag ~ '"' %}
        {% set be_search_tag = be_model_tag %}
    {% endif %}
{% endfor %}
{% if be_search_tag %}
    <template data-be-search-feed data-tag="{{ be_search_tag | escape }}" data-next="{{ pages.next | escape }}" data-last="{{ not products or pages.is_last ? '1' : '0' }}" data-page="{{ pages.current }}">
        <div data-be-feed-products>
            {% for product in products %}
                {% include 'snipplets/bolsas-eora/product-card.tpl' with {be_product_image_limit: 3} %}
            {% endfor %}
        </div>
        <div data-be-feed-facets>
            {% if has_filters_enabled %}
                {% for product_filter in product_filters %}
                    {% if product_filter.type == 'price' %}
                        <fieldset class="be-facet">
                            <legend>Preço</legend>
                            <div class="be-price-fields">
                                <label>De <input type="number" name="min_price" min="0" step="0.01" inputmode="decimal" placeholder="R$"></label>
                                <label>Até <input type="number" name="max_price" min="0" step="0.01" inputmode="decimal" placeholder="R$"></label>
                            </div>
                        </fieldset>
                    {% elseif product_filter.has_products %}
                        <fieldset class="be-facet">
                            <legend>{{ product_filter.name | escape }}</legend>
                            {% for value in product_filter.values %}
                                {% if value.product_count > 0 or value.selected %}
                                    <label class="be-choice"><input type="checkbox" name="{{ product_filter.key | escape }}" value="{{ value.name | escape }}"{% if value.selected %} checked{% endif %}><span>{{ value.name | escape }}</span></label>
                                {% endif %}
                            {% endfor %}
                        </fieldset>
                    {% endif %}
                {% endfor %}
            {% endif %}
        </div>
    </template>
{% endif %}
