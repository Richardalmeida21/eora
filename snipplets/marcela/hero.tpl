{% set mf_hero = settings.marcela_hero_image | first %}
{% set mf_hero_mobile = settings.marcela_hero_image_mobile | first %}
{% set mf_has_hero = mf_hero.image or settings.marcela_hero_video or settings.marcela_hero_video_mobile %}
{% if mf_has_hero and (settings.marcela_hero_enabled is not defined or settings.marcela_hero_enabled) %}
<section class="mf-hero" aria-label="{{ settings.marcela_hero_alt | default('Favoritos da Marcela') | escape }}" data-mf-media data-mf-video-desktop="{{ settings.marcela_hero_video | escape }}" data-mf-video-mobile="{{ settings.marcela_hero_video_mobile | escape }}" data-mf-video-ratio-desktop="{{ settings.marcela_hero_video_ratio_desktop | escape }}" data-mf-video-ratio-mobile="{{ settings.marcela_hero_video_ratio_mobile | escape }}">
    {% if mf_hero.image %}
        <picture>
            {% if mf_hero_mobile.image %}<source media="(max-width: 767px)" srcset="{{ mf_hero_mobile.image | static_url | settings_image_url('original') }}">{% endif %}
            <img src="{{ mf_hero.image | static_url | settings_image_url('original') }}" alt="{{ settings.marcela_hero_alt | default('Favoritos da Marcela') | escape }}" fetchpriority="high" decoding="async" width="2400" height="800">
        </picture>
    {% endif %}
    <div class="mf-hero__video" data-mf-video-player></div>
    {% if settings.marcela_hero_link %}<a class="mf-hero__link" href="{{ settings.marcela_hero_link | escape }}" aria-label="{{ settings.marcela_hero_alt | default('Conheça os favoritos da Marcela') | escape }}"></a>{% endif %}
</section>
{% endif %}
