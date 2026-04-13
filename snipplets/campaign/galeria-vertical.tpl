{% set vertical_array =  settings.franqueados_galeria_vertical %}

{% if vertical_array | length > 0 %}
    <section class="section-banner-galeria-vertical mb-5 py-5">
        <div class="container-fluid">
            <div class="row d-flex align-items-center">
                <div class="col-12 col-md-6">
                    <div class="content-gallery-vertical">
                        <!-- Swiper -->
                        <div class="swiper-container vertical-swiper">
                            <div class="swiper-wrapper">
                            {% for vertical in vertical_array %}
                                <div class="swiper-slide">
                                    <div class="row content-vertical">
                                        <div class="col-12">
                                            <figure class="image -vertical">
                                                <img src="{% if vertical.image %}{{ vertical.image | static_url }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Ícone">
                                            </figure>
                                        </div>
                                        <div class="col-12">
                                            <h3 class="title-vertical mt-4 mb-0">{{ vertical.title | raw  }}</h3>
                                        </div>
                                    </div>
                                </div>
                            {% endfor %}
                            </div>
                        </div>
                    </div>
                </div>

                <div class="col-12 col-md-6 mt-5 mt-md-0">
                    <div class="content-text">
                        <h2 class="title-campaign">{{settings.franqueados_galeria_vertical_title}}</h2>
                        <p class="text-campaign">{{settings.franqueados_galeria_vertical_text}}</p>
                        
                        <div class="itens-detalhes row px-3">
                            {% for item in settings.franqueados_galeria_vertical_detalhes %}
                                <div class="col-12 col-md-6 px-0">
                                    <div class="item-detalhe">
                                        <div class="row">
                                            <div class="col-3">
                                                <figure class="image -square">
                                                    <img src="{% if item.image %}{{ item.image | static_url }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Ícone">
                                                </figure>
                                            </div>

                                            <div class="col-9 pl-1">
                                                <h2 class="link-detalhe mb-1">{{item.link}}</h2>
                                            </div>

                                            <div class="col-12 pt-2">
                                                <h2 class="title-detalhe mb-0">{{item.title}}</h2>
                                            </div>

                                            <div class="col-12">
                                                <p class="text-detalhe mb-0">{{item.description}}</p>
                                            </div>
                                        </div>
                                    </div>
                                </div>
                            {% endfor %}
                        </div>

                        <a href="{{ settings.franqueados_galeria_vertical_url }}" class="btn-campaign btn-primary mt-4">
                            {{ settings.franqueados_galeria_vertical_button }}
                        </a>
                    </div>
                </div>
            </div>
        </div>
    </section>
{% endif %}
