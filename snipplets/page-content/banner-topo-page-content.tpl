{% set page_banner_topo = attribute(settings,"#{settings_name}_banner_topo") %}
{% set page_banner_topo_img = settings_name ~ '_banner_topo_img.jpg' %}
{% set page_banner_topo_mobile = attribute(settings,"#{settings_name}_banner_topo_mobile") %}
{% set page_banner_topo_mobile_img = settings_name ~ '_banner_topo_mobile_img.jpg' %}

{% if page_banner_topo %}
    <section class="section-banner-topo pb-5 mb-3 pt-2">
        <div class="container-fluid desktop px-3 {% if page_banner_topo_mobile %} d-none d-md-block {% endif %}">
            <div class="row">
                <div class="col-12 px-0">
                    {% set image_url = page_banner_topo_img | static_url %}

                    <figure class='image -topo'>
                        <img src="{% if page_banner_topo %}{{ image_url }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Banner topo">
                    </figure>
                </div>
            </div>
        </div>
        {% if page_banner_topo_mobile %}
            <div class="container-fluid mobile d-block d-md-none">
                <div class="row">
                    <div class="col-12">
                        {% set image_url_mobile = page_banner_topo_mobile_img | static_url %}
                        
                        <figure class='image -topo'>
                            <img src="{% if page_banner_topo %}{{ image_url_mobile }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Banner topo">
                        </figure>
                    </div>
                </div>
            </div>
        {% endif %}
    </section>
{% endif %}
