{% set has_featured = has_featured | default(false) and sections.best_sellers.products %}
{% set has_new = has_new | default(false) and sections.favorites.products %}
{% set has_sale = has_sale | default(false) and sections.picks_kings.products %}

{% if has_featured %}
	{# Estrutura idêntica ao bloco de novidades #}
	{% set data_store_name = 'favorites' %}
	{% set section_classes = settings.new_product_colors ? 'section-new-products-home section-new-products-home-colors section-home-color' : 'section-new-products-home' %}
	{% set section_columns_desktop = settings.new_products_desktop %}
	{% set section_columns_mobile = settings.new_products_mobile %}
	{% set section_slider = settings.new_products_format_mobile == 'slider' or settings.new_products_format_desktop == 'slider' %}
	{% set section_slider_both = settings.new_products_format_mobile == 'slider' and settings.new_products_format_desktop == 'slider' %}
	{% set section_slider_mobile_only = settings.new_products_format_mobile == 'slider' and settings.new_products_format_desktop == 'grid' %}
	{% set section_slider_desktop_only = settings.new_products_format_desktop == 'slider' and settings.new_products_format_mobile == 'grid' %}
	{% set section_slider_id = 'new' %}
	{% set section_title = settings.new_products_title %}
{% elseif has_new %}
	{% set data_store_name = 'favorites' %}
	{% set section_classes = settings.new_product_colors ? 'section-new-products-home section-new-products-home-colors section-home-color' : 'section-new-products-home' %}
{% elseif has_sale %}
	{% set data_store_name = 'picks_kings' %}
	{% set section_classes = settings.sale_product_colors ? 'section-sale-products-home section-sale-products-home-colors section-home-color' : 'section-sale-products-home' %}

{% elseif has_product_showcase %}
	{% set data_store_name = 'showcase_product' %}
	{% set name_setting = 'showcase' %}

{% elseif has_product_showcase_02 %}
	{% set data_store_name = 'showcase_product_02' %}
	{% set name_setting = 'showcase_02' %}

{% elseif has_product_showcase_03 %}
	{% set data_store_name = 'showcase_product_03' %}
	{% set name_setting = 'showcase_03' %}

{% elseif has_new %}
	{% set data_store_name = 'favorites' %}
	{% set section_classes = settings.new_product_colors ? 'section-new-products-home section-new-products-home-colors section-home-color' : 'section-new-products-home' %}
{% elseif has_new %}
	{% set data_store_name = 'favorites' %}
	{% set section_classes = settings.new_product_colors ? 'section-new-products-home section-new-products-home-colors section-home-color' : 'section-new-products-home' %}
{% endif %}

{% if has_featured or has_new or has_sale or has_product_showcase or has_product_showcase_02 or has_product_showcase_03 %}
	<section class="section-home section-featured-home {{ section_classes }}" data-store="home-products-{{ data_store_name }}">
		{% if has_featured %}
			{% if settings.best_sellers_style %}
				{% include 'snipplets/home/home-best-sellers.tpl' with {'featured_products': true} %}
			{% else %}
				{% include 'snipplets/home/home-featured-grid.tpl' with {'featured_products': true} %}
			{% endif %}
		{% endif %}
		{% if has_new %}
			{% include 'snipplets/home/home-featured-grid.tpl' with {'new_products': true} %}
		{% endif %}
		{% if has_product_showcase %}
			{% include 'snipplets/home/home-featured-grid.tpl' with {'product_showcase': true, settings_name: name_setting} %}
		{% endif %}
		{% if has_product_showcase_02 %}
			{% include 'snipplets/home/home-featured-grid.tpl' with {'product_showcase_02': true, settings_name: name_setting} %}
		{% endif %}
		{% if has_product_showcase_03 %}
			{% include 'snipplets/home/home-featured-grid.tpl' with {'product_showcase_03': true, settings_name: name_setting} %}
		{% endif %}
		{% if has_sale %}
			{% include 'snipplets/home/home-featured-grid.tpl' with {'sale_products': true} %}
		{% endif %}
	</section>
{% endif %}
