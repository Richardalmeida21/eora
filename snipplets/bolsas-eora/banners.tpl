{# O link da galeria e uma tag, nunca um destino de navegacao. #}
{% for banner in settings.bolsas_eora_banners %}
    {% if banner.image %}
        <template data-be-banner-template data-be-banner-tag="{{ banner.link | trim | escape }}">
            <figure class="be-catalog-banner" data-be-catalog-banner>
                <img src="{{ banner.image | static_url | settings_image_url('1080p') }}" srcset="{{ banner.image | static_url | settings_image_url('large') }} 480w, {{ banner.image | static_url | settings_image_url('huge') }} 640w, {{ banner.image | static_url | settings_image_url('1080p') }} 1920w" sizes="(max-width: 767px) 94vw, 47vw" alt="{{ banner.title | default('Bolsas Eora') | escape }}" width="{{ banner.width | default(1000) }}" height="{{ banner.height | default(1300) }}" loading="lazy" decoding="async">
            </figure>
        </template>
    {% endif %}
{% endfor %}
