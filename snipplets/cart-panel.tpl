{% if settings.cart_message_show %}
  {% if settings.cart_message_link %}
    <a href="{{ settings.cart_message_link }}" class="cart-message">
      <svg width="11" height="11" viewBox="0 0 11 11" fill="none" xmlns="http://www.w3.org/2000/svg">
        <path d="M10.3398 1.44984L1.5625 10.1998C1.31641 10.4733 0.90625 10.4733 0.660156 10.1998C0.386719 9.95375 0.386719 9.54359 0.660156 9.27016L9.41016 0.547501C9.65625 0.274063 10.0664 0.274063 10.3398 0.547501C10.5859 0.793594 10.5859 1.20375 10.3398 1.44984ZM3.3125 1.86C3.3125 2.35219 3.03906 2.76234 2.65625 3.00844C2.24609 3.25453 1.72656 3.25453 1.34375 3.00844C0.933594 2.76234 0.6875 2.35219 0.6875 1.86C0.6875 1.39516 0.933594 0.985001 1.34375 0.738907C1.72656 0.492813 2.24609 0.492813 2.65625 0.738907C3.03906 0.985001 3.3125 1.39516 3.3125 1.86ZM10.3125 8.86C10.3125 9.35219 10.0391 9.76234 9.65625 10.0084C9.24609 10.2545 8.72656 10.2545 8.34375 10.0084C7.93359 9.76234 7.6875 9.35219 7.6875 8.86C7.6875 8.39516 7.93359 7.985 8.34375 7.73891C8.72656 7.49281 9.24609 7.49281 9.65625 7.73891C10.0391 7.985 10.3125 8.39516 10.3125 8.86Z" fill="white"/>
      </svg>
      <p>{{ settings.cart_message | raw }}</p>
    </a>
  {% endif %}
{% endif %}
<div class="js-ajax-cart-list container">
    {# Cart panel items #}
    {% if cart.items %}
      {% for item in cart.items %}
        {% include "snipplets/cart-item-ajax.tpl" %}
      {% endfor %}
    {% endif %}
</div>
<div class="js-empty-ajax-cart" {% if cart.items_count > 0 %}style="display:none;"{% endif %}>
 	{# Cart panel empty #}
    <div class="alert alert-info text-center" data-component="cart.empty-message">{{ "El carrito de compras está vacío." | translate }} </div>
</div>
<div id="error-ajax-stock" style="display: none;">
	<div class="alert alert-warning m-3">
     	{{ "¡Uy! No tenemos más stock de este producto para agregarlo al carrito. Si querés podés" | translate }}<a href="{{ store.products_url }}" class="btn-link font-small ml-1">{{ "ver otros acá" | translate }}</a>
    </div>
</div>

<div class="cart-row mt-auto">
    {% include "snipplets/cart-totals.tpl" %}
</div>

