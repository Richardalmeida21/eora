{% set campaign_models = settings.campaign_page_10_models | default(settings.campaign_page_10_catalog_models) %}
{% set campaign_page_10_category_url = settings.campaign_page_10_catalog_url | default('') | trim %}
<link rel="stylesheet" href="{{ 'css/bolsas-eora.css' | static_url }}?v=20261127-2">
<link rel="stylesheet" href="{{ 'css/best-sellers-eora.css' | static_url }}?v=20261029-1">
<style>.campaign10-page .campaign10-hero{margin: -28px calc(-1 * clamp(12px, 3vw, 48px)) 28px}.campaign10-page .campaign10-hero img{width:100%;height:auto;display:block}@media(max-width:767px){.campaign10-page .campaign10-hero{margin-top:-20px}}</style>
<main class="be-page bs-page campaign10-page" data-bs-page data-bs-search-tags data-bs-search-url="{{ store.search_url | escape }}" data-bs-catalog-title="Todos os produtos" data-bs-loading-label="Carregando produtos da coleção…" data-bs-error-label="Não foi possível carregar os produtos da coleção. Tente novamente." data-bs-category-url="{{ campaign_page_10_category_url | escape }}">
    {% if settings.campaign_page_10_catalog_banner_enabled %}
        {% for banner in settings.campaign_page_10_catalog_banner | slice(0,1) %}
            {% if banner.image %}
                {% set mobile_banner = settings.campaign_page_10_catalog_banner_mobile | first %}
                <section class="be-campaign-intro campaign10-hero" aria-label="{{ settings.campaign_page_10_catalog_title | default(page.name) | escape }}">
                    {% if banner.link %}<a href="{{ banner.link | setting_url }}">{% endif %}
                    <picture>
                        {% if mobile_banner.image %}<source media="(max-width:767px)" srcset="{{ mobile_banner.image | static_url | settings_image_url('1080p') }}">{% endif %}
                        <img src="{{ banner.image | static_url | settings_image_url('1080p') }}" alt="{{ banner.title | default(page.name) | escape }}" fetchpriority="high" decoding="async">
                    </picture>
                    {% if banner.link %}</a>{% endif %}
                </section>
            {% endif %}
        {% endfor %}
    {% endif %}

    <header class="bs-heading"><h1>{{ settings.campaign_page_10_catalog_title | default(page.name) | escape }}</h1></header>
    {% set active_models = [] %}
    {% for model in campaign_models | slice(0, 2) %}
        {% if model.image and (model.link | default('') | trim) %}{% set active_models = active_models | merge([model]) %}{% endif %}
    {% endfor %}
    <nav class="bs-macros" style="--bs-macro-count: {{ active_models | length ? active_models | length : 1 }}" data-bs-carousel aria-label="Categorias da coleção"{% if not active_models %} hidden{% endif %}>
        <div class="bs-macros__track be-track" data-bs-track tabindex="0" aria-label="Percorrer categorias">
            {% for model in active_models %}
                {% set model_tag = model.link | trim %}
                {% set model_title = model.title | default(model_tag) | trim %}
                <a class="bs-macro" href="?bs_category={{ loop.index }}" data-bs-category="{{ loop.index }}" data-bs-tag="{{ model_tag | escape }}" data-bs-order="{{ loop.index }}" aria-expanded="false">
                    <span class="bs-macro__selection"><picture>
                        <img src="{{ model.image | static_url | settings_image_url('1080p') }}" srcset="{{ model.image | static_url | settings_image_url('large') }} 480w, {{ model.image | static_url | settings_image_url('huge') }} 640w, {{ model.image | static_url | settings_image_url('original') }} 1024w, {{ model.image | static_url | settings_image_url('xlarge') }} 1400w, {{ model.image | static_url | settings_image_url('1080p') }} 1920w" sizes="(max-width: 767px) 50vw, 50vw" onerror="if(!this.dataset.originalTried){this.dataset.originalTried='1';this.removeAttribute('srcset');this.src=this.dataset.originalSrc;}" data-original-src="{{ model.image | static_url }}" data-image-key="{{ model.image | escape }}" alt="{{ model_title | escape }}" width="2160" height="960" decoding="async">
                    </picture></span>
                    <span class="bs-macro__title">{{ model_title | escape }}</span>
                </a>
            {% endfor %}
        </div>
        <p class="bs-macros__description" id="bs-mobile-description" data-bs-mobile-description hidden aria-live="polite"></p>
        {% include 'snipplets/bolsas-eora/controls.tpl' %}
    </nav>
    <div class="bs-toolbar">
        <button class="be-text-button" type="button" data-bs-reset aria-pressed="true">Ver todos</button>
        <label><span class="bs-sort-label">Ordenar por</span><select data-bs-sort aria-label="Ordenar produtos"><option value="user">Ordem da categoria</option><option value="price-ascending">Menor preço</option><option value="price-descending">Maior preço</option><option value="created-descending">Mais novos</option><option value="alpha-ascending">A–Z</option></select></label>
    </div>
    <section class="bs-catalog" aria-label="Produtos da coleção" aria-busy="true">
        <h2 class="bs-sr-only" data-bs-result-title>Todos os produtos</h2>
        <p class="be-status" data-bs-status role="status" aria-live="polite"></p>
        <button class="be-button" type="button" data-bs-retry hidden>Tentar novamente</button>
        <div class="be-product-grid" data-bs-grid></div>
        <button class="be-button be-results__more" type="button" data-bs-more hidden>Mostrar mais produtos</button>
    </section>
    {% if settings.campaign_page_10_community_enabled and settings.campaign_page_10_community %}
        <div data-bs-community></div>
        {% include 'snipplets/best-sellers/community.tpl' with {bs_community_id: 'all', bs_community_items: settings.campaign_page_10_community, bs_community_title: settings.campaign_page_10_community_title, bs_community_subtitle: settings.campaign_page_10_community_subtitle, bs_community_link: settings.campaign_page_10_community_link} %}
    {% endif %}
    {% if settings.campaign_page_10_categories_enabled and settings.campaign_page_10_categories %}
        <div class="bs-categories">{% include 'snipplets/bolsas-eora/gallery.tpl' with {gallery_kind: 'categories', gallery_items: settings.campaign_page_10_categories, gallery_title: settings.campaign_page_10_categories_title, gallery_subtitle: '', gallery_link: '', gallery_high_quality: true} %}</div>
    {% endif %}
    {% if settings.campaign_page_10_filters_enabled %}
        {% include 'snipplets/best-sellers/filters.tpl' with {bs_all_label: 'Todos os produtos'} %}
    {% endif %}
    <noscript><p class="be-status">Ative o JavaScript para visualizar e filtrar os produtos.</p></noscript>
</main>
<script src="{{ 'js/bolsas-eora-filters.js' | static_url }}?v=20260930-1" defer></script>
<script src="{{ 'js/oculos-eora-filters.js' | static_url }}?v=20260930-1" defer></script>
<script src="{{ 'js/best-sellers-eora.js' | static_url }}?v=20261127-c10" defer></script>
