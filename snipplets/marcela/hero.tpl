{% set mf_hero = settings.marcela_hero_image | first %}
{% set mf_hero_mobile = settings.marcela_hero_image_mobile | first %}
{% set mf_has_hero = mf_hero.image or mf_hero_mobile.image or settings.marcela_hero_video or settings.marcela_hero_video_mobile %}
{% if mf_has_hero and (settings.marcela_hero_enabled is not defined or settings.marcela_hero_enabled) %}
<section class="mf-hero" aria-label="{{ settings.marcela_hero_alt | default('Favoritos da Marcela') | escape }}" data-mf-media data-mf-video-desktop="{{ settings.marcela_hero_video | escape }}" data-mf-video-mobile="{{ settings.marcela_hero_video_mobile | escape }}" data-mf-video-ratio-desktop="{{ settings.marcela_hero_video_ratio_desktop | escape }}" data-mf-video-ratio-mobile="{{ settings.marcela_hero_video_ratio_mobile | escape }}">
    {% if mf_hero.image or mf_hero_mobile.image %}
        <picture>
            {% if mf_hero_mobile.image %}<source media="(max-width: 767px)" srcset="{{ mf_hero_mobile.image | static_url | settings_image_url('large') }} 480w, {{ mf_hero_mobile.image | static_url | settings_image_url('huge') }} 640w, {{ mf_hero_mobile.image | static_url | settings_image_url('original') }} 1024w, {{ mf_hero_mobile.image | static_url | settings_image_url('xlarge') }} 1400w, {{ mf_hero_mobile.image | static_url | settings_image_url('1080p') }} 1920w" sizes="100vw">{% endif %}
            <img src="{{ (mf_hero.image | default(mf_hero_mobile.image)) | static_url | settings_image_url('original') }}" srcset="{{ (mf_hero.image | default(mf_hero_mobile.image)) | static_url | settings_image_url('large') }} 480w, {{ (mf_hero.image | default(mf_hero_mobile.image)) | static_url | settings_image_url('huge') }} 640w, {{ (mf_hero.image | default(mf_hero_mobile.image)) | static_url | settings_image_url('original') }} 1024w, {{ (mf_hero.image | default(mf_hero_mobile.image)) | static_url | settings_image_url('xlarge') }} 1400w, {{ (mf_hero.image | default(mf_hero_mobile.image)) | static_url | settings_image_url('1080p') }} 1920w" sizes="100vw" alt="{{ settings.marcela_hero_alt | default('Favoritos da Marcela') | escape }}" fetchpriority="high" decoding="async" width="2400" height="800">
        </picture>
    {% endif %}
    <div class="mf-hero__video" data-mf-video-player></div>
    {% if settings.marcela_hero_video or settings.marcela_hero_video_mobile %}<button class="mf-hero__toggle" type="button" data-mf-media-toggle hidden>Reproduzir vídeo</button>{% endif %}
    {% if settings.marcela_hero_link %}<a class="mf-hero__link" href="{{ settings.marcela_hero_link | escape }}" aria-label="{{ settings.marcela_hero_alt | default('Conheça os favoritos da Marcela') | escape }}"></a>{% endif %}
</section>
{% if settings.marcela_hero_video or settings.marcela_hero_video_mobile %}<script src="{{ 'js/marcela-hero.js' | static_url }}?v=20261125-2" async></script>{% endif %}
{% endif %}
