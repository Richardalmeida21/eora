{% if sections.best_sellers.products %}
	{% if settings.main_product_type == 'random' %}
		{% set product_type = sections.best_sellers.products | shuffle | take(1) %}
	{% else %}
		{% set product_type = sections.best_sellers.products | take(1) %}
	{% endif %}

	{% for product in product_type %}
		<section id="single-product" class="js-product-container section-home" data-variants="{{product.variants_object | json_encode }}" data-store="home-product-main">
			<div class="container-fluid">
				<div class="row justify-content-md-center">
					<div class="col-md-auto product-image-column">
						{% include 'snipplets/product/product-image.tpl' with { home_main_product: true } %}
					</div>
					<div class="col-md-auto product-info-column" data-store="product-info-{{ product.id }}">
						{% include 'snipplets/product/product-form.tpl' with { home_main_product: true } %}
					</div>
				</div>
			</div>
		</section>
	{% endfor %}
{% endif %}
