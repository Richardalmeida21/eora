<div class="product-infos">    
    {% set brand_product = product.brand %}
    {% if brand_product %}
        {% include 'snipplets/selo-brand.tpl' with {'product_brand': brand_product, 'product_page': true} %}
    {% endif %}

    {# Product name #}
    <h2 class="js-product-name mb-3">{{ product.name }}</h2>    

    {# Product SKU #}

    {% if settings.product_sku and product.sku %}
        <div class="font-small opacity-60 mb-3">
            {{ "SKU" | translate }}: <span class="js-product-sku">{{ product.sku }}</span>
        </div>
    {% endif %}

    {# Product price #}

    <div class="price-container mb-3" data-store="product-price-{{ product.id }}">
        <div class="item-price-block mb-1">
            <span class="d-inline-block mr-1">
                <div class="js-price-display item-price" id="price_display" {% if not product.display_price %}style="display:none;"{% endif %} data-product-price="{{ product.price }}">{% if product.display_price %}{{ product.price | money }}{% endif %}</div>
            </span>
            <span class="d-inline-block font-big">
                <div id="compare_price_display" class="js-compare-price-display price-compare item-price" {% if not product.compare_at_price or not product.display_price %}style="display:none;"{% else %} style="display:block;"{% endif %}>{% if product.compare_at_price and product.display_price %}{{ product.compare_at_price | money }}{% endif %}</div>
            </span>

            {{ component('price-without-taxes', {
                    container_classes: "mt-1 mb-2 font-small opacity-60",
                })
            }}
            {% if settings.payment_discount_price and not reduced_item %}
                <span class="discount-pix">
                    <svg class="icon-inline icon-w-14"><use xlink:href="#pix"/></svg>
                    {{ component('payment-discount-price', {
                            visibility_condition: settings.payment_discount_price and not reduced_item,
                            location: 'product',
                            container_classes: "font-small",
                        }) 
                    }}
                </span>
            {% endif %}
            
        </div>

        {% set installments_info = product.installments_info_from_any_variant %}
        {% set hasDiscount = product.maxPaymentDiscount.value > 0 %}
        {% set show_payments_info = settings.product_detail_installments and product.show_installments and product.display_price and installments_info %}
        {% set show_modal_payments = settings.modal_pagamentos %}
        {% if not home_main_product and (show_payments_info or hasDiscount) %}
            <div {% if show_modal_payments and installments_info %}data-toggle="#installments-modal" data-modal-url="modal-fullscreen-payments"{% endif %} class="{% if show_modal_payments and installments_info %}js-modal-open js-fullscreen-modal-open{% endif %} js-product-payments-container" {% if not (product.get_max_installments and product.get_max_installments(false)) %}style="display: none;"{% endif %}>
        {% endif %}
            {% if show_payments_info %}
                {{ component('installments', {'location' : 'product_detail', container_classes: { installment: "item-installments"}}) }}
            {% endif %}

            {# DESCONTO DO PIX DE OUTRA FORMA #}
            {#{% set hideDiscountContainer = not (hasDiscount and product.showMaxPaymentDiscount) %}
            {% set hideDiscountDisclaimer = not product.showMaxPaymentDiscountNotCombinableDisclaimer %}

            <div class="js-product-discount-container my-1 font-small" {% if hideDiscountContainer %}style="display: none;"{% endif %}>
                <span class="text-accent">{{ product.maxPaymentDiscount.value }}% {{'de descuento' | translate }}</span> {{'pagando con' | translate }} {{ product.maxPaymentDiscount.paymentProviderName }}
                <div class="js-product-discount-disclaimer opacity-60 mt-1" {% if hideDiscountDisclaimer %}style="display: none;"{% endif %}>
                    {{ "No acumulable con otras promociones" | translate }}
                </div>
            </div> #}

        {% if show_modal_payments and (show_payments_info or hasDiscount) %}
            <a id="btn-installments" class="d-inline-block btn-link mt-1 font-small" href="#" {% if not (product.get_max_installments and product.get_max_installments(false)) %}style="display: none;"{% endif %}>
                {% if not hasDiscount and not settings.product_detail_installments %}
                    {{ "Ver medios de pago" | translate }}
                {% else %}
                    {{ "Ver más detalles" | translate }}
                {% endif %}
            </a>
        {% endif %}

        {# Product availability #}

        {% set show_product_quantity = product.available and product.display_price %}

        {# Free shipping minimum message #}
        {% set has_free_shipping = cart.free_shipping.cart_has_free_shipping or cart.free_shipping.min_price_free_shipping.min_price %}
        {% set has_product_free_shipping = product.free_shipping %}
        {% set has_free_shipping_msg_product = settings.free_shipping_msg_product %}

        {% if not product.is_non_shippable and show_product_quantity and (has_free_shipping or has_product_free_shipping) and has_free_shipping_msg_product %}
            <div class="free-shipping-message pt-1 mb-4 font-small">
                <span class="text-accent">{{ "Envío gratis" | translate }}</span>
                <span {% if has_product_free_shipping %}style="display: none;"{% else %}class="js-shipping-minimum-label"{% endif %}>
                    {{ "superando los" | translate }} <span>{{ cart.free_shipping.min_price_free_shipping.min_price }}</span>
                </span>
                {% if not has_product_free_shipping %}
                    <div class="js-free-shipping-discount-not-combinable font-small opacity-60 mt-1">
                        {{ "No acumulable con otras promociones" | translate }}
                    </div>
                {% endif %}
            </div>
        {% endif %}
    </div>

    </div>
    {# Product Description #}
    {% if settings.full_width_description %}
        <div class="js-product-description-short product-description-short mb-3"></div>
    {% endif %}


    {# Promotional text #}

    {{ component('promotions-details', {
        promotions_details_classes: {
            container: 'js-product-promo-container px-0 mb-2' ~ (not home_main_product ? ' col-md-8' : ''),
            promotion_title: 'mb-1 mt-4 text-accent',
            valid_scopes: 'font-small mb-0',
            categories_combinable: 'font-small mb-0',
            not_combinable: 'font-small opacity-60 mb-0',
            progressive_discounts_table: 'table mb-2 mt-3',
            progressive_discounts_show_more_link: 'btn-link btn-link-primary mb-4',
            progressive_discounts_show_more_icon: 'icon-inline',
            progressive_discounts_hide_icon: 'icon-inline icon-flip-vertical',
            progressive_discounts_promotion_quantity: 'font-weight-light text-lowercase'
        },
        accordion_show_svg_id: 'chevron-down',
        accordion_hide_svg_id: 'chevron-down',
    }) }}

    {# Product form, includes: Variants, CTA and Shipping calculator #}

    <form id="product_form" class="js-product-form" method="post" action="{{ store.cart_url }}" data-store="product-form-{{ product.id }}">
        <input type="hidden" name="add_to_cart" value="{{product.id}}" />
        {% if template == "product" %}
            {% set show_size_guide = true %}
        {% endif %}
        {% if product.variations or settings.product_by_reference %}
            {% include "snipplets/product/product-variants.tpl" with {show_size_guide: show_size_guide, current_product: product} %}
        {% endif %}

        {% if settings.last_product and show_product_quantity %}
            <div class="{% if product.variations %}js-last-product{% endif %} text-accent mb-3"{% if product.selected_or_first_available_variant.stock != 1 %} style="display: none;"{% endif %}>
                {{ settings.last_product_text }}
            </div>
        {% endif %}

        <div class="row mb-0 {% if settings.product_stock %}mb-md-3{% endif %}">
            {% set product_quantity_home_product_value = home_main_product ? true : false %}
            {% set hidden_quantity_selector =  settings.show_quantity_selector   %}
            {% if show_product_quantity %}
                {% include "snipplets/product/product-quantity.tpl" with {'hidden_quantity_selector': hidden_quantity_selector} %}
            {% endif %}
            {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
            {% set texts = {'cart': "Comprar", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}
            
            <div class="{% if show_product_quantity and hidden_quantity_selector %}col-6{% else %}col-12{% endif %} pb-1 mb-2">

                {# Add to cart CTA #}
                <input type="submit" class="js-addtocart js-prod-submit-form btn-add-to-cart btn btn-primary btn-big btn-block {{ state }}" value="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} data-store="product-buy-button" data-component="product.add-to-cart"/>

                {# Fake add to cart CTA visible during add to cart event #}

                {% include 'snipplets/placeholders/button-placeholder.tpl' with {custom_class: "btn-big"} %}

            </div>

            {# mKFashion Provador Virtual - Tip Card #}
            {% if product.sku %}
            <div id="tip-card-provador" class="col-12 pb-1 mb-2" style="display: none;">
                <button
                    type="button"
                    class="js-tip-card-btn btn-tip-card"
                    data-mkfashion-identifier="{{ product.sku }}"
                >
                    <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                        <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
                        <circle cx="12" cy="13" r="4"/>
                    </svg>
                    EXPERIMENTE AGORA
                </button>
            </div>
            {% endif %}

            {% if settings.ajax_cart %}
                <div class="col-12">
                    <div class="js-added-to-cart-product-message font-small my-3" style="display: none;">
                        <svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#check"/></svg>
                        <span>
                            {{'Ya agregaste este producto.' | translate }}<a href="#" class="js-modal-open js-open-cart js-fullscreen-modal-open btn-link font-small ml-1" data-toggle="#modal-cart" data-modal-url="modal-fullscreen-cart">{{ 'Ver carrito' | translate }}</a>
                        </span>
                    </div>
                </div>
            {% endif %}

            {# Free shipping visibility message #}

            {% set free_shipping_minimum_label_changes_visibility = has_free_shipping and cart.free_shipping.min_price_free_shipping.min_price_raw > 0 %}

            {% set include_product_free_shipping_min_wording = cart.free_shipping.min_price_free_shipping.min_price_raw > 0 %}

            {% if not product.is_non_shippable and show_product_quantity and has_free_shipping and not has_product_free_shipping %}
                <div class="px-3">

                    {# Free shipping add to cart message #}

                    {% if include_product_free_shipping_min_wording %}

                        {% include "snipplets/shipping/shipping-free-rest.tpl" with {'product_detail': true} %}

                    {% endif %}

                    {# Free shipping achieved message #}

                    {# <div class="{% if free_shipping_minimum_label_changes_visibility %}js-free-shipping-message{% endif %} text-accent font-small my-2 pt-1" {% if not cart.free_shipping.cart_has_free_shipping %}style="display: none;"{% endif %}>
                        {{ "¡Genial! Tenés envío gratis" | translate }}
                    </div> #}
                </div>
            {% endif %}

            {% include "snipplets/product/product-light-blocking.tpl" %}

        </div>

        {% if template == 'product' %}

            <div class="dropdown-wrapper js-dropdown-wrapper-content js-glasses-measurements-wrapper">
                <button class="dropdown-toggle" type="button">
                    <span class="js-title-dropdown title-dropdown">Medidas do óculos</span>
                    <svg class="dropdown-arrow icon-inline icon-xs svg-icon-text"><use xlink:href="#chevron"/></svg>
                </button>
                <div class="dropdown-content js-glasses-measurements"></div>
            </div>
            <div class="dropdown-wrapper js-dropdown-wrapper-content js-accessories-information-wrapper">
                <button class="dropdown-toggle" type="button">
                    <span class="js-title-dropdown title-dropdown">Informações</span>
                    <svg class="dropdown-arrow icon-inline icon-xs svg-icon-text"><use xlink:href="#chevron"/></svg>
                </button>
                <div class="dropdown-content js-accessories-information"></div>
            </div>

            {% set show_product_fulfillment = settings.shipping_calculator_product_page and (store.has_shipping or store.branches) and not product.free_shipping and not product.is_non_shippable %}

            {% if show_product_fulfillment %}
                {# <div class="mb-4 pb-2"> #}
                    {# Shipping calculator and branch link #}
                    <div class="shipping-dropdown">
                        <button class="dropdown-toggle" type="button">
                            <span>Calcule o seu frete</span>
                            <!-- caret -->
                            <svg class="caret" width="10" height="10" viewBox="0 0 10 10" fill="none">
                            <path d="M1 3L5 7L9 3" stroke="currentColor" stroke-width="1.5" stroke-linecap="round"/>
                            </svg>
                        </button>

                        <div class="dropdown-content">
                            {# Shipping calculator #}
                            <div id="product-shipping-container" class="product-shipping-calculator list" {% if not product.display_price or not product.has_stock %}style="display:none;"{% endif %} data-shipping-url="{{ store.shipping_calculator_url }}">
                                {% if store.has_shipping %}
                                    {% include "snipplets/shipping/shipping-calculator.tpl" with {'shipping_calculator_variant' : product.selected_or_first_available_variant, 'product_detail': true} %}
                                {% endif %}
                            </div>
                        </div>
                    {# </div> #}


                    {% if store.branches %}
                        {# Link for branches #}
                        {% include "snipplets/shipping/branches.tpl" with {'product_detail': true} %}
                    {% endif %}
                </div>

            {% endif %}
        {% endif %}
    </form>
</div>

{% if not home_main_product %}
    {# Product payments details #}
    {% include 'snipplets/product/product-payment-details.tpl' %}
{% endif %}