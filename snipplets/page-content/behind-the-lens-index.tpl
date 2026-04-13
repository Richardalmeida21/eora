
{% include 'snipplets/page-content/infinite-carousel-shared.tpl' %}

{% include 'snipplets/page-content/video.tpl' with {settings_name: current_settings_name} %}
{% include 'snipplets/page-content/text.tpl' with {settings_name: current_settings_name} %}

{% include 'snipplets/page-content/banner-topo-page-content.tpl' with {settings_name: current_settings_name} %}
{% include 'snipplets/page-content/text.tpl' with {settings_name: current_settings_name ~ '_02' } %}

{% include 'snipplets/page-content/carrossel-banners.tpl' with {settings_name: current_settings_name } %}
{% include 'snipplets/page-content/banners-inferior-01.tpl' with {settings_name: current_settings_name} %}

{# {% include 'snipplets/page-content/carrossel-banners.tpl' with {settings_name: current_settings_name ~ '_02' } %} #}

{% include 'snipplets/page-content/carrossel-banners-02.tpl' with {settings_name: current_settings_name } %}
{% include 'snipplets/page-content/banners-inferior-02.tpl' with {settings_name: current_settings_name} %}

{# {% include 'snipplets/page-content/carrossel-banners.tpl' with {settings_name: current_settings_name ~ '_03' } %} #}

{% include 'snipplets/page-content/carrossel-banners-03.tpl' with {settings_name: current_settings_name } %}
{% include 'snipplets/page-content/banners-inferior-03.tpl' with {settings_name: current_settings_name} %}
