DOMContentLoaded.addEventOrExecute(() => {

    {# /* // Variants without stock */ #}

    {% set is_button_variant = settings.bullet_variants or settings.image_color_variants %}

    {% if is_button_variant %}
        const noStockVariants = (container = null) => {

            {# Configuration for variant elements #}
            const config = {
                variantsGroup: ".js-product-variants-group",
                variantButton: ".js-insta-variant",
                noStockClass: "btn-variant-no-stock",
                dataVariationId: "data-variation-id",
                dataOption: "data-option"
            };

            {# Product container wrapper #}
            const wrapper = container ? container : jQueryNuvem('#single-product');
            if (!wrapper) return;

            {# Fetch the variants data from the container #}
            const dataVariants = wrapper.data('variants');
            const variantsLength = wrapper.find(config.variantsGroup).length;

            {# Get selected options from product variations #}
            const getOptions = (productVariationId, variantOption) => {
                if (productVariationId === 2) {
                    return {
                        option0: String(wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="0"] select`).val()),
                        option1: String(wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="1"] select`).val()),
                        option2: String(jQueryNuvem(variantOption).attr('data-option')),
                    };
                } else if (productVariationId === 1) {
                    return {
                        option0: String(wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="0"] select`).val()),
                        option1: String(jQueryNuvem(variantOption).attr('data-option')),
                    };
                } else {
                    return {
                        option0: String(jQueryNuvem(variantOption).attr('data-option')),
                    };
                }
            };

            {# Filter available variants based on selected options #}
            const filterVariants = (options) => {
                return dataVariants.filter(variant => {
                    return Object.keys(options).every(optionKey => variant[optionKey] === options[optionKey]) && variant.available;
                });
            };

            {# Update stock status for variant buttons #}
            const updateStockStatus = (productVariationId) => {
                const variationGroup = wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="${productVariationId}"]`);
                variationGroup.find(`${config.variantButton}.${config.noStockClass}`).removeClass(config.noStockClass);

                variationGroup.find(config.variantButton).each((variantOption, item) => {
                    const options = getOptions(productVariationId, variantOption);
                    const itemsAvailable = filterVariants(options);
                    const button = wrapper.find(`${config.variantsGroup}[${config.dataVariationId}="${productVariationId}"] ${config.variantButton}[${config.dataOption}="${options[`option${productVariationId}`].replace(/"/g, '\\"')}"]`);
                    
                    if (!itemsAvailable.length) {
                        button.addClass(config.noStockClass);
                    }
                });
            };

            {# Iterate through all variant and update stock status #}
            for (let productVariationId = variantsLength - 1; productVariationId >= 0; productVariationId--) {
                updateStockStatus(productVariationId);
            }
        };

        noStockVariants();

    {% endif %}

    {% if settings.quick_shop %}

        {# /* // Quickshop */ #}

        jQueryNuvem(document).on("click", ".js-quickshop-modal-open", function (e) {
            e.preventDefault();
            var $this = jQueryNuvem(this);
            if($this.hasClass("js-quickshop-slide")){
                jQueryNuvem("#quickshop-modal .js-item-product").addClass("js-swiper-slide-visible js-item-slide");
            }

            {% if is_button_variant %}
                {# Updates variants without stock #}
                let container = jQueryNuvem(this).closest('.js-quickshop-container');
                if (!container.length) return;
                noStockVariants(container);
            {% endif %}

            LS.fillQuickshop($this);

            if (window.innerWidth < 768) {
                {# Image dimensions #}

                var product_image_dimension = jQueryNuvem(this).closest('.js-item-product').find('.js-item-image-padding').attr("style");
                jQueryNuvem("#quickshop-modal .js-quickshop-image-padding").attr("style", product_image_dimension);

            }
        });

    {% endif %}

    {% if settings.bullet_variants or settings.product_color_variants or settings.image_color_variants %}
        changeVariantButton = function(selector, parentSelector) {
            selector.siblings().removeClass("selected");
            selector.addClass("selected");
            var option_id = selector.attr('data-option');
            var parent = selector.closest(parentSelector);
            var selected_option = parent.find('.js-variation-option option').filter(function (el) {
                return el.value == option_id;
            });
            selected_option.prop('selected', true).trigger('change');
            parent.find('.js-insta-variation-label').html(option_id);
        }

        {% if settings.bullet_variants or settings.image_color_variants %}
            {# /* // Color and size variations */ #}

            jQueryNuvem(document).on("click", ".js-insta-variant", function (e) {
                e.preventDefault();
                $this = jQueryNuvem(this);
                changeVariantButton($this, '.js-product-variants-group');
            });

        {% endif %}


        {% if settings.product_color_variants %}

            {# Product color variations #}
            if (window.innerWidth > 767) {
                jQueryNuvem(document).on("click", ".js-color-variant", function(e) {
                    e.preventDefault();
                    $this = jQueryNuvem(this);
                    changeVariantButton($this, '.js-item-product');
                });
            }
        {% endif %}

    {% endif %}

    {% if settings.quick_shop or settings.product_color_variants %}

        LS.registerOnChangeVariant(function(variant){
            {# Show product image on color change #}
            var current_image = jQueryNuvem('.js-item-product[data-product-id="'+variant.product_id+'"] .js-item-image');
            current_image.attr('srcset', variant.image_url);

            {% if settings.product_hover %}
                {# Remove secondary feature on image updated from changeVariant #}
                current_image.closest(".js-item-with-secondary-image").removeClass("item-with-two-images");
            {% endif %}
        });

    {% endif %}

    {#/*============================================================================
      #Product detail functions
    ==============================================================================*/ #}

    {# /* // Installments */ #}

    {# Installments without interest #}

    function get_max_installments_without_interests(number_of_installment, installment_data, max_installments_without_interests) {
        if (parseInt(number_of_installment) > parseInt(max_installments_without_interests[0])) {
            if (installment_data.without_interests) {
                return [number_of_installment, installment_data.installment_value.toFixed(2)];
            }
        }
        return max_installments_without_interests;
    }

    {# Installments with interest #}

    function get_max_installments_with_interests(number_of_installment, installment_data, max_installments_with_interests) {
        if (parseInt(number_of_installment) > parseInt(max_installments_with_interests[0])) {
            if (installment_data.without_interests == false) {
                return [number_of_installment, installment_data.installment_value.toFixed(2)];
            }
        }
        return max_installments_with_interests;
    }

    {# Updates installments on payment popup for native integrations #}

    function refreshInstallmentv2(price){
        jQueryNuvem(".js-modal-installment-price" ).each(function( el ) {
            const installment = Number(jQueryNuvem(el).data('installment'));
            jQueryNuvem(el).text(LS.currency.display_short + (price/installment).toLocaleString('de-DE', {maximumFractionDigits: 2, minimumFractionDigits: 2}));
        });
    }

    {# Refresh price on payments popup with payment discount applied #}

    function refreshPaymentDiscount(price){
        jQueryNuvem(".js-price-with-discount" ).each(function( el ) {
            const payment_discount = jQueryNuvem(el).data('paymentDiscount');
            jQueryNuvem(el).text(LS.formatToCurrency(price - ((price * payment_discount) / 100)))
        });
    }

    {% set should_show_discount = product.maxPaymentDiscount.value > 0 %}
    {% if should_show_discount %}

        {# Shows/hides price with discount and strikethrough original price for every payment method #}

        function togglePaymentDiscounts(variant){
            jQueryNuvem(".js-payment-method-total").each(function( paymentMethodTotalElement ){
                const priceComparerElement = jQueryNuvem(paymentMethodTotalElement).find(".js-compare-price-display");
                const installmentsOnePaymentElement = jQueryNuvem(paymentMethodTotalElement).find('.js-installments-no-discount');
                const priceWithDiscountElement = jQueryNuvem(paymentMethodTotalElement).find('.js-price-with-discount');

                priceComparerElement.hide();
                installmentsOnePaymentElement.hide();
                priceWithDiscountElement.hide();

                const discount = priceWithDiscountElement.data('paymentDiscount');

                if (discount > 0 && showMaxPaymentDiscount(variant)){
                    priceComparerElement.show();
                    priceWithDiscountElement.show()
                } else {
                    installmentsOnePaymentElement.show();
                }
            })
        }

        {# Toggle discount and discount disclaimer both on product details and popup #}

        function updateDiscountDisclaimers(variant){
            updateProductDiscountDisclaimer(variant);
            updatePopupDiscountDisclaimers(variant);
        }

        {# Toggle discount and discount disclaimer in product details #}

        function updateProductDiscountDisclaimer(variant){
            jQueryNuvem(".js-product-discount-container, .js-product-discount-disclaimer").hide();

            if (showMaxPaymentDiscount(variant)){
                jQueryNuvem(".js-product-discount-container").show();
            }

            if (showMaxPaymentDiscountNotCombinableDisclaimer(variant)){
                jQueryNuvem(".js-product-discount-disclaimer").show();
            }
        }

        {# Shows/hides discount message for payment method and discount disclaimer in popup, for every payment method #}

        function updatePopupDiscountDisclaimers(variant){
            jQueryNuvem(".js-modal-tab-discount, .js-payment-method-discount").hide();

            {% if product.maxPaymentDiscount.value > 0 %}
                if (showMaxPaymentDiscount(variant)){
                    {% for key, method in product.payment_methods_config %}
                        {% if method.max_discount > 0 %}
                            {% if method.allows_discount_combination %}
                                jQueryNuvem("#method_{{ key | sanitize }} .js-modal-tab-discount").show();
                            {% elseif not product.free_shipping %}
                                if (!variantHasPromotionalPrice(variant)){
                                    jQueryNuvem("#method_{{ key | sanitize }} .js-modal-tab-discount").show();
                                }
                            {% endif %}
                        {% endif %}
                    {% endfor %}
                }
            {% endif %}

            jQueryNuvem(".js-info-payment-method-container").each(function(infoPaymentMethodElement){
                {# For each payment method this will show the payment method discount and discount explanation #}

                const infoPaymentMethod = jQueryNuvem(infoPaymentMethodElement)
                infoPaymentMethod.find(".js-discount-explanation").hide();
                infoPaymentMethod.find(".js-discount-disclaimer").hide();

                const priceWithDiscountElement = infoPaymentMethod.find('.js-price-with-discount');
                const discount = priceWithDiscountElement.data('paymentDiscount');

                if (discount > 0 && showMaxPaymentDiscount(variant)){
                    infoPaymentMethod.find(".js-discount-explanation").show();
                    infoPaymentMethod.find(".js-payment-method-discount").show();
                }

                if (discount > 0 && showMaxPaymentDiscountNotCombinableDisclaimer(variant)){
                    infoPaymentMethod.find(".js-discount-disclaimer").show();
                }
            })
        }

        function variantHasPromotionalPrice(variant) { return variant.compare_at_price_number > variant.price_number }

        function showMaxPaymentDiscount(variant) {
            {% if product.maxPaymentDiscount()["allowsDiscountCombination"] %}
                return true;
            {% elseif product.free_shipping %}
                return false;
            {% else %}
                return !variantHasPromotionalPrice(variant);
            {% endif %}
        }

        function showMaxPaymentDiscountNotCombinableDisclaimer(variant) {
            {% if product.maxPaymentDiscount()["allowsDiscountCombination"] or product.free_shipping %}
                return false
            {% else %}
                return !variantHasPromotionalPrice(variant)
            {% endif %}
        }

    {% endif %}

    {# /* // Change variant */ #}

    {# Updates price, installments, labels and CTA on variant change #}

    function changeVariant(variant) {
        jQueryNuvem(".js-product-detail .js-shipping-calculator-response").hide();
        jQueryNuvem("#shipping-variant-id").val(variant.id);

        var parent = jQueryNuvem("body");
        if (variant.element) {
            parent = jQueryNuvem(variant.element);
            if(parent.hasClass("js-quickshop-container")){
                var quick_id = parent.attr("data-quickshop-id");
                var parent = jQueryNuvem('.js-quickshop-container[data-quickshop-id="'+quick_id+'"]');
            }
        }

        {% if is_button_variant %}
            {# Updates variants without stock #}
            if(parent.hasClass("js-quickshop-container")){
                var itemContainer = parent.closest('.js-item-product');
                if(itemContainer.hasClass("js-item-slide")){
                    var parent = jQueryNuvem('.js-swiper-slide-visible .js-quickshop-container[data-quickshop-id="'+quick_id+'"]');
                }
                noStockVariants(parent);
            } else {
                noStockVariants();
            }
        {% endif %}
        
        var sku = parent.find('.js-product-sku');
        if(sku.length) {
            sku.text(variant.sku).show();
        }

        {% if settings.product_stock %}
            var stock = parent.find('.js-product-stock');
            stock.text(variant.stock).show();
        {% endif %}

        {# Updates installments on list item and inside payment popup for Payments Apps #}
        
        var installment_helper = function($element, amount, price){
            $element.find('.js-installment-amount').text(amount);
            $element.find('.js-installment-price').attr("data-value", price);
            $element.find('.js-installment-price').text(LS.currency.display_short + parseFloat(price).toLocaleString('de-DE', { minimumFractionDigits: 2 }));
            if(variant.price_short && Math.abs(variant.price_number - price * amount) < 1) {
                $element.find('.js-installment-total-price').text((variant.price_short).toLocaleString('de-DE', { minimumFractionDigits: 2 }));
            } else {
                $element.find('.js-installment-total-price').text(LS.currency.display_short + (price * amount).toLocaleString('de-DE', { minimumFractionDigits: 2 }));
            }
        };

        if (variant.installments_data) {
            var variant_installments = JSON.parse(variant.installments_data);
            var max_installments_without_interests = [0,0];
            var max_installments_with_interests = [0,0];

            {# Hide all installments rows on payments modal #}
            jQueryNuvem('.js-payment-provider-installments-row').hide();

            for (let payment_method in variant_installments) {

                {# Identifies the minimum installment value #}
                var paymentMethodId = '#installment_' + payment_method.replace(" ", "_") + '_1';
                var minimumInstallmentValue = jQueryNuvem(paymentMethodId).closest('.js-info-payment-method').attr("data-minimum-installment-value");

                let installments = variant_installments[payment_method];
                for (let number_of_installment in installments) {
                    let installment_data = installments[number_of_installment];
                    max_installments_without_interests = get_max_installments_without_interests(number_of_installment, installment_data, max_installments_without_interests);
                    max_installments_with_interests = get_max_installments_with_interests(number_of_installment, installment_data, max_installments_with_interests);
                    var installment_container_selector = '#installment_' + payment_method.replace(" ", "_") + '_' + number_of_installment;

                    {# Shows installments rows on payments modal according to the minimum value #}
                    if(minimumInstallmentValue <= installment_data.installment_value) {
                        jQueryNuvem(installment_container_selector).show();
                    }

                    if(!parent.hasClass("js-quickshop-container")){
                        installment_helper(jQueryNuvem(installment_container_selector), number_of_installment, installment_data.installment_value.toFixed(2));
                    }
                }
            }
            var $installments_container = jQueryNuvem(variant.element + ' .js-max-installments-container .js-max-installments');
            var $installments_modal_link = jQueryNuvem(variant.element + ' #btn-installments');
            var $payments_module = jQueryNuvem(variant.element + ' .js-product-payments-container');
            var $installmens_card_icon = jQueryNuvem(variant.element + ' .js-installments-credit-card-icon');

            {% if product.has_direct_payment_only %}
            var installments_to_use = max_installments_without_interests[0] >= 1 ? max_installments_without_interests : max_installments_with_interests;

            if(installments_to_use[0] <= 0 ) {
            {%  else %}
            var installments_to_use = max_installments_without_interests[0] > 1 ? max_installments_without_interests : max_installments_with_interests;

            if(installments_to_use[0] <= 1 ) {
            {% endif %}
                $installments_container.hide();
                $installments_modal_link.hide();
                $payments_module.hide();
                $installmens_card_icon.hide();
            } else {
                $installments_container.show();
                $installments_modal_link.show();
                $payments_module.show();
                $installmens_card_icon.show();
                installment_helper($installments_container, installments_to_use[0], installments_to_use[1]);
            }
        }

        if(!parent.hasClass("js-quickshop-container")){
            jQueryNuvem('#installments-modal .js-installments-one-payment').text(variant.price_short).attr("data-value", variant.price_number);
        }

        if (variant.price_short){
            parent.find('.js-price-display').text(variant.price_short).show();
            parent.find('.js-price-display').attr("content", variant.price_number).data('productPrice', variant.price_number_raw);

            parent.find('.js-payment-discount-price-product').text(variant.price_with_payment_discount_short);
            parent.find('.js-payment-discount-price-product-container').show();
            
            parent.find('.js-price-without-taxes').text(variant.price_without_taxes);
            parent.find('.js-price-without-taxes-container').show();
        } else {
            parent.find('.js-price-display, .js-payment-discount-price-product-container, .js-price-without-taxes-container').hide();
        }

        if ((variant.compare_at_price_short) && !(parent.find(".js-price-display").css("display") == "none")) {
            parent.find('.js-compare-price-display').text(variant.compare_at_price_short).show();
        } else {
            parent.find('.js-compare-price-display').hide();
        }

        var button = parent.find('.js-addtocart');
        const quickshopButtonWording = parent.find('.js-open-quickshop-wording');
        const quickshopButtonIcon = parent.find('.js-open-quickshop-icon');
        button.removeClass('cart').removeClass('contact').removeClass('nostock');
        var $product_shipping_calculator = parent.find("#product-shipping-container");

        {# Update CTA wording and status #}

        {% if not store.is_catalog %}
            if (!variant.available){
                button.val('{{ "Sin stock" | translate }}');
                button.addClass('nostock');
                button.attr('disabled', 'disabled');
                quickshopButtonWording.text('{{ "Sin stock" | translate }}');
                quickshopButtonIcon.addClass("d-none").removeClass("d-md-inline");
                $product_shipping_calculator.hide();
            } else if (variant.contact) {
                button.val('{{ "Consultar precio" | translate }}');
                button.addClass('contact');
                button.removeAttr('disabled');
                quickshopButtonWording.text('{{ "Consultar precio" | translate }}');
                quickshopButtonIcon.addClass("d-none").removeClass("d-md-inline");
                $product_shipping_calculator.hide();
            } else {
                button.val('{{ "Agregar al carrito" | translate }}');
                button.addClass('cart');
                button.removeAttr('disabled');
                quickshopButtonWording.text('{{ "Comprar" | translate }}');
                quickshopButtonIcon.addClass("d-md-inline");
                $product_shipping_calculator.show();
            }

        {% endif %}

        {% if template == 'product' %}
            const base_price = Number(jQueryNuvem("#price_display").attr("content"));
            refreshInstallmentv2(base_price);
            refreshPaymentDiscount(variant.price_number);
            {% if should_show_discount %}
                togglePaymentDiscounts(variant);
                updateDiscountDisclaimers(variant);
            {% endif %}
        {% endif %}

        {% if settings.last_product %}
            if(variant.stock == 1) {
                parent.find('.js-last-product').show();
            } else {
                parent.find('.js-last-product').hide();
            }
        {% endif %}


        {# Update shipping on variant change #}

        LS.updateShippingProduct();

        zipcode_on_changevariant = jQueryNuvem("#product-shipping-container .js-shipping-input").val();
        jQueryNuvem("#product-shipping-container .js-shipping-calculator-current-zip").text(zipcode_on_changevariant);

        {% if cart.free_shipping.min_price_free_shipping.min_price %}
            {# Updates free shipping bar #}

            LS.freeShippingProgress(true, parent);

        {% endif %}
    }

    {# /* // Trigger change variant */ #}

    jQueryNuvem(document).on("change", ".js-variation-option", function(e) {
        var $parent = jQueryNuvem(this).closest(".js-product-variants");
        var $variants_group = jQueryNuvem(this).closest(".js-product-variants-group");
        var $quickshop_parent_wrapper = jQueryNuvem(this).closest(".js-quickshop-container");

        {# If quickshop is used from modal, use quickshop-id from the item that opened it #}

        var quick_id = $quickshop_parent_wrapper.attr("data-quickshop-id");

        if($parent.hasClass("js-product-quickshop-variants")){

            var $quickshop_parent = jQueryNuvem(this).closest(".js-item-product");

            {# Target visible slider item if necessary #}
            
            if($quickshop_parent.hasClass("js-item-slide")){
                var $quickshop_variant_selector = '.js-swiper-slide-visible .js-quickshop-container[data-quickshop-id="'+quick_id+'"]';
            }else{
                var $quickshop_variant_selector = '.js-quickshop-container[data-quickshop-id="'+quick_id+'"]';
            }

            LS.changeVariant(changeVariant, $quickshop_variant_selector);

            {% if settings.product_color_variants or settings.bullet_variants or settings.image_color_variants %}
                {# Match selected color variant with selected quickshop variant #}

                var selected_option_id = jQueryNuvem(this).val();
                var $color_parent_to_update = jQueryNuvem('.js-quickshop-container[data-quickshop-id="'+quick_id+'"]');

                {# Update all color buttons on several places (quickshop, item, product detail) #}
                $color_parent_to_update.find('.js-color-variant[data-option="'+selected_option_id+'"]').addClass("selected").siblings().removeClass("selected");
                {# Update this specific variant button #}
                $variants_group.find('.js-insta-variant[data-option="'+selected_option_id+'"]').addClass("selected").siblings().removeClass("selected");
            {% endif %}

        } else {
            LS.changeVariant(changeVariant, '#single-product');
        }

        {# Offer and discount labels update #}

        var $this_product_container = jQueryNuvem(this).closest(".js-product-container");

        if($this_product_container.hasClass("js-quickshop-container")){
            var this_quickshop_id = $this_product_container.attr("data-quickshop-id");
            var $this_product_container = jQueryNuvem('.js-product-container[data-quickshop-id="'+this_quickshop_id+'"]');
        }
        var $this_compare_price = $this_product_container.find(".js-compare-price-display");
        var $this_price = $this_product_container.find(".js-price-display");
        var $installment_container = $this_product_container.find(".js-product-payments-container");
        var $installment_text = $this_product_container.find(".js-max-installments-container");
        var $this_add_to_cart = $this_product_container.find(".js-prod-submit-form");

        // Get the current product discount percentage value
        var current_percentage_value = $this_product_container.find(".js-offer-percentage");

        // Get the current product price and promotional price
        var compare_price_value = $this_compare_price.html();
        var price_value = $this_price.html();

        // Calculate new discount percentage based on difference between filtered old and new prices
        const percentageDifference = window.moneyDifferenceCalculator.percentageDifferenceFromString(compare_price_value, price_value);
        if(percentageDifference){
            $this_product_container.find(".js-offer-percentage").text(percentageDifference);
            $this_product_container.find(".js-offer-label").css("display" , "table");
        }

        if ($this_compare_price.css("display") == "none" || !percentageDifference) {
            $this_product_container.find(".js-offer-label").hide();
        }
        if ($this_add_to_cart.hasClass("nostock")) {
            $this_product_container.find(".js-stock-label").show();
            $this_product_container.find(".js-offer-label").hide();
            $this_product_container.find(".js-shipping-label").hide();
        }
        else {
            $this_product_container.find(".js-stock-label").hide();
            $this_product_container.find(".js-shipping-label").show();
        }
        if ($this_price.css('display') == 'none'){
            $installment_container.hide();
            $installment_text.hide();
        }else{
            $installment_text.show();
        }
    });

    {# /* // Submit to contact */ #}

    {# Submit to contact form when product has no price #}

    jQueryNuvem(".js-product-form").on("submit", function (e) {
        var button = jQueryNuvem(e.currentTarget).find('[type="submit"]');
        button.attr('disabled', 'disabled');
        if ((button.hasClass('contact')) || (button.hasClass('catalog'))) {
            e.preventDefault();
            var product_id = jQueryNuvem(e.currentTarget).find("input[name='add_to_cart']").val();
            window.location = "{{ store.contact_url | escape('js') }}?product=" + product_id;
        } else if (button.hasClass('cart')) {
            button.val('{{ "Agregando..." | translate }}');
        }
    });

    {% if template == 'product' or (template == 'home' and sections.best_sellers.products) %}

        var has_multiple_slides = false;

        {% if template == 'product' and (product.images_count > 1 or video_url) %}
            var has_multiple_slides = true;
        {% else %}
            var product_images_amount = jQueryNuvem(".js-swiper-product").attr("data-product-images-amount");
            if(product_images_amount > 1) {
                var has_multiple_slides = true;
            }
        {% endif %}

        {# /* // Product slider */ #}

        {% if template == 'product' %}

            {% block product_fancybox %}
                Fancybox.bind('[data-fancybox="product-gallery"]', {
                    Toolbar: {
                        items: {
                            close: {
                                html: '<svg class="icon-inline icon-lg svg-icon-text"><use xlink:href="#times"/></svg>',
                            },
                            counter: {
                                class: 'pt-2 mt-1',
                                type: 'div',
                                html: '<span data-fancybox-index=""></span>&nbsp;/&nbsp;<span data-fancybox-count=""></span>',
                                position: 'center',
                                },
                        },
                    },
                    Carousel: {
                        Navigation: {
                            classNames: {
                                button: 'btn',
                                next: 'swiper-button-next',
                                prev: 'swiper-button-prev',
                            },
                            prevTpl: '<svg class="icon-inline icon-lg svg-icon-invert icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>',
                            nextTpl: '<svg class="icon-inline icon-lg svg-icon-invert"><use xlink:href="#arrow-long"/></svg>',
                        },
                    },
                    Thumbs: { autoStart: false },
                    on: {
                        shouldClose: (fancybox, slide) => {
                            {% if settings.product_image_format != 'slider' %}
                                if (window.innerWidth < 768) {
                            {% endif %}
                                {# Update position of the slider #}
                                productSwiper.slideTo( fancybox.getSlide().index, 0 );
                            {% if settings.product_image_format != 'slider' %}
                                }
                            {% endif %}
                        },
                    },
                });
            {% endblock %}
        {% endif %}

        function productSliderNav(){

            var width = window.innerWidth;

            var productSwiper = null;
            createSwiper(
                '.js-swiper-product', {
                    lazy: true,
                    slidesPerView: 1.3,
                    threshold: 5,
                    centerInsufficientSlides: true,
                    watchOverflow: true,
                    spaceBetween: 16,
                    pagination: {
                        el: '.js-swiper-product-pagination',
                        clickable: true,
                    },
                    navigation: {
                        nextEl: '.js-swiper-product-next',
                        prevEl: '.js-swiper-product-prev',
                    },
                    breakpoints: {
                        768: {
                            slidesPerView: 'auto',
                        }
                    },
                    on: {
                        init: function () {
                            jQueryNuvem(".js-product-slider-placeholder").hide();
                            jQueryNuvem(".js-swiper-product").css("visibility", "visible").css("height", "auto");
                            {% if product.video_url and template == 'product' %}
                                if (window.innerWidth < 768) {
                                    productSwiperHeight = jQueryNuvem(".js-swiper-product").height();
                                    jQueryNuvem(".js-product-video-slide").height(productSwiperHeight);
                                }
                            {% endif %}
                        },
                        {% if product.video_url and template == 'product' %}
                            slideChangeTransitionEnd: function () {
                                if(jQueryNuvem(".js-product-video-slide").hasClass("swiper-slide-active")){
                                    jQueryNuvem(".js-labels-group").fadeOut(100);
                                }else{
                                    jQueryNuvem(".js-labels-group").fadeIn(100);
                                }
                                jQueryNuvem('.js-video').show();
                                jQueryNuvem('.js-video-iframe').hide().find("iframe").remove();
                            },
                        {% endif %}
                    },
                },
                function(swiperInstance) {
                    productSwiper = swiperInstance;
                }
            );

            {% if template == 'product' %}
                {{ block ('product_fancybox') }}
            {% endif %}

            if(has_multiple_slides){
                LS.registerOnChangeVariant(function(variant){
                    var liImage = jQueryNuvem('.js-swiper-product').find("[data-image='"+variant.image+"']");
                    var selectedPosition = liImage.data('imagePosition');
                    var slideToGo = parseInt(selectedPosition);
                    productSwiper.slideTo(slideToGo);
                    jQueryNuvem(".js-product-slide-img").removeClass("js-active-variant");
                    liImage.find(".js-product-slide-img").addClass("js-active-variant");
                });

            }
        }

        productSliderNav()

        {# /* // Pinterest sharing */ #}

        jQueryNuvem('.js-pinterest-share').on("click", function(e){
            e.preventDefault();
            jQueryNuvem(".pinterest-hidden a").get()[0].click();
        });

    {% endif %}

    {# Product quantity #}

    jQueryNuvem(document).on("click", ".js-quantity .js-quantity-up", function (e) {
        $quantity_input = jQueryNuvem(this).closest(".js-quantity").find(".js-quantity-input");
        $quantity_input.val( parseInt($quantity_input.val(), 10) + 1);
    });

    jQueryNuvem(document).on("click", ".js-quantity .js-quantity-down", function (e) {
        $quantity_input = jQueryNuvem(this).closest(".js-quantity").find(".js-quantity-input");
        quantity_input_val = $quantity_input.val();
        if (quantity_input_val>1) {
            $quantity_input.val( parseInt($quantity_input.val(), 10) - 1);
        }
    });

});
