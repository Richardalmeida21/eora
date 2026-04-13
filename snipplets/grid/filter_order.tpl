{# --------------------------------------------------------------------
    Componente: Ordenação de produtos  (NuvemShop / Twig)
    -------------------------------------------------------------------- #}

{% set sort_options = {
    'best-selling'       : 'MAIS VENDIDOS',
    'price-descending'   : 'PREÇO: MAIOR',
    'price-ascending'    : 'PREÇO: MENOR',
    'alpha-ascending'    : 'A - Z',
    'alpha-descending'   : 'Z - A',
    'created-descending' : 'MAIS NOVOS',
    'created-ascending'  : 'MAIS ANTIGOS'
} %}

{% set current_sort  = params.sort_by|default('best-selling') %}
{% set current_label = sort_options[current_sort] %}

<div class="sort-dropdown js-sort d-flex align-items-center justify-content-center">
    <button type="button" class="sort-dropdown__toggle" aria-haspopup="listbox" aria-expanded="false">
        <span class="sort-dropdown__label">ORDENAR&nbsp;POR:</span>
        <span class="sort-dropdown__value js-sort-label">{{ current_label }}</span>
        <svg class="sort-dropdown__arrow js-arrow" width="14" height="14" viewBox="0 0 20 20" aria-hidden="true">
            <path d="M5.23 7.21a.75.75 0 0 1 1.06.02L10 10.94l3.71-3.71a.75.75 0 1 1 1.06 1.06l-4.24 4.24a.75.75 0 0 1-1.06 0L5.21 8.29a.75.75 0 0 1 .02-1.08z"/>
        </svg>
    </button>

    <ul class="sort-dropdown__menu js-menu" role="listbox" tabindex="-1">
        {% for key, label in sort_options %}
            <li role="option">
                <button type="button"
                        data-sort="{{ key }}"
                        class="sort-dropdown__option{% if key == current_sort %} is-active{% endif %}">
                {{ label }}
                </button>
            </li>
        {% endfor %}
    </ul>
</div>