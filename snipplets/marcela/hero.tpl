{% set mf_hero = settings.marcela_hero_image | first %}
{% set mf_hero_mobile = settings.marcela_hero_image_mobile | first %}
{% set mf_legacy_image = marcela_legacy ~ '_banner_topo_img.jpg' %}
{% set mf_legacy_mobile = marcela_legacy ~ '_banner_topo_mobile_img.jpg' %}
{% set mf_has_hero = mf_hero.image or (mf_legacy_image | has_custom_image) or settings.marcela_hero_video or settings.marcela_hero_video_mobile %}
{% if mf_has_hero and (settings.marcela_hero_enabled is not defined or settings.marcela_hero_enabled) %}
<section class="mf-hero" aria-label="{{ settings.marcela_hero_alt | default('Favoritos da Marcela') | escape }}" data-mf-media data-mf-video-desktop="{{ settings.marcela_hero_video | escape }}" data-mf-video-mobile="{{ settings.marcela_hero_video_mobile | escape }}">
    {% if mf_hero.image or (mf_legacy_image | has_custom_image) %}
        <picture>
            {% if mf_hero_mobile.image %}<source media="(max-width: 767px)" srcset="{{ mf_hero_mobile.image | settings_image_url('original') }}">{% elseif mf_legacy_mobile | has_custom_image %}<source media="(max-width: 767px)" srcset="{{ mf_legacy_mobile | static_url }}">{% endif %}
            <img src="{% if mf_hero.image %}{{ mf_hero.image | settings_image_url('original') }}{% else %}{{ mf_legacy_image | static_url }}{% endif %}" alt="{{ settings.marcela_hero_alt | default('Favoritos da Marcela') | escape }}" fetchpriority="high" decoding="async" width="2400" height="960">
        </picture>
    {% endif %}
    <div class="mf-hero__video" data-mf-video-player></div>
    {% if settings.marcela_hero_link %}<a class="mf-hero__link" href="{{ settings.marcela_hero_link | escape }}" aria-label="{{ settings.marcela_hero_alt | default('Conheça os favoritos da Marcela') | escape }}"></a>{% endif %}
    {% if settings.marcela_hero_video or settings.marcela_hero_video_mobile %}<button class="mf-media-toggle" data-mf-media-toggle type="button" aria-pressed="false">Reproduzir vídeo</button>{% endif %}
</section>
{% endif %}
