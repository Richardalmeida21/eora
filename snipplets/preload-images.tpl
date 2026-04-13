{% set has_main_slider = settings.slider and settings.slider is not empty %}
{% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}

{% if has_mobile_slider %}
    {% set slider = settings.slider_mobile %}
{% else %}
    {% set slider = settings.slider %}
{% endif %}

{% if settings.home_order_position_1 == 'slider' and (has_main_slider or has_mobile_slider) %}
    {% for slide in slider %}
        {% if loop.first %}
            <link rel="preload" as="image" href="{{ slide.image | static_url | settings_image_url('1080p') }}" imagesrcset="{{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w" imagesizes="100vw">
        {% endif %}
    {% endfor %}
{% endif %}

{% set has_banner = settings.banner and settings.banner is not empty %}
{% set has_mobile_banners = settings.toggle_banner_mobile and settings.banner_mobile and settings.banner_mobile is not empty %}

{% set banners = has_mobile_banners ? settings.banner_mobile : settings.banner %}

{% if settings.home_order_position_1 == 'categories' and (has_banner or has_mobile_banners) %}
    {% for slide in banners %}
        {% if loop.first %}
            <link rel="preload" as="image" href="{{ slide.image | static_url | settings_image_url('1080p') }}" imagesrcset="{{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w" imagesizes="100vw">
        {% endif %}
    {% endfor %}
{% endif %}

{% set has_promotional_banner = settings.banner_promotional and settings.banner_promotional is not empty %}
{% set has_mobile_promotional_banners = settings.toggle_banner_promotional_mobile and settings.banner_promotional_mobile and settings.banner_promotional_mobile is not empty %}

{% set promotional_banners = has_mobile_promotional_banners ? settings.banner_promotional_mobile : settings.banner_promotional %}

{% if settings.home_order_position_1 == 'promotional' and (has_promotional_banner or has_mobile_promotional_banners) %}
    {% for slide in promotional_banners %}
        {% if loop.first %}
            <link rel="preload" as="image" href="{{ slide.image | static_url | settings_image_url('1080p') }}" imagesrcset="{{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w" imagesizes="100vw">
        {% endif %}
    {% endfor %}
{% endif %}

{% set has_news_banner = settings.banner_news and settings.banner_news is not empty %}
{% set has_mobile_news_banners = settings.toggle_banner_news_mobile and settings.banner_news_mobile and settings.banner_news_mobile is not empty %}

{% set news_banners = has_mobile_news_banners ? settings.banner_news_mobile : settings.banner_news %}

{% if settings.home_order_position_1 == 'news_banners' and (has_news_banner or has_mobile_news_banners) %}
    {% for slide in news_banners %}
        {% if loop.first %}
            <link rel="preload" as="image" href="{{ slide.image | static_url | settings_image_url('1080p') }}" imagesrcset="{{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w" imagesizes="100vw">
        {% endif %}
    {% endfor %}
{% endif %}

{% set has_module_banner = settings.module and settings.module is not empty %}

{% if settings.home_order_position_1 == 'modules' and has_module_banner %}
    {% for slide in settings.module %}
        {% if loop.first %}
            <link rel="preload" as="image" href="{{ slide.image | static_url | settings_image_url('1080p') }}" imagesrcset="{{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w" imagesizes="100vw">
        {% endif %}
    {% endfor %}
{% endif %}

{% set has_video = settings.video_embed %}

{% if settings.home_order_position_1 == 'video' and has_video %}
    {% if "video_image.jpg" | has_custom_image %}
        {% set video_image_src = 'video_image.jpg' | static_url | settings_image_url("1080p") %}
    {% else %}
        <link rel="preconnect" href="https://img.youtube.com/" />
        {% set video_url = settings.video_embed %}
        {% if '/watch?v=' in settings.video_embed %}
            {% set video_format = '/watch?v=' %}
        {% elseif '/youtu.be/' in settings.video_embed %}
            {% set video_format = '/youtu.be/' %}
        {% elseif '/shorts/' in settings.video_embed %}
            {% set video_format = '/shorts/' %}
        {% endif %}
        {% set video_id = (video_url|split(video_format)|last)|split('#')|first|split('?')|first|split('&')|first %}
        {% set video_image_src = 'https://img.youtube.com/vi/' ~ video_id ~ '/maxresdefault.jpg' %}
    {% endif %}
    <link rel="preload" as="image" href="{{ video_image_src }}"{% if "video_image.jpg" | has_custom_image %} imagesrcset="{{ 'video_image.jpg' | static_url | settings_image_url('original') }} 1024w, {{ 'video_image.jpg' | static_url | settings_image_url('1080p') }} 1920w" imagesizes="100vw"{% endif %}>
{% endif %}