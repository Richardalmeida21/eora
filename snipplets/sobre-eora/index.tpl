<link rel="stylesheet" href="{{ 'css/sobre-eora.css' | static_url }}?v=20261027-6">
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
        <section class="se-founders se-section" data-se-founders aria-labelledby="se-founders-title">
            <div class="se-founders__image">{% include 'snipplets/sobre-eora/image.tpl' with {image: 'sobre_eora_founders.jpg', image_mobile: ('sobre_eora_founders_mobile.jpg' | has_custom_image) ? 'sobre_eora_founders_mobile.jpg' : '', image_alt: settings.sobre_eora_founders_title | default('Fundadores da EORA'), image_sizes: '(max-width: 767px) calc(100vw - 40px), (max-width: 1600px) 41.85vw, calc(744px - 4.65vw)'} %}</div>
            <div class="se-founders__copy">
                <h2 class="se-heading" id="se-founders-title">{{ settings.sobre_eora_founders_title | default('Nossos fundadores') | escape }}</h2>
                <div class="se-rich-text" id="se-founders-text">{% include 'snipplets/sobre-eora/rich-text.tpl' with {text: settings.sobre_eora_founders_text} %}</div>
                <button type="button" class="se-link se-founders__toggle" data-se-founders-toggle aria-expanded="false" aria-controls="se-founders-text" hidden>Ver mais</button>
            </div>
        </section>
    {% endif %}

    {% for kind in ['press', 'quote', 'sustainability', 'timeline', 'values', 'community'] %}
        {% set prefix = 'sobre_eora_' ~ kind %}
        {% if attribute(settings, prefix ~ '_enabled') %}
            {% if kind == 'quote' %}
                {% if settings.sobre_eora_quote_text %}
                    <section class="se-quote se-section"{% if settings.sobre_eora_quote_title %} aria-labelledby="se-quote-title"{% else %} aria-label="Frase dos fundadores"{% endif %}>
                        {% if settings.sobre_eora_quote_title %}<h2 class="se-heading" id="se-quote-title">{{ settings.sobre_eora_quote_title | escape }}</h2>{% endif %}
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
                                <div class="se-product" data-se-card>{% include 'snipplets/bolsas-eora/product-card.tpl' with {be_product_image_limit: 1, be_product_high_quality: true, be_product_image_sizes: '(max-width: 767px) calc((100vw - 36px) / 1.2), (max-width: 1600px) calc((90vw - 96px) / 4.2), calc((1600px - 10vw - 96px) / 4.2)'} %}</div>
                            {% endfor %}
                        </div>
                        {% include 'snipplets/sobre-eora/controls.tpl' with {carousel_id: 'se-community', carousel_title: settings.sobre_eora_community_title | default('Favoritos da comunidade')} %}
                    </section>
                {% endif %}
            {% else %}
                {% set items = [] %}
                {% set mobile_gallery_complete = (attribute(settings, prefix ~ '_images_mobile') | length) == (attribute(settings, prefix ~ '_images') | length) %}
                {% for slide in attribute(settings, prefix ~ '_images') %}
                    {% if slide.image %}
                        {% set mobile_slide = mobile_gallery_complete ? attribute(settings, prefix ~ '_images_mobile')[loop.index0] : {} %}
                        {% set items = items | merge([{slot: loop.index, image: slide.image, image_mobile: mobile_slide.image | default(''), title: slide.title, text: slide.description, link: slide.link, button: slide.button}]) %}
                    {% endif %}
                {% endfor %}
                {% if items %}
                    {% if kind == 'values' %}
                        <section class="se-section se-values" id="se-values" data-se-carousel aria-labelledby="se-values-title">
                            <h2 class="se-heading" id="se-values-title">{{ settings.sobre_eora_values_title | default('Nossos valores') | escape }}</h2>
                            <div class="se-track se-values__grid" id="se-values-track" data-se-track tabindex="0" aria-label="Percorrer {{ settings.sobre_eora_values_title | default('Nossos valores') | escape }}">
                                {% for item in items %}
                                    <article class="se-card" data-se-card>
                                        <div class="se-card__image">
                                            {% if item.link %}<a href="{{ item.link | escape }}"{% if item.link | is_external %} target="_blank" rel="noopener noreferrer"{% endif %} aria-label="{{ item.title | default('Valores da EORA') | escape }}">{% endif %}
                                                {% include 'snipplets/sobre-eora/image.tpl' with {image: item.image, image_mobile: item.image_mobile, image_alt: item.title | default('Valores da EORA'), image_sizes: '(max-width: 767px) calc((100vw - 36px) / 1.2), (max-width: 1600px) calc((90vw - 48px) / 3), calc((1600px - 10vw - 48px) / 3)'} %}
                                            {% if item.link %}</a>{% endif %}
                                        </div>
                                        {% if item.title %}<h3>{{ item.title | escape }}</h3>{% endif %}
                                        {% if item.text %}<p>{{ item.text | escape }}</p>{% endif %}
                                        {% if item.link %}<a class="se-link" href="{{ item.link | escape }}"{% if item.link | is_external %} target="_blank" rel="noopener noreferrer"{% endif %}>{{ item.button | default('Saiba mais') | escape }}</a>{% endif %}
                                    </article>
                                {% endfor %}
                            </div>
                            {% include 'snipplets/sobre-eora/controls.tpl' with {carousel_id: 'se-values', carousel_title: settings.sobre_eora_values_title | default('Nossos valores')} %}
                        </section>
                    {% else %}
                        {% include 'snipplets/sobre-eora/cards.tpl' with {items: items, kind: kind, title: attribute(settings, prefix ~ '_title')} %}
                    {% endif %}
                {% endif %}
            {% endif %}
        {% endif %}
    {% endfor %}
</main>
<script src="{{ 'js/sobre-eora.js' | static_url }}?v=20261027-1" defer></script>
