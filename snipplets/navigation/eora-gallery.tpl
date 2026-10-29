{% if images | length %}
    <div class="eora-menu__gallery">
        {% for image in images | slice(0, 4) %}
            <a class="eora-menu__card" href="{{ image.link | default(image_fallback_url) | setting_url }}">
                {% if image.image starts with 'menu-preserved-' %}
                    <img src="{{ image.image | static_url }}" width="640" height="800" loading="lazy" alt="{{ image.title | default(image_fallback_title) | escape }}" />
                {% else %}
                    <img src="{{ image.image | static_url | settings_image_url('large') }}" srcset="{{ image.image | static_url | settings_image_url('large') }} 480w, {{ image.image | static_url | settings_image_url('huge') }} 640w, {{ image.image | static_url | settings_image_url('1080p') }} 1920w" sizes="{{ mode == 'desktop' ? '(min-width: 1200px) 16vw, 45vw' : '45vw' }}" width="640" height="800" loading="lazy" alt="{{ image.title | default(image_fallback_title) | escape }}" />
                {% endif %}
                <span>{{ image.title | default(image_fallback_title) }}</span>
            </a>
        {% endfor %}
    </div>
{% endif %}
