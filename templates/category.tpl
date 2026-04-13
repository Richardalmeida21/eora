{% set has_filters_available = products and has_filters_enabled and (filter_categories is not empty or product_filters is not empty) %}

{# Only remove this if you want to take away the theme onboarding advices #}
{% set show_help = not has_products %}

{% if settings.pagination == 'infinite' %}
	{% paginate by 12 %}
{% else %}
	{% paginate by 48 %}
{% endif %}

{% if not show_help %}

{% set category_banner = (category.images is not empty) or ("banner-products.jpg" | has_custom_image) %}
{% set has_category_description_without_banner = not category_banner and category.description %}

{% set is_gift_guide = 'gift-guide' in category.url or 'presenteaveis-eora' in category.url %}

{% if is_gift_guide %}
	{% include 'snipplets/gift-guide-banners.tpl' %}
{% elseif category_banner %}
	{% include 'snipplets/category-banner.tpl' %}
{% endif %}

{# Mensagens Personalizadas usando Descrição dos Banners (Versão Segura sem break) #}
{% if is_gift_guide %}
	{% set current_url = category.url %}
	{% set found_message = '' %}

	{# Mapear a descrição do banner correspondente #}
	{% for banner in settings.gift_guide_banners %}
		{% if not found_message and banner.link and banner.link in current_url and banner.description %}
			{% set found_message = banner.description %}
		{% endif %}
	{% endfor %}

	{% if found_message %}
		<section class="gift-category-message my-4 my-md-5">
			<div class="container">
				<div class="row justify-content-center">
					<div class="col-md-10 col-lg-8 text-center">
						<h2 class="h3 mb-3" style="font-family: serif; letter-spacing: 1px; font-weight: 400;">{{ found_message }}</h2>
					</div>
				</div>
			</div>
		</section>
	{% endif %}
{% endif %}

{% if products or has_filters_available %}

<style>
	.floating-filter-btn {
		position: fixed;
		left: 50%;
		bottom: 32px;
		transform: translateX(-50%);
		z-index: 1050;
		background: #000;
		color: #fff;
		border-radius: 4px;
		border: none;
		outline: none;
		min-width: 140px;
		min-height: 48px;
		padding: 0 24px;
		display: flex;
		align-items: center;
		justify-content: center;
		font-family: inherit;
		font-size: 1.1rem;
		font-weight: 400;
		letter-spacing: 0.04em;
		text-transform: uppercase;
		box-shadow: none;
		gap: 12px;
		cursor: pointer;
		transition: background 0.2s;
	}
	.floating-filter-btn:hover {
		background: #222;
	}
	.floating-filter-btn .filter-text {
		color: #fff;
		font-weight: 400;
		font-size: 1.1rem;
		letter-spacing: 0.04em;
		text-transform: uppercase;
		margin-right: 10px;
		display: flex;
		align-items: center;
	}
	.floating-filter-btn .filter-icon {
		display: flex;
		align-items: center;
		margin-left: 0;
	}
	@media (min-width: 768px) {
		.floating-filter-btn {
			bottom: 40px;
			min-width: 160px;
		}
	}

	.notification-cart-reopen-container  {
		bottom: 100px !important;
	}
</style>

<section class="js-category-controls category-controls visible-when-content-ready mt-4 mx-3 mx-md-5 d-flex justify-content-between {% if not settings.filters_desktop_modal %}d-md-none{% endif %}">
	<button href="#" class="js-modal-open floating-filter-btn" data-toggle="#nav-filters" data-component="filter-button">
		<span class="filter-text">FILTROS</span>
		<span class="filter-icon">
			<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
				<path d="M0 14.875C0 14.418 0.351562 14.0312 0.84375 14.0312H2.91797C3.26953 12.9062 4.35938 12.0625 5.625 12.0625C6.85547 12.0625 7.94531 12.9062 8.29688 14.0312H17.1562C17.6133 14.0312 18 14.418 18 14.875C18 15.3672 17.6133 15.7188 17.1562 15.7188H8.29688C7.94531 16.8789 6.85547 17.6875 5.625 17.6875C4.35938 17.6875 3.26953 16.8789 2.91797 15.7188H0.84375C0.351562 15.7188 0 15.3672 0 14.875ZM4.5 14.875C4.5 15.5078 4.99219 16 5.625 16C6.22266 16 6.75 15.5078 6.75 14.875C6.75 14.2773 6.22266 13.75 5.625 13.75C4.99219 13.75 4.5 14.2773 4.5 14.875ZM11.25 9.25C11.25 9.88281 11.7422 10.375 12.375 10.375C12.9727 10.375 13.5 9.88281 13.5 9.25C13.5 8.65234 12.9727 8.125 12.375 8.125C11.7422 8.125 11.25 8.65234 11.25 9.25ZM12.375 6.4375C13.6055 6.4375 14.6953 7.28125 15.0469 8.40625H17.1562C17.6133 8.40625 18 8.79297 18 9.25C18 9.74219 17.6133 10.0938 17.1562 10.0938H15.0469C14.6953 11.2539 13.6055 12.0625 12.375 12.0625C11.1094 12.0625 10.0195 11.2539 9.66797 10.0938H0.84375C0.351562 10.0938 0 9.74219 0 9.25C0 8.79297 0.351562 8.40625 0.84375 8.40625H9.66797C10.0195 7.28125 11.1094 6.4375 12.375 6.4375ZM6.75 4.75C7.34766 4.75 7.875 4.25781 7.875 3.625C7.875 3.02734 7.34766 2.5 6.75 2.5C6.11719 2.5 5.625 3.02734 5.625 3.625C5.625 4.25781 6.11719 4.75 6.75 4.75ZM9.42188 2.78125H17.1562C17.6133 2.78125 18 3.16797 18 3.625C18 4.11719 17.6133 4.46875 17.1562 4.46875H9.42188C9.07031 5.62891 7.98047 6.4375 6.75 6.4375C5.48438 6.4375 4.39453 5.62891 4.04297 4.46875H0.84375C0.351562 4.46875 0 4.11719 0 3.625C0 3.16797 0.351562 2.78125 0.84375 2.78125H4.04297C4.39453 1.65625 5.48438 0.8125 6.75 0.8125C7.98047 0.8125 9.07031 1.65625 9.42188 2.78125Z" fill="white"/>
			</svg>
		</span>
	</button>

<span class="category-title" style="color: #000; font-size: 20px; font-style: normal; font-weight: 700; line-height: normal; letter-spacing: 1px; text-transform: uppercase;">
	{% set menu_title = '' %}
	{% if megamenu is defined and megamenu|length > 0 %}
		{% for item in megamenu %}
			{% if item.children is defined and item.children|length > 0 %}
				{% for child in item.children %}
					{% if 'shop' in child.name|lower and 'all' in child.name|lower %}
						{% set menu_title = child.name %}
					{% endif %}
				{% endfor %}
			{% endif %}
		{% endfor %}
		{{ menu_title | default('Shop all') }}
	{% else %}
		{{ 'Shop all' }}
	{% endif %}
</span>

	{% embed "snipplets/modal.tpl" with{modal_id: 'nav-filters',modal_header_class: 'border-bottom-filter', modal_class: 'filters modal-docked-md', modal_body_class: 'h-100 p-0', modal_position: 'left', modal_position_desktop: left, modal_transition: 'slide', modal_header_title: true, modal_width: 'docked-md' } %}
		{% block modal_head %}
			<div class="d-flex align-items-center py-3 border-bottom ">
				<svg width="18" height="18" viewBox="0 0 18 18" fill="none" xmlns="http://www.w3.org/2000/svg">
					<path d="M0 14.875C0 14.418 0.351562 14.0312 0.84375 14.0312H2.91797C3.26953 12.9062 4.35938 12.0625 5.625 12.0625C6.85547 12.0625 7.94531 12.9062 8.29688 14.0312H17.1562C17.6133 14.0312 18 14.418 18 14.875C18 15.3672 17.6133 15.7188 17.1562 15.7188H8.29688C7.94531 16.8789 6.85547 17.6875 5.625 17.6875C4.35938 17.6875 3.26953 16.8789 2.91797 15.7188H0.84375C0.351562 15.7188 0 15.3672 0 14.875ZM4.5 14.875C4.5 15.5078 4.99219 16 5.625 16C6.22266 16 6.75 15.5078 6.75 14.875C6.75 14.2773 6.22266 13.75 5.625 13.75C4.99219 13.75 4.5 14.2773 4.5 14.875ZM11.25 9.25C11.25 9.88281 11.7422 10.375 12.375 10.375C12.9727 10.375 13.5 9.88281 13.5 9.25C13.5 8.65234 12.9727 8.125 12.375 8.125C11.7422 8.125 11.25 8.65234 11.25 9.25ZM12.375 6.4375C13.6055 6.4375 14.6953 7.28125 15.0469 8.40625H17.1562C17.6133 8.40625 18 8.79297 18 9.25C18 9.74219 17.6133 10.0938 17.1562 10.0938H15.0469C14.6953 11.2539 13.6055 12.0625 12.375 12.0625C11.1094 12.0625 10.0195 11.2539 9.66797 10.0938H0.84375C0.351562 10.0938 0 9.74219 0 9.25C0 8.79297 0.351562 8.40625 0.84375 8.40625H9.66797C10.0195 7.28125 11.1094 6.4375 12.375 6.4375ZM6.75 4.75C7.34766 4.75 7.875 4.25781 7.875 3.625C7.875 3.02734 7.34766 2.5 6.75 2.5C6.11719 2.5 5.625 3.02734 5.625 3.625C5.625 4.25781 6.11719 4.75 6.75 4.75ZM9.42188 2.78125H17.1562C17.6133 2.78125 18 3.16797 18 3.625C18 4.11719 17.6133 4.46875 17.1562 4.46875H9.42188C9.07031 5.62891 7.98047 6.4375 6.75 6.4375C5.48438 6.4375 4.39453 5.62891 4.04297 4.46875H0.84375C0.351562 4.46875 0 4.11719 0 3.625C0 3.16797 0.351562 2.78125 0.84375 2.78125H4.04297C4.39453 1.65625 5.48438 0.8125 6.75 0.8125C7.98047 0.8125 9.07031 1.65625 9.42188 2.78125Z" fill="black"/>
				</svg>
				<span class="ml-3">
					FILTROS
				</span>
			</div>
		{% endblock %}
								{% block modal_body %}
										{% if has_filters_available %}
											{{ component(
												'filters/remove-filters',{
													container_classes: {
														filters_container: "px-3 mt-4 mb-2",
													},
													filter_classes: {
														applied_filters_label: "font-body font-weight-bold mb-2",
														remove: "chip",
														remove_icon: "js-remove-filter-chip chip-remove-icon",
														remove_all: "btn-link d-inline-block mt-1 mt-md-0 font-small w-100 text-uppercase",
													},
													remove_filter_svg_id: 'times',
												}) 
											}}
										{% endif %}
									<div class="js-sorting-overlay filters-overlay" style="display: none;">
										<div class="filters-updating-message">
											<span class="h5 mr-2">{{ 'Ordenando productos' | translate }}</span>
											<span>
												<svg class="icon-inline h5 icon-spin svg-icon-text"><use xlink:href="#spinner-third"/></svg>
											</span>
										</div>
									</div>
									{% if has_filters_available %}

									{{ component(
										'filters/filters',{
											accordion: true,
											parent_category_link: false,
											applied_filters_badge: true,
											container_classes: {
												filters_container: "visible-when-content-ready px-3",
											},
											accordion_classes: {
												title_container: "row no-gutters align-items-center",
												title_col: "col my-1 pr-3 d-flex align-items-center",
												title: "h6 mb-0 font-weight-bold",
												actions_col: "col-auto my-1",
												title_icon: "icon-inline svg-icon-text icon-xs mr-1"
											},
											filter_classes: {
												list: "list-unstyled my-3",
												list_item: "mb-2",
												list_link: "font-small d-flex align-items-center",
												badge: "h6 ml-1",
												show_more_link: "d-inline-block btn-link font-small mt-1",
												checkbox_last: "m-0",
												checkbox_input: "mr-2",
												price_group: 'price-filter-container filter-accordion px-3',
												price_title: 'h6 mb-4 font-weight-bold',
												price_submit: 'btn btn-default d-inline-block mt-2',
												applying_feedback_message: 'font-big mr-2',
												applying_feedback_icon: 'icon-inline font-big icon-spin svg-icon-text'
											},
											accordion_show_svg_id: 'chevron',
											accordion_hide_svg_id: 'chevron-down',
											applying_feedback_svg_id: 'spinner-third'
										}) 
									}}								
									{% endif %}
								{% endblock %}
	{% endembed %}

	{% include 'snipplets/grid/filter_order.tpl' %}

</section>
	<section class="js-category-controls-prev category-controls-sticky-detector"></section>
{% endif %}

<section class="category-body {% if settings.filters_desktop_modal %}pt-md-2{% endif %}" data-store="category-grid-{{ category.id }}">
	<div class="container-fluid mt-3 mb-5">
		<div class="row">
			{% if has_applied_filters %}
				<div class="col-12 mb-3 mb-md-4 visible-when-content-ready{% if not products %}d-block{% endif %} {% if not settings.filters_desktop_modal %}d-md-block{% endif %}">
					{{ component(
						'filters/remove-filters',{
							filter_classes: {
								applied_filters_label: "font-body font-weight-bold mb-2",
								remove: "chip",
								remove_icon: "chip-remove-icon",
								remove_all: "btn-link d-inline-block mt-1 mt-md-0 font-small",
							},
							remove_filter_svg_id: 'times',
						}) 
					}}
				</div>
			{% endif %}
			{% if not settings.filters_desktop_modal %} 
				<div class="col-md-auto filters-sidebar d-none d-md-block visible-when-content-ready">
					{% if products %}

						{{ component(
							'sort-by',{
								sort_by_classes: {
									container: 'mb-4 pb-2',
									select_group: "d-inline-block w-auto mb-0",
									select_label: "h2 mb-3 d-block",
									select: "form-select-small",
									select_svg: "icon-inline icon-xs icon-w-14",
								},
								select_svg_id: 'chevron-down'
							}) 
						}}

						{{ component(
							'filters/filters',{
								container_classes: {
									filters_container: "visible-when-content-ready",
								},
								filter_classes: {
									parent_category_link: "d-block",
									parent_category_link_icon: "icon-inline icon-flip-horizontal mr-2 svg-icon-text",
									list: "mb-4 pb-2 list-unstyled",
									list_item: "mb-2",
									list_link: "font-small",
									list_title: "h2 mb-4",
									show_more_link: "d-inline-block btn-link font-small mt-1",
									checkbox_last: "m-0",
									price_group: 'price-filter-container filter-accordion mb-4 pb-2',
									price_title: 'font-weight-bold mb-4 font-body',
									price_submit: 'btn btn-default d-inline-block',
									price_group: 'price-filter-container mb-4 pb-2',
									price_title: 'h2 mb-4',
									price_submit: 'btn btn-default btn-small'
								},
							}) 
						}}
					{% endif %}
				</div>
			{% endif %}
			<div class="col" data-store="category-grid-{{ category.id }}">
				{% if products %}
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
					<div class="font-big py-5 text-center" data-component="filter.message">
						{{(has_filters_enabled ? "No tenemos resultados para tu búsqueda. Por favor, intentá con otros filtros." : "Próximamente") | translate}}
					</div>
				{% endif %}
			</div>
		</div>
	</div>
</section>
{% elseif show_help %}
	{# Category Placeholder #}
	{% include 'snipplets/defaults/show_help_category.tpl' %}
{% endif %}

{# institutional-message #}
{% include 'snipplets/home/home-institutional-message.tpl' %}

{# Banners de categoria customizados #}
{% include 'snipplets/category-banners-grid.tpl' %}

{# <div class="container-fluid">
	<div class="row">
		<div class="col-12 col-md-8 offset-md-2">
			<div class="title-category section-title-products-home">
				{{ category.name }}			
			</div>
			{% if category.description %}
				<div class="description-category">
					{{ category.description }}
				</div>
			{% endif %}
		</div>
	</div>
</div> #}
{# 
{% include 'snipplets/home/home-best-sellers.tpl' with {'featured_products': true, 'category': true} %}

{% include 'snipplets/home/home-most-search.tpl' %} #}
