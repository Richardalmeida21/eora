<section class="section-banner-marcas mb-5 mt-5 py-5">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12 col-md-5">
                <div class="content-text">
                    <h2 class="title-campaign">{{settings.franqueados_marcas_title}}</h2>
                    <p class="text-campaign">{{settings.franqueados_marcas_text}}</p>
                </div>
            </div>
        </div>
    </div>

    {% set marcas_array = settings.franqueados_marcas  %}

    {% if marcas_array | length > 0 %}
        <div class="content-marcas">
            <div class="swiper-container marcas-swiper">
                <div class="swiper-wrapper">
                {% for marca in marcas_array %}
                    <div class="swiper-slide">
                        <div class="marca">
                            <figure class="image -marca">
                                <img src="{% if marca.image %}{{ marca.image | static_url }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Ícone">
                            </figure>
                        </div>
                    </div>
                {% endfor %}
                </div>
            </div>
        </div>
    {% endif %}
</section>

