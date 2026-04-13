{% if product.compare_at_price > product.price %}
{% set price_discount_percentage = ((product.compare_at_price) - (product.price)) * 100 / (product.compare_at_price) %}
{% endif %}

{% set has_product_available = product.available and product.display_price %}

{% set store_has_free_shipping = not product.is_non_shippable and (product.free_shipping or (has_product_available and (cart.free_shipping.cart_has_free_shipping or cart.free_shipping.min_price_free_shipping.min_price))) %}

{% set product_price_above_free_shipping_minimum = cart.free_shipping.min_price_free_shipping and (product.price >= cart.free_shipping.min_price_free_shipping.min_price_raw) %}

{% set show_out_of_stock_label = not (product.has_stock and product.variations) or (product.variations and ((not product_detail and (settings.quick_shop or settings.product_color_variants)) or product_detail)) %}
{% set show_discount_labels = product.compare_at_price or product.promotional_offer %}

{% set has_multiple_slides = product.images_count > 1 or product.video_url %}

<div class="{% if product.video_url and product_detail %}js-labels-group{% endif %} labels {{ label_custom_class }}" data-store="product-item-labels">
  {% if show_out_of_stock_label %}
      <div class="js-stock-label label label-default mb-2{% if product_detail %} label-big{% endif %}" {% if product.has_stock %}style="display:none;"{% endif %}>{{ "Sin stock" | translate }}</div>
  {% endif %}
  {% if show_discount_labels and product.has_stock %}
    {% if product.compare_at_price or product.promotional_offer %}
      <div class="js-offer-label label label-accent mb-2{% if product_detail %} label-big{% endif %}" {% if (not product.compare_at_price and not product.promotional_offer) or not product.display_price %}style="display:none;"{% endif %} data-store="product-item-{% if product.compare_at_price %}offer{% else %}promotion{% endif %}-label">
        {% if product.promotional_offer %}
            {{ component('promotion-label-text') }}
        {% elseif product.compare_at_price %}
          -<span class="js-offer-percentage">{{ price_discount_percentage |round }}</span>% OFF
        {% endif %}
      </div>
    {% endif %}
  {% endif %}
  {% if store_has_free_shipping %}
    <div class="{% if not product.free_shipping %}js-free-shipping-minimum-label {% endif %} label label-accent{% if product_detail %} label-big{% endif %}" {% if not (product.free_shipping or product_price_above_free_shipping_minimum) or not settings.product_free_shipping %}style="display: none;"{% endif %}>{{ "Envío gratis" | translate }}</div>
  {% endif %}
</div>
<span class="hidden" data-store="stock-product-{{ product.id }}-{% if product.has_stock %}{% if product.stock %}{{ product.stock }}{% else %}infinite{% endif %}{% else %}0{% endif %}"></span>
