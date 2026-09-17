{% set block_key = 'bolsas_eora_' ~ block_number %}
{% set grid_section = attribute(sections, block_key ~ '_catalog') %}
{% set split_section = attribute(sections, block_key ~ '_split') %}
{% set banner_image = block_key ~ '_banner.jpg' %}
{% set banner_mobile = block_key ~ '_banner_mobile.jpg' %}
{% set banner_title = attribute(settings, block_key ~ '_title') %}
{% set banner_subtitle = attribute(settings, block_key ~ '_subtitle') %}
{% set banner_link = attribute(settings, block_key ~ '_link') %}

{% if attribute(settings, block_key ~ '_catalog_enabled') and grid_section.products %}
    <section class="be-catalog-block" data-be-paged aria-label="Catálogo {{ block_number }}">
        <div class="be-product-grid" data-be-page-items>
            {% for product in grid_section.products %}
                {% include 'snipplets/bolsas-eora/product-card.tpl' %}
            {% endfor %}
        </div>
        {% include 'snipplets/bolsas-eora/controls.tpl' %}
    </section>
{% endif %}

{% if attribute(settings, block_key ~ '_split_enabled') and banner_image | has_custom_image %}
    <section class="be-split{% if not split_section.products %} be-split--banner-only{% endif %}" aria-label="{{ banner_title | default('Bolsas Eora') | escape }}">
        {% if split_section.products %}
            <div class="be-split__products">
                {% for product in split_section.products | take(4) %}
                    {% include 'snipplets/bolsas-eora/product-card.tpl' %}
                {% endfor %}
            </div>
        {% endif %}
        {% if banner_link %}<a class="be-banner" href="{{ banner_link | escape }}">{% else %}<div class="be-banner">{% endif %}
            <picture>
                {% if banner_mobile | has_custom_image %}<source media="(max-width: 767px)" srcset="{{ banner_mobile | static_url | settings_image_url('large') }}">{% endif %}
                <img src="{{ banner_image | static_url | settings_image_url('1080p') }}" alt="{{ banner_title | default('Bolsas Eora') | escape }}" loading="lazy" decoding="async">
            </picture>
            {% if banner_title or banner_subtitle %}
                <span class="be-banner__caption">
                    <span>{% if banner_title %}<strong>{{ banner_title | escape }}</strong>{% endif %}{% if banner_subtitle %}<span>{{ banner_subtitle | escape }}</span>{% endif %}</span>
                    {% if banner_link %}<svg aria-hidden="true"><use xlink:href="#chevron-diagonal"/></svg>{% endif %}
                </span>
            {% endif %}
        {% if banner_link %}</a>{% else %}</div>{% endif %}
    </section>
{% endif %}
