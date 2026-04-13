{% if settings.colecoes_kings_show %}
    {% set padding_bottom = 48 %}
    {% set width_desktop = settings.colecoes_kings_width_desktop  %}
    {% set height_desktop = settings.colecoes_kings_height_desktop  %}

    {% set width_mobile = settings.colecoes_kings_width_mobile %}
    {% set height_mobile = settings.colecoes_kings_height_mobile %}

    {% if width_desktop > 0 and height_desktop > 0 and not mobile %}
        {% set padding_bottom = (height_desktop / width_desktop) * 100 %}
        {% endif %}
        
    {% if width_mobile > 0 and height_mobile > 0 and mobile %}
        {% set padding_bottom = (height_mobile / width_mobile) * 100 %}
    {% endif %}

    {% set slides_colecoes_kings =  settings.colecoes_kings %}

    {% if mobile  %}
        {% set slides_colecoes_kings = settings.colecoes_kings_mobile %}
    {% endif %}
    
    {% set section_title =  settings.colecoes_kings_title %}

    <div class="banner-colecoes-kings container-fluid {% if mobile %} d-md-none {% else %}{% if settings.toggle_colecoes_kings_mobile %} d-none {% endif %} d-md-flex {% endif %}" >
        {% if section_title %}
            <h2 class="section-title section-title-products-home">{{ section_title }}</h2>
        {% endif %}
        <div class="swiper js-swiper-colecoes-kings swiper-container">
            <div class="swiper-wrapper">
                {% for slide in slides_colecoes_kings %}
                    <div class="swiper-slide">
                        <a href="{{ slide.link }}" class="banner-colecoes-kings__link" >
                            <figure class="image -custom" style="--padding-bottom-colecoes-kings: {{ padding_bottom }}%">
                                <img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ slide.image | static_url | settings_image_url('large') }} 480w, {{ slide.image | static_url | settings_image_url('huge') }} 640w, {{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w' class='lazyload'/>
                            </figure>
                            <div class="banner-colecoes-kings__content">
                                <h2 class="banner-colecoes-kings__title">{{ slide.title }}</h2>
                            </div>
                        </a>
                    </div>
                {% endfor %}
            </div>
        </div>
        <div class="swiper-button-next swiper-button-next-colecoes-kings">
            <svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
        </div>
        <div class="swiper-button-prev swiper-button-prev-colecoes-kings">
            <svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
        </div>
    </div>
{% endif %}