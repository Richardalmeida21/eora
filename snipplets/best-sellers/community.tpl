{% if bs_community_items %}
<template data-bs-community-template="{{ bs_community_id }}">
    <section class="be-gallery be-gallery--community" data-bs-carousel aria-label="{{ bs_community_title | default('Quem usa Eora') | escape }}">
        <header class="be-section-heading">
            <h2>{{ bs_community_title | default('Quem usa Eora') | escape }}</h2>
            <a href="{{ bs_community_link | default('/quem-usa/') | escape }}">{{ bs_community_subtitle | default('Nossa comunidade') | escape }}</a>
        </header>
        <div class="be-track" data-bs-track tabindex="0" aria-label="Percorrer fotos de quem usa Eora">
            {% for slide in bs_community_items | take(15) %}
                {% if slide.image %}
                    <div class="be-gallery__item"><a class="be-banner" href="{{ slide.link | default(bs_community_link) | default('/quem-usa/') | escape }}">
                        <img src="{{ slide.image | static_url | settings_image_url('1080p') }}" srcset="{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('xlarge') }} 1400w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w" sizes="(max-width: 767px) calc(100vw - 24px), 20vw" alt="{{ slide.title | default(bs_community_title) | default('Quem usa Eora') | escape }}" width="1920" height="1920" loading="lazy" decoding="async">
                    </a></div>
                {% endif %}
            {% endfor %}
        </div>
        {% include 'snipplets/bolsas-eora/controls.tpl' %}
    </section>
</template>
{% endif %}
