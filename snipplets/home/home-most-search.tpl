<div class="container-fluid">
    <div class="most-search">
        <div class="row">
            <div class="col-12">
                <h2 class="section-title-products-home">PROCURE POR:</h2>
            </div>
            <div class="col-12">
                <div class="most-search-content">
                    <ul class="list-search">
                        {% set search_for_list = settings.home_sugestoes_busca | split(',')  %}
                        {% for search_item in search_for_list %}
                            <li class="list-group-item">
                                <a href="/search/?q={{ search_item | url_encode }}" class="search-suggestion-item">
                                    {{ search_item }}
                                </a>
                            </li>
                        {% endfor %}
                    </ul>
                </div>
            </div>
        </div>
    </div>
</div>        