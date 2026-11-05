{% if template == 'product' and not home_main_product and not quickshop %}
    {% import 'snipplets/product-name-pt.tpl' as oe_whatsapp_titles %}
    {% set oe_whatsapp_name = (oe_whatsapp_titles.get(product.id, product.name, current_language, languages) ~ '') | trim %}
    {% set oe_whatsapp_message = 'Olá! Eu gostaria de mais informações sobre: ' ~ oe_whatsapp_name ~ ' - ' ~ product.url %}
    <div class="col-12 eora-product-whatsapp-row">
        <a class="js-product-whatsapp eora-product-whatsapp"
           href="https://wa.me/5519999285508?text={{ oe_whatsapp_message | url_encode | escape }}"
           data-product-id="{{ product.id }}"
           data-product-url="{{ product.url | escape }}"
           data-product-name="{{ oe_whatsapp_name | escape }}"
           target="_blank" rel="noopener noreferrer">
            <svg class="icon-inline" aria-hidden="true" focusable="false"><use xlink:href="#whatsapp"/></svg>
            <span>Consulte-nos pelo WhatsApp</span>
        </a>
    </div>
{% endif %}
