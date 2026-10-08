{# Briefing Best Sellers — outubro/2026. Produtos da categoria /best-sellers/. #}
<link rel="stylesheet" href="{{ 'css/bolsas-eora.css' | static_url }}?v=20260922-1">
<link rel="stylesheet" href="{{ 'css/best-sellers-eora.css' | static_url }}?v=20261008-2">
<main class="be-page bs-page" data-bs-page data-bs-category-url="/best-sellers/">
    <header class="bs-heading"><h1>{{ settings.best_sellers_eora_title | default('Best sellers') | escape }}</h1></header>
    {% set bs_macro_count = 0 %}
    {% for i in 1..15 %}
        {% set prefix = 'best_sellers_eora_macro_' ~ i %}
        {% set macro_image = prefix ~ '.jpg' %}
        {% if attribute(settings, prefix ~ '_enabled') and (attribute(settings, prefix ~ '_tag') | default('') | trim) and (macro_image | has_custom_image) %}
            {% set bs_macro_count = bs_macro_count + 1 %}
        {% endif %}
    {% endfor %}
    {% set bs_macro_mobile_sizes = 'calc((100vw - 34px) / 2)' %}
    {% set bs_macro_desktop_sizes = '32vw' %}
    {% if bs_macro_count > 0 and bs_macro_count <= 4 %}
        {% set bs_macro_mobile_sizes = 'calc((100vw - 24px - ' ~ ((bs_macro_count - 1) * 10) ~ 'px) / ' ~ bs_macro_count ~ ')' %}
        {% set bs_macro_desktop_sizes = 'calc((100vw - clamp(24px, 6vw, 96px) - ' ~ ((bs_macro_count - 1) * 12) ~ 'px) / ' ~ bs_macro_count ~ ')' %}
    {% endif %}
    <nav class="bs-macros{% if bs_macro_count > 4 %} bs-macros--overflow{% endif %}" style="--bs-macro-count: {{ bs_macro_count ? bs_macro_count : 1 }}" data-bs-carousel aria-label="Categorias de best sellers"{% if not bs_macro_count %} hidden{% endif %}>
        <div class="bs-macros__track be-track" data-bs-track tabindex="0" aria-label="Percorrer categorias">
            {% for i in 1..15 %}
                {% set prefix = 'best_sellers_eora_macro_' ~ i %}
                {% set macro_image = prefix ~ '.jpg' %}
                {% set macro_mobile_image = prefix ~ '_mobile.jpg' %}
                {% set macro_tag = attribute(settings, prefix ~ '_tag') | default('') | trim %}
                {% set macro_title = attribute(settings, prefix ~ '_title') | default(macro_tag) %}
                {% set macro_description = attribute(settings, prefix ~ '_description') %}
                {% if attribute(settings, prefix ~ '_enabled') and macro_tag and (macro_image | has_custom_image) %}
                    {% set macro_url = attribute(settings, prefix ~ '_link') | default('?bs_category=' ~ i) %}
                    <a class="bs-macro" href="{{ macro_url | escape }}" data-bs-category="{{ i }}" data-bs-tag="{{ macro_tag | escape }}" data-bs-order="{{ attribute(settings, prefix ~ '_order') | default(i) | escape }}" aria-expanded="false"{% if macro_description %} aria-controls="bs-description-{{ i }} bs-mobile-description"{% endif %}>
                        <span class="bs-macro__selection">
                            <picture>
                                {% if macro_mobile_image | has_custom_image %}
                                    <source media="(max-width: 767px)" srcset="{{ macro_mobile_image | static_url | settings_image_url('large') }} 480w, {{ macro_mobile_image | static_url | settings_image_url('huge') }} 640w, {{ macro_mobile_image | static_url | settings_image_url('original') }} 1024w, {{ macro_mobile_image | static_url | settings_image_url('xlarge') }} 1400w, {{ macro_mobile_image | static_url | settings_image_url('1080p') }} 1920w" sizes="{{ bs_macro_mobile_sizes }}" width="1920" height="2560">
                                {% endif %}
                                <img src="{{ macro_image | static_url | settings_image_url('1080p') }}" srcset="{{ macro_image | static_url | settings_image_url('large') }} 480w, {{ macro_image | static_url | settings_image_url('huge') }} 640w, {{ macro_image | static_url | settings_image_url('original') }} 1024w, {{ macro_image | static_url | settings_image_url('xlarge') }} 1400w, {{ macro_image | static_url | settings_image_url('1080p') }} 1920w" sizes="(max-width: 767px) {{ bs_macro_mobile_sizes }}, {{ bs_macro_desktop_sizes }}" alt="{{ macro_title | escape }}" width="2160" height="960"{% if i > 3 %} loading="lazy"{% endif %} decoding="async">
                            </picture>
                        </span>
                        <span class="bs-macro__title">{{ macro_title | escape }}</span>
                        {% if macro_description %}<span class="bs-macro__description" id="bs-description-{{ i }}" hidden>{{ macro_description | escape }}</span>{% endif %}
                    </a>
                {% endif %}
            {% endfor %}
        </div>
        <p class="bs-macros__description" id="bs-mobile-description" data-bs-mobile-description hidden aria-live="polite"></p>
        {% include 'snipplets/bolsas-eora/controls.tpl' %}
    </nav>

    <div class="bs-toolbar">
        <button class="be-text-button" type="button" data-bs-reset aria-pressed="true">Ver todos</button>
        <label><span class="bs-sort-label">Ordenar por</span><select data-bs-sort aria-label="Ordenar produtos"><option value="user">Ordem da categoria</option><option value="price-ascending">Menor preço</option><option value="price-descending">Maior preço</option><option value="created-descending">Mais novos</option><option value="alpha-ascending">A–Z</option></select></label>
    </div>
    <section class="bs-catalog" aria-label="Catálogo de best sellers" aria-busy="true">
        <h2 class="bs-sr-only" data-bs-result-title>Todos os best sellers</h2>
        <p class="be-status" data-bs-status role="status" aria-live="polite"></p>
        <button class="be-button" type="button" data-bs-retry hidden>Tentar novamente</button>
        <div class="be-product-grid" data-bs-grid></div>
        <button class="be-button be-results__more" type="button" data-bs-more hidden>Mostrar mais produtos</button>
    </section>

    {% if settings.best_sellers_eora_community_enabled %}
        <div data-bs-community></div>
        {% include 'snipplets/best-sellers/community.tpl' with {bs_community_id: 'all', bs_community_items: settings.best_sellers_eora_community, bs_community_title: settings.best_sellers_eora_community_title, bs_community_subtitle: settings.best_sellers_eora_community_subtitle, bs_community_link: settings.best_sellers_eora_community_link} %}
        {% for i in 1..15 %}
            {% set prefix = 'best_sellers_eora_macro_' ~ i %}
            {% if attribute(settings, prefix ~ '_enabled') %}
                {% include 'snipplets/best-sellers/community.tpl' with {bs_community_id: i, bs_community_items: attribute(settings, prefix ~ '_community'), bs_community_title: attribute(settings, prefix ~ '_community_title') | default(settings.best_sellers_eora_community_title), bs_community_subtitle: attribute(settings, prefix ~ '_community_subtitle') | default(settings.best_sellers_eora_community_subtitle), bs_community_link: attribute(settings, prefix ~ '_community_link') | default(settings.best_sellers_eora_community_link)} %}
            {% endif %}
        {% endfor %}
    {% endif %}
    {% if settings.best_sellers_eora_categories_enabled and settings.best_sellers_eora_categories %}
        <div class="bs-categories">
            {% include 'snipplets/bolsas-eora/gallery.tpl' with {gallery_kind: 'categories', gallery_items: settings.best_sellers_eora_categories, gallery_title: settings.best_sellers_eora_categories_title, gallery_subtitle: '', gallery_link: '', gallery_high_quality: true, gallery_image_sizes: '(max-width: 767px) calc(100vw - 24px), 25vw', gallery_image_width: 1920, gallery_image_height: 2560} %}
        </div>
    {% endif %}
    {% if settings.best_sellers_eora_filters_enabled %}
        {% include 'snipplets/best-sellers/filters.tpl' %}
    {% endif %}
    <noscript>
        <style>.bs-page .bs-toolbar,.bs-page .bs-catalog,.bs-page .be-filter-button{display:none!important}</style>
        <p class="be-status"><a href="/best-sellers/">Ver todos os produtos da categoria Best Sellers</a></p>
    </noscript>
</main>
<script src="{{ 'js/bolsas-eora-filters.js' | static_url }}?v=20260930-1" defer></script>
<script src="{{ 'js/oculos-eora-filters.js' | static_url }}?v=20260930-1" defer></script>
<script src="{{ 'js/best-sellers-eora.js' | static_url }}?v=20261008-4" defer></script>
