<section class="section-duvidas-frequentes mb-5 py-5">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12 mb-3">
                <div class="content-text">
                    <h2>{{settings.franqueados_duvidas_title}}</h2>
                    <p>{{settings.franqueados_duvidas_text}}</p>
                </div>
            </div>

            {% set duvidas_array = settings.franqueados_duvidas  %}

            {% if duvidas_array | length > 0 %}
                {% for duvida in duvidas_array %}                    
                    <div class="col-12 col-md-6">
                        <div class="duvida">
                            <div class="row">
                                <div class="col-1">
                                    <figure class="image -square">
                                        <img src="{% if duvida.image %}{{ duvida.image | static_url }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Ícone">
                                    </figure>
                                </div>

                                <div class="col-10 pl-1 d-flex align-items-center">
                                    <h2 class="title-duvida mb-0">{{duvida.title}}</h2>
                                </div>

                                <div class="col-12 pt-2">
                                    <p class="text-duvida mb-0">{{duvida.description}}</p>
                                </div>
                            </div>
                        </div>
                    </div>
                {% endfor %}
            {% endif %}
            </div>
        </div>
    </div>
</section>