<link rel="stylesheet" href="{{ 'css/bolsas-eora.css' | static_url }}?v=20260921-18">
<main class="be-page" data-be-page data-search-url="{{ store.search_url | escape }}" data-category-url="{{ settings.bolsas_eora_category_url | default('') | trim | escape }}">
    {% if settings.bolsas_eora_models %}
        <nav class="be-models" data-be-carousel aria-label="Modelos de bolsas">
            <div class="be-models__viewport">
                <div class="be-track" data-be-track tabindex="0" aria-label="Percorrer modelos">
                    {% for model in settings.bolsas_eora_models %}
                        {% set model_tag = model.link | trim %}
                        {% if model.image and model_tag %}
                            <a class="be-model" href="?tag={{ model_tag | url_encode }}" data-be-tag="{{ model_tag | escape }}">
                                <img src="{{ model.image | static_url | settings_image_url('large') }}" srcset="{{ model.image | static_url | settings_image_url('medium') }} 320w, {{ model.image | static_url | settings_image_url('large') }} 480w, {{ model.image | static_url | settings_image_url('huge') }} 640w" sizes="(max-width: 767px) 40vw, (max-width: 1024px) 25vw, 222px" alt="{{ model_tag | escape }}" width="{{ model.width | default(300) }}" height="{{ model.height | default(300) }}"{% if loop.index > 4 %} loading="lazy"{% endif %} decoding="async">
                                <span>{{ model_tag | escape }}</span>
                            </a>
                        {% endif %}
                    {% endfor %}
                </div>
            </div>
            {% include 'snipplets/bolsas-eora/controls.tpl' %}
        </nav>
    {% endif %}

    <div class="be-toolbar" data-be-toolbar>
        <button class="be-button be-reset" type="button" data-be-reset aria-pressed="true">Ver todas as bolsas</button>
        <label data-be-sort-control hidden>Ordenar por <select data-be-sort aria-label="Ordenar produtos">
            <option value="user">Destaques</option>
            <option value="best-selling">Mais vendidos</option>
            <option value="price-ascending">Menor preço</option>
            <option value="price-descending">Maior preço</option>
            <option value="created-descending">Mais novos</option>
            <option value="alpha-ascending">A–Z</option>
        </select></label>
    </div>

    <section class="be-results" data-be-results hidden aria-label="Produtos de bolsas" aria-busy="false">
        <h2 data-be-result-title tabindex="-1"></h2>
        <p class="be-status" data-be-status role="status" aria-live="polite"></p>
        <div class="be-product-grid" data-be-results-grid></div>
        <button class="be-button be-results__more" type="button" data-be-more hidden>Mostrar mais produtos</button>
    </section>

    {% include 'snipplets/bolsas-eora/banners.tpl' %}

    {% if settings.bolsas_eora_best_enabled and sections.bolsas_eora_best.products %}
        <section class="be-best" data-be-carousel aria-label="{{ settings.bolsas_eora_best_title | default('Best sellers') | escape }}">
            <header class="be-section-heading"><h2>{{ settings.bolsas_eora_best_title | default('Best sellers') | escape }}</h2></header>
            <div class="be-track" data-be-track tabindex="0" aria-label="Percorrer produtos">
                {% for product in sections.bolsas_eora_best.products %}
                    {% include 'snipplets/bolsas-eora/product-card.tpl' %}
                {% endfor %}
            </div>
            {% include 'snipplets/bolsas-eora/controls.tpl' %}
        </section>
    {% endif %}

    {% if settings.bolsas_eora_community_enabled and settings.bolsas_eora_community %}
        {% include 'snipplets/bolsas-eora/gallery.tpl' with {gallery_kind: 'community', gallery_items: settings.bolsas_eora_community, gallery_title: settings.bolsas_eora_community_title, gallery_subtitle: settings.bolsas_eora_community_subtitle, gallery_link: settings.bolsas_eora_community_link} %}
    {% endif %}
    {% if settings.bolsas_eora_categories_enabled and settings.bolsas_eora_categories %}
        {% include 'snipplets/bolsas-eora/gallery.tpl' with {gallery_kind: 'categories', gallery_items: settings.bolsas_eora_categories, gallery_title: settings.bolsas_eora_categories_title, gallery_subtitle: '', gallery_link: ''} %}
    {% endif %}

    {% if settings.bolsas_eora_filters_enabled %}
        <button class="be-filter-button" type="button" data-be-open-filters aria-haspopup="dialog" aria-controls="be-filter-dialog" hidden>Filtros <svg aria-hidden="true" width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
				<path d="M0 14.875C0 14.418 0.351562 14.0312 0.84375 14.0312H2.91797C3.26953 12.9062 4.35938 12.0625 5.625 12.0625C6.85547 12.0625 7.94531 12.9062 8.29688 14.0312H17.1562C17.6133 14.0312 18 14.418 18 14.875C18 15.3672 17.6133 15.7188 17.1562 15.7188H8.29688C7.94531 16.8789 6.85547 17.6875 5.625 17.6875C4.35938 17.6875 3.26953 16.8789 2.91797 15.7188H0.84375C0.351562 15.7188 0 15.3672 0 14.875ZM4.5 14.875C4.5 15.5078 4.99219 16 5.625 16C6.22266 16 6.75 15.5078 6.75 14.875C6.75 14.2773 6.22266 13.75 5.625 13.75C4.99219 13.75 4.5 14.2773 4.5 14.875ZM11.25 9.25C11.25 9.88281 11.7422 10.375 12.375 10.375C12.9727 10.375 13.5 9.88281 13.5 9.25C13.5 8.65234 12.9727 8.125 12.375 8.125C11.7422 8.125 11.25 8.65234 11.25 9.25ZM12.375 6.4375C13.6055 6.4375 14.6953 7.28125 15.0469 8.40625H17.1562C17.6133 8.40625 18 8.79297 18 9.25C18 9.74219 17.6133 10.0938 17.1562 10.0938H15.0469C14.6953 11.2539 13.6055 12.0625 12.375 12.0625C11.1094 12.0625 10.0195 11.2539 9.66797 10.0938H0.84375C0.351562 10.0938 0 9.74219 0 9.25C0 8.79297 0.351562 8.40625 0.84375 8.40625H9.66797C10.0195 7.28125 11.1094 6.4375 12.375 6.4375ZM6.75 4.75C7.34766 4.75 7.875 4.25781 7.875 3.625C7.875 3.02734 7.34766 2.5 6.75 2.5C6.11719 2.5 5.625 3.02734 5.625 3.625C5.625 4.25781 6.11719 4.75 6.75 4.75ZM9.42188 2.78125H17.1562C17.6133 2.78125 18 3.16797 18 3.625C18 4.11719 17.6133 4.46875 17.1562 4.46875H9.42188C9.07031 5.62891 7.98047 6.4375 6.75 6.4375C5.48438 6.4375 4.39453 5.62891 4.04297 4.46875H0.84375C0.351562 4.46875 0 4.11719 0 3.625C0 3.16797 0.351562 2.78125 0.84375 2.78125H4.04297C4.39453 1.65625 5.48438 0.8125 6.75 0.8125C7.98047 0.8125 9.07031 1.65625 9.42188 2.78125Z" fill="white"/>
			</svg></button>
        <dialog class="be-filter-dialog" id="be-filter-dialog" aria-labelledby="be-filter-title">
            <header><h2 id="be-filter-title">Filtros</h2><button type="button" data-be-close-filters aria-label="Fechar filtros"><svg aria-hidden="true"><use xlink:href="#times"/></svg></button></header>
            <form data-be-filter-form>
                <div class="be-filter-dialog__body">
                    <label class="be-model-select">Modelo<select name="be_model"><option value="">Todos os modelos</option>
                        {% for model in settings.bolsas_eora_models %}
                            {% if model.image and model.link | trim %}<option value="{{ model.link | trim | escape }}">{{ model.link | trim | escape }}</option>{% endif %}
                        {% endfor %}
                    </select></label>
                    <p data-be-facet-status role="status"></p>
                    <div data-be-facets></div>
                    <fieldset class="be-facet">
                        <legend>Preço</legend>
                        <div class="be-price-fields">
                            <label>De R$ <input type="number" name="min_price" min="0" step="0.01" inputmode="decimal" placeholder="0,00"></label>
                            <label>Até R$ <input type="number" name="max_price" min="0" step="0.01" inputmode="decimal" placeholder="0,00"></label>
                        </div>
                    </fieldset>
                </div>
                <footer><button type="button" class="be-text-button" data-be-clear-filters>Limpar filtros</button><button type="submit" class="be-button">Aplicar filtros</button></footer>
            </form>
        </dialog>
    {% endif %}
    <noscript><p class="be-status">Ative o JavaScript para carregar as bolsas e filtrar por modelo.</p></noscript>
</main>
<script src="{{ 'js/bolsas-eora-filters.js' | static_url }}?v=20260918-5" defer></script>
<script src="{{ 'js/bolsas-eora.js' | static_url }}?v=20260921-18" defer></script>
