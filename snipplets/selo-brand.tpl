{% set selo_product = product_brand | default(false)  %}
{% if settings.selos and selo_product %}
    {% for selo in settings.selos  %}
        {% if selo.link == selo_product %}
            {% if selo.image %}
                <div class="brand-image {% if product_page %} mb-3 {% endif %}">
                    <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ selo.image | static_url | settings_image_url('medium') }}" class="lazyload" alt="{{ selo_product | default('') }}">
                    {% if product_page %}
                        <p>{{ selo.title | default('') }}</p>
                    {% endif %}
                </div>
            {% endif %}
        {% endif %}
    {% endfor %}
{% endif %}
