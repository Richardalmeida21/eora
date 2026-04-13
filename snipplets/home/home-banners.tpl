{% set has_banner = has_banner | default(false) %}
{% set has_mobile_banners = settings.toggle_banner_mobile and settings.banner_mobile and settings.banner_mobile is not empty %}

{% if has_banner %}
    {% set data_store_name = 'home-banner-categories' %}
    {% set section_without_margins = settings.banner_without_margins ? 'section-home-color p-0' %}

    <section class="section-home section-banners-home position-relative overflow-none {{ section_without_margins }}" data-store="{{ data_store_name }}">
        {% include 'snipplets/home/home-banners-grid.tpl' with {'banner': true} %}
        {% if has_mobile_banners %}
            {% include 'snipplets/home/home-banners-grid.tpl' with {'banner': true, mobile: true} %}
        {% endif %}
    </section>
{% endif %}
