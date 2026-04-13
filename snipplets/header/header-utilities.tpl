{# {% set search_padding_md_classes = settings.logo_position_desktop == 'center' and not settings.hamburger_desktop ? 'pl-xl-0' %} #}
{% set search_padding_md_classes = not settings.hamburger_desktop ? 'pl-xl-0' %}

{# {% set menu_padding_classes = settings.logo_position_mobile == 'center' ? 'pl-0' %} #}
{% set menu_padding_classes = 'pl-0' %}
{# {% set menu_padding_md_classes = settings.logo_position_desktop == 'center' ? 'pl-xl-0' : 'pl-xl-2' %} #}
{% set menu_padding_md_classes = 'pl-xl-0' %}

{% if use_menu %}
	<span class="utilities-container d-inline-block">
		<a href="#" class="js-modal-open utilities-item btn btn-utility {{ menu_padding_classes }} {{ menu_padding_md_classes }}" data-toggle="#nav-hamburger" aria-label="{{ 'Menú' | translate }}" data-component="menu-button">
			<svg width="18" height="17" viewBox="0 0 18 17" fill="none" xmlns="http://www.w3.org/2000/svg">
				<path d="M1 1H17" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
				<path d="M1 8.5H12" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
				<path d="M1 16H17" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
			</svg>
				
			<span class="utilities-text d-none d-xl-inline-flex">{{ 'Menú' | translate }}</span>
		</a>
	</span>
{% elseif use_account %}
	{# <div class="align-items-center justify-content-end block-actions-links d-flex"> #}
		{% if settings.header_has_actions %}
			<span class="utilities-container text-transform justify-content-between d-none d-xl-inline-flex">
				<a href="{{ settings.header_action_01_url }}" class="link-header -without-border mr-2" aria-label="{{ settings.header_action_01_text }}" target="_top">
					{{ settings.header_action_01_text }}
				</a>
				<a href="{{ settings.header_action_02_url }}" class="link-header -with-border" aria-label="{{ settings.header_action_02_text }}" target="_top">
					{{ settings.header_action_02_text }}
				</a>
			</span>
		{% endif %}
		<span class="utilities-container text-transform justify-content-end d-flex">
			{% if login_only %}
				<a href="{% if not customer %}{{ store.customer_login_url }}{% else %}{{ store.customer_home_url }}{% endif %}" class="btn btn-utility px-0">
					<span class="utilities-text">
						{% if customer %}
							<svg class="d-none d-xl-inline-block" width="52" height="48" viewBox="0 0 42 38" fill="none" xmlns="http://www.w3.org/2000/svg">
								<path d="M26.2734 24.3125C27.5391 23.0117 28.3125 21.2188 28.3125 19.25C28.3125 15.2422 25.0078 11.9375 21 11.9375C16.957 11.9375 13.6875 15.2422 13.6875 19.25C13.6875 21.2188 14.4258 23.0117 15.6914 24.3125C16.3594 22.6602 17.9766 21.5 19.875 21.5H22.125C23.9883 21.5 25.6055 22.6602 26.2734 24.3125ZM24.8672 25.4727C24.6211 24.1719 23.4609 23.1875 22.125 23.1875H19.875C18.5039 23.1875 17.3438 24.1719 17.0977 25.4727C18.2227 26.1758 19.5586 26.5625 21 26.5625C22.4062 26.5625 23.7422 26.1758 24.8672 25.4727ZM21 28.25C17.7656 28.25 14.8125 26.5625 13.1953 23.75C11.5781 20.9727 11.5781 17.5625 13.1953 14.75C14.8125 11.9727 17.7656 10.25 21 10.25C24.1992 10.25 27.1523 11.9727 28.7695 14.75C30.3867 17.5625 30.3867 20.9727 28.7695 23.75C27.1523 26.5625 24.1992 28.25 21 28.25ZM21 18.6875C21.4922 18.6875 21.9492 18.4414 22.1953 17.9844C22.4414 17.5625 22.4414 17.0352 22.1953 16.5781C21.9492 16.1562 21.4922 15.875 21 15.875C20.4727 15.875 20.0156 16.1562 19.7695 16.5781C19.5234 17.0352 19.5234 17.5625 19.7695 17.9844C20.0156 18.4414 20.4727 18.6875 21 18.6875ZM17.9062 17.2812C17.9062 16.1914 18.4688 15.1719 19.4531 14.6094C20.4023 14.082 21.5625 14.082 22.5469 14.6094C23.4961 15.1719 24.0938 16.1914 24.0938 17.2812C24.0938 18.4062 23.4961 19.4258 22.5469 19.9883C21.5625 20.5156 20.4023 20.5156 19.4531 19.9883C18.4688 19.4258 17.9062 18.4062 17.9062 17.2812Z" fill="currentColor"/>
							</svg>
							<svg class="d-xl-none" width="42" height="38" viewBox="0 0 42 38" fill="none" xmlns="http://www.w3.org/2000/svg">
								<path d="M26.2734 24.3125C27.5391 23.0117 28.3125 21.2188 28.3125 19.25C28.3125 15.2422 25.0078 11.9375 21 11.9375C16.957 11.9375 13.6875 15.2422 13.6875 19.25C13.6875 21.2188 14.4258 23.0117 15.6914 24.3125C16.3594 22.6602 17.9766 21.5 19.875 21.5H22.125C23.9883 21.5 25.6055 22.6602 26.2734 24.3125ZM24.8672 25.4727C24.6211 24.1719 23.4609 23.1875 22.125 23.1875H19.875C18.5039 23.1875 17.3438 24.1719 17.0977 25.4727C18.2227 26.1758 19.5586 26.5625 21 26.5625C22.4062 26.5625 23.7422 26.1758 24.8672 25.4727ZM21 28.25C17.7656 28.25 14.8125 26.5625 13.1953 23.75C11.5781 20.9727 11.5781 17.5625 13.1953 14.75C14.8125 11.9727 17.7656 10.25 21 10.25C24.1992 10.25 27.1523 11.9727 28.7695 14.75C30.3867 17.5625 30.3867 20.9727 28.7695 23.75C27.1523 26.5625 24.1992 28.25 21 28.25ZM21 18.6875C21.4922 18.6875 21.9492 18.4414 22.1953 17.9844C22.4414 17.5625 22.4414 17.0352 22.1953 16.5781C21.9492 16.1562 21.4922 15.875 21 15.875C20.4727 15.875 20.0156 16.1562 19.7695 16.5781C19.5234 17.0352 19.5234 17.5625 19.7695 17.9844C20.0156 18.4414 20.4727 18.6875 21 18.6875ZM17.9062 17.2812C17.9062 16.1914 18.4688 15.1719 19.4531 14.6094C20.4023 14.082 21.5625 14.082 22.5469 14.6094C23.4961 15.1719 24.0938 16.1914 24.0938 17.2812C24.0938 18.4062 23.4961 19.4258 22.5469 19.9883C21.5625 20.5156 20.4023 20.5156 19.4531 19.9883C18.4688 19.4258 17.9062 18.4062 17.9062 17.2812Z" fill="currentColor"/>
							</svg>
						{% else %}
							<svg class="d-none d-xl-block" width="52" height="48" viewBox="0 0 42 38" fill="none" xmlns="http://www.w3.org/2000/svg">
								<path d="M26.2734 24.3125C27.5391 23.0117 28.3125 21.2188 28.3125 19.25C28.3125 15.2422 25.0078 11.9375 21 11.9375C16.957 11.9375 13.6875 15.2422 13.6875 19.25C13.6875 21.2188 14.4258 23.0117 15.6914 24.3125C16.3594 22.6602 17.9766 21.5 19.875 21.5H22.125C23.9883 21.5 25.6055 22.6602 26.2734 24.3125ZM24.8672 25.4727C24.6211 24.1719 23.4609 23.1875 22.125 23.1875H19.875C18.5039 23.1875 17.3438 24.1719 17.0977 25.4727C18.2227 26.1758 19.5586 26.5625 21 26.5625C22.4062 26.5625 23.7422 26.1758 24.8672 25.4727ZM21 28.25C17.7656 28.25 14.8125 26.5625 13.1953 23.75C11.5781 20.9727 11.5781 17.5625 13.1953 14.75C14.8125 11.9727 17.7656 10.25 21 10.25C24.1992 10.25 27.1523 11.9727 28.7695 14.75C30.3867 17.5625 30.3867 20.9727 28.7695 23.75C27.1523 26.5625 24.1992 28.25 21 28.25ZM21 18.6875C21.4922 18.6875 21.9492 18.4414 22.1953 17.9844C22.4414 17.5625 22.4414 17.0352 22.1953 16.5781C21.9492 16.1562 21.4922 15.875 21 15.875C20.4727 15.875 20.0156 16.1562 19.7695 16.5781C19.5234 17.0352 19.5234 17.5625 19.7695 17.9844C20.0156 18.4414 20.4727 18.6875 21 18.6875ZM17.9062 17.2812C17.9062 16.1914 18.4688 15.1719 19.4531 14.6094C20.4023 14.082 21.5625 14.082 22.5469 14.6094C23.4961 15.1719 24.0938 16.1914 24.0938 17.2812C24.0938 18.4062 23.4961 19.4258 22.5469 19.9883C21.5625 20.5156 20.4023 20.5156 19.4531 19.9883C18.4688 19.4258 17.9062 18.4062 17.9062 17.2812Z" fill="currentColor"/>
							</svg>
							<svg class="d-xl-none" width="42" height="38" viewBox="0 0 42 38" fill="none" xmlns="http://www.w3.org/2000/svg">
								<path d="M26.2734 24.3125C27.5391 23.0117 28.3125 21.2188 28.3125 19.25C28.3125 15.2422 25.0078 11.9375 21 11.9375C16.957 11.9375 13.6875 15.2422 13.6875 19.25C13.6875 21.2188 14.4258 23.0117 15.6914 24.3125C16.3594 22.6602 17.9766 21.5 19.875 21.5H22.125C23.9883 21.5 25.6055 22.6602 26.2734 24.3125ZM24.8672 25.4727C24.6211 24.1719 23.4609 23.1875 22.125 23.1875H19.875C18.5039 23.1875 17.3438 24.1719 17.0977 25.4727C18.2227 26.1758 19.5586 26.5625 21 26.5625C22.4062 26.5625 23.7422 26.1758 24.8672 25.4727ZM21 28.25C17.7656 28.25 14.8125 26.5625 13.1953 23.75C11.5781 20.9727 11.5781 17.5625 13.1953 14.75C14.8125 11.9727 17.7656 10.25 21 10.25C24.1992 10.25 27.1523 11.9727 28.7695 14.75C30.3867 17.5625 30.3867 20.9727 28.7695 23.75C27.1523 26.5625 24.1992 28.25 21 28.25ZM21 18.6875C21.4922 18.6875 21.9492 18.4414 22.1953 17.9844C22.4414 17.5625 22.4414 17.0352 22.1953 16.5781C21.9492 16.1562 21.4922 15.875 21 15.875C20.4727 15.875 20.0156 16.1562 19.7695 16.5781C19.5234 17.0352 19.5234 17.5625 19.7695 17.9844C20.0156 18.4414 20.4727 18.6875 21 18.6875ZM17.9062 17.2812C17.9062 16.1914 18.4688 15.1719 19.4531 14.6094C20.4023 14.082 21.5625 14.082 22.5469 14.6094C23.4961 15.1719 24.0938 16.1914 24.0938 17.2812C24.0938 18.4062 23.4961 19.4258 22.5469 19.9883C21.5625 20.5156 20.4023 20.5156 19.4531 19.9883C18.4688 19.4258 17.9062 18.4062 17.9062 17.2812Z" fill="currentColor"/>
							</svg>
						{% endif %}
					</span>
				</a>
			{% else %}
				{% if not customer %}
					{{ "Iniciar sesión" | translate | a_tag(store.customer_login_url, '', '') }} 
					{% if 'mandatory' not in store.customer_accounts %}
						<span class="mx-1">/</span>
						{{ "Crear cuenta" | translate | a_tag(store.customer_register_url, '', '') }}
					{% endif %}
				{% else %}
					{% set customer_short_name = customer.name|split(' ')|slice(0, 1)|join %} 
					{{ "¡Hola, {1}!" | t(customer_short_name) | a_tag(store.customer_home_url, '', '') }}
					<span class="mx-1">/</span>
					{{ "Cerrar sesión" | translate | a_tag(store.customer_logout_url, '', 'ml-1') }}
				{% endif %}
			{% endif %}
		</span>
		<span class="utilities-container d-inline-block">
			<div id="ajax-cart" class="cart-summary" data-component='cart-button'>
				<a 
					{% if settings.ajax_cart and template != 'cart' %}
						href="#"
						data-toggle="#modal-cart" 
						data-modal-url="modal-fullscreen-cart"
					{% else %}
						href="{{ store.cart_url }}" 
					{% endif %}
					class="{% if settings.ajax_cart and template != 'cart' %}js-modal-open js-fullscreen-modal-open{% endif %} btn btn-utility d-flex px-0"
					>
					<span class="utilities-text">
						<svg class="d-none d-xl-inline-block" width="52" height="48" viewBox="0 0 42 38" fill="none" xmlns="http://www.w3.org/2000/svg">
							<path d="M18.75 14.1875V15.875H23.25V14.1875C23.25 12.957 22.2305 11.9375 21 11.9375C19.7344 11.9375 18.75 12.957 18.75 14.1875ZM17.0625 17.5625H14.8125V24.875C14.8125 25.8242 15.5508 26.5625 16.5 26.5625H25.5C26.4141 26.5625 27.1875 25.8242 27.1875 24.875V17.5625H24.9375V19.5312C24.9375 20.0234 24.5508 20.375 24.0938 20.375C23.6016 20.375 23.25 20.0234 23.25 19.5312V17.5625H18.75V19.5312C18.75 20.0234 18.3633 20.375 17.9062 20.375C17.4141 20.375 17.0625 20.0234 17.0625 19.5312V17.5625ZM17.0625 15.875V14.1875C17.0625 12.043 18.8203 10.25 21 10.25C23.1445 10.25 24.9375 12.043 24.9375 14.1875V15.875H27.1875C28.1016 15.875 28.875 16.6484 28.875 17.5625V24.875C28.875 26.7383 27.3633 28.25 25.5 28.25H16.5C14.6367 28.25 13.125 26.7383 13.125 24.875V17.5625C13.125 16.6484 13.8633 15.875 14.8125 15.875H17.0625Z" fill="currentColor"/>
						</svg>						
						<svg class="d-xl-none" width="42" height="38" viewBox="0 0 42 38" fill="none" xmlns="http://www.w3.org/2000/svg">
							<path d="M18.75 14.1875V15.875H23.25V14.1875C23.25 12.957 22.2305 11.9375 21 11.9375C19.7344 11.9375 18.75 12.957 18.75 14.1875ZM17.0625 17.5625H14.8125V24.875C14.8125 25.8242 15.5508 26.5625 16.5 26.5625H25.5C26.4141 26.5625 27.1875 25.8242 27.1875 24.875V17.5625H24.9375V19.5312C24.9375 20.0234 24.5508 20.375 24.0938 20.375C23.6016 20.375 23.25 20.0234 23.25 19.5312V17.5625H18.75V19.5312C18.75 20.0234 18.3633 20.375 17.9062 20.375C17.4141 20.375 17.0625 20.0234 17.0625 19.5312V17.5625ZM17.0625 15.875V14.1875C17.0625 12.043 18.8203 10.25 21 10.25C23.1445 10.25 24.9375 12.043 24.9375 14.1875V15.875H27.1875C28.1016 15.875 28.875 16.6484 28.875 17.5625V24.875C28.875 26.7383 27.3633 28.25 25.5 28.25H16.5C14.6367 28.25 13.125 26.7383 13.125 24.875V17.5625C13.125 16.6484 13.8633 15.875 14.8125 15.875H17.0625Z" fill="currentColor"/>
						</svg>						
					</span>
					<span class="js-cart-widget-amount badge">{{ "{1}" | translate(cart.items_count ) }}</span>
				</a>	
			</div>
		</span>
	{# </div> #}
{% elseif use_languages %}
	<span class="utilities-container nav-dropdown text-transform">
		<span class="btn btn-utility">
			{% for language in languages if language.active %}
				{{ language.country }}
			{% endfor %}
			<svg class="icon-inline icon-xs icon-w-12 ml-1"><use xlink:href="#chevron-down"/></svg>
		</span>
		<div class="nav-dropdown-content desktop-dropdown-small position-absolute">
			{% include "snipplets/navigation/navigation-lang.tpl" with { header: true } %}
		</div>
	</span>
{% elseif use_search %}
	<span class="utilities-container d-inline-block">
		<a href="#" class="js-search-button js-modal-open js-fullscreen-modal-open btn btn-utility utilities-item {{ search_padding_md_classes }}" data-modal-url="modal-fullscreen-search" data-toggle="#nav-search" aria-label="{{ 'Buscador' | translate }}">
			<svg width="19" height="19" viewBox="0 0 19 19" fill="none" xmlns="http://www.w3.org/2000/svg">
				<path d="M12.9375 7.5625C12.9375 5.55859 11.8477 3.73047 10.125 2.71094C8.36719 1.69141 6.22266 1.69141 4.5 2.71094C2.74219 3.73047 1.6875 5.55859 1.6875 7.5625C1.6875 9.60156 2.74219 11.4297 4.5 12.4492C6.22266 13.4688 8.36719 13.4688 10.125 12.4492C11.8477 11.4297 12.9375 9.60156 12.9375 7.5625ZM11.8477 13.3281C10.582 14.3125 9 14.875 7.3125 14.875C3.26953 14.875 0 11.6055 0 7.5625C0 3.55469 3.26953 0.25 7.3125 0.25C11.3203 0.25 14.625 3.55469 14.625 7.5625C14.625 9.28516 14.0273 10.8672 13.043 12.1328L17.7539 16.8086C18.0703 17.1602 18.0703 17.6875 17.7539 18.0039C17.4023 18.3555 16.875 18.3555 16.5586 18.0039L11.8477 13.3281Z" fill="currentColor"/>
			</svg>						
			{# <span class="utilities-text">{{ 'Buscar' | translate }}</span> #}
		</a>
	</span>
{% elseif use_search_with_toggle %}
	{# Mobile toggle search #}
	<span class="utilities-container d-inline-block">
		<a class="js-search-button js-toggle-search-button btn btn-utility utilities-item" aria-label="{{ 'Buscador' | translate }}">
			<svg class="js-card-collapse-icon icon-inline icon-xs svg-icon-text"><use xlink:href="#search"/></svg>
		</a>
		<a class="js-close-search-mobile btn btn-utility utilities-item d-none">
			<svg class="js-card-collapse-icon icon-inline icon-xs svg-icon-text"><use xlink:href="#times"/></svg>
		</a>
	</span>
{% endif %}