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


/* === EORA BAGS LAYOUT ENGINE === */
(function () {
    var themeProd = document.querySelector('#single-product');
    if (!themeProd) return;
    
    // DETECÇÃO DO LAYOUT PERSONALIZADO EORA (BOLSAS)
    // Verifica se a descrição do produto contém as tabelas de configuração do layout customizado
    var hasEoraLayout = false;
    document.querySelectorAll('.js-product-description-base table').forEach(function (t) {
        var td = t.querySelector('tbody > tr:first-child td:first-child');
        if (td) {
            var txt = td.textContent.trim().toLowerCase();
            if (txt === 'descricao_curta' || txt === 'medidas_do_oculos' || txt === 'texto_institucional') {
                hasEoraLayout = true;
            }
        }
    });
    if (!hasEoraLayout) return; // Se não for um produto de bolsa com o layout Eora, encerra imediatamente!

    var css = [
        /* Proteção máxima de layout e viewport contra quebras e encolhimento (squishing) */
        'html,body{max-width:100%!important;width:100%!important;overflow-x:hidden!important;margin:0!important;padding:0!important;-webkit-text-size-adjust:100%!important;text-size-adjust:100%!important}',
        'input,select,textarea,button,a{touch-action:manipulation!important}',

        /* Esconde o bloco inteiro do tema */
        '#single-product.js-coach-layout{display:none!important}',

        /* Container EORA que substitui */
        '.eora-product-wrap{display:grid;grid-template-columns:60% 40%;align-items:start;max-width:1400px;margin:0 auto;padding:40px 20px;box-sizing:border-box}',
        '@media(max-width:1024px) and (min-width:769px){.eora-product-wrap{grid-template-columns:55% 45%}}',
        '@media(max-width:768px){.eora-product-wrap{grid-template-columns:1fr}}',
        '.eora-product-info{padding-left:40px;box-sizing:border-box;display:flex!important;flex-direction:column!important}',
        '@media(max-width:1024px) and (min-width:769px){.eora-product-info{padding-left:24px}}',
        '@media(max-width:768px){.eora-product-info{padding-left:0;margin-top:24px}}',
        '.eora-product-info .product-infos{display:flex!important;flex-direction:column!important}',
        '.eora-product-info .eora-bolsa-vars{margin-left:0!important;margin-right:0!important}',

        /* ── Galeria vertical ── */
        '.eora-blg-wrap{display:flex!important;flex-direction:row!important;width:100%!important;gap:16px!important;align-items:stretch!important}',
        '.eora-product-gallery{width:100%!important;min-width:0!important;display:block!important}',
        '.eora-blg-strip{display:flex!important;flex-direction:column!important;align-items:center!important;justify-content:flex-start!important;position:relative!important;width:var(--eora-gallery-thumb-size,180px)!important;height:var(--eora-gallery-main-height,auto)!important;max-height:var(--eora-gallery-main-height,none)!important;overflow:visible!important;box-sizing:border-box!important;align-self:flex-start!important;flex-shrink:0!important}',
        '.eora-blg-arrow{position:absolute!important;left:50%!important;transform:translateX(-50%)!important;background:none!important;border:none!important;padding:6px!important;cursor:pointer!important;display:flex!important;align-items:center!important;justify-content:center!important;opacity:0.5!important;transition:opacity .2s!important;flex-shrink:0!important;z-index:2!important}',
        '.eora-blg-strip .eora-blg-arrow:first-child{top:-28px!important}',
        '.eora-blg-strip .eora-blg-arrow:last-child{bottom:-28px!important}',
        '.eora-blg-arrow:hover{opacity:1!important}',
        '.eora-blg-arrow svg{width:14px!important;height:14px!important;fill:none!important;stroke:#111!important;stroke-width:2px!important;stroke-linecap:round!important;stroke-linejoin:round!important;display:block!important}',
        '.eora-blg-tvp{overflow:hidden!important;width:var(--eora-gallery-thumb-size,180px)!important;height:100%!important;flex:0 0 100%!important;min-height:0!important;display:flex!important;align-items:flex-start!important;justify-content:center!important;padding:0!important}',
        '.eora-blg-ttrack{display:flex!important;flex-direction:column!important;gap:14px!important;transition:transform .3s ease!important;width:100%!important}',
        '.eora-blg-thumb{width:var(--eora-gallery-thumb-size,180px)!important;height:var(--eora-gallery-thumb-size,180px)!important;cursor:pointer!important;border:1px solid transparent!important;box-sizing:border-box!important;flex-shrink:0!important;transition:border-color .2s!important}',
        '.eora-blg-thumb img{width:100%!important;height:100%!important;object-fit:cover!important;display:block!important}',
        '.eora-blg-thumb.eora-active{border-color:#111!important}',
        '.eora-blg-main-wrap{flex:1 1 auto!important;width:100%!important;min-width:0!important;overflow:hidden!important;position:relative!important;aspect-ratio:1/1!important;align-self:flex-start!important}',
        '.eora-blg-track{display:flex!important;transition:transform .35s ease!important;will-change:transform!important}',
        '.eora-blg-slide{flex:0 0 100%!important;width:100%!important;box-sizing:border-box!important;aspect-ratio:1/1!important;overflow:hidden!important}',
        '.eora-blg-slide img{width:100%!important;height:100%!important;display:block!important;object-fit:cover!important}',
        '.eora-blg-mdots{display:none!important;justify-content:center!important;gap:8px!important;padding:14px 0 6px!important}',
        '.eora-blg-dot{width:7px!important;height:7px!important;border-radius:50%!important;background:#ccc!important;border:none!important;padding:0!important;cursor:pointer!important;transition:background .2s!important}',
        '.eora-blg-dot.eora-active{background:#111!important}',

        /* tablet: esconde strip, mostra dots (imagem maior) */
        '@media(max-width:1024px) and (min-width:769px){' +
            '.eora-blg-strip{display:none!important}' +
            '.eora-blg-mdots{display:flex!important}' +
        '}',

        /* mobile: strip horizontal abaixo da imagem principal */
        '@media(max-width:768px){' +
            '.eora-blg-wrap{flex-direction:column!important;gap:0!important;position:static!important}' +
            '.eora-blg-main-wrap{order:1!important}' +
            '.eora-blg-strip{order:2!important;display:flex!important;position:static!important;width:100%!important;height:auto!important;max-height:none!important;background:transparent!important;flex-direction:row!important;align-items:center!important;padding:8px 0 0!important;flex-shrink:0!important}' +
            '.eora-blg-strip .eora-blg-arrow{display:none!important}' +
            '.eora-blg-strip .eora-blg-tvp{width:100%!important;padding:0!important;max-height:none!important;overflow-x:auto!important;overflow-y:hidden!important;scrollbar-width:none!important;-ms-overflow-style:none!important;scroll-snap-type:x mandatory!important}' +
            '.eora-blg-strip .eora-blg-tvp::-webkit-scrollbar{display:none!important}' +
            '.eora-blg-strip .eora-blg-ttrack{flex-direction:row!important;gap:6px!important;width:auto!important;transform:none!important}' +
            '.eora-blg-strip .eora-blg-thumb{border:1px solid transparent!important;box-shadow:none!important;scroll-snap-align:start!important;flex-shrink:0!important}' +
            '.eora-blg-strip .eora-blg-thumb.eora-active{border-color:#111!important;outline:none!important}' +
            '.eora-blg-mdots{display:none!important}' +
            '.eora-blg-slide{aspect-ratio:4/5!important}' +
        '}',

        /* ── Swatches de variante ── */
        '.eora-bolsa-vars{display:flex!important;flex-wrap:wrap!important;gap:8px!important;margin:12px 0 16px!important;width:100%!important;max-width:100%!important}',
        '.eora-bolsa-var-item{border:1px solid #ecece8!important;cursor:pointer!important;width:56px!important;height:56px!important;min-width:56px!important;min-height:56px!important;overflow:hidden!important;transition:border-color .2s!important;box-sizing:border-box!important;background:#f5f5f3!important}',
        '.eora-bolsa-var-item:hover,.eora-bolsa-var-item.eora-active{border:2px solid #111!important}',
        '.eora-bolsa-var-item img{width:100%!important;height:100%!important;object-fit:cover!important;display:block!important}',

        /* mobile: miniaturas levemente menores */
        '@media(max-width:480px){' +
            '.eora-bolsa-var-item{width:52px!important;height:52px!important;min-width:52px!important;min-height:52px!important}' +
        '}',

        /* ── Descrição com "ver mais" ── */
        '.eora-desc-acc{margin-bottom:16px!important}',
        '.eora-desc-body{max-height:130px!important;overflow:hidden!important;transition:max-height .4s ease!important;position:relative!important}',
        '.eora-desc-body::after{content:""!important;position:absolute!important;bottom:0!important;left:0!important;right:0!important;height:32px!important;background:linear-gradient(transparent,#fff)!important;pointer-events:none!important;transition:opacity .3s!important}',
        '.eora-desc-acc.eora-open .eora-desc-body{max-height:1200px!important}',
        '.eora-desc-acc.eora-open .eora-desc-body::after{opacity:0!important}',
        '.eora-desc-inner{font-size:13px!important;line-height:1.75!important;color:#444!important;font-weight:400!important}',
        '.eora-desc-inner strong,.eora-desc-inner b{font-weight:400!important}',
        '.eora-desc-toggle{background:none!important;border:none!important;padding:4px 0!important;cursor:pointer!important;font-size:12px!important;letter-spacing:.5px!important;text-decoration:underline!important;color:#111!important;font-family:inherit!important;display:block!important;margin-top:6px!important}',

        /* ── Títulos e espaçamento padrão de seção ── */
        '.eora-section-titulo{display:block!important;text-align:center!important;font-size:32px!important;line-height:1.2!important;letter-spacing:0!important;text-transform:uppercase!important;margin:0 auto 32px!important;color:#000!important;font-family:inherit!important;font-weight:800!important}',
        '@media(max-width:767px){.eora-section-titulo{font-size:26px!important;margin-bottom:24px!important}}',
        '.eora-section-bloco{margin-top:80px!important;width:100%!important;box-sizing:border-box!important}',
        '.eora-section-bloco.eora-banner-full-bloco{margin-top:40px!important}',
        '#cheguei-alert-div{display:none!important}',
        '.eora-cloned-product-form,.eora-cloned-product-form .row,.eora-cloned-product-form [class*="col-"]{margin-bottom:0px!important;padding-bottom:0px!important}',
        '.eora-cloned-product-form .dropdown-wrapper,.eora-cloned-product-form .shipping-dropdown{margin-top:16px!important;margin-bottom:8px!important}'
    ].join('');

    var styleEl = document.createElement('style');
    styleEl.textContent = css;
    (document.head || document.documentElement).appendChild(styleEl);

    var eoraConfigTableCache = [];

    function snapshotConfigTables() {
        if (eoraConfigTableCache.length) return;
        document.querySelectorAll('table').forEach(function (table) {
            eoraConfigTableCache.push(table.cloneNode(true));
        });
    }

    function getSrc(img) {
        /* Tenta atributos de zoom/lazy primeiro (maior resolução) */
        var candidates = [
            img.getAttribute('data-zoom-image'),
            img.getAttribute('data-image'),
            img.getAttribute('data-src'),
            img.getAttribute('data-lazy-src'),
            img.getAttribute('data-original')
        ];
        /* Parent <a href> no Nuvemshop contém a URL em alta resolução */
        var par = img.parentElement;
        if (par && par.tagName === 'A') candidates.push(par.getAttribute('href'));
        candidates.push(img.getAttribute('src'));
        candidates.push(img.src);
        for (var i = 0; i < candidates.length; i++) {
            var c = candidates[i];
            if (c && c.indexOf('data:') !== 0 && c.length > 10 && /\.(jpg|jpeg|png|webp|avif)(\?|$)/i.test(c)) return c;
        }
        return img.getAttribute('src') || img.src || '';
    }

    function normalizeUrl(url) {
        if (!url || typeof url !== 'string') return url;
        // Path-based: /thumbnail/ /small/ /medium/ /large/ /huge/ → /original/
        url = url.replace(/\/(thumbnail|small|medium|large|huge)\//g, '/original/');
        // Filename-based (mitiendanube CDN): nome-50-0.jpg ou nome-1024-1024.jpg → nome-1024-1024.jpg
        // Substitui o sufixo numérico final (width-height) pela versão 1024x1024
        url = url.replace(/(-\d+-\d+)(\.[\w]{2,5})(\?.*)?$/, '-1024-1024$2');
        return url;
    }

    function getDados() {
        var d = {};
        document.querySelectorAll('.js-product-description-base table').forEach(function (t) {
            var td = t.querySelector('tbody > tr:first-child td:first-child');
            if (td) d[td.textContent.trim().toLowerCase()] = t;
        });
        eoraConfigTableCache.forEach(function (t) {
            var td = t.querySelector('tbody > tr:first-child td:first-child');
            if (td) d[td.textContent.trim().toLowerCase()] = t;
        });
        return d;
    }

    function criarBlocoTitulo(titulo) {
        var bloco = document.createElement('div');
        bloco.className = 'eora-section-bloco';
        if (titulo) {
            var h2 = document.createElement('h2');
            h2.className = 'eora-section-titulo';
            h2.textContent = titulo;
            bloco.appendChild(h2);
        }
        return bloco;
    }

    function normalizeConfigKey(key) {
        return String(key || '')
            .replace(/[\u00a0\s]+/g, ' ')
            .trim()
            .toLowerCase()
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '');
    }

    function isTitleKey(key) {
        key = normalizeConfigKey(key);
        return key.indexOf('titulo') === 0;
    }

    function getTableTitleText(table) {
        var title = '';
        if (!table) return title;
        table.querySelectorAll('tbody > tr').forEach(function (row) {
            if (title) return;
            var cells = row.querySelectorAll('td');
            if (cells.length < 2 || !isTitleKey(cells[0].textContent)) return;
            title = cells[1].textContent.replace(/[\u00a0\s]+/g, ' ').trim();
        });
        return title;
    }

    function syncSectionTitleBefore(target, title, className) {
        if (!target || !target.parentNode) return;
        className = className || 'eora-section-titulo-dinamico';
        var prev = target.previousElementSibling;
        if (prev && prev.classList.contains(className)) prev.parentNode.removeChild(prev);
        if (!title) return;
        var h2 = document.createElement('h2');
        h2.className = 'eora-section-titulo ' + className;
        h2.textContent = title;
        target.parentNode.insertBefore(h2, target);
    }

    function findInstitutionalAnchor() {
        var direct = document.querySelector('[data-store="home-institutional-message"]');
        if (direct && !(direct.closest && direct.closest('[class*="product-description-"]'))) return direct;

        var needle = 'na eora, cada detalhe foi criado para entregar mais do que produtos';
        var candidates = [];
        document.querySelectorAll('section,[data-store],.container-fluid,.container,.row,div').forEach(function (el) {
            if (el.classList && (
                el.classList.contains('eora-banner-produto') ||
                el.classList.contains('eora-section-bloco') ||
                el.classList.contains('eora-social-inline')
            )) return;
            if (el.closest && el.closest('[class*="product-description-"]')) return;
            var txt = el.textContent || '';
            var norm = txt.toLowerCase().replace(/[\u00a0\s]+/g, ' ').trim();
            if (norm.indexOf(needle) === -1) return;
            candidates.push({ el: el, len: norm.length });
        });

        candidates.sort(function (a, b) { return a.len - b.len; });
        return candidates.length ? candidates[0].el : null;
    }

    var cachedInstitutionalAnchor = null;
    function buildCustomInstitutionalMessage() {
        var dados = getDados();
        var t = dados['texto_institucional'];
        if (!t) return;
        var titulo = '';
        var texto = '';
        var nomeVariacao = '';
        t.querySelectorAll('tbody > tr').forEach(function(row) {
            var cells = row.querySelectorAll('td');
            if (cells.length < 2) return;
            var key = (cells[0].textContent || '').trim().toLowerCase();
            
            var cleanHTML = function(html) {
                return html.replace(/<br\s*\/?>/gi, ' ')
                           .replace(/<\/p>\s*<p[^>]*>/gi, ' ')
                           .replace(/<\/?p[^>]*>/gi, ' ')
                           .replace(/\s+/g, ' ')
                           .trim();
            };
            
            if (key === 'titulo_institucional') titulo = cleanHTML(cells[1].innerHTML);
            if (key === 'texto_institucional' && row.rowIndex > 0) texto = cleanHTML(cells[1].innerHTML);
            if (key === 'nome_variacao' || key === 'nome_variação') nomeVariacao = cells[1].innerHTML || cells[1].textContent;
        });

        if (nomeVariacao) {
            var infoEl = document.querySelector('.eora-product-info');
            if (infoEl) {
                var h2 = infoEl.querySelector('.js-product-name');
                if (h2 && !infoEl.querySelector('.eora-nome-variacao')) {
                    var div = document.createElement('div');
                    div.className = 'eora-nome-variacao';
                    div.style.marginTop = '-8px';
                    div.style.marginBottom = '16px';
                    div.style.fontSize = '12px';
                    div.style.color = '#666';
                    div.innerHTML = nomeVariacao;
                    h2.parentNode.insertBefore(div, h2.nextSibling);
                }
            }
        }

        if (!titulo && !texto) return;

        var anchor = findInstitutionalAnchor();
        if (anchor) {
            var wrapper = anchor.querySelector('.container') || anchor.querySelector('.row') || anchor;
            
            var contentHTML = '<div class="institutional-container container-fluid">' +
                              '<div class="institutional-left d-flex flex-column">' + 
                              (titulo ? '<h3 class="institutional-title mb-0">' + titulo + '</h3>' : '') + 
                              (texto ? '<p class="institutional-text mb-0">' + texto + '</p>' : '') + 
                              '</div>' + 
                              '<div class="institutional-right">' + 
                              '<a href="/sobre1" class="institutional-link" aria-label="Sobre a EORA">' + 
                              'Sobre a EORA' + 
                              '<svg class="institutional-link-icon icon-inline icon-md"><use xlink:href="#chevron"></use></svg>' + 
                              '</a></div></div>';
            
            wrapper.innerHTML = contentHTML;
        }
    }

    function getOriginalProductRoot() {
        return document.querySelector('#single-product');
    }

    function getOriginalProductForm() {
        var root = getOriginalProductRoot();
        if (!root) return null;
        return root.querySelector('#product_form, .js-product-form, form[action*="/cart"], form');
    }

    function getOriginalAddButton() {
        var form = getOriginalProductForm();
        if (!form) return null;
        return form.querySelector('[name="commit"], input.js-addtocart, button.js-addtocart, .js-addtocart');
    }

    function syncFormValues(fromForm, toForm) {
        if (!fromForm || !toForm) return;
        var fields = fromForm.querySelectorAll('input[name], select[name], textarea[name]');
        fields.forEach(function (src) {
            if (src.disabled) return;
            var name = src.getAttribute('name');
            if (!name) return;
            var dstList = toForm.querySelectorAll('[name="' + name.replace(/"/g, '\\"') + '"]');
            if (!dstList.length) return;

            if (src.type === 'radio') {
                if (!src.checked) return;
                dstList.forEach(function (dst) {
                    dst.checked = (dst.value === src.value);
                });
                return;
            }

            if (src.type === 'checkbox') {
                dstList.forEach(function (dst) {
                    dst.checked = src.checked;
                });
                return;
            }

            dstList.forEach(function (dst) {
                dst.value = src.value;
            });
        });
    }

    function triggerOriginalBuy() {
        var form = getOriginalProductForm();
        if (!form) return false;
        var addBtn = getOriginalAddButton();
        if (addBtn) {
            addBtn.click();
            return true;
        }
        if (typeof form.requestSubmit === 'function') {
            form.requestSubmit();
            return true;
        }
        form.submit();
        return true;
    }

    function bindShippingCalculator(infoEl, themeProd) {
        var origShipping = themeProd.querySelector('.js-shipping-calculator-container, .shipping-calculator-container, .js-shipping-calculator, .shipping-calculator') || themeProd.querySelector('input[name="zipcode"], .js-shipping-input')?.closest('div');
        var clonedShipping = infoEl.querySelector('.js-shipping-calculator-container, .shipping-calculator-container, .js-shipping-calculator, .shipping-calculator') || infoEl.querySelector('input[name="zipcode"], .js-shipping-input')?.closest('div');
        
        if (origShipping && clonedShipping) {
            var origInput = origShipping.querySelector('input[name="zipcode"], .js-shipping-input, input');
            var origBtn = origShipping.querySelector('.js-calculate-shipping, .js-shipping-calculator-btn, button, input[type="button"]');
            var origResponse = origShipping.querySelector('.js-shipping-calculator-response, .shipping-calculator-response, .js-shipping-response');
            
            var clonedInput = clonedShipping.querySelector('input[name="zipcode"], .js-shipping-input, input');
            var clonedBtn = clonedShipping.querySelector('.js-calculate-shipping, .js-shipping-calculator-btn, button, input[type="button"]');
            var clonedResponse = clonedShipping.querySelector('.js-shipping-calculator-response, .shipping-calculator-response, .js-shipping-response');
            
            if (clonedBtn) {
                clonedBtn.classList.remove('js-calculate-shipping', 'js-shipping-calculator-btn');
                clonedBtn.classList.add('eora-calculate-shipping-btn');
                
                var freshBtn = clonedBtn.cloneNode(true);
                clonedBtn.parentNode.replaceChild(freshBtn, clonedBtn);
                
                freshBtn.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    if (clonedInput && origInput) {
                        origInput.value = clonedInput.value;
                        origInput.dispatchEvent(new Event('input', { bubbles: true }));
                        origInput.dispatchEvent(new Event('change', { bubbles: true }));
                    }
                    if (origBtn) {
                        origBtn.click();
                    }
                });
            }
            
            if (clonedInput) {
                var freshInput = clonedInput.cloneNode(true);
                clonedInput.parentNode.replaceChild(freshInput, clonedInput);
                freshInput.addEventListener('keydown', function (e) {
                    if (e.key === 'Enter') {
                        e.preventDefault();
                        e.stopPropagation();
                        var btn = clonedShipping.querySelector('.eora-calculate-shipping-btn');
                        if (btn) btn.click();
                    }
                });
            }
            
            if (origResponse && clonedResponse) {
                var syncResponse = function () {
                    clonedResponse.innerHTML = origResponse.innerHTML;
                    clonedResponse.style.display = origResponse.style.display;
                    clonedResponse.className = origResponse.className;
                };
                var observer = new MutationObserver(syncResponse);
                observer.observe(origResponse, { childList: true, subtree: true, attributes: true });
                syncResponse();
            }
            
            var syncAllShipping = function () {
                var origResp = origShipping.querySelector('.js-shipping-calculator-response, .shipping-calculator-response, .js-shipping-response');
                var clonedResp = clonedShipping.querySelector('.js-shipping-calculator-response, .shipping-calculator-response, .js-shipping-response');
                if (origResp && clonedResp && clonedResp.innerHTML !== origResp.innerHTML) {
                    clonedResp.innerHTML = origResp.innerHTML;
                    clonedResp.style.display = origResp.style.display;
                }
            };
            var fallbackObserver = new MutationObserver(syncAllShipping);
            fallbackObserver.observe(origShipping, { childList: true, subtree: true, attributes: true });
        }
    }

    var eoraPageCache = {};
    
    function prefetchVariationPages(items) {
        items.forEach(function (item) {
            var path = normalizePathname(item.href);
            if (!path || eoraPageCache[path]) return;
            
            var doFetch = function () {
                fetch(path)
                    .then(function (r) { return r.text(); })
                    .then(function (html) {
                        eoraPageCache[path] = html;
                    })
                    .catch(function () {});
            };
            
            if (typeof requestIdleCallback === 'function') {
                requestIdleCallback(doFetch);
            } else {
                setTimeout(doFetch, 1000);
            }
        });
    }

    function reorganizeEoraProductInfo(infoEl) {
        if (!infoEl) return;
        
        // 1. Reordenar fisicamente os filhos internos de .product-infos
        var productInfos = infoEl.querySelector('.product-infos');
        if (productInfos) {
            var nameEl = productInfos.querySelector('.js-product-name');
            var nameVarEl = productInfos.querySelector('.eora-nome-variacao');
            var priceContainer = productInfos.querySelector('.price-container');
            
            var innerOrdered = [nameEl, nameVarEl, priceContainer];
            innerOrdered.forEach(function (el) {
                if (el && productInfos.contains(el)) {
                    productInfos.appendChild(el);
                }
            });
        }
        
        // 2. Reordenar fisicamente os filhos diretos da coluna de detalhes
        var descAcc = infoEl.querySelector('.eora-desc-acc') || infoEl.querySelector('.js-product-description-short') || infoEl.querySelector('.product-description-short');
        var bolsaVars = infoEl.querySelector('.eora-bolsa-vars') || infoEl.querySelector('.js-product-variants') || infoEl.querySelector('.js-color-variants-container');
        var clonedForm = infoEl.querySelector('.eora-cloned-product-form') || infoEl.querySelector('#product_form') || infoEl.querySelector('form');
        
        var orderedElements = [productInfos, descAcc, bolsaVars, clonedForm];
        orderedElements.forEach(function (el) {
            if (el && infoEl.contains(el)) {
                infoEl.appendChild(el);
            }
        });
    }

    function navigateToVariation(path, fullUrl) {
        var grid = document.querySelector('.eora-bolsa-vars');
        if (grid) {
            grid.querySelectorAll('.eora-bolsa-var-item').forEach(function (x) {
                var itemPath = x.getAttribute('data-href-path');
                x.classList.toggle('eora-active', itemPath === path);
            });
        }
        
        var htmlPromise = eoraPageCache[path]
            ? Promise.resolve(eoraPageCache[path])
            : fetch(path).then(function (r) { return r.text(); });
            
        htmlPromise.then(function (html) {
            eoraPageCache[path] = html;
            
            var parser = new DOMParser();
            var newDoc = parser.parseFromString(html, 'text/html');
            var newSP = newDoc.querySelector('#single-product');
            
            // Se o produto atual ou o destino estiver sem estoque, recarrega a página tradicionalmente para recriar o App Cheguei corretamente
            var currentIsNoStock = document.querySelector('.nostock, [disabled], .eora-buy-btn[disabled]') || document.getElementById('cheguei-alert-div');
            var targetIsNoStock = newSP && (newSP.querySelector('.nostock, [disabled], .eora-buy-btn[disabled]') || newSP.querySelector('#cheguei-alert-div'));
            if (currentIsNoStock || targetIsNoStock) {
                window.location.href = fullUrl;
                return;
            }
            
            if (normalizePathname(window.location.href) !== path) {
                history.pushState({ eoraPath: path }, '', fullUrl);
            }
            
            document.title = newDoc.title;
            
            var oldSP = document.querySelector('#single-product');
            var newSP = newDoc.querySelector('#single-product');
            if (oldSP && newSP) {
                oldSP.parentNode.replaceChild(newSP, oldSP);
                newSP.style.setProperty('display', 'none', 'important');
                newSP.style.setProperty('visibility', 'hidden', 'important');
                newSP.style.setProperty('height', '0', 'important');
                newSP.style.setProperty('overflow', 'hidden', 'important');
                newSP.style.setProperty('position', 'absolute', 'important');
                newSP.style.setProperty('left', '-99999px', 'important');
                newSP.style.setProperty('top', '-99999px', 'important');
                newSP.style.setProperty('width', '0', 'important');
                newSP.style.setProperty('opacity', '0', 'important');
                newSP.style.setProperty('pointer-events', 'none', 'important');
            }
            
            var infoEl = document.querySelector('.eora-product-info');
            var galleryEl = document.querySelector('.eora-product-gallery');
            var themeProd = document.querySelector('#single-product');
            
            if (infoEl && themeProd) {
                var nameEl = infoEl.querySelector('.js-product-name');
                var newNameEl = newSP.querySelector('.js-product-name');
                if (nameEl && newNameEl) nameEl.innerHTML = newNameEl.innerHTML;
                
                var priceEl = infoEl.querySelector('.js-price-display, .product-price');
                var newPriceEl = newSP.querySelector('.js-price-display, .product-price');
                if (priceEl && newPriceEl) priceEl.innerHTML = newPriceEl.innerHTML;
                
                var dados = {};
                newDoc.querySelectorAll('.js-product-description-base table').forEach(function (t) {
                    var td = t.querySelector('tbody > tr:first-child td:first-child');
                    if (td) dados[td.textContent.trim().toLowerCase()] = t;
                });
                var t = dados['texto_institucional'];
                var nomeVariacao = '';
                if (t) {
                    t.querySelectorAll('tbody > tr').forEach(function(row) {
                        var cells = row.querySelectorAll('td');
                        if (cells.length < 2) return;
                        var key = (cells[0].textContent || '').trim().toLowerCase();
                        if (key === 'nome_variacao' || key === 'nome_variação') nomeVariacao = cells[1].innerHTML || cells[1].textContent;
                    });
                }
                
                var varTitleEl = infoEl.querySelector('.eora-nome-variacao');
                if (varTitleEl) {
                    if (nomeVariacao) {
                        varTitleEl.style.display = 'block';
                        varTitleEl.innerHTML = nomeVariacao;
                    } else {
                        varTitleEl.style.display = 'none';
                    }
                } else if (nomeVariacao) {
                    var h2 = infoEl.querySelector('.js-product-name');
                    if (h2) {
                        var div = document.createElement('div');
                        div.className = 'eora-nome-variacao';
                        div.style.marginTop = '-8px';
                        div.style.marginBottom = '16px';
                        div.style.fontSize = '12px';
                        div.style.color = '#666';
                        div.innerHTML = nomeVariacao;
                        h2.parentNode.insertBefore(div, h2.nextSibling);
                    }
                }
                
                var newPhotos = [];
                var seenUrls = {};
                function addPhoto(url) {
                    if (!url || typeof url !== 'string' || url.indexOf('data:') === 0 || url.length < 10) return;
                    var u = normalizeUrl(url);
                    if (!u) return;
                    var k = u.replace(/\?.*$/, '').toLowerCase();
                    if (seenUrls[k]) return;
                    seenUrls[k] = true;
                    newPhotos.push(u);
                }
                try {
                    var scripts = newDoc.querySelectorAll('script');
                    var parsedLS = null;
                    scripts.forEach(function (s) {
                        var txt = s.textContent || '';
                        if (txt.indexOf('LS.product') !== -1) {
                            var m = txt.match(/LS\.product\s*=\s*({[\s\S]*?});/);
                            if (m && m[1]) {
                                try { parsedLS = JSON.parse(m[1]); } catch (e) {}
                            }
                        }
                    });
                    if (parsedLS && parsedLS.images) {
                        parsedLS.images.forEach(function (img) { addPhoto(img.src || img.url || ''); });
                    }
                } catch (e) {}
                if (!newPhotos.length) {
                    newSP.querySelectorAll('.product-image-column img').forEach(function (img) { addPhoto(getSrc(img)); });
                }
                if (galleryEl && galleryEl._eoraSetPhotos && newPhotos.length) {
                    galleryEl._eoraSetPhotos(newPhotos);
                }
                
                var oldClonedForm = infoEl.querySelector('.eora-cloned-product-form');
                var newClonedForm = newSP.querySelector('#product_form, .js-product-form, form[action*="/cart"], form');
                if (oldClonedForm && newClonedForm) {
                    var formParent = oldClonedForm.parentNode;
                    var freshForm = newClonedForm.cloneNode(true);
                    freshForm.classList.add('eora-cloned-product-form');
                    if (freshForm.id === 'product_form') freshForm.removeAttribute('id');
                    
                    freshForm.querySelectorAll('.js-color-variants-container,.js-product-variants').forEach(function (el) {
                        el.parentNode && el.parentNode.removeChild(el);
                    });
                    
                    formParent.replaceChild(freshForm, oldClonedForm);
                    
                    var forwardToOriginal = function () {
                        var originalForm = getOriginalProductForm();
                        if (!originalForm) return;
                        syncFormValues(freshForm, originalForm);
                        triggerOriginalBuy();
                    };
                    freshForm.addEventListener('submit', function (e) {
                        e.preventDefault();
                        e.stopPropagation();
                        forwardToOriginal();
                    });
                    freshForm.querySelectorAll('[name="commit"], input.js-addtocart, button.js-addtocart, .js-addtocart').forEach(function (btn) {
                        btn.classList.remove('js-addtocart', 'js-addtocart-btn');
                        btn.removeAttribute('name');
                        btn.classList.add('eora-buy-btn');
                        btn.addEventListener('click', function (e) {
                            e.preventDefault();
                            e.stopPropagation();
                            forwardToOriginal();
                        });
                    });
                    freshForm.querySelectorAll('button, input[type="submit"]').forEach(function (btn) {
                        if (btn.classList.contains('eora-buy-btn')) return;
                        btn.addEventListener('click', function (e) {
                            e.preventDefault();
                            e.stopPropagation();
                            forwardToOriginal();
                        });
                    });
                }
                
                bindShippingCalculator(infoEl, themeProd);
                reorganizeEoraProductInfo(infoEl);
            }
        }).catch(function () {
            window.location.href = fullUrl;
        });
    }

    window.addEventListener('popstate', function (e) {
        if (e.state && e.state.eoraPath) {
            navigateToVariation(e.state.eoraPath, window.location.href);
        }
    });

    function makePlaceholderThumb(label) {
        var safeLabel = String(label || 'EORA').trim().slice(0, 18) || 'EORA';
        var svg = [
            '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 400 400">',
            '<rect width="400" height="400" fill="#f2f2ef"/>',
            '<rect x="24" y="24" width="352" height="352" rx="28" fill="none" stroke="#d6d6cf" stroke-width="3" stroke-dasharray="10 10"/>',
            '<text x="200" y="186" text-anchor="middle" font-family="Arial, sans-serif" font-size="28" fill="#7a7a73" letter-spacing="2">EORA</text>',
            '<text x="200" y="228" text-anchor="middle" font-family="Arial, sans-serif" font-size="18" fill="#8e8e87">',
            safeLabel.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;'),
            '</text>',
            '</svg>'
        ].join('');
        return 'data:image/svg+xml;charset=UTF-8,' + encodeURIComponent(svg);
    }

    function isRenderableThumbUrl(url) {
        return !!url && (/\.(jpg|jpeg|png|webp|avif)(\?|$)/i.test(url) || /^data:image\//i.test(url));
    }

    function normalizeCompareText(value) {
        return String(value || '')
            .toLowerCase()
            .normalize('NFD')
            .replace(/[\u0300-\u036f]/g, '')
            .replace(/[^a-z0-9]+/g, ' ')
            .trim();
    }

    var eoraProductVisibilityCache = {};

    function normalizePathname(url) {
        try {
            return new URL(url, window.location.origin).pathname.replace(/\/?$/, '/');
        } catch (e) {
            return '';
        }
    }

    function isVisibleProductPageByDocument(doc) {
        if (!doc) return false;
        if (doc.querySelector('.template-404, [data-store="page-not-found"], .error-page, .not-found')) return false;
        var root = doc.querySelector('#single-product');
        return !!root;
    }

    function isProductPublicAndBuyable(url) {
        var pathKey = normalizePathname(url);
        if (!pathKey) return Promise.resolve(false);
        if (eoraProductVisibilityCache.hasOwnProperty(pathKey)) {
            return Promise.resolve(eoraProductVisibilityCache[pathKey]);
        }

        var probeUrl = pathKey + (pathKey.indexOf('?') === -1 ? '?' : '&') + '_eora_probe=' + Date.now();
        return fetch(probeUrl, { credentials: 'same-origin', cache: 'no-store' })
            .then(function (response) {
                if (!response || !response.ok) return null;
                var finalPath = normalizePathname(response.url || pathKey);
                if (!finalPath || finalPath.indexOf('/produtos/') !== 0) return null;
                return response.text();
            })
            .then(function (html) {
                if (!html) {
                    eoraProductVisibilityCache[pathKey] = false;
                    return false;
                }
                var doc = new DOMParser().parseFromString(html, 'text/html');
                var ok = isVisibleProductPageByDocument(doc);
                eoraProductVisibilityCache[pathKey] = ok;
                return ok;
            })
            .catch(function () {
                eoraProductVisibilityCache[pathKey] = false;
                return false;
            });
    }

    function fetchProductPrimaryImage(url) {
        var pathKey = normalizePathname(url);
        if (!pathKey) return Promise.resolve('');

        function fetchFromIframe() {
            return new Promise(function (resolve) {
                var done = false;
                function finish(value) {
                    if (done) return;
                    done = true;
                    clearTimeout(timeoutId);
                    try {
                        iframe.onload = null;
                        iframe.parentNode && iframe.parentNode.removeChild(iframe);
                    } catch (e) {}
                    resolve(value || '');
                }

                var iframe = document.createElement('iframe');
                iframe.setAttribute('aria-hidden', 'true');
                iframe.style.cssText = 'position:absolute;left:-99999px;top:-99999px;width:1px;height:1px;opacity:0;pointer-events:none;';

                var timeoutId = setTimeout(function () {
                    finish('');
                }, 6000);

                iframe.onload = function () {
                    try {
                        var doc = iframe.contentDocument || (iframe.contentWindow && iframe.contentWindow.document);
                        if (!doc) return finish('');

                        var startedAt = Date.now();
                        var selectors = [
                            '.eora-product-gallery .eora-blg-slide img',
                            '.eora-product-gallery img',
                            '.product-image-column img',
                            '.js-product-slide img',
                            '.js-product-image img',
                            '[data-image-gallery] img'
                        ];

                        function tryReadImage() {
                            var candidates = [];
                            selectors.forEach(function (sel) {
                                var img = doc.querySelector(sel);
                                if (!img) return;
                                candidates.push(img.getAttribute('data-zoom-image'));
                                candidates.push(img.getAttribute('data-image'));
                                candidates.push(img.getAttribute('data-src'));
                                candidates.push(img.getAttribute('data-lazy-src'));
                                candidates.push(img.getAttribute('src'));
                                candidates.push(img.src);
                            });

                            for (var i = 0; i < candidates.length; i++) {
                                var c = candidates[i];
                                if (!c) continue;
                                try {
                                    c = new URL(c, window.location.origin).href;
                                } catch (e) {}
                                c = normalizeUrl(c);
                                if (isRenderableThumbUrl(c) && !/^data:image\//i.test(c)) return finish(c);
                            }

                            if (Date.now() - startedAt > 5000) return finish('');
                            setTimeout(tryReadImage, 200);
                        }

                        tryReadImage();
                    } catch (e) {
                        finish('');
                    }
                };

                var src = pathKey + (pathKey.indexOf('?') === -1 ? '?' : '&') + '_eora_iframe=' + Date.now();
                iframe.src = src;
                document.body.appendChild(iframe);
            });
        }

        var probeUrl = pathKey + (pathKey.indexOf('?') === -1 ? '?' : '&') + '_eora_img=' + Date.now();
        return fetch(probeUrl, { credentials: 'same-origin', cache: 'no-store' })
            .then(function (response) {
                if (!response || !response.ok) return '';
                return response.text();
            })
            .then(function (html) {
                if (!html) return '';
                var doc = new DOMParser().parseFromString(html, 'text/html');

                var candidates = [];
                var og = doc.querySelector('meta[property="og:image"]');
                if (og) candidates.push(og.getAttribute('content'));

                var tw = doc.querySelector('meta[name="twitter:image"]');
                if (tw) candidates.push(tw.getAttribute('content'));

                var mainImg = doc.querySelector('.product-image-column img, .js-product-slide img, .js-product-image img, [data-image-gallery] img, .js-product-image-container img');
                if (mainImg) {
                    candidates.push(mainImg.getAttribute('data-zoom-image'));
                    candidates.push(mainImg.getAttribute('data-image'));
                    candidates.push(mainImg.getAttribute('data-src'));
                    candidates.push(mainImg.getAttribute('data-lazy-src'));
                    candidates.push(mainImg.getAttribute('src'));
                    candidates.push(mainImg.src);
                }

                for (var i = 0; i < candidates.length; i++) {
                    var c = candidates[i];
                    if (!c) continue;
                    try {
                        c = new URL(c, window.location.origin).href;
                    } catch (e) {}
                    c = normalizeUrl(c);
                    if (isRenderableThumbUrl(c) && !/^data:image\//i.test(c)) return c;
                }

                return '';
            })
            .then(function (imgUrl) {
                if (imgUrl) return imgUrl;
                return fetchFromIframe();
            })
            .catch(function () { return ''; });
    }

    function fetchTagProducts(tag, currentPath) {
        if (!tag) return Promise.resolve([]);
        var baseSearchUrl = '/search/?q=' + encodeURIComponent(tag);

        var cacheKey = 'eora_vars_v2_' + tag.toLowerCase().trim();
        var cached = sessionStorage.getItem(cacheKey);
        if (cached) {
            try {
                var parsed = JSON.parse(cached);
                if (parsed && parsed.length) {
                    return Promise.resolve(parsed);
                }
            } catch (e) {}
        }

        function extractUrlFromSrcset(srcset) {
            if (!srcset) return '';
            var parts = String(srcset).split(',').map(function (p) { return p.trim(); }).filter(Boolean);
            if (!parts.length) return '';
            var last = parts[parts.length - 1].split(/\s+/)[0];
            return last || '';
        }

        function collectItemsFromDoc(doc, items, seen) {
            doc.querySelectorAll('.item').forEach(function (itemEl) {
                var link = itemEl.querySelector('a[href*="/produtos/"]');
                if (!link) return;
                var href = link.getAttribute('href') || '';
                if (!href) return;
                var absUrl;
                try {
                    absUrl = new URL(href, window.location.origin).href;
                } catch (e) {
                    return;
                }

                var hrefPath = normalizePathname(absUrl);
                if (!hrefPath || hrefPath.indexOf('/produtos/') !== 0) return;
                if (seen[hrefPath]) return;

                var img = itemEl.querySelector('img.js-item-image, img.item-image-primary, img');
                var name = (link.getAttribute('title') || link.getAttribute('aria-label') || '').trim();
                
                if (!name) {
                    var altLink = itemEl.querySelector('a.item-link');
                    if (altLink) {
                        name = (altLink.getAttribute('title') || altLink.getAttribute('aria-label') || altLink.textContent || '').trim();
                    }
                }
                
                if (!name && img) {
                    name = (img.getAttribute('alt') || '').trim();
                }
                
                var imgUrl = '';
                if (img) {
                    var candidates = [
                        img.getAttribute('data-srcset'),
                        img.getAttribute('srcset'),
                        img.getAttribute('data-zoom-image'),
                        img.getAttribute('data-image'),
                        img.getAttribute('data-src'),
                        img.getAttribute('data-lazy-src'),
                        img.getAttribute('data-original'),
                        img.getAttribute('src'),
                        img.src
                    ];
                    
                    var bg = '';
                    var styleNode = itemEl.querySelector('[style*="background"]');
                    if (styleNode) {
                        var st = styleNode.getAttribute('style') || '';
                        var m = st.match(/url\((['"]?)(.*?)\1\)/i);
                        if (m && m[2]) bg = m[2];
                    }
                    candidates.push(bg);

                    for (var i = 0; i < candidates.length; i++) {
                        var raw = candidates[i];
                        if (!raw) continue;
                        var candidate = raw;
                        if (candidate.indexOf(',') !== -1 || /\s\d+w/.test(candidate)) {
                            candidate = extractUrlFromSrcset(candidate);
                        }
                        if (!candidate || candidate.indexOf('data:') === 0) continue;
                        try {
                            candidate = new URL(candidate, window.location.origin).href;
                        } catch (e) {}
                        if (isRenderableThumbUrl(candidate)) {
                            imgUrl = normalizeUrl(candidate);
                            break;
                        }
                    }
                }
                
                if (!imgUrl) {
                    imgUrl = makePlaceholderThumb(name || tag);
                }

                seen[hrefPath] = true;
                items.push({ url: imgUrl, href: absUrl, name: name || tag });
            });
        }

        function collectPageUrls(doc) {
            var urls = [];
            var seenPage = {};
            var normTag = normalizeCompareText(tag);

            doc.querySelectorAll('a[href*="/search"], a[href*="q="]').forEach(function (a) {
                var href = a.getAttribute('href') || '';
                if (!href) return;
                var u;
                try {
                    u = new URL(href, window.location.origin);
                } catch (e) {
                    return;
                }
                if (u.pathname.indexOf('/search') !== 0) return;
                var q = normalizeCompareText(u.searchParams.get('q') || '');
                if (q && q !== normTag) return;
                u.searchParams.set('_', String(Date.now()));
                var key = u.pathname + '?' + u.searchParams.toString();
                if (seenPage[key]) return;
                seenPage[key] = true;
                urls.push(u.toString());
            });

            return urls;
        }

        return fetch(baseSearchUrl + '&_=' + Date.now(), { credentials: 'same-origin', cache: 'no-store' })
            .then(function (response) { return response.text(); })
            .then(function (html) {
                var firstDoc = new DOMParser().parseFromString(html, 'text/html');
                var items = [];
                var seen = {};

                collectItemsFromDoc(firstDoc, items, seen);

                var pageUrls = collectPageUrls(firstDoc).filter(function (url) {
                    return normalizePathname(url).indexOf('/search') === 0;
                });

                if (!pageUrls.length) return items;

                return Promise.all(pageUrls.map(function (url) {
                    return fetch(url, { credentials: 'same-origin', cache: 'no-store' })
                        .then(function (res) { return res.text(); })
                        .then(function (pageHtml) {
                            var pageDoc = new DOMParser().parseFromString(pageHtml, 'text/html');
                            collectItemsFromDoc(pageDoc, items, seen);
                        })
                        .catch(function () {});
                })).then(function () { return items; });
            })
            .then(function (items) {
                var unique = [];
                var seenHref = {};
                (items || []).forEach(function (it) {
                    var norm = normalizePathname(it.href);
                    if (!seenHref[norm]) {
                        seenHref[norm] = true;
                        unique.push(it);
                    }
                });

                // Garantia/Salvaguarda: assegurar que o produto atual está na lista de variações
                var currentHref = window.location.href;
                var currentPathNormalized = normalizePathname(currentHref);
                var hasCurrent = unique.some(function (it) {
                    return normalizePathname(it.href) === currentPathNormalized;
                });
                if (!hasCurrent) {
                    var nameEl = document.querySelector('.js-product-name');
                    var imgEl = document.querySelector('.eora-blg-slide img, .product-image-column img, img');
                    if (nameEl) {
                        var currentName = nameEl.textContent.trim();
                        var currentImgSrc = '';
                        if (imgEl) {
                            currentImgSrc = imgEl.getAttribute('data-zoom-image') || imgEl.getAttribute('data-image') || imgEl.getAttribute('data-src') || imgEl.getAttribute('src') || '';
                        }
                        if (currentImgSrc) currentImgSrc = normalizeUrl(currentImgSrc);
                        unique.push({
                            url: currentImgSrc || makePlaceholderThumb(currentName),
                            href: currentHref,
                            name: currentName
                        });
                    }
                }

                // Ordenar alfabeticamente pelo nome para garantir ordem 100% idêntica em qualquer página
                unique.sort(function (a, b) {
                    var nameA = String(a.name || '');
                    var nameB = String(b.name || '');
                    return nameA.localeCompare(nameB, 'pt', { sensitivity: 'base' });
                });

                // Armazenar no cache da sessão
                try {
                    sessionStorage.setItem(cacheKey, JSON.stringify(unique));
                } catch (e) {}

                return unique;
            })
            .catch(function () { return []; });
    }

    function cellText(cell) {
        return cell ? cell.textContent.replace(/[\u00a0\s]+/g, ' ').trim() : '';
    }

    function buildGallery(galleryEl, photos) {
        var activeIdx = 0, visStart = 0;
        var VISIBLE = 3, thumbStep = 194;

        var wrap = document.createElement('div');
        wrap.className = 'eora-blg-wrap';

        var strip = document.createElement('div');
        strip.className = 'eora-blg-strip';
        var svgUp = '<svg viewBox="0 0 24 24"><polyline points="18 15 12 9 6 15"/></svg>';
        var svgDn = '<svg viewBox="0 0 24 24"><polyline points="6 9 12 15 18 9"/></svg>';
        var btnUp = document.createElement('button');
        btnUp.className = 'eora-blg-arrow'; btnUp.innerHTML = svgUp; btnUp.setAttribute('aria-label', 'Anterior');
        var tvp = document.createElement('div'); tvp.className = 'eora-blg-tvp';
        var ttrack = document.createElement('div'); ttrack.className = 'eora-blg-ttrack';
        tvp.appendChild(ttrack);
        var btnDn = document.createElement('button');
        btnDn.className = 'eora-blg-arrow'; btnDn.innerHTML = svgDn; btnDn.setAttribute('aria-label', 'Pr\u00f3ximo');
        strip.appendChild(btnUp); strip.appendChild(tvp); strip.appendChild(btnDn);

        var mainWrap = document.createElement('div'); mainWrap.className = 'eora-blg-main-wrap';
        var mainTrack = document.createElement('div'); mainTrack.className = 'eora-blg-track';
        mainWrap.appendChild(mainTrack);
        var dotsEl = document.createElement('div'); dotsEl.className = 'eora-blg-mdots';
        mainWrap.appendChild(dotsEl);

        wrap.appendChild(strip); wrap.appendChild(mainWrap);
        galleryEl.appendChild(wrap);

        var thumbEls = [], dots = [];

        function syncGallerySizes() {
            if (window.innerWidth <= 768) {
                wrap.style.removeProperty('--eora-gallery-main-height');
                wrap.style.removeProperty('--eora-gallery-thumb-size');
                thumbStep = 0;
                return;
            }

            var mainH = mainWrap.offsetHeight;
            if (!mainH) return;

            wrap.style.setProperty('--eora-gallery-main-height', mainH + 'px');

            var visibleCount = Math.min(VISIBLE, thumbEls.length || VISIBLE);
            var gap = 14;
            var available = Math.max(120, mainH - (gap * Math.max(0, visibleCount - 1)));
            var size = available / visibleCount;
            thumbStep = size + gap;
            wrap.style.setProperty('--eora-gallery-thumb-size', size + 'px');
            thumbEls.forEach(function (th) {
                th.style.setProperty('flex', '0 0 ' + size + 'px', 'important');
                th.style.setProperty('width', size + 'px', 'important');
                th.style.setProperty('height', size + 'px', 'important');
            });
            goTo(activeIdx);
        }

        function populate(ph) {
            ttrack.innerHTML = ''; mainTrack.innerHTML = ''; dotsEl.innerHTML = '';
            thumbEls.length = 0; dots.length = 0;
            activeIdx = 0; visStart = 0;
            ph.forEach(function (u, idx) {
                var th = document.createElement('div');
                th.className = 'eora-blg-thumb' + (idx === 0 ? ' eora-active' : '');
                var tim = document.createElement('img'); tim.src = u; tim.alt = 'foto ' + (idx + 1);
                th.appendChild(tim); ttrack.appendChild(th); thumbEls.push(th);
                th.addEventListener('click', function () { goTo(idx); });
                var slide = document.createElement('div'); slide.className = 'eora-blg-slide';
                var sim = document.createElement('img'); sim.src = u; sim.alt = 'EORA';
                slide.appendChild(sim); mainTrack.appendChild(slide);
                var dot = document.createElement('button');
                dot.className = 'eora-blg-dot' + (idx === 0 ? ' eora-active' : '');
                dot.setAttribute('aria-label', 'Foto ' + (idx + 1));
                dotsEl.appendChild(dot); dots.push(dot);
                dot.addEventListener('click', function () { goTo(idx); });
            });
            goTo(0);
        }

        function goTo(idx) {
            activeIdx = Math.max(0, Math.min(thumbEls.length - 1, idx));
            mainTrack.style.setProperty('transform', 'translateX(-' + (activeIdx * 100) + '%)', 'important');
            thumbEls.forEach(function (t, i) { t.classList.toggle('eora-active', i === activeIdx); });
            dots.forEach(function (d, i) { d.classList.toggle('eora-active', i === activeIdx); });
            if (window.innerWidth <= 768) {
                /* Mobile: centraliza o thumb ativo no carrossel horizontal */
                var th = thumbEls[activeIdx];
                if (th) th.scrollIntoView({ behavior: 'smooth', block: 'nearest', inline: 'center' });
            } else {
                /* Desktop/tablet vertical: desloca o ttrack */
                if (activeIdx < visStart) visStart = activeIdx;
                if (activeIdx >= visStart + VISIBLE) visStart = activeIdx - VISIBLE + 1;
                ttrack.style.setProperty('transform', 'translateY(-' + (visStart * thumbStep) + 'px)', 'important');
            }
        }

        btnUp.addEventListener('click', function () { goTo(activeIdx - 1); });
        btnDn.addEventListener('click', function () { goTo(activeIdx + 1); });

        var tx = null;
        mainTrack.addEventListener('touchstart', function (e) { tx = e.touches[0].clientX; }, { passive: true });
        mainTrack.addEventListener('touchend', function (e) {
            if (tx === null) return;
            var dx = e.changedTouches[0].clientX - tx; tx = null;
            if (Math.abs(dx) > 40) goTo(dx < 0 ? activeIdx + 1 : activeIdx - 1);
        }, { passive: true });

        /* Ajusta largura dos thumbs no mobile de acordo com a quantidade */
        function setThumbWidths() {
            if (window.innerWidth > 768) {
                syncGallerySizes();
                return;
            }
            var count = thumbEls.length;
            var tvpW = tvp.offsetWidth;
            if (!tvpW || !count) return;
            var gap = 6;
            var w = count <= 3
                ? Math.floor((tvpW - (count - 1) * gap) / count)   /* preenche exato */
                : Math.floor((tvpW - 2 * gap) / 3.3);              /* 3 inteiros + peek da 4ª */
            thumbEls.forEach(function (th) {
                th.style.setProperty('flex', '0 0 ' + w + 'px', 'important');
                th.style.setProperty('width', w + 'px', 'important');
                th.style.setProperty('height', w + 'px', 'important');
            });
        }

        populate(photos && photos.length ? photos : [makePlaceholderThumb('sem foto')]);
        [0, 100, 400, 900].forEach(function (t) { setTimeout(setThumbWidths, t); });
        window.addEventListener('resize', setThumbWidths, { passive: true });
        galleryEl._eoraSetPhotos = populate;
    }

    function buildVariantSwatches(infoEl, relatedItems) {
        var grid = document.createElement('div'); grid.className = 'eora-bolsa-vars';
        var currentPath = normalizePathname(window.location.href);
        relatedItems.forEach(function (item, i) {
            var itemPath = normalizePathname(item.href);
            var isActive = (itemPath === currentPath);
            var el = document.createElement('div');
            el.className = 'eora-bolsa-var-item' + (isActive ? ' eora-active' : '');
            el.setAttribute('data-href-path', itemPath);
            var img = document.createElement('img');
            img.alt = item.name || ('variante ' + (i + 1));
            img.onerror = function () {
                if (img._fallback) return; img._fallback = true;
                if (item.url && !/^data:image\//i.test(item.url)) {
                    var altTry = item.url.replace(/(-\d+-\d+)(\.[\w]{2,5})(\?.*)?$/, '-480-480$2');
                    if (altTry && altTry !== item.url) {
                        img.src = altTry;
                        return;
                    }
                }
                img.src = makePlaceholderThumb(item.name || 'variante');
            };
            img.onload = function () {
                if (!img.naturalWidth || !img.naturalHeight) {
                    img.src = makePlaceholderThumb(item.name || 'variante');
                    return;
                }
            };
            img.src = item.url || makePlaceholderThumb(item.name || 'variante');
            el.appendChild(img);
            if (item.href) {
                el.addEventListener('click', function (e) {
                    e.preventDefault();
                    e.stopPropagation();
                    navigateToVariation(itemPath, item.href);
                });
            }
            grid.appendChild(el);
        });

        /* Tenta inserir ANTES do botao comprar (form) */
        var buyBtn = infoEl.querySelector('input.js-addtocart,button.js-addtocart,.js-addtocart,[name="commit"]');
        if (buyBtn) {
            var formNode = buyBtn.closest('form') || buyBtn.parentNode;
            if (formNode && formNode.parentNode) { formNode.parentNode.insertBefore(grid, formNode); return; }
        }
        /* Fallback: logo apos o preco */
        var priceEl = infoEl.querySelector('.js-price-display,.product-price,.js-product-price,[class*="price"]');
        if (priceEl) {
            var anchor = priceEl;
            while (anchor.parentNode && anchor.parentNode !== infoEl) anchor = anchor.parentNode;
            anchor.parentNode.insertBefore(grid, anchor.nextSibling);
            return;
        }
        infoEl.appendChild(grid);
    }

    function buildBannerImagemFull() {
        if (document.querySelector('.eora-banner-imagem-full')) return;

        /* Busca tabela banner_imagem_full / banner foto full */
        var tableKeys = ['banner_imagem_full', 'banner foto full'];
        var t = findConfigTable(tableKeys);
        if (!t) return;

        /* Lê imagem e link */
        var cfg = {};
        t.querySelectorAll('tbody tr').forEach(function (row) {
            var cells = row.querySelectorAll('td');
            if (cells.length < 2) return;
            var k = normalizeConfigKey(cells[0].textContent);
            if (k && tableKeys.indexOf(k) === -1) cfg[k] = cells[1];
        });

        var imgEl = cfg['imagem'] ? cfg['imagem'].querySelector('img') : null;
        var imagemUrl = imgEl ? (imgEl.getAttribute('src') || imgEl.src || '') : '';
        if (!imagemUrl) return;

        var imgMobileEl = cfg['imagem_mobile'] ? cfg['imagem_mobile'].querySelector('img') : null;
        var imagemMobileUrl = imgMobileEl
            ? (imgMobileEl.getAttribute('src') || imgMobileEl.src || '')
            : (cfg['imagem_mobile'] ? cfg['imagem_mobile'].textContent.trim() : '');

        function cleanText(td) { return td ? td.textContent.replace(/[\u00a0\s]+/g, ' ').trim() : ''; }
        var linkUrl = cleanText(cfg['link']);
        var tituloText = getTableTitleText(t);

        /* CSS */
        var css = [
            '.eora-banner-imagem-full{display:block;width:100vw;position:relative;left:50%;transform:translateX(-50%);text-decoration:none}',
            '.eora-banner-imagem-full picture{display:block;width:100%}',
            '.eora-banner-imagem-full img{display:block;width:100%;height:auto;object-fit:contain}',
            '@media(max-width:767px){.eora-banner-imagem-full picture{display:block;width:100%;overflow:visible;background:transparent}.eora-banner-imagem-full img{position:static;width:100%;height:auto;object-fit:contain;object-position:center center}}'
        ].join('');
        var styleEl = document.createElement('style');
        styleEl.textContent = css;
        document.head.appendChild(styleEl);

        var outer = document.createElement(linkUrl ? 'a' : 'div');
        outer.className = 'eora-banner-imagem-full';
        if (linkUrl) { outer.href = linkUrl; outer.rel = 'noopener'; }

        var picture = document.createElement('picture');
        if (imagemMobileUrl) {
            var source = document.createElement('source');
            source.media = '(max-width: 768px)';
            source.srcset = imagemMobileUrl;
            picture.appendChild(source);
        }
        var img = document.createElement('img');
        img.src = imagemUrl;
        img.alt = 'Banner';
        picture.appendChild(img);
        outer.appendChild(picture);

        /* Insere após o .js-product-video */
        var bloco = criarBlocoTitulo(tituloText);
        bloco.classList.add('eora-banner-full-bloco');
        bloco.appendChild(outer);
        var anchor =
            document.querySelector('.js-product-video') ||
            findInstitutionalAnchor() ||
            document.querySelector('.js-banners-alternados-product');
        if (anchor && anchor.closest && anchor.closest('[class*="product-description-"]')) anchor = null;
        if (!anchor) anchor = document.querySelector('.eora-product-wrap') || document.querySelector('#single-product');
        if (anchor && anchor.parentNode) {
            anchor.parentNode.insertBefore(bloco, anchor.nextSibling);
        } else {
            document.body.appendChild(bloco);
        }
    }

    function buildBannerProduto() {
        if (document.querySelector('.eora-banner-produto')) return;

        /* Busca tabela banner_produto / banner foto ou video */
        var tableKeys = ['banner_produto', 'banner foto ou video'];
        var t = findConfigTable(tableKeys);
        if (!t) return;

        /* Lê sub-chaves das linhas da tabela */
        var cfg = {};
        t.querySelectorAll('tbody tr').forEach(function (row) {
            var cells = row.querySelectorAll('td');
            if (cells.length < 2) return;
            var k = normalizeConfigKey(cells[0].textContent);
            if (k && tableKeys.indexOf(k) === -1) cfg[k] = cells[1];
        });

        function cleanText(td) { return td ? td.textContent.replace(/[\u00a0\s]+/g, ' ').trim() : ''; }
        function parseVideoMeta(url) {
            var parsedUrl = String(url || '').trim();
            if (!parsedUrl) return null;
            var platform = '';
            var videoId = '';
            var m;
            if ((m = parsedUrl.match(/vimeo\.com\/(?:video\/)?(\d+)/))) { platform = 'vimeo';   videoId = m[1]; }
            else if ((m = parsedUrl.match(/[?&]v=([^&]+)/)))           { platform = 'youtube'; videoId = m[1]; }
            else if ((m = parsedUrl.match(/youtu\.be\/([^?]+)/)))     { platform = 'youtube'; videoId = m[1]; }
            else if ((m = parsedUrl.match(/\/shorts\/([^?]+)/)))      { platform = 'youtube'; videoId = m[1]; }
            if (!platform || !videoId) return null;
            return { platform: platform, videoId: videoId };
        }

        function firstText(keys) {
            for (var i = 0; i < keys.length; i++) {
                var key = normalizeConfigKey(keys[i]);
                if (cfg[key]) {
                    var value = cleanText(cfg[key]);
                    if (value) return value;
                }
            }
            return '';
        }

        var videoUrl  = firstText(['video']);
        var videoMobileUrl = firstText(['video_mobile', 'video mobile']);
        var botaoText = cleanText(cfg['botao']);
        var linkUrl   = cleanText(cfg['link']);
        var tituloText = getTableTitleText(t);
        var imagemUrl = '';
        if (cfg['imagem']) {
            var imgEl = cfg['imagem'].querySelector('img');
            imagemUrl = imgEl ? (imgEl.getAttribute('src') || imgEl.src || '') : cfg['imagem'].textContent.trim();
        }
        var imagemMobileUrl = '';
        if (cfg['imagem_mobile']) {
            var imgMobileEl = cfg['imagem_mobile'].querySelector('img');
            imagemMobileUrl = imgMobileEl ? (imgMobileEl.getAttribute('src') || imgMobileEl.src || '') : cfg['imagem_mobile'].textContent.trim();
        }

        var desktopVideoMeta = parseVideoMeta(videoUrl);
        var mobileVideoMeta = parseVideoMeta(videoMobileUrl);
        var hasVideo = !!(desktopVideoMeta || mobileVideoMeta);

        if (!hasVideo && !imagemUrl) return;

        /* CSS */
        var css = [
            '.eora-banner-produto{display:block;text-decoration:none;color:inherit;box-sizing:border-box}',
            '.eora-banner-prod-wrap{position:relative;width:100%;overflow:hidden;background:transparent}',
            '.eora-banner-prod-wrap::before{content:"";display:block;padding-bottom:42.857%}',
            '.eora-banner-prod-video{position:absolute;inset:0;width:100%;height:100%;border:0;overflow:hidden}',
            '.eora-banner-prod-img,.eora-banner-prod-img img{position:absolute;inset:0;width:100%;height:100%;display:block;object-fit:cover}',
            '.eora-banner-prod-video{overflow:hidden}',
            '.eora-banner-prod-video iframe{position:absolute;top:50%;left:50%;width:100vw;height:56.25vw;min-width:150%;min-height:150%;transform:translate(-50%,-50%) scale(1.24);border:0;pointer-events:none}',
            '@media(max-width:767px){.eora-banner-prod-wrap::before{padding-bottom:100%}.eora-banner-prod-video iframe{width:177.78vh;height:100vh;min-width:220%;min-height:124%;transform:translate(-50%,-50%) scale(1.24)}}',
            '.eora-banner-prod-btn{position:absolute!important;bottom:20px!important;left:20px!important;z-index:2!important}'
        ].join('');
        var styleEl = document.createElement('style');
        styleEl.textContent = css;
        document.head.appendChild(styleEl);

        /* Monta DOM */
        var uid = 'bprod-' + Math.random().toString(36).slice(2, 8);
        var outer = document.createElement(linkUrl ? 'a' : 'section');
        outer.className = 'eora-banner-produto my-4 my-md-5';
        if (linkUrl) { outer.href = linkUrl; outer.rel = 'noopener'; }

        var wrap = document.createElement('div');
        wrap.className = 'eora-banner-prod-wrap';
        wrap.id = uid;

        if (hasVideo) {
            var vbox = document.createElement('div');
            vbox.className = 'eora-banner-prod-video';
            wrap.appendChild(vbox);
        } else if (imagemUrl) {
            if (imagemMobileUrl) {
                var picture = document.createElement('picture');
                picture.className = 'eora-banner-prod-img';

                var source = document.createElement('source');
                source.media = '(max-width: 768px)';
                source.srcset = imagemMobileUrl;
                picture.appendChild(source);

                var picImg = document.createElement('img');
                picImg.src = imagemUrl;
                picImg.alt = botaoText || 'Banner';
                picture.appendChild(picImg);

                wrap.appendChild(picture);
            } else {
                var img = document.createElement('img');
                img.src = imagemUrl;
                img.className = 'eora-banner-prod-img';
                img.alt = botaoText || 'Banner';
                wrap.appendChild(img);
            }
        }

        if (botaoText) {
            var btn = document.createElement('div');
            btn.className = 'banner-floating-button eora-banner-prod-btn';
            btn.innerHTML =
                '<div class="banner-floating-button-content">' +
                '<div class="banner-floating-title">' + botaoText + '</div>' +
                '<svg class="banner-floating-icon" viewBox="0 0 10 10" fill="none"><use xlink:href="#chevron-diagonal"></use></svg>' +
                '</div>';
            wrap.appendChild(btn);
        }

        outer.appendChild(wrap);

        /* Insere após a mensagem institucional */
        var bloco = criarBlocoTitulo(tituloText);
        bloco.appendChild(outer);
        var anchor =
            findInstitutionalAnchor() ||
            document.querySelector('.js-texto-campanha-produto') ||
            document.querySelector('.js-banners-alternados-product') ||
            document.querySelector('.js-banner-produto') ||
            document.querySelector('#single-product');
        if (anchor && anchor.closest && anchor.closest('[class*="product-description-"]')) anchor = null;
        if (!anchor) {
            var productWrapAnchor = document.querySelector('.eora-product-wrap');
            anchor = productWrapAnchor || document.querySelector('#single-product');
        }
        if (anchor && anchor.parentNode) {
            var afterAnchor = anchor.nextSibling;
            if (afterAnchor && afterAnchor.classList && afterAnchor.classList.contains('eora-social-inline')) {
                afterAnchor = afterAnchor.nextSibling;
            }
            anchor.parentNode.insertBefore(bloco, afterAnchor);
        } else {
            document.body.appendChild(bloco);
        }
        ensureSocialBeforeBanner();

        /* Injeta iframe de vídeo */
        if (hasVideo) {
            var useMobileVideo = window.matchMedia && window.matchMedia('(max-width: 768px)').matches;
            var activeVideoMeta = useMobileVideo
                ? (mobileVideoMeta || desktopVideoMeta)
                : (desktopVideoMeta || mobileVideoMeta);
            if (!activeVideoMeta) return;

            var src = activeVideoMeta.platform === 'vimeo'
                ? 'https://player.vimeo.com/video/' + activeVideoMeta.videoId + '?autoplay=1&muted=1&loop=1&background=1&controls=0&playsinline=1&dnt=1'
                : 'https://www.youtube.com/embed/' + activeVideoMeta.videoId + '?autoplay=1&mute=1&controls=0&loop=1&playlist=' + activeVideoMeta.videoId + '&modestbranding=1&playsinline=1&rel=0&iv_load_policy=3&disablekb=1';
            var iframe = document.createElement('iframe');
            iframe.src = src;
            iframe.setAttribute('frameborder', '0');
            iframe.setAttribute('allow', 'autoplay; encrypted-media; picture-in-picture');
            iframe.setAttribute('allowfullscreen', '');
            iframe.setAttribute('title', 'Banner vídeo produto');
            var vboxEl = document.getElementById(uid);
            if (vboxEl) { var vd = vboxEl.querySelector('.eora-banner-prod-video'); if (vd) vd.appendChild(iframe); }

            if (window.matchMedia) {
                var mq = window.matchMedia('(max-width: 768px)');
                var updateBannerVideo = function () {
                    var mobileActive = mq.matches;
                    var nextVideoMeta = mobileActive
                        ? (mobileVideoMeta || desktopVideoMeta)
                        : (desktopVideoMeta || mobileVideoMeta);
                    if (!nextVideoMeta || !iframe) return;
                    var nextSrc = nextVideoMeta.platform === 'vimeo'
                        ? 'https://player.vimeo.com/video/' + nextVideoMeta.videoId + '?autoplay=1&muted=1&loop=1&background=1&controls=0&playsinline=1&dnt=1'
                        : 'https://www.youtube.com/embed/' + nextVideoMeta.videoId + '?autoplay=1&mute=1&controls=0&loop=1&playlist=' + nextVideoMeta.videoId + '&modestbranding=1&playsinline=1&rel=0&iv_load_policy=3&disablekb=1';
                    if (iframe.src !== nextSrc) iframe.src = nextSrc;
                };
                if (typeof mq.addEventListener === 'function') mq.addEventListener('change', updateBannerVideo);
                else if (typeof mq.addListener === 'function') mq.addListener(updateBannerVideo);
            }
        }
    }

    function initChegueiObserver(visibleInfoEl) {
        if (!visibleInfoEl) return;

        var attempts = 0;
        var checkInterval = setInterval(function () {
            attempts++;
            
            // Tenta localizar o elemento clicável real do Cheguei
            var realChegueiBtn = document.querySelector('#cheguei-alert-div div[style*="cursor"]') ||
                                 document.querySelector('#cheguei-alert-div [class*="sc-"]') ||
                                 document.querySelector('#cheguei-alert-div section');
            
            // Garante que não é o nosso próprio placeholder
            var placeholder = visibleInfoEl.querySelector('.eora-cheguei-placeholder');
            if (realChegueiBtn && (!placeholder || !placeholder.contains(realChegueiBtn))) {
                clearInterval(checkInterval);
                
                var buyBtn = visibleInfoEl.querySelector('.eora-buy-btn, input.js-addtocart, button.js-addtocart, .js-addtocart, [name="commit"]');
                var chegueiDiv = document.getElementById('cheguei-alert-div');
                
                if (chegueiDiv && buyBtn && buyBtn.parentNode) {
                    // Move o bloco real para a posição visível correta
                    buyBtn.parentNode.insertBefore(chegueiDiv, buyBtn.nextSibling);
                    
                    // Sobrescreve o display:none do CSS para exibir o real perfeitamente
                    chegueiDiv.style.setProperty('display', 'block', 'important');
                    chegueiDiv.style.setProperty('visibility', 'visible', 'important');
                    chegueiDiv.style.setProperty('position', 'relative', 'important');
                    chegueiDiv.style.setProperty('left', 'auto', 'important');
                    chegueiDiv.style.setProperty('top', 'auto', 'important');
                    chegueiDiv.style.setProperty('opacity', '1', 'important');
                    chegueiDiv.style.setProperty('pointer-events', 'auto', 'important');
                    chegueiDiv.style.setProperty('width', '100%', 'important');
                    chegueiDiv.style.setProperty('max-width', '100%', 'important');
                    chegueiDiv.style.setProperty('margin-top', '12px', 'important');
                    chegueiDiv.style.setProperty('margin-bottom', '16px', 'important');
                    chegueiDiv.style.setProperty('padding-bottom', '0px', 'important');
                }
                
                // Esconde o nosso placeholder instantâneo agora que o real carregou
                if (placeholder) {
                    placeholder.style.setProperty('display', 'none', 'important');
                }
            }
            
            if (attempts > 400) { // 20 segundos
                clearInterval(checkInterval);
            }
        }, 50);
    }

    function initChegueiPlaceholder(visibleInfoEl) {
        if (!visibleInfoEl) return;

        var buyBtn = visibleInfoEl.querySelector('.eora-buy-btn, input.js-addtocart, button.js-addtocart, .js-addtocart, [name="commit"]');
        if (!buyBtn || !buyBtn.parentNode) return;

        // Só injeta o placeholder se o botão de compra estiver desabilitado ou marcado como sem estoque (Esgotado)
        var isNoStock = buyBtn.disabled || buyBtn.classList.contains('nostock') || buyBtn.value === 'Esgotado';
        if (!isNoStock) return;

        if (visibleInfoEl.querySelector('.eora-cheguei-placeholder')) return;

        var placeholder = document.createElement('div');
        placeholder.className = 'eora-cheguei-placeholder';
        placeholder.style.cssText = 'width: 100%; max-width: 100%; margin-top: 12px !important; margin-bottom: 16px !important; padding-bottom: 0px !important; display: block !important;';
        
        placeholder.innerHTML = [
            '<div class="placeholder-btn" style="display: flex; align-items: center; justify-content: center; text-align: center; cursor: pointer; padding: 12px 10px; width: 100%; background: rgb(0, 9, 127); border-radius: 0px; color: rgb(255, 255, 255); font-weight: 500; font-size: 13px; text-transform: uppercase; letter-spacing: 1px; line-height: 1.2;">',
            '<svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="#FFFFFF" stroke-width="2" stroke-linecap="round" stroke-linejoin="round" style="margin-right: 8px; flex-shrink: 0;">',
            '<path d="M18 8A6 6 0 0 0 6 8c0 7-3 9-3 9h18s-3-2-3-9"></path>',
            '<path d="M13.73 21a2 2 0 0 1-3.46 0"></path>',
            '</svg>',
            '<span class="placeholder-text" style="color: #FFFFFF !important; font-family: inherit !important;">Avise-me quando chegar!</span>',
            '</div>'
        ].join('');

        buyBtn.parentNode.insertBefore(placeholder, buyBtn.nextSibling);

        placeholder.addEventListener('click', function (e) {
            e.preventDefault();
            e.stopPropagation();

            var realChegueiBtn = document.querySelector('#cheguei-alert-div div[style*="cursor"]') ||
                                 document.querySelector('#cheguei-alert-div [class*="sc-"]') ||
                                 document.querySelector('#cheguei-alert-div section') ||
                                 document.querySelector('#cheguei-alert-div div') ||
                                 document.getElementById('cheguei-alert-div');
            
            if (realChegueiBtn && realChegueiBtn !== placeholder && !placeholder.contains(realChegueiBtn)) {
                realChegueiBtn.click();
            } else {
                var txtNode = placeholder.querySelector('.placeholder-text');
                if (txtNode) txtNode.textContent = 'Carregando formulário...';

                var attempts = 0;
                var checkInterval = setInterval(function () {
                    attempts++;
                    var btn = document.querySelector('#cheguei-alert-div div[style*="cursor"]') ||
                              document.querySelector('#cheguei-alert-div [class*="sc-"]') ||
                              document.querySelector('#cheguei-alert-div section') ||
                              document.querySelector('#cheguei-alert-div div') ||
                              document.getElementById('cheguei-alert-div');
                    
                    if (btn && btn !== placeholder && !placeholder.contains(btn)) {
                        clearInterval(checkInterval);
                        if (txtNode) txtNode.textContent = 'Avise-me quando chegar!';
                        btn.click();
                    } else if (attempts > 80) {
                        clearInterval(checkInterval);
                        if (txtNode) txtNode.textContent = 'Avise-me quando chegar!';
                        alert('O formulário de aviso de estoque está demorando a carregar. Por favor, tente novamente em instantes.');
                    }
                }, 100);
            }
        });
    }

    function init() {
        var themeProd = document.querySelector('#single-product');
        if (!themeProd) return;
        if (!themeProd.classList.contains('js-coach-layout')) return;
        if (document.querySelector('.eora-product-wrap')) return;

        /* ── Coleta fotos ── */
        var photos = [], seenUrls = {};
        function addPhoto(url) {
            if (!url || typeof url !== 'string' || url.indexOf('data:') === 0 || url.length < 10) return;
            var u = normalizeUrl(url);
            if (!u) return;
            var k = u.replace(/\?.*$/, '').toLowerCase();
            if (seenUrls[k]) return;
            seenUrls[k] = true;
            photos.push(u);
        }
        try {
            if (typeof LS !== 'undefined' && LS.product && LS.product.images && LS.product.images.length) {
                LS.product.images.forEach(function (img) { addPhoto(img.src || img.url || ''); });
            }
        } catch (e) {}
        if (!photos.length) {
            themeProd.querySelectorAll('.product-image-column img').forEach(function (img) { addPhoto(getSrc(img)); });
        }
        /* ── Cria container externo ao #single-product ── */
        var wrap = document.createElement('div');
        wrap.className = 'eora-product-wrap';

        /* Coluna da galeria */
        var galleryEl = document.createElement('div');
        galleryEl.className = 'eora-product-gallery';
        wrap.appendChild(galleryEl);

        /* Coluna de info: clona o .product-info-column original */
        var origInfo = themeProd.querySelector('.product-info-column');
        var infoEl;
        if (origInfo) {
            infoEl = origInfo.cloneNode(true);
            infoEl.className = 'eora-product-info';

            var clonedForm = infoEl.querySelector('#product_form, .js-product-form, form[action*="/cart"], form');
            if (clonedForm) {
                clonedForm.classList.add('eora-cloned-product-form');
                if (clonedForm.id === 'product_form') clonedForm.removeAttribute('id');

                // Esconde a mensagem de carrinho vazio e seu container col-12 para eliminar o espaço em branco
                var addMsg = clonedForm.querySelector('.js-added-to-cart-product-message');
                if (addMsg && addMsg.parentNode) {
                    var colContainer = addMsg.parentNode;
                    while (colContainer && colContainer !== clonedForm && !colContainer.classList.contains('col-12')) {
                        colContainer = colContainer.parentNode;
                    }
                    if (colContainer && colContainer.classList.contains('col-12')) {
                        colContainer.style.setProperty('display', 'none', 'important');
                    } else {
                        addMsg.parentNode.style.setProperty('display', 'none', 'important');
                    }
                }

                var forwardToOriginal = function () {
                    var originalForm = getOriginalProductForm();
                    if (!originalForm) return;
                    syncFormValues(clonedForm, originalForm);
                    triggerOriginalBuy();
                };

                clonedForm.addEventListener('submit', function (e) {
                    e.preventDefault();
                    e.stopPropagation(); // Impede o bubbling para evitar que listeners globais do tema quebrem
                    forwardToOriginal();
                });

                clonedForm.querySelectorAll('[name="commit"], input.js-addtocart, button.js-addtocart, .js-addtocart').forEach(function (btn) {
                    // Remove classes de gatilho nativas do botão clonado para que listeners nativos delegados ao body/document não rodem nele
                    btn.classList.remove('js-addtocart', 'js-addtocart-btn');
                    btn.removeAttribute('name');
                    btn.classList.add('eora-buy-btn');
                    
                    btn.addEventListener('click', function (e) {
                        e.preventDefault();
                        e.stopPropagation(); // Impede o bubbling
                        forwardToOriginal();
                    });
                });
                
                clonedForm.querySelectorAll('button, input[type="submit"]').forEach(function (btn) {
                    if (btn.classList.contains('eora-buy-btn')) return;
                    btn.addEventListener('click', function (e) {
                        e.preventDefault();
                        e.stopPropagation();
                        forwardToOriginal();
                    });
                });
            }

            // Ponte do calculador de frete para evitar quebra no JS nativo
            bindShippingCalculator(infoEl, themeProd);

            /* Remove os seletores de cor nativos (substituidos pelos nossos swatches) */
            infoEl.querySelectorAll('.js-color-variants-container,.js-product-variants').forEach(function (el) {
                el.parentNode && el.parentNode.removeChild(el);
            });
            /* Remove a descricao longa — ela ja aparece no resto da pagina,
               mantemos so titulo + preco + variantes + botao COMPRAR visíveis */
            infoEl.querySelectorAll(
                '.js-product-description,.js-product-description-base,.product-description,' +
                '.js-product-info,.product-info-tabs,.js-product-tabs,' +
                '[class*="description"]:not([class*="price"]):not([class*="name"])'
            ).forEach(function (el) {
                /* Nao remove se contem o form de compra ou preco */
                if (el.querySelector('form,.js-addtocart,[name="commit"],[class*="price"]')) return;
                el.parentNode && el.parentNode.removeChild(el);
            });
            /* Remove tambem qualquer <table> que veio do conteudo da descricao do admin */
            infoEl.querySelectorAll('table').forEach(function (t) {
                t.parentNode && t.parentNode.removeChild(t);
            });
            /* Remove paragrafos longos soltos (descricao em texto plano) */
            infoEl.querySelectorAll('p').forEach(function (p) {
                if (p.closest('form')) return;
                if (p.closest('[class*="price"]')) return;
                if (p.textContent.trim().length > 80) p.parentNode && p.parentNode.removeChild(p);
            });
        } else {
            infoEl = document.createElement('div');
            infoEl.className = 'eora-product-info';
        }

        /* Constroi accordion de descricao antes do preco */
        (function () {
            var dados = getDados();
            var descTable = dados['descricao_curta'];
            if (!descTable) return;
            var td = descTable.querySelector('tbody > tr:first-child td:last-child');
            if (!td || !td.innerHTML.trim()) return;
            var acc = document.createElement('div');
            acc.className = 'eora-desc-acc';
            var body = document.createElement('div'); body.className = 'eora-desc-body';
            var inner = document.createElement('div'); inner.className = 'eora-desc-inner';
            inner.innerHTML = td.innerHTML;
            body.appendChild(inner);
            var btn = document.createElement('button'); btn.className = 'eora-desc-toggle';
            btn.textContent = 'ver mais';
            acc.appendChild(body); acc.appendChild(btn);
            btn.addEventListener('click', function () {
                var open = acc.classList.toggle('eora-open');
                btn.textContent = open ? 'ver menos' : 'ver mais';
            });
            /* Insere logo antes do form de compra (fica entre preco e variacoes) */
            var buyBtn2 = infoEl.querySelector('input.js-addtocart,button.js-addtocart,.js-addtocart,[name="commit"]');
            if (buyBtn2) {
                var formNode2 = buyBtn2.closest('form') || buyBtn2.parentNode;
                if (formNode2 && formNode2.parentNode) { formNode2.parentNode.insertBefore(acc, formNode2); return; }
            }
            var priceEl = infoEl.querySelector('.js-price-display,.product-price,.js-product-price,[class*="price"]');
            if (priceEl) {
                var anchor = priceEl;
                while (anchor.parentNode && anchor.parentNode !== infoEl) anchor = anchor.parentNode;
                anchor.parentNode.insertBefore(acc, anchor.nextSibling);
            } else {
                infoEl.appendChild(acc);
            }
        })();

        reorganizeEoraProductInfo(infoEl);

        wrap.appendChild(infoEl);

        /* Insere o container logo antes do #single-product */
        themeProd.parentNode.insertBefore(wrap, themeProd);

        /* Inicializa o observador do app Cheguei para não sumir o Avise-me */
        initChegueiObserver(infoEl);
        initChegueiPlaceholder(infoEl);

        /* Esconde via inline style com !important — bate qualquer CSS do tema */
        function hideTheme() {
            themeProd.style.setProperty('display', 'none', 'important');
            themeProd.style.setProperty('visibility', 'hidden', 'important');
            themeProd.style.setProperty('height', '0', 'important');
            themeProd.style.setProperty('overflow', 'hidden', 'important');
            themeProd.style.setProperty('position', 'absolute', 'important');
            themeProd.style.setProperty('left', '-99999px', 'important');
            themeProd.style.setProperty('top', '-99999px', 'important');
            themeProd.style.setProperty('width', '0', 'important');
            themeProd.style.setProperty('opacity', '0', 'important');
            themeProd.style.setProperty('pointer-events', 'none', 'important');
        }
        hideTheme();

        /* Reaplica sempre que o tema reescrever o style attribute */
        var hideGuard = false;
        var moStyle = new MutationObserver(function () {
            if (hideGuard) return;
            hideGuard = true;
            hideTheme();
            hideGuard = false;
        });
        moStyle.observe(themeProd, { attributes: true, attributeFilter: ['style', 'class'] });

        /* Se o tema remover/recriar o #single-product, garante que nosso wrap permanece */
        var moParent = new MutationObserver(function () {
            if (!document.body.contains(wrap)) return;
            /* Se o tema inseriu algo visível com gallery dentro, esconde */
            var newSP = document.querySelector('#single-product');
            if (newSP && newSP !== themeProd) {
                themeProd = newSP;
                hideTheme();
                moStyle.disconnect();
                moStyle.observe(themeProd, { attributes: true, attributeFilter: ['style', 'class'] });
            }
        });
        if (themeProd.parentNode) {
            moParent.observe(themeProd.parentNode, { childList: true });
        }

        /* Constrói galeria */
        buildGallery(galleryEl, photos);

        /* ── Variantes ── */
        function getCurrentProductTags() {
            var root = getOriginalProductRoot();
            if (!root) return [];
            var raw = root.getAttribute('data-product-tags');
            if (!raw) return [];
            try {
                var parsed = JSON.parse(raw);
                return parsed.map(function (item) {
                    if (!item) return '';
                    if (typeof item === 'string') return item;
                    return item.tag || item.name || '';
                }).filter(Boolean);
            } catch (e) {
                return [];
            }
        }

        function getVariantSearchTag() {
            var tags = getCurrentProductTags().map(function (tag) { return String(tag || '').trim().toLowerCase(); });
            if (tags.indexOf('maxivertice') !== -1) return 'maxivertice';
            for (var i = 0; i < tags.length; i++) {
                var tag = tags[i];
                if (!tag || tag === 'bolsa' || tag === 'vertice' || tag === 'preto' || tag === 'preta') continue;
                if (tag.indexOf('produto-gradiente:') === 0 || tag.indexOf('card-produto-gradiente:') === 0) continue;
                if (tag.indexOf(':') !== -1) continue;
                return tag;
            }
            return 'maxivertice';
        }

        function fetchVariantsFromTag(tag) {
            if (!tag) return Promise.resolve([]);
            var currentPath = window.location.pathname.replace(/\/?$/, '/');
            return fetchTagProducts(tag, currentPath);
        }

        function collectRelatedFromPanel() {
            var candidates = [];
            var currentPath = window.location.pathname.replace(/\/?$/, '/');
            var seen = {};

            document.querySelectorAll('.js-color-variants-container .btn-variant-thumb').forEach(function (a) {
                if (a.classList.contains('selected')) return;

                var href = a.getAttribute('href') || '';
                if (!href) return;

                var absUrl;
                try {
                    absUrl = new URL(href, window.location.origin).href;
                } catch (e) {
                    return;
                }

                var hrefPath = normalizePathname(absUrl);
                if (!hrefPath || hrefPath === currentPath || hrefPath.indexOf('/produtos/') !== 0) return;
                if (seen[hrefPath]) return;

                var img = a.querySelector('img');
                var src = img ? normalizeUrl(img.getAttribute('data-src') || img.getAttribute('src') || '') : '';
                var name = (img && (img.getAttribute('alt') || '').trim()) || (a.getAttribute('title') || '').trim() || '';
                if (!src) src = makePlaceholderThumb(name || 'variante');
                if (!isRenderableThumbUrl(src)) return;

                seen[hrefPath] = true;
                candidates.push({ url: src, href: absUrl, name: name });
            });

            if (!candidates.length) return Promise.resolve([]);
            return Promise.all(candidates.map(function (item) {
                return isProductPublicAndBuyable(item.href).then(function (ok) {
                    return ok ? item : null;
                });
            })).then(function (checked) {
                return checked.filter(Boolean);
            });
        }

        function collectRelatedFromAnySource() {
            var tag = getVariantSearchTag();
            if (!tag) return Promise.resolve([]);
            return fetchVariantsFromTag(tag);
        }

        function applyVariants(items) {
            var old = infoEl.querySelector('.eora-bolsa-vars');
            if (old) old.parentNode.removeChild(old);
            items = items || [];
            if (!items.length) return;
            buildVariantSwatches(infoEl, items);
            reorganizeEoraProductInfo(infoEl);
        }
        collectRelatedFromAnySource().then(function (rel) {
            if (rel.length) {
                applyVariants(rel);
                prefetchVariationPages(rel);
            }

            var retryN = 0;
            function retryVariants() {
                retryN++;
                collectRelatedFromAnySource().then(function (late) {
                    var existing = infoEl.querySelector('.eora-bolsa-vars');
                    var cur = existing ? existing.querySelectorAll('.eora-bolsa-var-item').length : 0;
                    if (late.length > cur) {
                        applyVariants(late);
                        prefetchVariationPages(late);
                    }
                    if (!infoEl.querySelector('.eora-bolsa-vars') && retryN < 10) setTimeout(retryVariants, 500);
                });
            }
            setTimeout(retryVariants, 500);
        });

        try {
            var initialPath = normalizePathname(window.location.href);
            history.replaceState({ eoraPath: initialPath }, '', window.location.href);
        } catch (e) {}

    }

    function buildBanners3Videos() {
        var existingSection = document.querySelector('.eora-banners-3-videos');
        if (existingSection && existingSection.querySelector('.eora-b3v-card')) return;
        if (existingSection && existingSection.parentNode) existingSection.parentNode.removeChild(existingSection);
        function parseVideoMeta(url) {
            var parsedUrl = String(url || '').trim();
            if (!parsedUrl) return null;
            var platform = '';
            var videoId = '';
            var m;
            if ((m = parsedUrl.match(/vimeo\.com\/(?:video\/)?(\d+)/))) { platform = 'vimeo'; videoId = m[1]; }
            else if ((m = parsedUrl.match(/[?&]v=([^&]+)/))) { platform = 'youtube'; videoId = m[1]; }
            else if ((m = parsedUrl.match(/youtu\.be\/([^?]+)/))) { platform = 'youtube'; videoId = m[1]; }
            else if ((m = parsedUrl.match(/\/shorts\/([^?]+)/))) { platform = 'youtube'; videoId = m[1]; }
            if (!platform || !videoId) return null;
            return { platform: platform, videoId: videoId };
        }


        var t = findConfigTable(['banners_3_videos', '3 banners videos', '3 banners video']);
        if (!t) return;

        var rowsByKey = {};
        t.querySelectorAll('tbody tr').forEach(function (row) {
            var cells = row.querySelectorAll('td');
            if (cells.length < 2) return;
            rowsByKey[normalizeConfigKey(cells[0].textContent)] = cells[1];
        });

        function firstCellByKeys(keys) {
            for (var i = 0; i < keys.length; i++) {
                var key = normalizeConfigKey(keys[i]);
                if (rowsByKey[key]) return rowsByKey[key];
            }
            return null;
        }

        var medias = [];
        for (var idx = 1; idx <= 3; idx++) {
            var baseKey = 'video_' + idx;
            var desktopCell = firstCellByKeys([baseKey, baseKey + ' ou imagem']);
            var mobileCell = firstCellByKeys([baseKey + '_mobile', baseKey + ' mobile']);
            if (!desktopCell && !mobileCell) continue;

            var desktopImgEl = desktopCell ? desktopCell.querySelector('img') : null;
            var mobileImgEl = mobileCell ? mobileCell.querySelector('img') : null;

            var desktopVideoUrl = desktopCell ? desktopCell.textContent.replace(/[\u00a0\s]+/g, ' ').trim() : '';
            var mobileVideoUrl = mobileCell ? mobileCell.textContent.replace(/[\u00a0\s]+/g, ' ').trim() : '';

            var desktopVideoMeta = parseVideoMeta(desktopVideoUrl || mobileVideoUrl);
            var mobileVideoMeta = parseVideoMeta(mobileVideoUrl || desktopVideoUrl);

            if (desktopVideoMeta || mobileVideoMeta) {
                var fallbackImgUrl = '';
                if (desktopImgEl) {
                    fallbackImgUrl = desktopImgEl.getAttribute('src') || desktopImgEl.src || '';
                } else if (mobileImgEl) {
                    fallbackImgUrl = mobileImgEl.getAttribute('src') || mobileImgEl.src || '';
                }
                medias.push({
                    type: 'video',
                    desktopMeta: desktopVideoMeta,
                    mobileMeta: mobileVideoMeta,
                    fallbackImgUrl: fallbackImgUrl
                });
            } else if (desktopImgEl || mobileImgEl) {
                var imgUrl = desktopImgEl ? (desktopImgEl.getAttribute('src') || desktopImgEl.src || '') : (mobileImgEl.getAttribute('src') || mobileImgEl.src || '');
                if (imgUrl) {
                    medias.push({
                        type: 'image',
                        url: imgUrl,
                        alt: (desktopImgEl || mobileImgEl).getAttribute('alt') || 'EORA'
                    });
                }
            }
        }

        if (!medias.length) return;
        var tituloText = getTableTitleText(t);

        var css = [
            '.eora-banners-3-videos{width:100vw;position:relative;left:50%;transform:translateX(-50%);overflow:hidden;background:transparent;display:block!important}',
            'html{overflow-x:hidden}',
            '.eora-b3v-track{display:flex;gap:0;width:100%}',
            '.eora-b3v-card{flex:0 0 calc(100% / 3);min-width:0;overflow:hidden}',
            '.eora-b3v-frame{width:100%;padding-bottom:177.78%;position:relative;overflow:hidden;background:transparent}',
            /* CSS matemático e responsivo para cobrir 100% do container sem usar vw/vh (evita falha no Safari mobile) */
            '.eora-b3v-frame iframe{position:absolute;top:50%;left:50%;width:320%;height:102%;transform:translate(-50%,-50%);border:0;pointer-events:none;background:transparent;z-index:2}',
            '.eora-b3v-frame img,.eora-b3v-frame .eora-b3v-fallback{position:absolute;top:0;left:0;width:100%;height:100%;display:block;object-fit:cover;z-index:1}',
            '@media(max-width:768px){' +
                '.eora-banners-3-videos{overflow:visible;background:transparent}' +
                '.eora-b3v-track{overflow-x:scroll!important;overflow-y:hidden;scroll-snap-type:x mandatory;-webkit-overflow-scrolling:touch;scrollbar-width:thin;-ms-overflow-style:auto;padding:0 5px 10px 12px;gap:10px;touch-action:pan-x;cursor:grab}' +
                '.eora-b3v-track:active{cursor:grabbing}' +
                '.eora-b3v-track::-webkit-scrollbar{height:4px;display:block}' +
                '.eora-b3v-track::-webkit-scrollbar-track{background:#f1f1f1;border-radius:10px}' +
                '.eora-b3v-track::-webkit-scrollbar-thumb{background:#888;border-radius:10px}' +
                '.eora-b3v-card{flex:0 0 60vw;min-width:60vw;scroll-snap-align:center}' +
            '}'
        ].join('');
        var styleEl = document.createElement('style');
        styleEl.textContent = css;
        document.head.appendChild(styleEl);

        var section = document.createElement('section');
        section.className = 'eora-banners-3-videos';

        var track = document.createElement('div');
        track.className = 'eora-b3v-track';

        medias.forEach(function (media) {
            var card = document.createElement('div');
            card.className = 'eora-b3v-card';

            var frame = document.createElement('div');
            frame.className = 'eora-b3v-frame';

            if (media.type === 'image') {
                var img = document.createElement('img');
                img.src = media.url;
                img.alt = media.alt || 'EORA';
                frame.appendChild(img);
            } else {
                var desktopMeta = media.desktopMeta || null;
                var mobileMeta = media.mobileMeta || null;
                var useMobileVideo = window.matchMedia && window.matchMedia('(max-width: 768px)').matches;
                var activeMeta = useMobileVideo
                    ? (mobileMeta || desktopMeta)
                    : (desktopMeta || mobileMeta);
                if (!activeMeta) return;

                /* Renderiza imagem de poster/fallback se existir */
                if (media.fallbackImgUrl) {
                    var fallbackImg = document.createElement('img');
                    fallbackImg.src = media.fallbackImgUrl;
                    fallbackImg.alt = 'EORA fallback';
                    fallbackImg.className = 'eora-b3v-fallback';
                    frame.appendChild(fallbackImg);
                }

                var iframe = document.createElement('iframe');
                iframe.src = activeMeta.platform === 'vimeo'
                    ? 'https://player.vimeo.com/video/' + activeMeta.videoId + '?autoplay=1&loop=1&muted=1&background=1&playsinline=1&title=0&byline=0&portrait=0&controls=0&sidedock=0&autopause=0&dnt=1'
                    : 'https://www.youtube-nocookie.com/embed/' + activeMeta.videoId + '?autoplay=1&mute=1&controls=0&loop=1&playlist=' + activeMeta.videoId + '&modestbranding=1&playsinline=1&rel=0&iv_load_policy=3&disablekb=1';
                iframe.setAttribute('frameborder', '0');
                iframe.setAttribute('allow', 'autoplay; encrypted-media; gyroscope; picture-in-picture');
                iframe.setAttribute('allowfullscreen', '');
                frame.appendChild(iframe);
            }
            card.appendChild(frame);
            track.appendChild(card);
        });

        if (!track.children.length) return;

        section.appendChild(track);

        var bloco = criarBlocoTitulo(tituloText);
        bloco.appendChild(section);
        var imgFullEl = document.querySelector('.eora-banner-imagem-full');
        var anchor = imgFullEl ? (imgFullEl.closest('.eora-section-bloco') || imgFullEl) : null;
        if (anchor && anchor.closest && anchor.closest('[class*="product-description-"]')) anchor = null;
        if (!anchor) {
            var bannerProduto = document.querySelector('.eora-banner-produto');
            anchor = bannerProduto ? (bannerProduto.closest('.eora-section-bloco') || bannerProduto) : null;
        }
        if (!anchor) anchor = findInstitutionalAnchor();
        if (anchor && anchor.parentNode) {
            anchor.parentNode.insertBefore(bloco, anchor.nextSibling);
        } else {
            document.body.appendChild(bloco);
        }
    }

    function ensureSocialBeforeBanner() {
        var social = document.querySelector('.eora-social-inline');
        var bannerProduto = document.querySelector('.eora-banner-produto');
        if (!social) return;

        var institutional = findInstitutionalAnchor();
        if (institutional && institutional.parentNode) {
            if (social.previousElementSibling === institutional) return;
            institutional.parentNode.insertBefore(social, institutional.nextSibling);
            return;
        }

        if (!bannerProduto) return;

        var bannerBlock = bannerProduto.closest('.eora-section-bloco') || bannerProduto;
        if (!bannerBlock || !bannerBlock.parentNode) return;
        if (social === bannerBlock.previousElementSibling) return;

        bannerBlock.parentNode.insertBefore(social, bannerBlock);
    }

    function cleanupLegacyDescriptionAndMoveSocial() {
        var descEls = Array.from(document.querySelectorAll('[class*="product-description-"]:not(.eora-desc-inner)'));
        var descEl = descEls[0] || null;

        function normalizeLabel(txt) {
            return String(txt || '')
                .toLowerCase()
                .normalize('NFD')
                .replace(/[\u0300-\u036f]/g, '')
                .replace(/[^a-z]+/g, '')
                .trim();
        }

        function findSocialContainer(root) {
            if (!root) return null;
            var socialKeys = { whatsapp: true, facebook: true, twitter: true, pinterest: true };
            var best = null;
            var bestScore = 0;

            root.querySelectorAll('a').forEach(function (a) {
                var label = normalizeLabel(a.textContent);
                if (!socialKeys[label]) return;

                var candidates = [
                    a.closest('[class*="social"]'),
                    a.closest('[class*="share"]'),
                    a.closest('ul'),
                    a.closest('nav'),
                    a.closest('p'),
                    a.closest('div')
                ].filter(Boolean);

                candidates.forEach(function (node) {
                    if (!root.contains(node)) return;
                    var score = 0;
                    node.querySelectorAll('a').forEach(function (lnk) {
                        if (socialKeys[normalizeLabel(lnk.textContent)]) score++;
                    });
                    if (score > bestScore) {
                        bestScore = score;
                        best = node;
                    }
                });
            });

            return bestScore >= 2 ? best : null;
        }

        function countSocialLinks(node) {
            if (!node) return 0;
            var socialKeys = { whatsapp: true, facebook: true, twitter: true, pinterest: true };
            var score = 0;
            node.querySelectorAll('a').forEach(function (a) {
                var label = normalizeLabel(a.textContent);
                if (socialKeys[label]) score += label === 'whatsapp' ? 2 : 1;
            });
            return score;
        }

        function collectSocialContainers() {
            var found = [];
            function add(node) {
                if (!node || found.indexOf(node) !== -1) return;
                found.push(node);
            }

            document.querySelectorAll('.eora-social-inline').forEach(add);
            descEls.forEach(function (root) { add(findSocialContainer(root)); });
            document.querySelectorAll('a').forEach(function (a) {
                var label = normalizeLabel(a.textContent);
                if (!({ whatsapp: true, facebook: true, twitter: true, pinterest: true })[label]) return;
                [
                    a.closest('[class*="social"]'),
                    a.closest('[class*="share"]'),
                    a.closest('ul'),
                    a.closest('nav'),
                    a.closest('p'),
                    a.closest('div')
                ].filter(Boolean).forEach(function (node) {
                    if (countSocialLinks(node) >= 2) add(node);
                });
            });

            return found;
        }

        var socialContainers = collectSocialContainers();
        var socialNode = socialContainers.sort(function (a, b) {
            return countSocialLinks(b) - countSocialLinks(a);
        })[0] || null;
        if (socialNode) {
            if (!document.getElementById('eora-social-inline-style')) {
                var socialStyle = document.createElement('style');
                socialStyle.id = 'eora-social-inline-style';
                socialStyle.textContent = [
                    '.eora-social-inline{display:flex!important;flex-wrap:wrap!important;gap:22px!important;align-items:center!important;justify-content:flex-start!important;margin:18px 0 0!important;padding:0 20px!important;box-sizing:border-box!important}',
                    '.eora-social-inline a{text-decoration:underline!important;text-transform:uppercase!important;font-size:12px!important;letter-spacing:.5px!important;color:#111!important}',
                    '@media(max-width:767px){.eora-social-inline{margin:14px 0 0!important;padding:0 16px!important;gap:18px!important}.eora-social-inline a{font-size:11px!important}}'
                ].join('');
                document.head.appendChild(socialStyle);
            }

            socialNode.classList.add('eora-social-inline');
            var institutional = findInstitutionalAnchor();
            var bannerProduto = document.querySelector('.eora-banner-produto');
            var anchor = institutional || bannerProduto || document.querySelector('.js-product-video');
            if (institutional && institutional.parentNode) {
                institutional.parentNode.insertBefore(socialNode, institutional.nextSibling);
            } else if (bannerProduto && bannerProduto.parentNode) {
                bannerProduto.parentNode.insertBefore(socialNode, bannerProduto);
            } else if (anchor && anchor.parentNode) {
                anchor.parentNode.insertBefore(socialNode, anchor.nextSibling);
            }

            ensureSocialBeforeBanner();

            socialContainers.forEach(function (node) {
                if (!node || node === socialNode || node.contains(socialNode)) return;
                if (node.parentNode) node.parentNode.removeChild(node);
            });
        }

        descEls.forEach(function (node) {
            if (node && node.parentNode && !node.contains(socialNode)) node.parentNode.removeChild(node);
        });
        ensureSocialBeforeBanner();
    }

    function buildClientesEora() {
        if (document.querySelector('.eora-clientes-section')) return;

        var t = findConfigTable('clientes_eora');
        if (!t) return;

        var fotos = [], tituloText = '';
        var rows = Array.from(t.querySelectorAll('tbody tr'));
        rows.forEach(function (row) {
            var cells = row.querySelectorAll('td');
            if (cells.length < 2) return;
            var k = cells[0].textContent.trim().toLowerCase();
            if (!k || k === 'clientes_eora') return;
            if (isTitleKey(k)) {
                tituloText = cells[1].textContent.replace(/[\u00a0\s]+/g, ' ').trim();
                return;
            }
            var imgEl = cells[1].querySelector('img');
            var url = imgEl ? (imgEl.getAttribute('src') || imgEl.src || '') : '';
            if (url) fotos.push(url);
        });

        rows.forEach(function (row, rowIdx) {
            var labelCells = Array.from(row.querySelectorAll('td'));
            var hasFotoLabels = labelCells.some(function (cell) {
                return /^foto_\d+$/i.test(cell.textContent.replace(/[\u00a0\s]+/g, '').trim());
            });
            if (!hasFotoLabels) return;
            var valueRow = rows[rowIdx + 1];
            if (!valueRow) return;
            var valueCells = Array.from(valueRow.querySelectorAll('td'));
            labelCells.forEach(function (labelCell, idx) {
                var label = labelCell.textContent.replace(/[\u00a0\s]+/g, '').trim();
                if (!/^foto_\d+$/i.test(label)) return;
                var valueCell = valueCells[idx];
                var imgEl = valueCell ? valueCell.querySelector('img') : null;
                var url = imgEl ? (imgEl.getAttribute('src') || imgEl.src || '') : '';
                if (url && fotos.indexOf(url) === -1) fotos.push(url);
            });
        });
        if (!fotos.length) return;

        var css = [
            '.eora-clientes-section{width:100%;margin:0;padding:0;box-sizing:border-box}',
            '.eora-clientes-inner{max-width:1200px;margin:0 auto;padding:0 20px}',
            '.eora-clientes-carousel{position:relative;width:100%;padding:0 64px}',
            '.eora-clientes-swiper{position:relative;width:100%;max-width:100%;margin:0 auto;padding-bottom:40px;overflow:hidden}',
            '.eora-clientes-swiper .swiper-wrapper{display:flex;align-items:stretch}',
            '.eora-clientes-swiper .swiper-slide{display:block!important;height:auto;flex-shrink:0}',
            '.eora-clientes-slide{position:relative;width:100%;padding-bottom:125%;overflow:hidden;background:#f5f5f5}',
            '.eora-clientes-slide img{position:absolute;top:0;left:0;width:100%;height:100%;object-fit:cover;display:block}',
            '.eora-clientes-arrow{position:absolute;top:50%;transform:translateY(-50%);z-index:5;width:44px;height:44px;border-radius:50%;border:1px solid #000;background:#fff;color:#000;cursor:pointer;display:flex;align-items:center;justify-content:center;padding:0;transition:background .2s,color .2s,opacity .2s;margin-top:-20px}',
            '.eora-clientes-arrow:hover{background:#000;color:#fff}',
            '.eora-clientes-arrow:focus{outline:none}',
            '.eora-clientes-arrow.swiper-button-disabled{opacity:.35;cursor:default}',
            '.eora-clientes-arrow-prev{left:8px}',
            '.eora-clientes-arrow-next{right:8px}',
            '.eora-clientes-swiper .swiper-pagination{bottom:0}',
            '.eora-clientes-swiper .swiper-pagination-bullet-active{background:#000}',
            '@media(max-width:991px){.eora-clientes-inner{padding:0 16px}.eora-clientes-carousel{padding:0 48px}.eora-clientes-arrow{width:38px;height:38px}.eora-clientes-arrow-prev{left:4px}.eora-clientes-arrow-next{right:4px}}',
            '@media(max-width:767px){.eora-clientes-section{margin:40px 0;overflow:visible}.eora-clientes-inner{padding:0;overflow:hidden}.eora-clientes-carousel{padding:0;overflow:visible}.eora-clientes-arrow{display:none!important}.eora-clientes-swiper{overflow:visible;padding-left:12px}}'
        ].join('');
        var styleEl = document.createElement('style');
        styleEl.textContent = css;
        document.head.appendChild(styleEl);

        var section = document.createElement('section');
        section.className = 'eora-clientes-section';

        var inner = document.createElement('div');
        inner.className = 'eora-clientes-inner';

        var carousel = document.createElement('div');
        carousel.className = 'eora-clientes-carousel';

        var svgPrev = '<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>';
        var svgNext = '<svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>';

        var btnPrev = document.createElement('button');
        btnPrev.type = 'button';
        btnPrev.className = 'eora-clientes-arrow eora-clientes-arrow-prev js-eora-clientes-prev';
        btnPrev.setAttribute('aria-label', 'Anterior');
        btnPrev.innerHTML = svgPrev;

        var swiperEl = document.createElement('div');
        swiperEl.className = 'swiper js-eora-clientes-swiper eora-clientes-swiper';

        var wrapper = document.createElement('div');
        wrapper.className = 'swiper-wrapper';

        fotos.forEach(function (url) {
            var slide = document.createElement('div');
            slide.className = 'swiper-slide';
            var slideInner = document.createElement('div');
            slideInner.className = 'eora-clientes-slide';
            var img = document.createElement('img');
            img.src = url;
            img.alt = 'Cliente Eora';
            img.loading = 'lazy';
            slideInner.appendChild(img);
            slide.appendChild(slideInner);
            wrapper.appendChild(slide);
        });

        var paginationEl = document.createElement('div');
        paginationEl.className = 'swiper-pagination js-eora-clientes-pagination';

        swiperEl.appendChild(wrapper);
        swiperEl.appendChild(paginationEl);

        var btnNext = document.createElement('button');
        btnNext.type = 'button';
        btnNext.className = 'eora-clientes-arrow eora-clientes-arrow-next js-eora-clientes-next';
        btnNext.setAttribute('aria-label', 'Pr\u00f3ximo');
        btnNext.innerHTML = svgNext;

        carousel.appendChild(btnPrev);
        carousel.appendChild(swiperEl);
        carousel.appendChild(btnNext);
        inner.appendChild(carousel);
        section.appendChild(inner);

        /* Insere DEPOIS do texto institucional */
        var bloco = criarBlocoTitulo(tituloText);
        bloco.appendChild(section);
        var institutional = document.querySelector('[data-store="home-institutional-message"]');
        var anchor = institutional || document.querySelector('.js-texto-campanha-produto') || document.querySelector('.js-banners-alternados-product');
        if (institutional && institutional.parentNode) {
            var afterInstitutional = institutional.nextSibling;
            var socialAfterInstitutional = institutional.nextElementSibling;
            if (socialAfterInstitutional && socialAfterInstitutional.classList && socialAfterInstitutional.classList.contains('eora-social-inline')) {
                afterInstitutional = socialAfterInstitutional.nextSibling;
            }
            institutional.parentNode.insertBefore(bloco, afterInstitutional);
        } else if (anchor && anchor.parentNode) {
            anchor.parentNode.insertBefore(bloco, anchor);
        } else {
            document.body.appendChild(bloco);
        }

        /* Inicializa Swiper (disponível no tema) */
        function initSwiper() {
            if (typeof Swiper === 'undefined') return false;
            var el = document.querySelector('.js-eora-clientes-swiper');
            if (!el || el.dataset.swiperInit === '1') return true;
            el.dataset.swiperInit = '1';
            var isMobile = window.innerWidth < 576;
            new Swiper(el, {
                slidesPerView: isMobile ? 2.2 : 2.5,
                spaceBetween: isMobile ? 8 : 10,
                loop: false,
                watchOverflow: false,
                observer: true,
                observeParents: true,
                pagination: { el: '.js-eora-clientes-pagination', clickable: true },
                navigation: { prevEl: '.js-eora-clientes-prev', nextEl: '.js-eora-clientes-next' },
                breakpoints: {
                    576: { slidesPerView: 2.5, spaceBetween: 10 },
                    992: { slidesPerView: 3, spaceBetween: 20 }
                }
            });
            return true;
        }
        if (!initSwiper()) {
            var tries = 0;
            var iv = setInterval(function () {
                tries++;
                if (initSwiper() || tries > 20) clearInterval(iv);
            }, 250);
        }
    }

    function decodeHtmlText(text) {
        var tmp = document.createElement('textarea');
        tmp.innerHTML = text || '';
        return tmp.value;
    }

    function findConfigTable(keyOrKeys) {
        var keys = Array.isArray(keyOrKeys) ? keyOrKeys : [keyOrKeys];
        var normalizedKeys = keys
            .map(function (k) { return normalizeConfigKey(k); })
            .filter(Boolean);
        if (!normalizedKeys.length) return null;

        var found = null;
        var tables = Array.from(document.querySelectorAll('table')).concat(eoraConfigTableCache);
        tables.forEach(function (tb) {
            if (found) return;
            tb.querySelectorAll('tbody > tr > td:first-child').forEach(function (cell) {
                if (!found && normalizedKeys.indexOf(normalizeConfigKey(cell.textContent)) !== -1) found = tb;
            });
        });
        return found;
    }

    function getRowValue(table, key, mode) {
        if (!table) return '';
        key = String(key || '').toLowerCase();
        var value = '';
        table.querySelectorAll('tbody > tr').forEach(function (row) {
            if (value) return;
            var cells = row.querySelectorAll('td');
            if (cells.length < 2) return;
            if (cells[0].textContent.trim().toLowerCase() !== key) return;
            value = mode === 'html' ? cells[1].innerHTML.trim() : cells[1].textContent.trim();
        });
        return value;
    }

    function buildProductVideoWithText() {
        var table = findConfigTable('video_link');
        var destino = document.querySelector('.js-product-video');
        if (!destino) return;
        if (!table) {
            destino.innerHTML = '';
            destino.style.display = 'none';
            syncSectionTitleBefore(destino, '', 'eora-product-video-title');
            return;
        }

        var videoUrl = getRowValue(table, 'video_link');
        var descriptionText = getRowValue(table, 'descricao_video');
        var descriptionHtml = decodeHtmlText(descriptionText).trim();

        if (!videoUrl) {
            destino.innerHTML = '';
            destino.style.display = 'none';
            syncSectionTitleBefore(destino, '', 'eora-product-video-title');
            return;
        }

        var videoId = '', platform = '', match;
        if ((match = videoUrl.match(/youtu\.be\/([^?&]+)/))) { platform = 'youtube'; videoId = match[1]; }
        else if ((match = videoUrl.match(/[?&]v=([^&]+)/))) { platform = 'youtube'; videoId = match[1]; }
        else if ((match = videoUrl.match(/vimeo\.com\/(\d+)/))) { platform = 'vimeo'; videoId = match[1]; }
        if (!platform || !videoId) {
            destino.innerHTML = '';
            destino.style.display = 'none';
            syncSectionTitleBefore(destino, '', 'eora-product-video-title');
            return;
        }

        var embedUrl = platform === 'vimeo'
            ? 'https://player.vimeo.com/video/' + videoId + '?autoplay=1&muted=1&background=1&loop=1&controls=0&title=0&byline=0&portrait=0&dnt=1'
            : 'https://www.youtube.com/embed/' + videoId + '?autoplay=1&mute=1&controls=0&showinfo=0&rel=0&loop=1&playlist=' + videoId + '&modestbranding=1&playsinline=1';

        var tituloText = getTableTitleText(table);
        destino.style.display = '';

        var css = [
            '.js-product-video{width:100%!important;margin:64px 0!important;box-sizing:border-box!important}',
            '.js-product-video .product-video-container{display:flex!important;justify-content:center!important;align-items:center!important;flex-direction:row-reverse!important;gap:48px!important;width:100%!important;height:auto!important;max-width:1720px!important;margin:0 auto!important;overflow:visible!important;background:transparent!important;padding:0 24px!important;box-sizing:border-box!important}',
            '.js-product-video .product-video-container iframe{display:block!important;width:min(56vw,960px)!important;height:auto!important;aspect-ratio:16/9!important;border:0!important;flex:0 0 auto!important;background:#000!important}',
            '.js-product-video .product-video-description{display:block!important;visibility:visible!important;opacity:1!important;max-width:560px!important;margin:0!important;padding:0 24px!important;text-align:center!important;font-size:14px!important;line-height:1.75!important;color:#111!important;box-sizing:border-box!important}',
            '.js-product-video .product-video-description p{margin:0 0 12px!important}',
            '@media(max-width:1342px){.js-product-video .product-video-container{flex-direction:column!important;gap:32px!important}.js-product-video .product-video-container iframe{width:min(92vw,800px)!important}.js-product-video .product-video-description{max-width:760px!important;padding:0 16px!important}}'
        ].join('');
        var styleEl = document.getElementById('eora-product-video-fix-style');
        if (!styleEl) {
            styleEl = document.createElement('style');
            styleEl.id = 'eora-product-video-fix-style';
            document.head.appendChild(styleEl);
        }
        styleEl.textContent = css;

        destino.innerHTML =
            '<div class="product-video-container">' +
                '<iframe src="' + embedUrl + '" frameborder="0" allow="autoplay; fullscreen; picture-in-picture" allowfullscreen></iframe>' +
                (descriptionHtml ? '<div class="product-video-description">' + descriptionHtml + '</div>' : '') +
            '</div>';
        syncSectionTitleBefore(destino, tituloText, 'eora-product-video-title');
    }

    function buildBannersAlternadosProduct() {
        var table = findConfigTable('banners_alternados');
        var destino = document.querySelector('.js-banners-alternados-product');
        if (!table || !destino) return;

        var rows = Array.from(table.querySelectorAll('tbody > tr'));
        if (rows.length < 2) return;

        var imageRow = rows.find(function (row) {
            var first = row.querySelector('td:first-child');
            return first && normalizeConfigKey(first.textContent) === 'banners_alternados';
        });
        if (!imageRow) return;

        var imageCells = Array.from(imageRow.querySelectorAll('td')).slice(1);
        var textRow = rows.find(function (row, idx) {
            if (row === imageRow) return false;
            var first = row.querySelector('td:first-child');
            var key = first ? normalizeConfigKey(first.textContent) : '';
            if (isTitleKey(key)) return false;
            return row.querySelectorAll('td').length > 1;
        });
        var textCells = textRow ? Array.from(textRow.querySelectorAll('td')).slice(1) : [];

        var html = '';
        imageCells.forEach(function (cell, idx) {
            var img = cell.querySelector('img');
            var textHtml = textCells[idx] ? textCells[idx].innerHTML.trim() : '';
            if (!img && !textHtml) return;
            var src = img ? (img.getAttribute('src') || img.src || '') : '';
            var alt = img ? (img.getAttribute('alt') || '') : '';
            html +=
                '<div class="banner-alternado-item">' +
                    '<div class="banner-img image">' + (src ? '<img src="' + src + '" alt="' + alt.replace(/"/g, '&quot;') + '">' : '') + '</div>' +
                    '<div class="banner-text">' + textHtml + '</div>' +
                '</div>';
        });
        if (!html) return;

        var css = [
            '.js-banners-alternados-product{display:block!important;width:100%!important;max-width:1720px!important;margin:64px auto!important;padding:0 24px!important;box-sizing:border-box!important}',
            '.js-banners-alternados-product .banner-alternado-item{display:grid!important;grid-template-columns:1fr 1fr!important;align-items:center!important;width:100%!important;margin:0!important;gap:0!important}',
            '.js-banners-alternados-product .banner-img{position:relative!important;width:100%!important;min-height:0!important;padding-bottom:59.17%!important;overflow:hidden!important;background:#f4f4f4!important}',
            '.js-banners-alternados-product .banner-img img{position:absolute!important;inset:0!important;width:100%!important;height:100%!important;display:block!important;object-fit:cover!important}',
            '.js-banners-alternados-product .banner-text{display:block!important;visibility:visible!important;opacity:1!important;box-sizing:border-box!important;padding:48px 56px!important;text-align:center!important;color:#111!important}',
            '.js-banners-alternados-product .banner-text h1,.js-banners-alternados-product .banner-text h2,.js-banners-alternados-product .banner-text h3{margin:0 0 16px!important;text-transform:uppercase!important;letter-spacing:1px!important;font-size:24px!important;line-height:1.2!important;color:#111!important}',
            '.js-banners-alternados-product .banner-text p{margin:0 0 14px!important;font-size:14px!important;line-height:1.7!important;color:#444!important;letter-spacing:0!important}',
            '.js-banners-alternados-product .banner-alternado-item:nth-child(odd) .banner-img{order:2!important}',
            '.js-banners-alternados-product .banner-alternado-item:nth-child(odd) .banner-text{order:1!important}',
            '@media(max-width:767px){.js-banners-alternados-product{margin:40px auto!important;padding:0!important}.js-banners-alternados-product .banner-alternado-item{grid-template-columns:1fr!important}.js-banners-alternados-product .banner-alternado-item .banner-img{order:1!important}.js-banners-alternados-product .banner-alternado-item .banner-text{order:2!important}.js-banners-alternados-product .banner-alternado-item:nth-child(odd) .banner-img{order:1!important}.js-banners-alternados-product .banner-alternado-item:nth-child(odd) .banner-text{order:2!important}.js-banners-alternados-product .banner-text{padding:28px 20px 44px!important}.js-banners-alternados-product .banner-text h1,.js-banners-alternados-product .banner-text h2,.js-banners-alternados-product .banner-text h3{font-size:20px!important}.js-banners-alternados-product .banner-text p{font-size:13px!important}}'
        ].join('');
        var styleEl = document.getElementById('eora-banners-alternados-fix-style');
        if (!styleEl) {
            styleEl = document.createElement('style');
            styleEl.id = 'eora-banners-alternados-fix-style';
            document.head.appendChild(styleEl);
        }
        styleEl.textContent = css;

        destino.innerHTML = html;
        syncSectionTitleBefore(destino, getTableTitleText(table), 'eora-banners-alternados-title');
    }

    function buildFloatingBuyBtn() {
        if (document.querySelector('.eora-bolsa-float-bar')) return;

        var css = [
            '.eora-bolsa-float-bar{position:fixed!important;bottom:20px!important;left:50%!important;transform:translateX(-50%)!important;background:#fff!important;border-radius:3px!important;box-shadow:0 2px 12px rgba(0,0,0,.12)!important;padding:4px!important;display:flex!important;align-items:center!important;z-index:9000!important;transition:transform .3s ease,opacity .3s ease!important}',
            '.eora-bolsa-float-bar.eora-hidden{transform:translate(-50%,150%)!important;opacity:0!important;pointer-events:none!important;visibility:hidden!important}',
            'body.modal-open .eora-bolsa-float-bar,body.ajax-cart-open .eora-bolsa-float-bar,body.side-cart-open .eora-bolsa-float-bar{transform:translate(-50%,150%)!important;opacity:0!important;pointer-events:none!important;visibility:hidden!important}',
            '.eora-bolsa-float-buy{background:#000!important;color:#fff!important;border:none!important;height:40px!important;padding:0 28px!important;font-size:10px!important;font-weight:600!important;letter-spacing:2px!important;text-transform:uppercase!important;border-radius:3px!important;cursor:pointer!important;display:flex!important;align-items:center!important;white-space:nowrap!important}',
            '.eora-bolsa-float-buy:hover{background:#333!important}',
            '@media(max-width:767px){.eora-bolsa-float-bar{max-width:90vw!important;bottom:64px!important}.eora-bolsa-float-buy{padding:0 18px!important}}',
            /* popup */
            '.eora-bolsa-pu{position:fixed!important;top:0!important;left:0!important;width:100vw!important;height:100vh!important;background:rgba(0,0,0,.5)!important;z-index:999999!important;display:flex!important;align-items:center!important;justify-content:center!important;opacity:0!important;pointer-events:none!important;transition:opacity .3s!important}',
            '.eora-bolsa-pu.eora-pu-open{opacity:1!important;pointer-events:all!important}',
            '.eora-bolsa-pu-box{background:#fff!important;width:92%!important;max-width:450px!important;border-radius:12px!important;padding:24px!important;box-sizing:border-box!important;position:relative!important;transform:scale(.85)!important;transition:transform .3s cubic-bezier(.2,.8,.2,1)!important}',
            '.eora-bolsa-pu.eora-pu-open .eora-bolsa-pu-box{transform:scale(1)!important}',
            '.eora-bolsa-pu-close{position:absolute!important;top:16px!important;right:16px!important;width:32px!important;height:32px!important;display:flex!important;align-items:center!important;justify-content:center!important;cursor:pointer!important}',
            '.eora-bolsa-pu-title{text-align:center!important;font-size:14px!important;font-weight:700!important;letter-spacing:2px!important;text-transform:uppercase!important;margin:0 0 24px!important;color:#000!important}',
            '.eora-bolsa-pu-card{display:flex!important;align-items:center!important;padding:16px 0!important;border-bottom:1px solid #efefef!important}',
            '.eora-bolsa-pu-card:last-child{border-bottom:none!important}',
            '.eora-bolsa-pu-card img{width:64px!important;height:64px!important;object-fit:cover!important;margin-right:16px!important;background:#efefef!important}',
            '.eora-bolsa-pu-info{flex:1!important;display:flex!important;flex-direction:column!important;padding-right:12px!important}',
            '.eora-bolsa-pu-info strong{font-size:12px!important;font-weight:600!important;letter-spacing:.5px!important;color:#000!important}',
            '.eora-bolsa-pu-info span{font-size:12px!important;color:#555!important;margin-top:2px!important}',
            '.eora-bolsa-pu-select{background:#000!important;color:#fff!important;border:none!important;padding:10px 16px!important;font-size:10px!important;font-weight:600!important;letter-spacing:1px!important;text-transform:uppercase!important;cursor:pointer!important;border-radius:3px!important;white-space:nowrap!important}',
            '.eora-bolsa-pu-select:hover{background:#333!important}'
        ].join('');
        var styleEl = document.createElement('style');
        styleEl.textContent = css;
        document.head.appendChild(styleEl);

        /* ── Barra flutuante ── */
        var floatBar = document.createElement('div');
        floatBar.className = 'eora-bolsa-float-bar eora-hidden';

        var floatBtn = document.createElement('button');
        floatBtn.className = 'eora-bolsa-float-buy';
        floatBtn.id = 'eora-bolsa-float-buy';
        floatBtn.textContent = 'COMPRAR AGORA';
        floatBar.appendChild(floatBtn);
        document.body.appendChild(floatBar);

        /* Atualiza preço quando o tema renderizar */
        function updatePrice() {
            var pe = document.querySelector('.js-price-display, .product-price, [class*="price"]');
            var pt = pe ? pe.textContent.trim() : '';
            if (pt) floatBtn.textContent = 'COMPRAR AGORA \u2013 ' + pt;
        }
        [500, 1000, 2000, 3500].forEach(function (t) { setTimeout(updatePrice, t); });

        function normalizeTagValue(tag) {
            return String(tag || '').trim().toLowerCase();
        }

        function getCurrentProductTags() {
            var root = document.querySelector('#single-product');
            if (!root) return [];
            var raw = root.getAttribute('data-product-tags');
            if (!raw) return [];
            try {
                var parsed = JSON.parse(raw);
                return parsed.map(function (item) {
                    if (!item) return '';
                    if (typeof item === 'string') return item;
                    return item.tag || item.name || '';
                }).filter(Boolean);
            } catch (e) {
                return [];
            }
        }

        function getVariantGroupTag() {
            var tags = getCurrentProductTags().map(normalizeTagValue);
            if (tags.indexOf('maxivertice') !== -1) return 'maxivertice';
            var blocked = {
                bolsa: true,
                preto: true,
                preta: true,
                vertice: true,
                maxivertice: true
            };
            for (var i = 0; i < tags.length; i++) {
                var tag = tags[i];
                if (!tag || blocked[tag]) continue;
                if (tag.indexOf('produto-gradiente:') === 0 || tag.indexOf('card-produto-gradiente:') === 0) continue;
                if (tag.indexOf(':') !== -1) continue;
                return tag;
            }
            return 'maxivertice';
        }

        function fetchProductsFromTag(tag) {
            if (!tag) return Promise.resolve([]);
            var currentPath = window.location.pathname.replace(/\/?$/, '/');
            return fetchTagProducts(tag, currentPath);
        }

        /* ── Popup de seleção de variante ── */
        var popup = document.createElement('div');
        popup.className = 'eora-bolsa-pu';
        popup.innerHTML =
            '<div class="eora-bolsa-pu-box">' +
            '<div class="eora-bolsa-pu-close" id="eora-bolsa-pu-close"><svg width="14" height="14" viewBox="0 0 14 14" fill="none" stroke="#000" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"><path d="M13 1L1 13M1 1l12 12"/></svg></div>' +
            '<h3 class="eora-bolsa-pu-title">SELECIONE UMA VARIANTE</h3>' +
            '<div id="eora-bolsa-pu-list" style="max-height:60vh;overflow-y:auto;padding-right:4px;"></div>' +
            '</div>';
        document.body.appendChild(popup);

        document.getElementById('eora-bolsa-pu-close').addEventListener('click', function () {
            popup.classList.remove('eora-pu-open');
        });
        popup.addEventListener('click', function (e) {
            if (e.target === popup) popup.classList.remove('eora-pu-open');
        });

        function submitVariant(combo, variants) {
            var selects = Array.from(document.querySelectorAll('select.js-variation-option, select[name^="variation"]')).filter(function (s) {
                return !s.classList.contains('js-shipping-select') && !!s.closest('#product_form, .js-product-form, #single-product');
            });
            if (typeof LS !== 'undefined' && LS.variants && combo.lsIdx !== undefined) {
                var v = LS.variants[combo.lsIdx];
                if (v) {
                    if (v.option0 && selects[0]) { selects[0].value = v.option0; selects[0].dispatchEvent(new Event('change')); }
                    if (v.option1 && selects[1]) { selects[1].value = v.option1; selects[1].dispatchEvent(new Event('change')); }
                    if (v.option2 && selects[2]) { selects[2].value = v.option2; selects[2].dispatchEvent(new Event('change')); }
                }
            } else if (combo.refs && combo.values) {
                combo.refs.forEach(function (sel, i) {
                    sel.value = combo.values[i];
                    sel.dispatchEvent(new Event('change'));
                });
            }
            setTimeout(function () {
                var form = document.querySelector('#product_form, .js-product-form');
                var addBtn = form && form.querySelector('[name="commit"], input.js-addtocart, button.js-addtocart');
                if (addBtn) addBtn.click();
            }, 200);
        }

        function abrirPopup() {
            var list = document.getElementById('eora-bolsa-pu-list');
            list.innerHTML = '';
            var priceEl2 = document.querySelector('.js-price-display, .product-price');
            var basePrice = priceEl2 ? priceEl2.textContent.trim() : '';
            var validOptions = [];
            var groupTag = getVariantGroupTag();

            if (typeof LS !== 'undefined' && LS.variants && LS.variants.length > 0) {
                LS.variants.forEach(function (v, i) {
                    var opts = [v.option0, v.option1, v.option2].filter(Boolean);
                    validOptions.push({ name: opts.join(' / '), lsIdx: i, price: v.price_short || basePrice, image_url: v.image_url || '', stock: v.stock });
                });
            } else {
                var sels = Array.from(document.querySelectorAll('select.js-variation-option, select[name^="variation"]')).filter(function (s) {
                    return !s.classList.contains('js-shipping-select') && !!s.closest('#product_form, .js-product-form, #single-product');
                });
                if (sels.length) {
                    Array.from(sels[0].querySelectorAll('option')).filter(function (o) { return o.value; }).forEach(function (o) {
                        validOptions.push({ name: o.text.trim(), values: [o.value], refs: [sels[0]], price: basePrice });
                    });
                } else if (groupTag) {
                    list.innerHTML = '<div style="padding:12px 0;text-align:center;font-size:12px;letter-spacing:.5px;">CARREGANDO VARIAÇÕES</div>';
                    popup.classList.add('eora-pu-open');
                    fetchProductsFromTag(groupTag).then(function (items) {
                        list.innerHTML = '';
                        validOptions = items.map(function (item, index) {
                            return {
                                name: item.name || ('produto ' + (index + 1)),
                                href: item.href,
                                image_url: item.url,
                                price: basePrice
                            };
                        });

                        if (!validOptions.length) {
                            if (triggerOriginalBuy()) return;
                            var wrapEl = document.querySelector('.eora-product-wrap');
                            if (wrapEl) wrapEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
                            popup.classList.remove('eora-pu-open');
                            return;
                        }

                        validOptions.forEach(function (combo, idx) {
                            var card = document.createElement('div');
                            card.className = 'eora-bolsa-pu-card';
                            card.innerHTML =
                                '<div style="display:flex;align-items:center;flex:1;">' +
                                (combo.image_url ? '<img src="' + combo.image_url + '" alt="' + combo.name + '">' : '') +
                                '<div class="eora-bolsa-pu-info"><strong>' + combo.name + '</strong><span>' + (combo.price || basePrice) + '</span></div>' +
                                '</div>' +
                                '<button class="eora-bolsa-pu-select" data-idx="' + idx + '">VER PRODUTO</button>';
                            list.appendChild(card);
                        });

                        list.querySelectorAll('.eora-bolsa-pu-select').forEach(function (btn) {
                            btn.addEventListener('click', function () {
                                var combo = validOptions[parseInt(this.getAttribute('data-idx'))];
                                if (combo && combo.href) window.location.href = combo.href;
                            });
                        });
                    });
                    return;
                }
            }

            /* Se 1 variante ou nenhuma: vai direto */
            if (validOptions.length <= 1) {
                if (validOptions.length === 1) { submitVariant(validOptions[0]); return; }
                if (triggerOriginalBuy()) return;
                var wrapEl = document.querySelector('.eora-product-wrap');
                if (wrapEl) wrapEl.scrollIntoView({ behavior: 'smooth', block: 'start' });
                return;
            }

            var seen = {};
            validOptions.forEach(function (combo, idx) {
                if (seen[combo.name]) return; seen[combo.name] = true;
                var outOfStock = (combo.stock !== null && combo.stock !== undefined && combo.stock <= 0);
                var imgSrc = (combo.image_url || '').replace(/^\/\//, 'https://');
                var card = document.createElement('div');
                card.className = 'eora-bolsa-pu-card';
                card.innerHTML =
                    '<div style="display:flex;align-items:center;flex:1;">' +
                    (imgSrc ? '<img src="' + imgSrc + '" alt="' + combo.name + '">' : '') +
                    '<div class="eora-bolsa-pu-info"><strong>' + combo.name + '</strong><span>' + (combo.price || basePrice) + '</span></div>' +
                    '</div>' +
                    '<button class="eora-bolsa-pu-select" data-idx="' + idx + '">' + (outOfStock ? 'PR\u00C9-VENDA' : 'SELECIONAR') + '</button>';
                list.appendChild(card);
            });

            list.querySelectorAll('.eora-bolsa-pu-select').forEach(function (btn) {
                btn.addEventListener('click', function () {
                    popup.classList.remove('eora-pu-open');
                    submitVariant(validOptions[parseInt(this.getAttribute('data-idx'))]);
                });
            });
            popup.classList.add('eora-pu-open');
        }

        floatBtn.addEventListener('click', abrirPopup);

        /* Mostra após rolar além do product-wrap */
        var floatRef = document.querySelector('.eora-product-wrap') || document.querySelector('#product_form') || document.querySelector('#single-product');
        window.addEventListener('scroll', function () {
            var show = floatRef ? floatRef.getBoundingClientRect().bottom < 80 : window.scrollY > 400;
            if (show) { floatBar.classList.remove('eora-hidden'); }
            else { floatBar.classList.add('eora-hidden'); }
        }, { passive: true });

        /* Referência ao floatRef pode não existir ainda — re-tenta */
        setTimeout(function () {
            if (!floatRef) {
                floatRef = document.querySelector('.eora-product-wrap') || document.querySelector('#product_form');
            }
        }, 1500);
    }

    function setup() {
        snapshotConfigTables();
        init();
        [400, 900, 1500, 2400, 4200, 6200].forEach(function (delay) {
            setTimeout(cleanupLegacyDescriptionAndMoveSocial, delay);
            setTimeout(buildCustomInstitutionalMessage, delay + 10);
        });
        /* Banners rodam independente do init(), com delay para garantir DOM pronto */
        [800, 1800, 3400, 5600, 7600].forEach(function (delay) {
            setTimeout(buildBannerImagemFull, delay);
            setTimeout(buildBannerProduto, delay + 60);
            setTimeout(buildBanners3Videos, delay + 120);
        });
        setTimeout(buildClientesEora, 1000);
        [1200, 2200, 3600, 5200].forEach(function (delay) {
            setTimeout(ensureSocialBeforeBanner, delay);
        });
        [1300, 2600, 4200].forEach(function (delay) {
            setTimeout(buildProductVideoWithText, delay);
            setTimeout(buildBannersAlternadosProduct, delay + 100);
        });
        setTimeout(buildFloatingBuyBtn, 1200);
    }

    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', setup);
    } else {
        setup();
    }
})();
