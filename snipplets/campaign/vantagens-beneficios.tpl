{% set vantagens_beneficios_array =  settings.franqueados_beneficios %}

{% if vantagens_beneficios_array | length > 0 %}
    <section class="section-banner-vantagens-beneficios pb-5 mb-3 mt-2">
        <div class="container-fluid">
            <div class="row">
                <div class="col-12">
                    <h2 class="title-campaign">{{settings.franqueados_beneficios_title}}</h2>
                </div>
                <div class="col-12 col-md-6">
                    <div class="content-text">
                        <p class="text-campaign">
                            {{settings.franqueados_beneficios_text}}
                        </p>
                    </div>
                </div>

                <div class="col-12 d-none d-md-block mt-4">
                    <div class="row">
                        {% for vantagem in vantagens_beneficios_array %}
                            <div class="col-3 pb-2">
                                <div class="row content-vantagem">
                                    <div class="col-2 pr-0">
                                        <figure class="image -square">
                                            <img src="{% if vantagem.image %}{{ vantagem.image | static_url }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Ícone">
                                        </figure>
                                    </div>

                                    <div class="col-9">
                                        <div class='row'>
                                            <div class="col-12">
                                                <h3 class="title-vantagem mb-1">{{vantagem.title}}</h3>
                                            </div>
                                            <div class="col-12">
                                                <p class="text-vantagem">
                                                    {{vantagem.description}}
                                                </p>
                                            </div>
                                        </div>  
                                    </div>
                                </div>
                            </div>
                        {% endfor %}
                    </div>
                </div>
                <div class="col-12 d-block d-md-none mt-4">
                    <!-- Swiper -->
                    <div class="swiper-container vantagens-swiper">
                        <div class="swiper-wrapper">
                        {% for vantagem in vantagens_beneficios_array %}
                            <div class="swiper-slide">
                            <div class="row content-vantagem">
                                <div class="col-2 pr-0">
                                    <figure class="image -square">
                                        <img src="{% if vantagem.image %}{{ vantagem.image | static_url }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Ícone">
                                    </figure>
                                </div>
                                <div class="col-10">
                                    <h3 class="title-vantagem mb-1">{{ vantagem.title }}</h3>
                                    <p class="text-vantagem">{{ vantagem.description }}</p>
                                </div>
                            </div>
                            </div>
                        {% endfor %}
                        </div>
                        <!-- Pagination (bolinhas) -->
                        <div class="swiper-pagination"></div>
                    </div>
                </div>
            </div>
        </div>
    </section>
{% endif %}


