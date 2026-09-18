<section class="be-gallery be-gallery--{{ gallery_kind }}" data-be-carousel aria-label="{{ gallery_title | default('Bolsas Eora') | escape }}">
    {% if gallery_title or gallery_subtitle %}
        <header class="be-section-heading">
            {% if gallery_title %}<h2>{{ gallery_title | escape }}</h2>{% endif %}
            {% if gallery_subtitle %}
                {% if gallery_link %}<a href="{{ gallery_link | escape }}">{{ gallery_subtitle | escape }}</a>{% else %}<p>{{ gallery_subtitle | escape }}</p>{% endif %}
            {% elseif gallery_link %}<a href="{{ gallery_link | escape }}">Ver mais</a>{% endif %}
        </header>
    {% endif %}
    <div class="be-track" data-be-track tabindex="0" aria-label="Percorrer imagens">
        {% for slide in gallery_items %}
            {% if slide.image %}
                <div class="be-gallery__item">
                    {% set slide_link = slide.link | default(gallery_link) %}
                    {% if slide_link %}<a class="be-banner" href="{{ slide_link | escape }}">{% else %}<div class="be-banner">{% endif %}
                        <img src="{{ slide.image | static_url | settings_image_url('huge') }}" srcset="{{ slide.image | static_url | settings_image_url('medium') }} 320w, {{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w" sizes="{% if gallery_kind == 'community' %}(max-width: 767px) 45vw, 20vw{% else %}(max-width: 767px) 85vw, 25vw{% endif %}" alt="{{ slide.title | default(gallery_title) | default('Bolsas Eora') | escape }}" loading="lazy" decoding="async" width="{{ slide.width | default(600) }}" height="{{ slide.height | default(800) }}">
                        {% if gallery_kind == 'categories' and (slide.title or slide.description or slide.button) %}
                            <span class="be-banner__caption"><span>
                                {% if slide.title %}<strong>{{ slide.title | escape }}</strong>{% endif %}
                                {% if slide.description %}<span>{{ slide.description | escape }}</span>{% endif %}
                                {% if slide.button %}<span class="be-banner__cta">{{ slide.button | escape }}</span>{% endif %}
                            </span>{% if slide_link %}<svg aria-hidden="true"><use xlink:href="#chevron-diagonal"/></svg>{% endif %}</span>
                        {% endif %}
                    {% if slide_link %}</a>{% else %}</div>{% endif %}
                </div>
            {% endif %}
        {% endfor %}
    </div>
    {% include 'snipplets/bolsas-eora/controls.tpl' %}
</section>
