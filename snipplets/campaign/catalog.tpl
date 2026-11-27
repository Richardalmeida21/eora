{# Campanha 10: fonte exclusiva da categoria configurada pelo lojista. #}
{% set collection_url = settings.campaign_page_10_catalog_url | default('') | trim %}
{% set collection_title = settings.campaign_page_10_catalog_title | default(page.name) %}
<link rel="stylesheet" href="{{ 'css/bolsas-eora.css' | static_url }}?v=20261020-1">
<link rel="stylesheet" href="{{ 'css/best-sellers-eora.css' | static_url }}?v=20261029-1">
<link rel="stylesheet" href="{{ 'css/campaign-catalog.css' | static_url }}?v=20261127-1">
<main class="be-page bs-page cc-page" data-bs-page data-bs-category-url="{{ collection_url | escape }}" data-bs-catalog-title="{{ collection_title | escape }}" data-bs-default-sort="{{ settings.campaign_page_10_catalog_sort | default('user') | escape }}" data-bs-page-size="{{ settings.campaign_page_10_catalog_page_size | default('24') | escape }}" data-bs-mobile-page-size="{{ settings.campaign_page_10_catalog_page_size | default('24') | escape }}" data-bs-loading-label="Carregando produtos da coleção…" data-bs-error-label="Não foi possível carregar todos os produtos da coleção. Tente novamente." style="--cc-columns:{{ settings.campaign_page_10_catalog_columns | default('4') | escape }};--cc-mobile-columns:{{ settings.campaign_page_10_catalog_mobile_columns | default('2') | escape }}">
    {% if settings.campaign_page_10_catalog_banner_enabled and settings.campaign_page_10_catalog_banner %}
        {% for banner in settings.campaign_page_10_catalog_banner | slice(0,1) %}
            {% set mobile_banner = settings.campaign_page_10_catalog_banner_mobile | first %}
            <section class="cc-banner" aria-label="{{ collection_title | escape }}">
                {% if banner.link %}<a href="{{ banner.link | setting_url }}">{% endif %}
                <picture>
                    {% if mobile_banner.image %}<source media="(max-width:767px)" srcset="{{ mobile_banner.image | static_url | settings_image_url('1080p') }}">{% endif %}
                    <img src="{{ banner.image | static_url | settings_image_url('1080p') }}" alt="{{ banner.title | default(collection_title) | escape }}" fetchpriority="high" decoding="async">
                </picture>
                {% if banner.link %}</a>{% endif %}
            </section>
        {% endfor %}
    {% endif %}
    <header class="bs-heading cc-heading">
        <h1>{{ collection_title | escape }}</h1>
        {% if settings.campaign_page_10_catalog_description %}<p>{{ settings.campaign_page_10_catalog_description | escape | nl2br }}</p>{% endif %}
    </header>
    <nav class="bs-macros cc-types" aria-label="Tipos de produto"{% if not settings.campaign_page_10_catalog_types_enabled %} hidden{% endif %}>
        {% if settings.campaign_page_10_catalog_types_enabled %}
        <div class="bs-macros__track cc-types__track">
            <a class="bs-macro" href="?bs_category=eyewear" data-bs-category="eyewear" data-bs-type="eyewear" data-bs-order="1" aria-expanded="false"><span class="bs-macro__title">{{ settings.campaign_page_10_catalog_eyewear_label | default('Óculos') | escape }}</span></a>
            <a class="bs-macro" href="?bs_category=bag" data-bs-category="bag" data-bs-type="bag" data-bs-order="2" aria-expanded="false"><span class="bs-macro__title">{{ settings.campaign_page_10_catalog_bags_label | default('Bolsas') | escape }}</span></a>
        </div>
        {% endif %}
    </nav>
    <div class="bs-toolbar">
        <button class="be-text-button" type="button" data-bs-reset aria-pressed="true">{{ settings.campaign_page_10_catalog_all_label | default('Ver todos') | escape }}</button>
        <label><span class="bs-sort-label">Ordenar por</span><select data-bs-sort aria-label="Ordenar produtos"><option value="user">Ordem da coleção</option><option value="price-ascending">Menor preço</option><option value="price-descending">Maior preço</option><option value="created-descending">Mais novos</option><option value="alpha-ascending">A–Z</option></select></label>
    </div>
    <section class="bs-catalog" aria-label="{{ collection_title | escape }}" aria-busy="true">
        <h2 class="bs-sr-only" data-bs-result-title>{{ collection_title | escape }}</h2>
        <p class="be-status" data-bs-status role="status" aria-live="polite"></p>
        <button class="be-button" type="button" data-bs-retry hidden>Tentar novamente</button>
        <div class="be-product-grid" data-bs-grid></div>
        <button class="be-button be-results__more" type="button" data-bs-more hidden>Mostrar mais produtos</button>
    </section>
    {% if settings.campaign_page_10_catalog_filters_enabled %}
        {% set collection_models = (settings.bolsas_eora_models | default([])) | merge(settings.oculos_eora_models | default([])) | merge(settings.campaign_page_10_catalog_models | default([])) %}
        {% include 'snipplets/best-sellers/filters.tpl' with {bs_all_label: collection_title, bs_models: collection_models} %}
    {% endif %}
    <noscript><p class="be-status">{% if collection_url %}<a href="{{ collection_url | setting_url }}">Ver produtos da coleção</a>{% else %}Em breve.{% endif %}</p></noscript>
</main>
<script src="{{ 'js/bolsas-eora-filters.js' | static_url }}?v=20260930-1" defer></script>
<script src="{{ 'js/oculos-eora-filters.js' | static_url }}?v=20260930-1" defer></script>
<script src="{{ 'js/best-sellers-eora.js' | static_url }}?v=20261127-1" defer></script>
