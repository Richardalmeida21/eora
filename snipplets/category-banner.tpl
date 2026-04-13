{% set image_sizes = ['small', 'large', 'huge', 'original', '1080p'] %}
{% set category_images = [] %}
{% set has_category_images = category.images is not empty %}

{% for size in image_sizes %}
    {% if has_category_images %}
        {# Define images for admin categories #}
        {% set category_images = category_images|merge({(size):(category.images | first | category_image_url(size))}) %}
    {% else %}
        {# Define images for general banner #}
        {% set category_images = category_images|merge({(size):('banner-products.jpg' | static_url | settings_image_url(size))}) %}
    {% endif %}
{% endfor %}

{% set category_image_url = 'banner-products.jpg' | static_url %}

{# {% include 'snipplets/breadcrumbs.tpl' with {breadcrumbs_custom_class: '-mobile'} %} #}

<div class="category-section-slider position-relative" data-store="category-banner">
  <section class="category-banner position-relative h-100">
    <img class="category-banner-image lazyautosizes lazyload fade-in w-100" src="{{ category_images['small'] }}" data-srcset="{{ category_images['large'] }} 480w, {{ category_images['huge'] }} 640w, {{ category_images['original'] }} 1024w, {{ category_images['1080p'] }} 1920w" data-sizes="auto" alt="{{ 'Banner de la categoría' | translate }} {{ category.name }}" style="width:100%; height:auto; display:block; margin:0 auto;" />
    <div class="textbanner-text category-banner-info over-image over-image-invert px-0">
        <div class="d-flex align-items-end">
            <div class="container-fluid">
                {% embed "snipplets/page-header.tpl" with {container: false, padding: false, breadcrumbs: false} %}
                    {% block page_header_text %}{{ category.name }}{% endblock page_header_text %}
                {% endembed %}
            </div>
        </div>
    </div>
  </section>
</div>

{# {% include 'snipplets/breadcrumbs.tpl' with {breadcrumbs_custom_class: '-desktop'} %} #}
