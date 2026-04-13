{# Modal Hamburger #}

{# {% set modal_position_desktop_val = settings.logo_position_desktop != 'center' ? 'right' : 'left' %}
{% set modal_position_mobile_val = settings.logo_position_mobile != 'center' ? 'right' : 'left' %} #}

{% set modal_position_desktop_val = 'left' %}
{% set modal_position_mobile_val = 'left' %}

{% if not settings.search_big_desktop %}

	{# Modal Search #}

	{% embed "snipplets/modal.tpl" with{modal_id: 'nav-search',modal_class: 'search modal-docked-md pb-0', modal_position: modal_position_mobile_val, modal_position_desktop: modal_position_desktop_val, modal_transition: 'slide', modal_width: 'full', modal_mobile_full_screen: false, modal_hide_close: 'true',modal_header_class: 'js-toggle-menu-close p-3', modal_body_class: 'nav-body', modal_footer_class: 'hamburger-footer mb-0 p-0',modal_header_title: false, modal_fixed_footer: true, modal_footer: true, desktop_overlay_only: modal_with_desktop_only_overlay_val} %}
		{% block modal_body %}
			{% include "snipplets/header/header-search.tpl" with {search_modal: true} %}
		{% endblock %}
	{% endembed %}

{% endif %}

{% set modal_with_desktop_only_overlay_val = false %}

{# Modal Hamburger #}

{% embed "snipplets/modal.tpl" with{modal_id: 'nav-hamburger',modal_class: 'nav-hamburger modal-docked-md pb-0', modal_position: modal_position_mobile_val, modal_header_title: true, modal_position_desktop: modal_position_desktop_val, modal_transition: 'slide', modal_width: 'full', modal_mobile_full_screen: false, modal_hide_close: 'true',modal_header_class: 'js-toggle-menu-close py-3', modal_body_class: 'nav-body', modal_footer_class: 'hamburger-footer mb-0 p-0', modal_fixed_footer: true, modal_footer: true, desktop_overlay_only: modal_with_desktop_only_overlay_val} %}
	{% block modal_head %}
		<span class="d-flex align-items-center " >
			<svg width="18" height="17" viewBox="0 0 18 17" style="margin-right: 10px" fill="none" xmlns="http://www.w3.org/2000/svg">
				<path d="M1 1H17" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
				<path d="M1 8.5H12" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
				<path d="M1 16H17" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
			</svg>
				
			Menu
		</span>
	{% endblock %}	
	{% block modal_body %}
		{# {% if not settings.search_big_mobile %}
			<div class="d-block d-md-none position-relative">
				{% include "snipplets/header/header-search.tpl" %}
			</div>
		{% endif %} #}
		<div class="nav-login d-flex d-md-none align-items-center">
			<svg class="icon-inline icon-w-16 mr-2"><use xlink:href="#icon-account"/></svg>

			{% if not customer %}
				{{ "ENTRE" | translate | a_tag(store.customer_login_url, '', '') }} 
				{% if 'mandatory' not in store.customer_accounts %}
					<span class="mx-1">OU</span>
					{{ "CADASTRE-SE" | translate | a_tag(store.customer_register_url, '', '') }}
				{% endif %}
			{% else %}
				{% set customer_short_name = customer.name|split(' ')|slice(0, 1)|join %} 
				{{ "¡Hola, {1}!" | t(customer_short_name) | a_tag(store.customer_home_url, '', '') }}
				<span class="mx-1">/</span>
				{{ "Cerrar sesión" | translate | a_tag(store.customer_logout_url, '', 'ml-1') }}
			{% endif %}
		</div>

		{% include "snipplets/navigation/navigation-panel.tpl" with {hamburger: true, primary_links: true} %}

		{% if settings.header_has_actions %}
			<div class="align-items-center justify-content-center block-actions-links d-flex">
				<span class="utilities-container text-transform justify-content-between d-inline-flex">
					<a href="{{ settings.header_action_01_url }}" class="link-header -without-border mr-2" aria-label="{{ settings.header_action_01_text }}" target="_top">
						{{ settings.header_action_01_text }}
					</a>
					<a href="{{ settings.header_action_02_url }}" class="link-header -with-border" aria-label="{{ settings.header_action_02_text }}" target="_top">
						{{ settings.header_action_02_text }}
					</a>
				</span>
			</div>
		{% endif %}

		{% if settings.header_menu_image %}
			<div class="header-image-menu">
				{% if settings.header_menu_imagem_url %}
					<a href="{{ settings.header_menu_imagem_url }}" class="header-image-menu-link" target="_top">
				{% endif %}
					{% if "header_menu_imagem.jpg" | has_custom_image %}
						<figure class="image -custom">
							<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ "header_menu_imagem.jpg" | static_url | settings_image_url('large') }} 480w, {{ "header_menu_imagem.jpg" | static_url | settings_image_url('huge') }} 640w, {{ "header_menu_imagem.jpg" | static_url | settings_image_url('original') }} 1024w, {{ "header_menu_imagem.jpg" | static_url | settings_image_url('1080p') }} 1920w' class='lazyload'/>
						</figure>
					{% endif %}					
					{% if settings.header_menu_imagem_upper_title %}
						<h3> {{ settings.header_menu_imagem_upper_title }} </h3>
					{% endif %}
					{% if settings.header_menu_imagem_lower_title %}
						<h2> {{ settings.header_menu_imagem_lower_title }} </h2>
					{% endif %}
				{% if settings.header_menu_imagem_url %}
					</a>
				{% endif %}
			</div>
		{% endif %}
	{% endblock %}
	
{% endembed %}

{# Modal Cart #}

{% if not store.is_catalog and settings.ajax_cart and template != 'cart' %}           

	{# Cart Ajax #}
	
	{% embed "snipplets/modal.tpl" with{modal_id: 'modal-cart', modal_class: 'cart', modal_position: 'right', modal_position_desktop: 'right', modal_transition: 'slide', modal_width: 'docked-md', modal_form_action: store.cart_url, modal_form_class: 'js-ajax-cart-panel', modal_body_class: 'text-left', modal_header_title: true, modal_mobile_full_screen: true, modal_form_hook: 'cart-form', data_component:'cart', desktop_overlay_only: modal_with_desktop_only_overlay_val } %}
		{% block modal_head %}
			{% block page_header_text %}
			<svg width="16" height="19" viewBox="0 0 16 19" fill="none" xmlns="http://www.w3.org/2000/svg">
				<path d="M5.75 4.7425V6.43H10.25V4.7425C10.25 3.51203 9.23047 2.4925 8 2.4925C6.73438 2.4925 5.75 3.51203 5.75 4.7425ZM4.0625 8.1175H1.8125V15.43C1.8125 16.3792 2.55078 17.1175 3.5 17.1175H12.5C13.4141 17.1175 14.1875 16.3792 14.1875 15.43V8.1175H11.9375V10.0863C11.9375 10.5784 11.5508 10.93 11.0938 10.93C10.6016 10.93 10.25 10.5784 10.25 10.0863V8.1175H5.75V10.0863C5.75 10.5784 5.36328 10.93 4.90625 10.93C4.41406 10.93 4.0625 10.5784 4.0625 10.0863V8.1175ZM4.0625 6.43V4.7425C4.0625 2.59797 5.82031 0.805 8 0.805C10.1445 0.805 11.9375 2.59797 11.9375 4.7425V6.43H14.1875C15.1016 6.43 15.875 7.20344 15.875 8.1175V15.43C15.875 17.2933 14.3633 18.805 12.5 18.805H3.5C1.63672 18.805 0.125 17.2933 0.125 15.43V8.1175C0.125 7.20344 0.863281 6.43 1.8125 6.43H4.0625Z" fill="black"/>
			</svg>
			<p>({{ cart.items_count }})</p>
			{% endblock page_header_text %}
		{% endblock %}
		{% block modal_body %}
			{% snipplet "cart-panel.tpl" %}
		{% endblock %}
	{% endembed %}

	{% if settings.add_to_cart_recommendations %}

		{# Recommended products on add to cart #}

		{% embed "snipplets/modal.tpl" with{modal_id: 'related-products-notification', modal_class: 'bottom modal-overflow-none modal-bottom-sheet h-auto', modal_position: 'bottom', modal_transition: 'slide', modal_header_title: true, modal_footer: false, modal_width: 'centered-md modal-centered-md-600px', modal_body_class: 'modal-scrollable'} %}
			{% block modal_head %}
				{% block page_header_text %}{{ '¡Agregado al carrito!' | translate }}{% endblock page_header_text %}
			{% endblock %}
			{% block modal_body %}

				{# Product added info #}

				{% include "snipplets/notification-cart.tpl" with {related_products: true} %}
				
				{# Product added recommendations #}

				<div class="js-related-products-notification-container" style="display: none"></div>

			{% endblock %}
		{% endembed %}
	{% endif %}

{% endif %}