{% if settings.pagination == 'infinite' %}
	{% paginate by 12 %}
{% else %}
	{% paginate by 48 %}
{% endif %}

{% embed "snipplets/page-header.tpl" with { breadcrumbs: false, container_fluid: true } %}
	{% block page_header_text %}
		{% if products %}
			{{ 'Resultados de búsqueda' | translate }}
		{% else %}
			{{ "No encontramos nada para" | translate }}<span class="ml-2">"{{ query }}"</span>
		{% endif %}
	{% endblock page_header_text %}
{% endembed %}

<section class="category-body overflow-none">
	<div class="container-fluid mb-5">
		{% if products %}
			<h2 class="font-body font-family-body mb-4 pb-2 font-weight-normal">
				{{ "Mostrando los resultados para" | translate }}<span class="ml-2 font-weight-bold">"{{ query }}"</span>
			</h2>
			<div class="js-product-table row row-grid">
				{% include 'snipplets/product_grid.tpl' %}
			</div>

			{% if settings.pagination == 'infinite' %}
				{% set pagination_type_val = true %}
			{% else %}
				{% set pagination_type_val = false %}
			{% endif %}
			{% include "snipplets/grid/pagination.tpl" with {infinite_scroll: pagination_type_val} %}
		{% else %}
			<div class="my-4">
				{{ "Escribilo de otra forma y volvé a intentar." | translate }}
			</div>
		{% endif %}
	</div>
</section>