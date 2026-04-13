{# /*============================================================================
  #Item grid
==============================================================================*/

#Properties

#Slide Item

#}


{% set product_img_height =  settings.product_item_img_height | default(100) %}
{% set product_img_width =  settings.product_item_img_width | default(100) %}

{% set item_img_spacing = product_img_height / product_img_width * 100 %}

{% set slide_item = slide_item | default(false) %}
{% set look_item = look_item | default(false) %}



{% if template == 'home' or section_name starts with 'campaign_page_' %}
    {% set columns_desktop = section_columns_desktop %}
    {% set columns_mobile = section_columns_mobile %}
    {% set section_slider = section_slider %}
{% else %}
    {% set columns_desktop = settings.grid_columns_desktop %}
    {% set columns_mobile = settings.grid_columns_mobile %}
    {% if template == 'product'%}
        {% set section_slider = true %}
    {% endif %}
{% endif %}

{% set columns_mobile_class = columns_mobile == 1 ? 'col-12' : columns_mobile == 2 ? 'col-6' : loop.index % 5 == 1 ? 'col-12' : 'col-6' %}
{% set columns_desktop_class = columns_desktop == 2 ? 'col-md-6' : columns_desktop == 3 ? 'col-md-4' : columns_desktop == 4 ? 'col-md-3' : 'col-md-4' %}

{# {% if first_imagem %}
    {% for imagens_item in settings.categories_images_list  %}
        {% if category.handle == imagens_item.link %}
            
            <div class="col-12 {% if columns_desktop == 2 ? 'col-md-6' %} {% elseif columns_desktop == 3 ? 'col-md-4' %} {% else %} col-md-3 {% endif %}   col-grid first-image-category">
                <div style="padding-bottom: {{ item_img_spacing }}%;" class="d-none d-md-block js-item-image-padding position-relative" data-store="product-item-image-{{ product.id }}">
                    {% set slide_src = imagens_item.image | static_url | settings_image_url('large') %}
                    <img 
                        {% if imagens_item.width and imagens_item.height %} width="{{ imagens_item.width }}" height="{{ imagens_item.height }}" {% endif %}
                        data-src="{{ slide_src }}"
                        data-srcset="{{ imagens_item.image | static_url | settings_image_url('large') }} 480w, {{ imagens_item.image | static_url | settings_image_url('huge') }} 640w, {{ imagens_item.image | static_url | settings_image_url('original') }} 1024w, {{ imagens_item.image | static_url | settings_image_url('1080p') }} 1920w"  
                        class="js-item-image lazyautosizes lazyload img-absolute img-absolute-centered fade-in"
                    />
                </div>
                <div class="block-text">
                    <div class="block-text-content">
                        <div class="block-text-content-title">
                            {{ imagens_item.title }}
                        </div>
                        <div class="block-text-content-description line-clamp-3">
                            {{ imagens_item.description }}
                        </div>
                    </div>
                </div>
            </div>
        {% endif %}
    {% endfor %}
{% else %} #}
    <div class="js-item-product {% if slide_item %} js-item-slide swiper-slide{% endif %} {% if look_item %} col-12 px-0 {% else %} {{ columns_mobile_class }} {{ columns_desktop_class }} {% endif %} item-product {% if reduced_item %}item-product-reduced{% endif %} col-grid" data-product-type="list" data-product-id="{{ product.id }}" data-store="product-item-{{ product.id }}" data-component="product-list-item" data-component-value="{{ product.id }}">
        <div class="item {% if reduced_item %}mb-0{% endif %}">
            {% if (settings.quick_shop or settings.product_color_variants) and not reduced_item %}
                <div class="js-product-container js-quickshop-container{% if product.variations %} js-quickshop-has-variants{% endif %} position-relative" data-variants="{{ product.variants_object | json_encode }}" data-quickshop-id="quick{{ product.id }}">
            {% endif %}
            {% set product_url_with_selected_variant = has_filters ?  ( product.url | add_param('variant', product.selected_or_first_available_variant.id)) : product.url  %}

            {% set item_img_width = product.featured_image.dimensions['width'] %}
            {% set item_img_height = product.featured_image.dimensions['height'] %}
            {% set item_img_srcset = product.featured_image %}
            {% set item_img_alt = product.featured_image.alt %}
            {% set show_secondary_image = settings.product_hover and product.other_images %}

            {# Set how much viewport space the images will take to load correct image #}

            {% if columns_mobile == 2 %}
                {% set mobile_image_viewport_space = '50' %}
            {% else %}
                {% set mobile_image_viewport_space = '100' %}
            {% endif %}

            {% if columns_desktop == 4 %}
                {% set desktop_image_viewport_space = '25' %}
            {% elseif columns_desktop == 3 %}
                {% set desktop_image_viewport_space = '33' %}
            {% else %}
                {% set desktop_image_viewport_space = '50' %}
            {% endif %}

            {# --- Selo NOVO: exibe se produto foi criado há até 45 dias --- #}
            {# DEBUG: inspecione o código-fonte da página para ver os valores reais #}
            <!-- EORA_DEBUG product_id={{ product.id }} created_at_raw={{ product.created_at }} cutoff={{ "now - 45 days" | date("Y-m-d") }} product_date={{ product.created_at | date("Y-m-d") }} -->
            {% set now_ts = "now" | date("U") %}
            {% set prod_ts = product.created_at %}
            {% set secs_old = now_ts - prod_ts %}
            {% set is_new_product = prod_ts is not empty and secs_old > 0 and secs_old <= 3888000 %}


            <div class="{% if show_secondary_image %}js-item-with-secondary-image{% endif %} item-image{% if columns == 1 %} item-image-big{% endif %}">
                {% set brand_product = product.brand %}
                {% if brand_product %}
                    {% include 'snipplets/selo-brand.tpl' with {'product_brand': brand_product} %}
                {% endif %}

                <div style="padding-bottom: {{ item_img_spacing }}%;" class="js-item-image-padding position-relative" data-store="product-item-image-{{ product.id }}">
                    <a class="" href="{{ product_url_with_selected_variant }}" title="{{ product.name }}" aria-label="{{ product.name }}" >
                        <img alt="{{ item_img_alt }}" data-expand="-10" src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset="{{ item_img_srcset | product_image_url('small')}} 240w, {{ item_img_srcset | product_image_url('medium')}} 320w, {{ item_img_srcset | product_image_url('large')}} 480w, {{ item_img_srcset | product_image_url('huge')}} 640w, {{ item_img_srcset | product_image_url('original')}} 1024w" class="js-item-image lazyautosizes lazyload img-absolute img-absolute-centered fade-in {% if show_secondary_image %}item-image-primary{% endif %}" width="{{ item_img_width }}" height="{{ item_img_height }}" sizes="(max-width: 768px) {{ mobile_image_viewport_space }}vw, (min-width: 769px) {{ desktop_image_viewport_space }}vw"/> 

                        {% if show_secondary_image %}
                            <img alt="{{ item_img_alt }}" data-sizes="auto" src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset="{{ product.other_images | first | product_image_url('small')}} 240w, {{ product.other_images | first | product_image_url('medium')}} 320w, {{ product.other_images | first | product_image_url('large')}} 480w, {{ product.other_images | first | product_image_url('huge')}} 640w, {{ product.other_images | first | product_image_url('original')}} 1024w" class="js-item-image js-item-image-secondary lazyautosizes lazyload img-absolute img-absolute-centered fade-in item-image-secondary" sizes="(min-width: 768px) {{ desktop_image_viewport_space }}vw, {{ mobile_image_viewport_space }}vw" style="display:none;" />
                        {% endif %}
                    </a>
                    {% if is_new_product and not reduced_item %}
                        <div class="badge-novo" aria-label="Produto novo">NOVO</div>
                    {% endif %}
                    {% if product.sku and not reduced_item %}
                    <button
                        class="js-btn-provador-virtual btn-provador-virtual"
                        type="button"
                        data-mkfashion-identifier="{{ product.sku }}"
                        aria-label="Provador Virtual"
                        style="display: none;"
                    >
                        <svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
                            <path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
                            <circle cx="12" cy="13" r="4"/>
                        </svg>
                    </button>
                    {% endif %}
                </div>

                {% if not reduced_item %}
                    {% include 'snipplets/labels.tpl' %}
                {% endif %}
                
                {# {% if product.available and product.display_price and settings.quick_shop and not reduced_item %} #}
                {% if product.available and product.display_price and not reduced_item %}
                    {# {% if settings.quick_shop %} #}
                        <div class="item-actions -over-image d-none d-md-flex">
                            {% if product.variations %}
                                {# {% set all_sizes = [] %}
                                {% for variant in product.variations_object %} #}
                                    {# se a chave existir e ainda não estiver no array, adiciona #}
                                    {# {% if variant.option0 is defined
                                        and variant.option0 is not empty
                                        and variant.option0 not in all_sizes %}
                                        {% set all_sizes = all_sizes | merge([variant.option0]) %}
                                    {% endif %}
                                {% endfor %} #}
                                {# 1) Sequência “oficial” de tamanhos, em minúsculas — ajuste se precisar #}
                                {# {% set size_order = ['20', '21', '22', '23', '24', '25', '26', '27', '28', '29', '30', '31', '32', '33', '34', '35', '36', '37', '38', '39', '40', '41', '42', '43', '44', '45', '46', '47', '48', '49', '50', 'pp','p','m','g','gg','2gg','3gg','4gg', '5gg'] %} #}
                                {# 2) Reconstrói ordered_sizes seguindo size_order, preservando
                                    o “case” que veio em all_sizes — só usa lower() e merge() #}
                                {# {% set ordered_sizes = [] %}
                                {% for ref in size_order %}
                                    {% for original in all_sizes %}
                                        {% if original|lower == ref %}
                                            {% set ordered_sizes = ordered_sizes|merge([original]) %}
                                        {% endif %}
                                    {% endfor %}
                                {% endfor %} #}
                                {# 3) Anexa quaisquer tamanhos extras que não estavam na lista-guia #}
                                {# {% for original in all_sizes %}
                                    {% if original not in ordered_sizes %}
                                        {% set ordered_sizes = ordered_sizes|merge([original]) %}
                                    {% endif %}
                                {% endfor %} #}
                                {# 4) Mantém sua lógica de mostrar só 7 itens e o “+” no final #}
                                {# {% set display_sizes = ordered_sizes|slice(0, 7) %}
                                <div class="item-sizes">
                                    {% for size in display_sizes %}
                                        {% if loop.index == 7 and ordered_sizes|length > 7 %}
                                            <div class="size-block -last">+</div>
                                        {% else %}
                                            <div class="size-block">{{ size }}</div>
                                        {% endif %}
                                    {% endfor %}
                                </div> #}
                                
                                {# <div class="item-sizes">
                                    {% for size in all_sizes %}
                                        {% if loop.index == 7 and loop.last %}
                                            <div class="size-block -last">+</div>                                        
                                        {% else %}
                                            <div class="size-block">{{ size }}</div>
                                        {% endif %}    
                                    {% endfor %}
                                </div> #}
                                {# Open quickshop popup if has variants  DESATIVADO #}
                                {# <span data-toggle="#quickshop-modal" href="#" class="js-quickshop-modal-open {% if slide_item %}js-quickshop-slide{% endif %} js-modal-open btn btn-item" title="{{ 'Compra rápida de' | translate }} {{ product.name }}" aria-label="{{ 'Compra rápida de' | translate }} {{ product.name }}" data-component="product-list-item.add-to-cart" data-component-value="{{product.id}}">
                                    <span class="js-open-quickshop-wording">compre agora</span>
                                </span> #}
                                {#  deixado somente como botão de enviar para o produto #}
                                <a href="{{ product_url_with_selected_variant }}" class="js-quickshop-modal-open {% if slide_item %}js-quickshop-slide{% endif %} btn btn-item" title="{{ 'Compra' | translate }} {{ product.name }}" aria-label="{{ 'Compra' | translate }} {{ product.name }}" >
                                    <span>compre agora</span>
                                </a>
                            {% else %}
                                {# If not variants add directly to cart #}
                                <form class="js-product-form w-100" method="post" action="{{ store.cart_url }}">
                                    <input type="hidden" name="add_to_cart" value="{{product.id}}" />
                                    {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
                                    {% set texts = {'cart': "compre agora", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}

                                    <div class="js-item-submit-container item-submit-container position-relative float-left d-inline-block w-100">
                                        <input type="submit" class="js-addtocart js-prod-submit-form js-quickshop-icon-add btn btn-item {{ state }}" value="{{ texts[state] | translate }}" alt="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} data-component="product-list-item.add-to-cart" data-component-value="{{ product.id }}"/>
                                    </div>

                                    {# Fake add to cart CTA visible during add to cart event #}
                                    {% include 'snipplets/placeholders/button-placeholder.tpl' with {direct_add: true, custom_class: 'w-100 text-left'} %}
                                </form>
                            {% endif %}
                        </div>
                    {# {% endif %} #}
                {% endif %}
            </div>
            {% if (settings.quick_shop or settings.product_color_variants) and product.available and product.display_price and product.variations and not reduced_item %}

                {# Hidden product form to update item image and variants: Also this is used for quickshop popup #}
                <div class="js-item-variants hidden">
                    <form class="js-product-form" method="post" action="{{ store.cart_url }}">
                        <input type="hidden" name="add_to_cart" value="{{product.id}}" />
                        {% if product.variations %}
                            {% include "snipplets/product/product-variants.tpl" with {quickshop: true} %}
                        {% endif %}
                        {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
                        {% set texts = {'cart': "Agregar al carrito", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}

                        {# Add to cart CTA #}
                        {% set show_product_quantity = product.available and product.display_price %}
                        <div class="row mt-3">
                            {% if show_product_quantity %}
                                {% include "snipplets/product/product-quantity.tpl" with {quickshop: true} %}
                            {% endif %}

                            <div class="{% if show_product_quantity %}col-8 pl-0{% else %}col-12{% endif %}">
                                <input type="submit" class="js-addtocart js-prod-submit-form btn-add-to-cart btn btn-primary btn-big w-100 {{ state }}" value="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} />
                                {# Fake add to cart CTA visible during add to cart event #}
                                {% include 'snipplets/placeholders/button-placeholder.tpl' with {custom_class: "btn-big"} %}
                            </div>
                        </div>
                    </form>
                </div>
            {% endif %}
            {% set show_labels = not product.has_stock or product.compare_at_price or product.promotional_offer %}
            <div class="item-description" data-store="product-item-info-{{ product.id }}">
                <a href="{{ product_url_with_selected_variant }}" title="{{ product.name }}" aria-label="{{ product.name }}" class="item-link">
                    {# --- pega a tag de cor do card --- #}
                    {% set has_card_color_tag = false %}
                    {% set all_card_color_tag = [] %}
                    {% set product_color_displayed = [] %}
                    {% for item in product.tags %}
                        {% if item matches '/card-produto-gradiente/' %}
                            {% set has_card_color_tag = true %}
                            {% set all_card_color_tag = all_card_color_tag | merge([item.tag]) %}
                        {% endif %}
                        {% if item.tag starts with 'produto-gradiente:' %}
                            {% set has_card_color_tag = true %}
                            {% set product_color_displayed = item %}
                        {% endif %}
                    {% endfor %}

                    {# Respect product_by_reference_setting passed from parent, fallback to global setting #}
                    {% set product_by_reference = product_by_reference_setting is defined ? product_by_reference_setting : settings.product_by_reference %}

                    {% if product_by_reference and not reduced_item %}
                        {% include 'snipplets/grid/item-colors.tpl' with {color_by_tags: has_card_color_tag, array_tags_colors: all_card_color_tag, product_color: product_color_displayed } %}
                    {# {% elseif settings.product_color_variants and not reduced_item %}
                        {% include 'snipplets/grid/item-colors.tpl' %} #}
                    {% endif %}

                    <div class="d-flex justify-content-between align-items-center mb-2">
                        <div class="js-item-name item-name" data-store="product-item-name-{{ product.id }}">{{ product.name }}</div>
                        {% if product.display_price %}
                            <div class="item-price-container {% if settings.quick_shop %}mb-3{% endif %}" data-store="product-item-price-{{ product.id }}">
                                <div class="item-price-block">
                                    <span class="js-price-display item-price" data-product-price="{{ product.price }}">
                                        {{ product.price | money }}
                                    </span>
                                    {# {% if not reduced_item %}
                                        <span class="js-compare-price-display price-compare" {% if not product.compare_at_price or not product.display_price %}style="display:none;"{% else %}style="display:inline-block;"{% endif %}>
                                            {{ product.compare_at_price | money }}
                                        </span>
                                    {% endif %} #}

                                    {# {% set product_can_show_installments = product.show_installments and product.display_price and product.get_max_installments.installment > 1 and settings.product_installments and not reduced_item %} #}

                                    {# {% if settings.payment_discount_price %}
                                        <span class="discount-pix">
                                            <svg class="icon-inline icon-w-14"><use xlink:href="#pix"/></svg>
                                            {{ component('payment-discount-price', {
                                                    visibility_condition: settings.payment_discount_price and not reduced_item,
                                                    location: 'product',
                                                    container_classes: "font-small",
                                                }) 
                                            }}
                                        </span>
                                    {% endif %} #}
                                </div>

                                {# {% if product_can_show_installments %}
                                    {{ component('installments', {'location' : 'product_item' , 'short_wording' : true, container_classes: { installment: "item-installments mt-2"}}) }}
                                {% endif %} #}
                            </div>
                        {% endif %}
                    </div>

                    {% if product.available and product.display_price and settings.quick_shop and not reduced_item %}
                        {% if settings.quick_shop %}
                            <div class="item-actions d-block d-md-none">
                                {% if product.variations %}

                                    {# Open quickshop popup if has variants #}

                                    <span data-toggle="#quickshop-modal" href="#" class="js-quickshop-modal-open {% if slide_item %}js-quickshop-slide{% endif %} js-modal-open btn btn-item" title="{{ 'Compra rápida de' | translate }} {{ product.name }}" aria-label="{{ 'Compra rápida de' | translate }} {{ product.name }}" data-component="product-list-item.add-to-cart" data-component-value="{{product.id}}">
                                        <span class="js-open-quickshop-wording">compre agora</span>
                                    </span>
                                {% else %}
                                    {# If not variants add directly to cart #}
                                    <form class="js-product-form" method="post" action="{{ store.cart_url }}">
                                        <input type="hidden" name="add_to_cart" value="{{product.id}}" />
                                        {% set state = store.is_catalog ? 'catalog' : (product.available ? product.display_price ? 'cart' : 'contact' : 'nostock') %}
                                        {% set texts = {'cart': "compre agora", 'contact': "Consultar precio", 'nostock': "Sin stock", 'catalog': "Consultar"} %}

                                        <div class="js-item-submit-container item-submit-container position-relative float-left d-inline-block w-100">
                                            <input type="submit" class="js-addtocart js-prod-submit-form js-quickshop-icon-add btn btn-item {{ state }}" value="{{ texts[state] | translate }}" alt="{{ texts[state] | translate }}" {% if state == 'nostock' %}disabled{% endif %} data-component="product-list-item.add-to-cart" data-component-value="{{ product.id }}"/>
                                        </div>

                                        {# Fake add to cart CTA visible during add to cart event #}

                                        {% include 'snipplets/placeholders/button-placeholder.tpl' with {direct_add: true, custom_class: 'w-100 text-left'} %}
                                    </form>
                                {% endif %}
                            </div>
                        {% endif %}
                    {% endif %}
                {# Product description #}
                {% if product.description is not empty and '<table' in product.description %}
                    <div class="js-product-card-description-base user-content d-none">
                        {{ product.description }}
                    </div>
                    <div class="js-product-card-description-text product-card-description-text"></div>
                {% elseif product.description is not empty %}
                    <div class="js-product-description">
                        {{ product.description }}
                    </div>
                {% endif %}
                </a>
            </div>
            {% if (settings.quick_shop or settings.product_color_variants) and not reduced_item %}
                </div>{# This closes the quickshop tag #}
            {% endif %}

            {# Structured data to provide information for Google about the product content #}
            {{ component('structured-data', {'item': true}) }}
        </div>
    </div>
{# {% endif %} #}
