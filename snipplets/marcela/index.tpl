{# Favoritos da Marcela: briefing outubro/2026. Os campos antigos continuam como fallback. #}
{% set marcela_legacy = current_settings_name | default('campaign_page_04') %}
{% set marcela_products = [] %}
{% set marcela_custom_catalog = settings.marcela_custom_catalog %}
{% for i in 1..10 %}
    {% if attribute(settings, 'marcela_catalog_' ~ i ~ '_enabled') %}
        {% set marcela_custom_catalog = true %}
        {% set marcela_products = marcela_products | merge(attribute(sections, 'marcela_catalog_' ~ i).products | default([])) %}
    {% endif %}
{% endfor %}
{% if not marcela_custom_catalog %}
    {% for suffix in ['_fpc', '_spc', '_tpc', '_qpc'] %}
        {% set marcela_products = marcela_products | merge(attribute(sections, marcela_legacy ~ suffix).products | default([])) %}
    {% endfor %}
{% endif %}
<link rel="stylesheet" href="{{ 'css/bolsas-eora.css' | static_url }}?v=20261020-1">
<link rel="stylesheet" href="{{ 'css/best-sellers-eora.css' | static_url }}?v=20261029-1">
<link rel="stylesheet" href="{{ 'css/marcela.css' | static_url }}?v=20261112-1">
<main class="be-page bs-page mf-page" data-mf-page data-bs-page data-bs-inline-catalog data-bs-category-url="/favoritosdamarcela/" data-bs-page-size="12" data-bs-mobile-page-size="6" data-bs-macro-visible="3" data-bs-catalog-title="Todos os favoritos da Marcela">
    <h1 class="bs-sr-only">{{ settings.marcela_title | default('Favoritos da Marcela') | escape }}</h1>
    {% include 'snipplets/marcela/hero.tpl' %}
    <div class="mf-content">
        {% include 'snipplets/marcela/categories.tpl' %}
        <div class="bs-toolbar">
            <button class="be-text-button" type="button" data-bs-reset aria-pressed="true">Ver todos</button>
            <label><span class="bs-sort-label">Ordenar por</span><select data-bs-sort aria-label="Ordenar produtos"><option value="user">Escolhas da Marcela</option><option value="price-ascending">Menor preço</option><option value="price-descending">Maior preço</option><option value="created-descending">Mais novos</option><option value="alpha-ascending">A–Z</option></select></label>
        </div>
        <section class="bs-catalog" aria-label="Favoritos da Marcela" aria-busy="true">
            <h2 class="bs-sr-only" data-bs-result-title>Todos os favoritos da Marcela</h2>
            <p class="be-status" data-bs-status role="status" aria-live="polite"></p>
            <button class="be-button" type="button" data-bs-retry hidden>Tentar novamente</button>
            <div class="be-product-grid" data-bs-grid></div>
            <button class="be-button be-results__more" type="button" data-bs-more hidden>Mostrar mais produtos</button>
        </section>
        <template data-bs-initial-products>
            {% for product in marcela_products %}{% include 'snipplets/bolsas-eora/product-card.tpl' with {be_product_image_limit: 3, be_product_variants_enabled: true, be_product_high_quality: true} %}{% endfor %}
        </template>
        <noscript><style>.mf-page .bs-toolbar,.mf-page .bs-catalog,.mf-page .be-filter-button{display:none!important}</style><div class="be-product-grid">{% for product in marcela_products %}{% include 'snipplets/bolsas-eora/product-card.tpl' with {be_product_image_limit: 1} %}{% endfor %}</div></noscript>
        {% include 'snipplets/marcela/looks.tpl' %}
        {% include 'snipplets/marcela/founder.tpl' %}
    </div>
    {% include 'snipplets/best-sellers/filters.tpl' with {bs_all_label: 'Todos os favoritos da Marcela'} %}
</main>
<script src="{{ 'js/bolsas-eora-filters.js' | static_url }}?v=20260930-1" defer></script>
<script src="{{ 'js/oculos-eora-filters.js' | static_url }}?v=20260930-1" defer></script>
<script src="{{ 'js/best-sellers-eora.js' | static_url }}?v=20261112-1" defer></script>
<script src="{{ 'js/marcela.js' | static_url }}?v=20261112-1" defer></script>
