{% set franqueados_investimento_array =  settings.franqueados_investimento %}

<section class="section-banner-investimento mb-5 py-5">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12 col-md-6">
                <div class="content-image">

                    {% if settings.franqueados_investimento_url_video %}
                        <figure class="image -investimento">
                            <div
                                id="home-investimento-player"
                                class="video-container js-home-investimento-player"
                                data-home-investimento-url="{{ settings.franqueados_investimento_url_video | escape }}"
                            ></div>
                        </figure>
                    {% else %}

                        {% set image_url =  'franqueados_investimento.jpg' | static_url %}
                        
                        <figure class='image -investimento'>
                            <img src="{% if settings.franqueados_investimento %}{{ image_url }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Banner topo">
                        </figure>
                    {% endif %}  
                </div>
            </div>
            <div class="col-12 col-md-6 d-flex align-items-center pt-4 pt-md-0">
                <div class="content-text">
                    <h2 class="title-campaign">{{settings.franqueados_investimento_title}}</h2>
                    <p class="text-campaign">{{settings.franqueados_investimento_text}}</p>

                    <div class="col-12 col-md-9 mt-4">
                        <div class="row">
                            {% for investimento in franqueados_investimento_array %}
                                <div class="col-12 mb-2">
                                    <div class="row content-investimento">
                                        <div class="col-2">
                                            <figure class="image -square">
                                                <img src="{% if investimento.image %}{{ investimento.image | static_url }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Ícone">
                                            </figure>
                                        </div>

                                        <div class="col-9 d-flex align-items-center">
                                            <div class='row'>
                                                <div class="col-12 pl-0 d-flex align-items-center">
                                                    <h3 class="title-investimento mb-0 pr-1">{{investimento.title}}</h3>
                                                    <p class="text-investimento mb-0">{{investimento.description}}</p>
                                                </div>
                                            </div>  
                                        </div>
                                    </div>
                                </div>
                            {% endfor %}
                        </div>
                    </div>

                    <a href="{{settings.franqueados_investimento_url}}" class="btn-campaign btn-primary">
                        {{settings.franqueados_investimento_button}}
                    </a>
                </div>
            </div>
            
        </div>
    </div>
</section>
