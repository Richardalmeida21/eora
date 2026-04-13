{# Check if store has free shipping without regions or categories #}

{% set has_free_shipping = cart.free_shipping.cart_has_free_shipping or cart.free_shipping.min_price_free_shipping.min_price %}
{% set has_free_shipping_bar = has_free_shipping and cart.free_shipping.min_price_free_shipping.min_price_raw > 0 %}

{% if has_free_shipping_bar %}
  
  {# includes free shipping progress bar: only if store has free shipping with a minimum #}
  
  {% if cart_page %}
    <div class="d-block d-md-none">
  {% endif %}
      {% include "snipplets/shipping/shipping-free-rest.tpl" %}
  {% if cart_page %}
    </div>
  {% endif %}

{% endif %}

{# IMPORTANT Do not remove this hidden subtotal, it is used by JS to calculate cart total #}
<div class="subtotal-price hidden" data-priceraw="{{ cart.subtotal }}"></div>

{# Used to assign currency to total #}
<div id="store-curr" class="hidden">{{ cart.currency }}</div>

{# Define conditions to show shipping calculator and store branches on cart #}

{% set show_calculator_on_cart = settings.shipping_calculator_cart_page and store.has_shipping %}
{% set show_cart_fulfillment = settings.shipping_calculator_cart_page and (store.has_shipping or store.branches) %}

{# Cart subtotals for cart popup #}

{% if not cart_page %}

  {# Cart popup subtotal #}
  
  {% if settings.show_price_and_subprice %}
    <div class="js-visible-on-cart-filled row mb-3 font-weight-normal" {% if cart.items_count == 0 %}style="display:none;"{% endif %} data-store="cart-subtotal">
      <span {% if not cart_page %}class="col-7"{% endif %}>
        <span class="font-weight-bold">{{ "Subtotal" | translate }}</span>
        
        <small class="js-subtotal-shipping-wording" {% if not (cart.has_shippable_products or show_calculator_on_cart) %}style="display: none"{% endif %}>{{ " (sin envío)" | translate }}</small>
        :
      </span>
      <span class="js-ajax-cart-total js-cart-subtotal font-weight-bold {% if not cart_page %}col{% endif %} text-right" data-priceraw="{{ cart.subtotal }}" data-component="cart.subtotal" data-component-value={{ cart.subtotal }}>{{ cart.subtotal | money }}</span>
    </div>
  {% endif %}

  {# Cart popup promos #}

  <div class="js-total-promotions text-accent">
    <span class="js-promo-discount" style="display:none;"> {{ "Descuento" | translate }}</span>
    <span class="js-promo-in" style="display:none;">{{ "en" | translate }}</span>
    <span class="js-promo-all" style="display:none;">{{ "todos los productos" | translate }}</span>
    <span class="js-promo-buying" style="display:none;"> {{ "comprando" | translate }}</span>
    <span class="js-promo-units-or-more" style="display:none;"> {{ "o más" | translate }}</span>
    {% for promotion in cart.promotional_discount.promotions_applied %}
      {% if(promotion.scope_value_id) %}
        {% set id = promotion.scope_value_id %}
      {% else %}
        {% set id = 'all' %}
      {% endif %}
        <span class="js-total-promotions-detail-row row mb-3" id="{{ id }}">
          <span class="col pr-3">
            {% if promotion.discount_script_type != "custom" %}
              {% if promotion.discount_script_type == "NAtX%off" %}
                {{ promotion.selected_threshold.discount_decimal_percentage * 100 }}% OFF
              {% elseif promotion.isBuyXPayY %}
                {{ promotion.buy }}x{{ promotion.pay }}
              {% elseif promotion.isCrossSelling %}
                {{ "Descuento" | translate }}  
              {% else %}
                {{ promotion.discount_script_type }}
              {% endif %}

              {{ "en" | translate }} {% if id == 'all' %}{{ "todos los productos" | translate }}{% else %}{{ promotion.scope_value_name }}{% endif %}

              {% if promotion.discount_script_type == "NAtX%off" %}
                <span>{{ "Comprando {1} o más" | translate(promotion.selected_threshold.quantity) }}</span>
              {% endif %}
            {% else %}
              {{ promotion.scope_value_name }}
            {% endif %}
            :
          </span>
          <span class="col-auto text-right">-{{ promotion.total_discount_amount_short }}</span>
        </span>
    {% endfor %}
  </div>
{% endif %}

{% if cart_page %}

  {# Cart page subtotal #}

  <div id="cart-sticky-summary" class="position-sticky-md cart-page-totals">
    {% if has_free_shipping_bar %}
      {# includes free shipping progress bar: only if store has free shipping with a minimum #}
    
      <div class="d-none d-md-block">
        {% include "snipplets/shipping/shipping-free-rest.tpl" %}
      </div>
    {% endif %}
    {% if settings.show_price_and_subprice %}
      <div class="js-visible-on-cart-filled row no-gutters mb-3" {% if cart.items_count == 0 %}style="display:none;"{% endif %} data-store="cart-subtotal">
        <span class="col-auto pl-md-0">
          {{ "Subtotal" | translate }}:
        </span>
        <span class="js-ajax-cart-total js-cart-subtotal col text-right pr-md-0" data-priceraw="{{ cart.subtotal }}">{{ cart.subtotal | money }}</span>
      </div>
    {% endif %}
    {# Cart page promos #}

    <div class="js-total-promotions text-accent">
      <span class="js-promo-discount" style="display:none;">{{ "Descuento" | translate }}</span>
      <span class="js-promo-in" style="display:none;">{{ "en" | translate }}</span>
      <span class="js-promo-all" style="display:none;">{{ "todos los productos" | translate }}</span>
      <span class="js-promo-buying" style="display:none;"> {{ "comprando" | translate }}</span>
      <span class="js-promo-units-or-more" style="display:none;"> {{ "o más" | translate }}</span>
      {% for promotion in cart.promotional_discount.promotions_applied %}
        {% if(promotion.scope_value_id) %}
          {% set id = promotion.scope_value_id %}
        {% else %}
          {% set id = 'all' %}
        {% endif %}
          <span class="js-total-promotions-detail-row row no-gutters mb-3" id="{{ id }}">
            <span class="col pr-3">
              {% if promotion.discount_script_type != "custom" %}
                {% if promotion.discount_script_type == "NAtX%off" %}
                  {{ promotion.selected_threshold.discount_decimal_percentage * 100 }}% OFF
                {% elseif promotion.isBuyXPayY %}
                  {{ promotion.buy }}x{{ promotion.pay }}
                {% elseif promotion.isCrossSelling %}
                  {{ "Descuento" | translate }}
                {% else %}
                  {{ promotion.discount_script_type }}
                {% endif %}

                {{ "en" | translate }} {% if id == 'all' %}{{ "todos los productos" | translate }}{% else %}{{ promotion.scope_value_name }}{% endif %}

                {% if promotion.discount_script_type == "NAtX%off" %}
                  <span>{{ "Comprando {1} o más" | translate(promotion.selected_threshold.quantity) }}</span>
                {% endif %}
              {% else %}
                {{ promotion.scope_value_name }}
              {% endif %}
              :
            </span>
            <span class="col-auto text-right pr-md-0">-{{ promotion.total_discount_amount_short }}</span>
          </span>
      {% endfor %}
    </div>

    {# Cart page shipping costs #}
    
    {% if show_calculator_on_cart %}
      <div id="shipping-cost-container" class="js-fulfillment-info js-visible-on-cart-filled js-shipping-cost-table mb-3 row no-gutters" {% if cart.items_count == 0 or (not cart.has_shippable_products) %}style="display:none;"{% endif %}>
        <span class="col-auto pl-md-0">{{ 'Envío:' | translate }}</span>
        <span id="shipping-cost" class="col text-right opacity-40 pr-md-0">
          {{ "Calculalo para verlo" | translate }}
        </span>
        <span class="js-calculating-shipping-cost col text-right opacity-40 pr-md-0" style="display: none">
          {{ "Calculando" | translate }}...
        </span>
        <span class="js-shipping-cost-empty col text-right opacity-40 pr-md-0" style="display: none">
          {{ "Calculalo para verlo" | translate }}
        </span>
      </div>
    {% endif %}
{% else %}

  {# Cart fulfillment #}

  {% include "snipplets/shipping/cart-fulfillment.tpl" %}
{% endif %}
  
    {# Cart page and popup total #}

    {% if settings.show_price_and_subprice %}
      <div class="js-cart-total-container js-visible-on-cart-filled" {% if cart.items_count == 0 %}style="display:none;"{% endif %} data-store="cart-total">
        <div class="row {% if cart_page %}no-gutters{% endif %} mb-3 h4 font-family-body">
          <span class="col-auto {% if cart_page %}pl-md-0{% endif %}">{{ "Total" | translate }}:</span>
          <span class="js-cart-total {% if cart.free_shipping.cart_has_free_shipping %}js-free-shipping-achieved{% endif %} {% if cart.shipping_data.selected %}js-cart-saved-shipping{% endif %} col text-right {% if cart_page %}pr-md-0{% endif %}" data-component="cart.total" data-component-value={{ cart.total }}>{{ cart.total | money }}</span>
          <span class="col-12 {% if cart_page %}pr-md-0{% endif %}">
            <div class="eora-cart-pix-whole" data-cart-total="{{ cart.total }}">
              <div class="eora-cart-pix-display text-right mt-1"></div>
            </div>
          </span>
        </div>

        {# IMPORTANT Do not remove this hidden total, it is used by JS to calculate cart total #}
        <div class='total-price hidden'>
          {{ "Total" | translate }}: {{ cart.total | money }}
        </div>
      </div>
    {% endif %}

    <div class="js-visible-on-cart-filled" {% if cart.items_count == 0 %}style="display:none;"{% endif %}>

      {# Cart page and popup CTA Module #}
      
      {% set cart_total = (settings.cart_minimum_value * 100) %}

      {% if cart_page %}

        {# Cart page CTA and minimum alert: Needs to be present or absence on DOM to work correctly with minimum price feature #}

        {% if cart.checkout_enabled %}
          <input id="go-to-checkout" class="btn btn-primary btn-big btn-block mb-3" type="submit" name="go_to_checkout" value="{{ 'Iniciar Compra' | translate }}"/>
        {% else %}

          {# Cart minium alert #}
          
          <div class="alert alert-warning w-100 mb-2 text-center">
            {{ "El monto mínimo de compra es de {1} sin incluir el costo de envío" | t(cart_total | money) }}
          </div>
        {% endif %}
      {% else %}

        {# Cart popup CTA and minimum alert #}

        {# PIX e parcelas - popup carrinho #}
        <div class="eora-cart-pix-whole eora-cart-pix-popup" data-cart-total="{{ cart.total }}">
          <div class="eora-cart-pix-display"></div>
        </div>

        <div class="js-ajax-cart-submit mb-3" {{ not cart.checkout_enabled ? 'style="display:none"' }} id="ajax-cart-submit-div" >
          <input class="btn btn-primary btn-big btn-block" type="submit" name="go_to_checkout" value="comprar" data-component="cart.checkout-button"/>
          <div class="cart-total-price subtotal-price" data-priceraw="{{ cart.subtotal }}">{{ cart.subtotal | money }}</div>

          {# <p class="cart-total-price">
            <strong>
              {{ cart.total | money }}
            </strong>
          </p> #}
        </div>
        <div class="js-ajax-cart-minimum alert alert-warning mb-2 text-center" {{ cart.checkout_enabled ? 'style="display:none"' }} id="ajax-cart-minumum-div">
          {{ "El monto mínimo de compra es de {1} sin incluir el costo de envío" | t(cart_total | money) }}
        </div>

        <input type="hidden" id="ajax-cart-minimum-value" value="{{ cart_total  }}"/>
      {% endif %}

      {# Cart panel continue buying link #}

      {% if settings.continue_buying %}
        <div class="text-center w-100 {% if not cart_page %}{% endif %}">
          <a href="{% if cart_page %}{{ store.products_url }}{% else %}#{% endif %}" class="{% if not cart_page %}js-modal-close js-fullscreen-modal-close{% endif %} btn-link font-small">{{ 'Ver más productos' | translate }}</a>
        </div>
      {% endif %}
    </div>
{% if cart_page %}
  {# End of sticky module #}
  </div>
{% endif %}

<style>
.eora-cart-pix-display {
  display: flex;
  flex-direction: column;
  gap: 3px;
}
.eora-cart-pix-whole.eora-cart-pix-popup .eora-cart-pix-display {
  align-items: flex-end;
  padding: 6px 0 4px;
  border-bottom: 1px solid #f0f0f0;
  margin-bottom: 8px;
}
.eora-cart-pix-line {
  font-size: 12px;
  color: #00aa6c;
  font-weight: 600;
  display: flex;
  align-items: center;
  gap: 6px;
  line-height: 1.3;
}
.eora-cart-pix-badge {
  font-size: 9px;
  background: #00aa6c;
  color: #fff;
  padding: 2px 5px;
  border-radius: 3px;
  font-weight: 700;
  white-space: nowrap;
}
.eora-cart-inst-line {
  font-size: 11px;
  color: #888;
  line-height: 1.3;
}
.eora-notif-pix-display {
  display: flex;
  flex-direction: column;
  align-items: flex-end;
  gap: 3px;
  padding-top: 4px;
}
</style>

<script>
(function () {
  function fmtBRL(v) {
    return 'R$\u00a0' + v.toLocaleString('pt-BR', { minimumFractionDigits: 2, maximumFractionDigits: 2 });
  }
  function renderPixInfo(display, total) {
    if (!display) return;
    var newHTML = '';
    if (total > 0) {
      var pix = total * 0.93;
      var n = Math.max(1, Math.min(10, Math.floor(total / 110)));
      var inst = total / n;
      newHTML =
        '<span class="eora-cart-pix-line">PIX: ' + fmtBRL(pix) + ' <span class="eora-cart-pix-badge">7% OFF</span></span>' +
        (n > 1 ? '<span class="eora-cart-inst-line">ou ' + n + 'x de ' + fmtBRL(inst) + ' sem juros</span>' : '');
    }
    if (display.innerHTML !== newHTML) display.innerHTML = newHTML;
  }
  function parseMoneyBRL(txt) {
    if (!txt) return 0;
    var s = ('' + txt).replace(/[^\d,]/g, '').replace(',', '.');
    return parseFloat(s) || 0;
  }
  function getCartTotal() {
    // Platform updates text content via AJAX but NOT data-component-value attribute
    var totalEl = document.querySelector('[data-component="cart.total"]');
    if (totalEl) {
      var v = parseMoneyBRL(totalEl.textContent);
      if (v > 0) return v;
    }
    var anyTotal = document.querySelector('.js-cart-total');
    if (anyTotal) {
      var v2 = parseMoneyBRL(anyTotal.textContent);
      if (v2 > 0) return v2;
    }
    if (totalEl) {
      var raw = totalEl.getAttribute('data-component-value');
      if (raw) { var v3 = parseFloat(raw); if (v3 > 0) return v3 / 100; }
    }
    return 0;
  }
  function updateAllPixDisplays() {
    var liveTotal = getCartTotal();
    document.querySelectorAll('.eora-cart-pix-whole').forEach(function (wrapper) {
      var display = wrapper.querySelector('.eora-cart-pix-display');
      if (!display) return;
      var total = liveTotal;
      if (total <= 0) {
        var raw = wrapper.getAttribute('data-cart-total');
        total = raw ? parseFloat(raw) / 100 : 0;
      }
      renderPixInfo(display, total);
    });
  }
  function updateNotifPix() {
    var notifModal = document.getElementById('related-products-notification');
    if (!notifModal) return;
    var display = notifModal.querySelector('.eora-notif-pix-display');
    if (!display) return;
    var totalEl = notifModal.querySelector('.js-cart-total');
    var total = totalEl ? parseMoneyBRL(totalEl.textContent) : 0;
    if (total <= 0) total = getCartTotal();
    renderPixInfo(display, total);
  }
  function listenCartReleased() {
    document.addEventListener('cart.released', function() {
      var source = document.querySelector('[data-component="cart-button"] .js-cart-widget-amount');
      if (!source) return;
      var n = parseInt(source.textContent.trim(), 10);
      if (isNaN(n) || n < 0) return;
      document.querySelectorAll('.js-cart-widget-amount').forEach(function(el) {
        if (el !== source && parseInt(el.textContent.trim(), 10) !== n) el.textContent = n;
      });
    });
  }
  function watchCartPanel() {
    var panel = document.getElementById('modal-cart');
    if (!panel) panel = document.querySelector('.js-ajax-cart-panel');
    if (!panel) { setTimeout(watchCartPanel, 500); return; }
    var debounceTimer = null;
    var isUpdating = false;
    new MutationObserver(function (m) {
      if (isUpdating) return;
      var relevant = false;
      m.forEach(function (x) {
        if (x.type === 'characterData') {
          var el = x.target.parentElement;
          if (el && (el.classList.contains('js-cart-total') || (el.getAttribute && el.getAttribute('data-component') === 'cart.total'))) relevant = true;
        } else if (x.type === 'attributes') {
          var tgt = x.target;
          var isPix = tgt && tgt.classList && (tgt.classList.contains('eora-cart-pix-whole') || tgt.classList.contains('eora-cart-pix-display'));
          if (!isPix) relevant = true;
        } else if (x.type === 'childList' && x.addedNodes.length) {
          var tgt = x.target;
          var isPix = tgt && tgt.classList && (tgt.classList.contains('eora-cart-pix-display') || tgt.classList.contains('eora-cart-pix-whole'));
          if (!isPix) relevant = true;
        }
      });
      if (!relevant) return;
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(function () {
        isUpdating = true;
        updateAllPixDisplays();
        isUpdating = false;
      }, 300);
    }).observe(panel, {
      childList: true,
      subtree: true,
      characterData: true,
      attributes: true,
      attributeFilter: ['data-component-value', 'data-priceraw', 'style', 'class']
    });
  }
  function watchNotifModal() {
    var notifModal = document.getElementById('related-products-notification');
    if (!notifModal) return;
    var debounceTimer = null;
    var isUpdating = false;
    new MutationObserver(function (m) {
      if (isUpdating) return;
      var relevant = false;
      m.forEach(function (x) {
        if (x.type === 'attributes') relevant = true;
        if (x.type === 'characterData') relevant = true;
        if (x.type === 'childList' && x.addedNodes.length) relevant = true;
      });
      if (!relevant) return;
      clearTimeout(debounceTimer);
      debounceTimer = setTimeout(function () {
        isUpdating = true;
        updateNotifPix();
        isUpdating = false;
      }, 150);
    }).observe(notifModal, {
      childList: true,
      subtree: true,
      characterData: true,
      attributes: true,
      attributeFilter: ['style', 'class']
    });
  }
  function init() {
    updateAllPixDisplays();
    watchCartPanel();
    watchNotifModal();
    listenCartReleased();
  }
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', init);
  } else {
    init();
  }
}());
</script>
