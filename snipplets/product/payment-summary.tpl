{# Values are integer cents. Native installment components remain authoritative. #}
{% set payment_item = payment_product %}
{% set payment_has_price = payment_item.display_price and payment_item.price is defined and payment_item.price > 0 %}
{% if payment_has_price or payment_empty %}
    {% set payment_price = payment_has_price ? payment_item.price : 0 %}
    {% set payment_native = payment_item.get_max_installments or payment_item.installments_info_from_any_variant %}
    {% set payment_count = (payment_price / 11000) | round(0, 'floor') %}
    {% if payment_count > 10 %}{% set payment_count = 10 %}{% endif %}
    <div class="eora-product-payments" data-eora-payments data-price-cents="{{ payment_price }}" data-external-native-installments="{{ payment_native_installments ? 'true' : 'false' }}" data-native-installments="{{ payment_native ? 'true' : 'false' }}" data-installments-enabled="{{ payment_item.show_installments is defined and not payment_item.show_installments ? 'false' : 'true' }}"{% if not payment_has_price %} hidden{% endif %}>
        {% if payment_native and payment_item.show_installments is not same as(false) %}
            <div data-eora-native-installments>
                {% if not payment_native_installments %}
                    {% set payment_component_classes = {installment: 'item-installments'} %}
                    {% set payment_component_location = payment_location | default('product_item') %}
                    {{ component('installments', {'location': payment_component_location, 'short_wording': true, container_classes: payment_component_classes}) }}
                {% endif %}
            </div>
        {% endif %}
        <div class="eora-product-payments__installments" data-eora-fallback-installments{% if payment_native or payment_count < 2 or payment_item.show_installments is same as(false) %} hidden{% endif %}>{% if not payment_native and payment_count >= 2 and payment_item.show_installments is not same as(false) %}{{ payment_count }}x de {{ (payment_price / payment_count) | round(0, 'common') | money }} sem juros{% endif %}</div>
        <div class="eora-product-payments__pix"><svg aria-hidden="true" focusable="false"><use xlink:href="#pix"/></svg><strong data-eora-pix-price>{{ (payment_price * 95 / 100) | round(0, 'common') | money }}</strong> <span>no Pix</span> <span class="eora-product-payments__badge">5% OFF</span></div>
        {% set payment_freight_url = payment_shipping_url | default(payment_item.url ~ '#shipping') %}
        {% if payment_link is same as(false) %}<span class="eora-product-payments__shipping">Frete e prazo pelo CEP</span>{% else %}<a class="eora-product-payments__shipping" data-eora-shipping-link href="{{ payment_freight_url | escape }}">Frete e prazo pelo CEP</a>{% endif %}
    </div>
{% endif %}
