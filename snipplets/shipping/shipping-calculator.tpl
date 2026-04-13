{% if product_detail %}
	{% set cart_zipcode = false %}
{% else %}
	{% set cart_zipcode = cart.shipping_zipcode %}
{% endif %}

<div data-store="shipping-calculator">
	<div class="js-shipping-calculator-head shipping-calculator-head position-relative transition-soft {% if cart_zipcode %}with-zip{% else %}with-form{% endif %}">
		<div class="js-shipping-calculator-with-zipcode {% if cart_zipcode %}js-cart-saved-zipcode transition-up-active{% endif %} mt-1 w-100 transition-up position-absolute">
			<div class="d-flex justify-content-between align-items-center">
				<span style="display: flex;gap: 7px;align-items: center;">
					<svg width="21" height="16" viewBox="0 0 21 16" fill="none" xmlns="http://www.w3.org/2000/svg">
						<path d="M11.2935 1.5H4.29346C4.01221 1.5 3.79346 1.75 3.79346 2V3H7.79346C8.04346 3 8.29346 3.25 8.29346 3.5C8.29346 3.78125 8.04346 4 7.79346 4H0.793457C0.512207 4 0.293457 3.78125 0.293457 3.5C0.293457 3.25 0.512207 3 0.793457 3H2.29346V2C2.29346 0.90625 3.16846 0 4.29346 0H11.2935C12.3872 0 13.2935 0.90625 13.2935 2V3H14.606C15.0747 3 15.5122 3.1875 15.856 3.53125L18.7622 6.4375C19.106 6.78125 19.2935 7.21875 19.2935 7.6875V11.5H19.5435C19.9497 11.5 20.2935 11.8438 20.2935 12.25C20.2935 12.6875 19.9497 13 19.5435 13H18.2935C18.2935 14.6562 16.9497 16 15.2935 16C13.6372 16 12.2935 14.6562 12.2935 13H12.0435H11.2935H10.2935H8.29346C8.29346 14.6562 6.94971 16 5.29346 16C3.63721 16 2.29346 14.6562 2.29346 13V11.5V9H3.79346V10.4062C4.23096 10.1562 4.73096 10 5.29346 10C6.38721 10 7.35596 10.625 7.88721 11.5H10.2935H11.2935C11.5435 11.5 11.7935 11.2812 11.7935 11V2C11.7935 1.75 11.5435 1.5 11.2935 1.5ZM17.6997 7.5L14.7935 4.59375C14.731 4.53125 14.6685 4.5 14.606 4.5H13.2935V7.5H17.731H17.6997ZM6.79346 13C6.79346 12.4688 6.48096 12 6.04346 11.7188C5.57471 11.4375 4.98096 11.4375 4.54346 11.7188C4.07471 12 3.79346 12.4688 3.79346 13C3.79346 13.5625 4.07471 14.0312 4.54346 14.3125C4.98096 14.5938 5.57471 14.5938 6.04346 14.3125C6.48096 14.0312 6.79346 13.5625 6.79346 13ZM15.2935 14.5C15.8247 14.5 16.2935 14.2188 16.5747 13.75C16.856 13.3125 16.856 12.7188 16.5747 12.25C16.2935 11.8125 15.8247 11.5 15.2935 11.5C14.731 11.5 14.2622 11.8125 13.981 12.25C13.6997 12.7188 13.6997 13.3125 13.981 13.75C14.2622 14.2188 14.731 14.5 15.2935 14.5ZM1.79346 5H8.79346C9.04346 5 9.29346 5.25 9.29346 5.5C9.29346 5.78125 9.04346 6 8.79346 6H1.79346C1.51221 6 1.29346 5.78125 1.29346 5.5C1.29346 5.25 1.51221 5 1.79346 5ZM0.793457 7H7.79346C8.04346 7 8.29346 7.25 8.29346 7.5C8.29346 7.78125 8.04346 8 7.79346 8H0.793457C0.512207 8 0.293457 7.78125 0.293457 7.5C0.293457 7.25 0.512207 7 0.793457 7Z" fill="black"/>
					</svg>

					<strong class="js-shipping-calculator-current-zip">{{ cart_zipcode }}</strong>
				</span>
				<span style="display:flex;align-items:center;gap:4px;">
					<a class="js-shipping-calculator-change-zipcode btn btn-link font-small" href="#">
						<svg width="16" height="16" viewBox="0 0 16 16" fill="none" xmlns="http://www.w3.org/2000/svg">
							<path d="M1.79346 7H1.54346C1.10596 7 0.793457 6.6875 0.793457 6.25V2.25C0.793457 1.96875 0.949707 1.6875 1.23096 1.5625C1.51221 1.46875 1.85596 1.53125 2.07471 1.71875L3.35596 3.03125C6.10596 0.34375 10.5122 0.34375 13.231 3.0625C15.9497 5.8125 15.9497 10.2188 13.231 12.9688C10.481 15.6875 6.07471 15.6875 3.32471 12.9688C2.94971 12.5625 2.94971 11.9375 3.32471 11.5625C3.73096 11.1562 4.35596 11.1562 4.73096 11.5625C6.69971 13.5 9.85596 13.5 11.8247 11.5625C13.7622 9.59375 13.7622 6.4375 11.8247 4.46875C9.88721 2.53125 6.73096 2.53125 4.76221 4.4375L6.07471 5.71875C6.26221 5.9375 6.32471 6.28125 6.23096 6.5625C6.10596 6.84375 5.82471 7 5.54346 7H1.79346Z" fill="black"/>
						</svg>
					</a>
					<a href="#" class="js-toggle-shipping-options btn btn-link font-small" title="Mostrar/ocultar fretes" style="padding:4px 6px; line-height:1;">
						<svg class="js-shipping-chevron" width="12" height="12" viewBox="0 0 12 12" fill="none" xmlns="http://www.w3.org/2000/svg" style="transition:transform .3s ease;">
							<path d="M2 4L6 8L10 4" stroke="black" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/>
						</svg>
					</a>
				</span>
			</div>
		</div>

		<div class="js-shipping-calculator-form shipping-calculator-form transition-up position-absolute w-100">

			{# Shipping calculator input #}

			{% embed "snipplets/forms/form-input.tpl" with{type_tel: true, input_value: cart_zipcode, input_name: 'zipcode', input_custom_class: 'js-shipping-input d-block form-control-line', input_placeholder: "Informe seu CEP", input_aria_label: 'Tu código postal' | translate, input_label: false, input_append_content: true, input_group_custom_class: 'mb-3'} %}
				{% block input_append_content %}
					<div class="js-calculate-shipping btn form-control-btn form-control-line-btn mt-2 pt-1" aria-label="{{ 'Calcular envío' | translate }}">	
						<span class="js-calculate-shipping-wording d-inline-block">
							<svg width="11" height="10" viewBox="0 0 11 10" fill="none" xmlns="http://www.w3.org/2000/svg">
								<path d="M10.606 5.42188L6.48096 9.35938C6.24658 9.57031 5.89502 9.57031 5.68408 9.33594C5.47314 9.10156 5.47314 8.75 5.70752 8.53906L8.82471 5.5625H0.855957C0.527832 5.5625 0.293457 5.32812 0.293457 5C0.293457 4.69531 0.527832 4.4375 0.855957 4.4375H8.82471L5.70752 1.48438C5.47314 1.27344 5.47314 0.898438 5.68408 0.6875C5.89502 0.453125 6.27002 0.453125 6.48096 0.664062L10.606 4.60156C10.7231 4.71875 10.7935 4.85938 10.7935 5C10.7935 5.16406 10.7231 5.30469 10.606 5.42188Z" fill="white"/>
							</svg>
						</span>
						<span class="loading ml-1" style="display: none;">
							<svg class="icon-inline icon-spin icon-md ml-2"><use xlink:href="#spinner-third"/></svg>
						</span>
					</div>
				{% endblock input_append_content %}
				{% block input_form_alert %}
				{% set zipcode_help_countries = ['BR', 'AR', 'MX'] %}
				{% if store.country in zipcode_help_countries %}
					{% set zipcode_help_ar = 'https://www.correoargentino.com.ar/formularios/cpa' %}
					{% set zipcode_help_br = 'http://www.buscacep.correios.com.br/sistemas/buscacep/' %}
					{% set zipcode_help_mx = 'https://www.correosdemexico.gob.mx/SSLServicios/ConsultaCP/Descarga.aspx' %}
					<a class="btn-link font-small my-2 {% if product_detail %} js-shipping-zipcode-help {% endif %}" href="{% if store.country == 'AR' %}{{ zipcode_help_ar }}{% elseif store.country == 'BR' %}{{ zipcode_help_br }}{% elseif store.country == 'MX' %}{{ zipcode_help_mx }}{% endif %}" target="_blank">{{ "No sé mi código postal" | translate }}</a>
				{% endif %}
				<div class="js-ship-calculator-error invalid-zipcode alert alert-danger mt-1" style="display: none;">
					
					{# Specific error message considering if store has multiple languages #}

					{% for language in languages %}
						{% if language.active %}
							{% if languages | length > 1 %}
								{% set wrong_zipcode_wording = ' para ' | translate ~ language.country_name ~ '. Podés intentar con otro o' | translate %}
							{% else %}
								{% set wrong_zipcode_wording = '. ¿Está bien escrito?' | translate %}
							{% endif %}
							{{ "No encontramos este código postal{1}" | translate(wrong_zipcode_wording) }}

							{% if languages | length > 1 %}
								<a href="#" data-toggle="#{% if product_detail %}product{% else %}cart{% endif %}-shipping-country" class="js-modal-open js-open-over-modal btn-link">
									{{ 'cambiar tu país de entrega' | translate }}
								</a>
							{% endif %}
						{% endif %}
					{% endfor %}
				</div>
				<div class="js-ship-calculator-error js-ship-calculator-common-error alert alert-danger" style="display: none;">{{ "Ocurrió un error al calcular el envío. Por favor intentá de nuevo en unos segundos." | translate }}</div>
				<div class="js-ship-calculator-error js-ship-calculator-external-error alert alert-danger" style="display: none;">{{ "El calculo falló por un problema con el medio de envío. Por favor intentá de nuevo en unos segundos." | translate }}</div>
				{% endblock input_form_alert %}
				{% block input_add_on %}
					{% if shipping_calculator_variant %}
						<input type="hidden" name="variant_id" id="shipping-variant-id" value="{{ shipping_calculator_variant.id }}">
					{% endif %}
				{% endblock input_add_on %}
			{% endembed %}
		</div>
	</div>
	<div class="js-shipping-calculator-spinner pt-3 pb-4" style="display: none;">
		{% include "snipplets/placeholders/shipping-placeholder.tpl"%}
	</div>
	<div class="js-shipping-calculator-response transition-soft {% if product_detail %}list {% else %} radio-buttons-group{% endif %}" style="display: none;"></div>
</div>

{# Shipping country modal #}

{% if languages | length > 1 %}

	{% if product_detail %}
		{% set country_modal_id = 'product-shipping-country' %}
	{% else %}
		{% set country_modal_id = 'cart-shipping-country' %}
	{% endif %}

	{% embed "snipplets/modal.tpl" with{modal_id: country_modal_id, modal_class: 'bottom modal-centered-small js-modal-shipping-country', modal_position: 'center', modal_position_desktop: 'bottom', modal_transition: 'slide', modal_header_title: true, modal_footer: true, modal_width: 'centered', modal_zindex_top: true, modal_mobile_full_screen: false} %}
		{% block modal_head %}
			{{ 'País de entrega' | translate }}
		{% endblock %}
		{% block modal_body %}
			{% embed "snipplets/forms/form-select.tpl" with{select_label: true, select_label_name: 'País donde entregaremos tu compra' | translate, select_aria_label: 'País donde entregaremos tu compra' | translate, select_custom_class: 'js-country-select' } %}
				{% block select_options %}
					{% for language in languages %}
						<option value="{{ language.country }}" data-country-url="{{ language.url }}" {% if language.active %}selected{% endif %}>{{ language.country_name }}</option>
					{% endfor %}
				{% endblock select_options%}
			{% endembed %}
		{% endblock %}
		{% block modal_foot %}
			<a href="#" class="js-save-shipping-country btn btn-primary d-inline-block">{{ 'Aplicar' | translate }}</a>
		{% endblock %}
	{% endembed %}
{% endif %}
