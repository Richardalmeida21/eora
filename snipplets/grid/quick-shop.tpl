{% if settings.quick_shop %}
    {% embed "snipplets/modal.tpl" with{modal_id: 'quickshop-modal', modal_class: 'quickshop bottom modal-overflow-none modal-bottom-sheet', modal_position: 'bottom', modal_transition: 'slide', modal_footer: false, modal_width: 'centered-md modal-centered-medium', modal_header_class: 'js-quickshop-header d-none', modal_body_class: 'modal-scrollable p-0'} %}
        {% block modal_body %}
            <div class="js-item-product modal-scrollable modal-scrollable-area" data-product-id="">
                <div class="js-product-container js-quickshop-container js-quickshop-modal js-quickshop-modal-shell" data-variants="" data-quickshop-id="">
                    <div class="row no-gutters">
                        <div class="col-md-6">
                            <div class="quickshop-image-container d-none d-md-block px-3 px-md-0">                                
                                {% set product_img_height =  settings.product_img_height | default(100) %}
                                {% set product_img_width =  settings.product_img_width | default(100) %}
                                {% set item_img_spacing = product_img_height / product_img_width * 100 %}

                                <div class="js-quickshop-image-padding" style="padding-bottom: {{ item_img_spacing }}%;">
                                    <img srcset="" class="js-item-image js-quickshop-img quickshop-image d-block img-absolute-centered"/>
                                </div>
                            </div>
                        </div>
                        <div class="js-item-variants col-md-6 p-3 p-md-4">
                            <div class="row no-gutters align-items-start mr-md-1 mb-3 d-flex">
                                <div class="col">
                                    <div class="js-item-name h4-huge h3-huge-md mb-2 mb-md-0" data-store="product-item-price-{{ product.id }}"></div>
                                </div>
                                <div class="col-auto">
                                    <a class="js-modal-close modal-close pr-0 py-0">
                                        <svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#times"/></svg>
                                    </a>
                                </div>
                            </div>
                            <div class="mb-4 mr-md-1" data-store="product-item-price-{{ product.id }}">
                                <span class="js-price-display h2 font-family-body font-weight-bold"></span>
                                <span class="js-compare-price-display price-compare h3 font-family-body font-weight-normal ml-2"></span>
                                {{ component('payment-discount-price', {
                                        visibility_condition: settings.payment_discount_price,
                                        location: 'product',
                                        container_classes: "mt-1 mb-3",
                                        text_classes: {
                                            price: 'h5 font-family-body text-accent'
                                        }
                                    }) 
                                }}
                            </div>
                            {# Image is hidden but present so it can be used on cart notifiaction #}
                            
                            <div id="quickshop-form" class="mr-md-1"></div>
                        </div>
                    </div>
                </div>
            </div>
        {% endblock %}
    {% endembed %}
{% endif %}