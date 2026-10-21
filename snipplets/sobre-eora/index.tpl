<link rel="stylesheet" href="{{ 'css/sobre-eora.css' | static_url }}?v=20261021-1">
<main class="se-page" data-se-page>
    {% set intro_text = settings.sobre_eora_intro_text | default(page.content) %}
    {% if settings.sobre_eora_intro_enabled and intro_text %}
        <section class="se-intro" aria-labelledby="se-title">
            <h1 class="se-heading" id="se-title">{{ settings.sobre_eora_intro_title | default('Sobre a EORA') | escape }}</h1>
            <div class="se-rich-text">{% include 'snipplets/sobre-eora/rich-text.tpl' with {text: intro_text} %}</div>
        </section>
    {% else %}
        <h1 class="se-sr-only">{{ page.name | default('Sobre a EORA') | escape }}</h1>
    {% endif %}

    {% if settings.sobre_eora_founders_enabled and 'sobre_eora_founders.jpg' | has_custom_image and settings.sobre_eora_founders_text %}
        <section class="se-founders se-section" aria-labelledby="se-founders-title">
            <div class="se-founders__image">{% include 'snipplets/sobre-eora/image.tpl' with {image: 'sobre_eora_founders.jpg', image_alt: settings.sobre_eora_founders_title | default('Fundadores da EORA')} %}</div>
            <div class="se-founders__copy">
                <h2 class="se-heading" id="se-founders-title">{{ settings.sobre_eora_founders_title | default('Nossos fundadores') | escape }}</h2>
                <div class="se-rich-text">{% include 'snipplets/sobre-eora/rich-text.tpl' with {text: settings.sobre_eora_founders_text} %}</div>
            </div>
        </section>
    {% endif %}

    {% for kind in ['press', 'quote', 'sustainability', 'timeline', 'values', 'community'] %}
        {% set prefix = 'sobre_eora_' ~ kind %}
        {% if settings[prefix ~ '_enabled'] %}
            {% if kind == 'quote' %}
                {% if settings.sobre_eora_quote_text %}
                    <section class="se-quote se-section" aria-label="Frase dos fundadores">
                        <blockquote class="se-rich-text">{% include 'snipplets/sobre-eora/rich-text.tpl' with {text: settings.sobre_eora_quote_text} %}</blockquote>
                        {% if settings.sobre_eora_quote_author %}<p class="se-quote__author">{{ settings.sobre_eora_quote_author | escape }}</p>{% endif %}
                    </section>
                {% endif %}
            {% elseif kind == 'community' %}
                {% if sections.sobre_eora_community.products %}
                    <section class="se-section se-products" id="se-community" data-se-carousel aria-labelledby="se-community-title">
                        <h2 class="se-heading" id="se-community-title">{{ settings.sobre_eora_community_title | default('Favoritos da comunidade') | escape }}</h2>
                        <div class="se-track" id="se-community-track" data-se-track tabindex="0" aria-label="Percorrer favoritos da comunidade">
                            {% for product in sections.sobre_eora_community.products %}
                                <div class="se-product" data-se-card>{% include 'snipplets/bolsas-eora/product-card.tpl' with {be_product_image_limit: 1, be_product_high_quality: true} %}</div>
                            {% endfor %}
                        </div>
                        {% include 'snipplets/sobre-eora/controls.tpl' with {carousel_id: 'se-community', carousel_title: settings.sobre_eora_community_title | default('Favoritos da comunidade')} %}
                    </section>
                {% endif %}
            {% else %}
                {% set items = [] %}
                {% for slot in 1..(kind == 'values' ? 3 : 10) %}
                    {% set key = prefix ~ '_' ~ slot %}
                    {% set image = key ~ '.jpg' %}
                    {% if settings[key ~ '_enabled'] and image | has_custom_image %}
                        {% set items = items | merge([{slot: slot, image: image, title: settings[key ~ '_title'], text: settings[key ~ '_text'], link: settings[key ~ '_link'], button: settings[key ~ '_button']}]) %}
                    {% endif %}
                {% endfor %}
                {% if items %}
                    {% if kind == 'values' %}
                        <section class="se-section se-values" aria-labelledby="se-values-title">
                            <h2 class="se-heading" id="se-values-title">{{ settings.sobre_eora_values_title | default('Nossos valores') | escape }}</h2>
                            <div class="se-values__grid">
                                {% for item in items %}
                                    <article class="se-card">
                                        <div class="se-card__image">{% include 'snipplets/sobre-eora/image.tpl' with {image: item.image, image_alt: item.title | default('Valores da EORA')} %}</div>
                                        {% if item.title %}<h3>{{ item.title | escape }}</h3>{% endif %}
                                        {% if item.text %}<p>{{ item.text | escape }}</p>{% endif %}
                                    </article>
                                {% endfor %}
                            </div>
                        </section>
                    {% else %}
                        {% include 'snipplets/sobre-eora/cards.tpl' with {items: items, kind: kind, title: settings[prefix ~ '_title']} %}
                    {% endif %}
                {% endif %}
            {% endif %}
        {% endif %}
    {% endfor %}
</main>
<script src="{{ 'js/sobre-eora.js' | static_url }}?v=20261021-1" defer></script>
