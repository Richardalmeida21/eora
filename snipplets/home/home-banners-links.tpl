{% if settings.banner_links_show %}
    {% set padding_bottom = 48 %}
    {% set width_desktop = settings.banner_links_width_desktop  %}
    {% set height_desktop = settings.banner_links_height_desktop  %}

    {% set width_mobile = settings.banner_links_width_mobile %}
    {% set height_mobile = settings.banner_links_height_mobile %}

    {% if width_desktop > 0 and height_desktop > 0 and not mobile %}
        {% set padding_bottom = (height_desktop / width_desktop) * 100 %}
        {% endif %}
        
    {% if width_mobile > 0 and height_mobile > 0 and mobile %}
        {% set padding_bottom = (height_mobile / width_mobile) * 100 %}
    {% endif %}

    {% set slides_banner_links =  settings.banner_links %}

    {% if mobile  %}
        {% set slides_banner_links = settings.banner_links_mobile %}
    {% endif %}
    

    <div class="banner-links container-fluid {% if mobile %} d-md-none {% else %}{% if settings.toggle_banner_links_mobile %} d-none {% endif %} d-md-flex {% endif %}" >
        <div class="swiper js-swiper-banner-links swiper-container">
            <div class="swiper-wrapper">
                {% for slide in slides_banner_links %}
                    <div class="swiper-slide">
                        <a href="{{ slide.link }}" class="banner-links__link" >
                            <figure class="image -custom" style="--padding-bottom-banner-links: {{ padding_bottom }}%">
                                <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w' class='lazyload'/>
                            </figure>
                            <div class="banner-links__content">
                                <h2 class="banner-links__title">{{ slide.title }}</h2>
                                <p class="banner-links__description">{{ slide.description }}</p>
                            </div>
                        </a>
                    </div>
                {% endfor %}
            </div>
        </div>
        
        {# <div class="swiper-button-next swiper-button-next-banner-links">
            <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
        </div>
        <div class="swiper-button-prev swiper-button-prev-banner-links">
            <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
        </div> #}

    </div>
{% endif %}