{% set discovery_products = [] %}
{% for item in sections.menu_search.products %}
    {% if item.url and item.featured_image %}{% set discovery_products = discovery_products | merge([item]) %}{% endif %}
{% endfor %}
{% set discovery_products = discovery_products | slice(0, 6) %}
{% if discovery_products | length %}
    {% import 'snipplets/product-name-pt.tpl' as discovery_titles %}
    <section class="eora-search-discovery" data-search-discovery aria-label="{{ settings.eora_search_title | default('Você também pode gostar') }}">
        <div class="eora-search-discovery__heading">
            <h2>{{ settings.eora_search_title | default('Você também pode gostar') }}</h2>
            <div class="eora-search-discovery__controls">
                <button type="button" data-search-prev aria-label="Produtos anteriores" disabled>‹</button>
                <button type="button" data-search-next aria-label="Próximos produtos">›</button>
            </div>
        </div>
        <div class="eora-search-discovery__track" data-search-track tabindex="0" role="region" aria-label="Produtos sugeridos">
            {% for item in discovery_products %}
                {% set item_name = discovery_titles.get(item.id, item.name, current_language, languages) | trim %}
                <a class="eora-search-discovery__product" data-search-product href="{{ item.url }}">
                    <img src="{{ item.featured_image | product_image_url('large') }}" srcset="{{ item.featured_image | product_image_url('large') }} 480w, {{ item.featured_image | product_image_url('huge') }} 640w" sizes="(min-width: 1200px) 220px, 45vw" loading="lazy" width="640" height="800" alt="{{ item_name | escape }}" />
                    <span>{{ item_name }}</span>
                    {% if item.display_price %}<span class="eora-search-discovery__price">{{ item.price | money }}</span>{% endif %}
                </a>
            {% endfor %}
        </div>
    </section>
{% endif %}
