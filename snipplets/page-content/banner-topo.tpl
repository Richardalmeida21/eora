{% if settings[settings_name ~ '_banner_topo'] %}
    <div class="banner-topo-page-content">
        {% if settings[settings_name ~ '_banner_topo_mobile'] and settings[settings_name ~ '_banner_topo_mobile_img'] %}
            <img src="{{ 'images/' ~ settings[settings_name ~ '_banner_topo_img'] | static_url }}" alt="Banner topo" class="d-none d-md-block img-fluid w-100">
            <img src="{{ 'images/' ~ settings[settings_name ~ '_banner_topo_mobile_img'] | static_url }}" alt="Banner topo mobile" class="d-block d-md-none img-fluid w-100">
        {% else %}
            <img src="{{ 'images/' ~ settings[settings_name ~ '_banner_topo_img'] | static_url }}" alt="Banner topo" class="img-fluid w-100">
        {% endif %}
    </div>
{% endif %}