<section class="se-section se-{{ kind }}" id="se-{{ kind }}" data-se-carousel aria-labelledby="se-{{ kind }}-title">
    <h2 class="se-heading" id="se-{{ kind }}-title">{{ title | escape }}</h2>
    <div class="se-track" id="se-{{ kind }}-track" data-se-track tabindex="0" aria-label="Percorrer {{ title | escape }}">
        {% for item in items %}
            <article class="se-card{% if kind == 'timeline' %} se-timeline__entry{% endif %}" data-se-card data-se-item="{{ kind }}-{{ item.slot }}">
                <div class="se-card__image">
                    {% if kind != 'timeline' and item.link %}<a href="{{ item.link | escape }}"{% if item.link | is_external %} target="_blank" rel="noopener noreferrer"{% endif %} aria-label="{{ item.title | default(title) | escape }}">{% endif %}
                        {% include 'snipplets/sobre-eora/image.tpl' with {image: item.image, image_mobile: item.image_mobile, image_alt: item.title | default(title), image_sizes: kind == 'timeline' ? '(max-width: 767px) calc((100vw - 36px) / 1.5), (max-width: 1600px) 45.54vw, calc(809.6px - 5.06vw)' : ''} %}
                    {% if kind != 'timeline' and item.link %}</a>{% endif %}
                </div>
                <div class="se-card__copy">
                    {% if item.title %}<h3>{{ item.title | escape }}</h3>{% endif %}
                    {% if item.text %}<p>{{ item.text | escape }}</p>{% endif %}
                    {% if item.link %}<a class="se-link" href="{{ item.link | escape }}"{% if item.link | is_external %} target="_blank" rel="noopener noreferrer"{% endif %}>{{ item.button | default(kind == 'press' ? 'Ler matéria' : 'Saiba mais') | escape }}</a>{% endif %}
                </div>
            </article>
        {% endfor %}
    </div>
    {% include 'snipplets/sobre-eora/controls.tpl' with {carousel_id: 'se-' ~ kind, carousel_title: title} %}
</section>
