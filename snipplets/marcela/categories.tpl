{% set mf_category_count = 0 %}
{% for i in 1..15 %}
    {% set mf_prefix = 'marcela_category_' ~ i %}
    {% set mf_image = attribute(settings, mf_prefix ~ '_image') | first %}
    {% if attribute(settings, mf_prefix ~ '_enabled') and mf_image.image and attribute(settings, mf_prefix ~ '_tag') %}{% set mf_category_count = mf_category_count + 1 %}{% endif %}
{% endfor %}
<nav class="bs-macros" data-bs-carousel aria-label="Categorias dos favoritos da Marcela"{% if not mf_category_count %} hidden{% endif %}>
    {% if mf_category_count %}<h2 class="mf-section-title">{{ settings.marcela_categories_title | default('Favoritos da Marcela') | escape }}</h2>{% endif %}
    <div class="bs-macros__track be-track" data-bs-track tabindex="0" aria-label="Percorrer categorias">
        {% for i in 1..15 %}
            {% set mf_prefix = 'marcela_category_' ~ i %}
            {% set mf_image = attribute(settings, mf_prefix ~ '_image') | first %}
            {% set mf_mobile = attribute(settings, mf_prefix ~ '_mobile') | first %}
            {% set mf_tag = attribute(settings, mf_prefix ~ '_tag') | default('') | trim %}
            {% if attribute(settings, mf_prefix ~ '_enabled') and mf_image.image and mf_tag %}
                {% set mf_title = attribute(settings, mf_prefix ~ '_title') | default(mf_tag) %}
                <a class="bs-macro" href="{{ attribute(settings, mf_prefix ~ '_link') | default('?bs_category=' ~ i) | escape }}" data-bs-category="{{ i }}" data-bs-tag="{{ mf_tag | escape }}" data-bs-order="{{ attribute(settings, mf_prefix ~ '_order') | default(i) | escape }}" aria-expanded="false" aria-controls="bs-description-{{ i }} bs-mobile-description">
                    <span class="bs-macro__selection"><picture>{% if mf_mobile.image %}<source media="(max-width: 767px)" srcset="{{ mf_mobile.image | settings_image_url('original') }}">{% endif %}<img src="{{ mf_image.image | settings_image_url('original') }}" alt="{{ mf_title | escape }}" width="2160" height="960" decoding="async" loading="lazy"></picture></span>
                    <span class="bs-macro__title">{{ mf_title | escape }}</span>
                    <span class="bs-macro__description" id="bs-description-{{ i }}" hidden>{{ attribute(settings, mf_prefix ~ '_description') | escape }}</span>
                </a>
            {% endif %}
        {% endfor %}
    </div>
    <p class="bs-macros__description" id="bs-mobile-description" data-bs-mobile-description hidden aria-live="polite"></p>
    {% include 'snipplets/bolsas-eora/controls.tpl' %}
</nav>
