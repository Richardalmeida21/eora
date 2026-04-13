{% set form_class = search_modal ? 'w-100' %}
{% set search_suggestions_container_class = search_modal ? 'position-relative mt-2 w-100' %}

{{ component('search/search-form', {
    use_submit_text: true,
    use_delete_btn: false,
    placeholder_text: settings.header_placeholder,
    form_classes: { 
        form: form_class,
        input_group: 'm-0', 
        input: input_class, 
        submit: submit_class,
        search_suggestions_container: search_suggestions_container_class 
    }
    }) 
}}

<div class="search-suggestions-container d-none d-xl-block">
    <div class="search-suggestions">
        <h2 class="search-title">SUGESTÕES DE BUSCA</h2>
        {% set suggestions_list = settings.header_sugestoes_busca | split(',')  %}
        
        <div class="search-suggestions-list">
            {% for suggestion in suggestions_list %}
                <a href="/search/?q={{ suggestion | url_encode }}" class="search-suggestion-item">
                    <p>{{ suggestion }}</p>
                    <svg class="" ><use xlink:href="#chevron-diagonal"/></svg>
                </a>
            {% endfor %}
        </div>
    </div>
</div>

<h2 class="search-title -result-input d-none d-xl-block">PRODUTOS SUGERIDOS</h2>
