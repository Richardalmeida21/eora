{% set se_mobile_image = image_mobile | default('') %}
{% set se_image_sizes = image_sizes | default('(max-width: 767px) calc((100vw - 36px) / 1.5), (max-width: 1600px) calc((90vw - 48px) / 3), calc((1600px - 10vw - 48px) / 3)') %}
<picture>
    {% if se_mobile_image %}
        <source media="(max-width: 767px)" srcset="{{ se_mobile_image | static_url | settings_image_url('large') }} 480w, {{ se_mobile_image | static_url | settings_image_url('huge') }} 640w, {{ se_mobile_image | static_url | settings_image_url('original') }} 1024w, {{ se_mobile_image | static_url | settings_image_url('xlarge') }} 1400w, {{ se_mobile_image | static_url | settings_image_url('1080p') }} 1920w" sizes="{{ se_image_sizes }}" width="1600" height="2000">
    {% endif %}
    <img src="{{ image | static_url | settings_image_url('1080p') }}" srcset="{{ image | static_url | settings_image_url('large') }} 480w, {{ image | static_url | settings_image_url('huge') }} 640w, {{ image | static_url | settings_image_url('original') }} 1024w, {{ image | static_url | settings_image_url('xlarge') }} 1400w, {{ image | static_url | settings_image_url('1080p') }} 1920w" sizes="{{ se_image_sizes }}" alt="{{ image_alt | default('EORA') | escape }}" width="1920" height="2400" loading="lazy" decoding="async">
</picture>
