<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xmlns:fb="http://www.facebook.com/2008/fbml" xmlns:og="http://opengraphprotocol.org/schema/" lang="{% for language in languages %}{% if language.active %}{{ language.lang }}{% endif %}{% endfor %}">
    <head>
        <link rel="preconnect" href="{{ store_resource_hints }}" />
        <link rel="dns-prefetch" href="{{ store_resource_hints }}" />
        <link rel="preconnect" href="https://vod-adaptive-ak.vimeocdn.com" />
        <link rel="preconnect" href="https://empreender-sa-east-1.s3.sa-east-1.amazonaws.com" />
        <link rel="preconnect" href="https://acdn-us.mitiendanube.com" />
        <link rel="preconnect" href="https://fonts.googleapis.com" />
        <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin />
        
        <meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />
        <meta name="viewport" content="width=device-width, initial-scale=1" />
        <title>{{ page_title }}</title>
        <meta name="description" content="{{ page_description }}" />
        <link rel="preload" href="{{ 'css/style-critical.scss' | static_url }}" as="style" />
        <link rel="preload" href="{{ 'js/external-no-dependencies.js.tpl' | static_url }}" as="script" />

        {# Preload of first image of Slider to improve LCP #}
        {% if template == 'home'%}
            {% snipplet 'preload-images.tpl' %}
        {% endif %}

        {{ component('social-meta') }}

        {#/*============================================================================
            #CSS and fonts
        ==============================================================================*/#}

        {% set page_current_01 = settings.campaign_page_01_url %}
        {% set page_current_02 = settings.campaign_page_02_url %}
        {% set page_current_03 = settings.campaign_page_03_url %}
        {% set is_on_campaign_page = page.handle == page_current_01 or page.handle == page_current_02 or page.handle == page_current_03  %}

        <style>
            {# Font families #}

            {{ component(
                'fonts',{
                    font_weights: '400,500,600,700',
                    font_settings: 'settings.font_headings, settings.font_rest'
                })
            }}

            {{ component(
                'fonts',{
                    font_weights: '700',
                    font_settings: 'settings.font_institutional_message'
                })
            }}

            {% if is_on_campaign_page %}
                {% set current_settings_name = '' %}
                {% if page.handle == page_current_01 %} {% set current_settings_name = 'campaign_page_01' %}
                {% elseif page.handle == page_current_02 %} {% set current_settings_name = 'campaign_page_02' %}
                {% elseif page.handle == page_current_03 %} {% set current_settings_name = 'campaign_page_03' %}
                {% endif %}

                {% set campaign_page_font_message = attribute(settings,"#{current_settings_name}_font_message") %}
                {% set is_campaign_page_font_message_active = attribute(settings,"#{current_settings_name}_message_active") %}

                {% if is_campaign_page_font_message_active %}
                    {{ component(
                        'fonts',{
                            font_weights: '700',
                            font_settings: campaign_page_font_message
                        })
                    }}
                {% endif %}
            {% endif %}


            {# General CSS Tokens #}

            {% include "static/css/style-tokens.tpl" %}
        </style>

        <link rel="stylesheet" href="{{ 'css/style_above.scss' | static_url }}">
        
        <link rel="stylesheet" href="{{ 'css/style-critical.scss' | static_url }}">

        {% set behind_lens_page = settings.behind_lens_page_url %}
        {% set is_behind_lens_page = page.handle == behind_lens_page %}

        {% if is_on_campaign_page or is_behind_lens_page %}
            {{ 'css/style_campaign.scss' | static_url | static_inline }}
        {% endif %}

        {% if page.handle == 'garantia-eora' %}
            {{ 'css/garantia-eora.scss.tpl' | static_url | static_inline }}
        {% endif %}

        {# Load async styling not mandatory for first meaningfull paint #}

        <link rel="stylesheet" href="{{ 'css/style.scss' | static_url }}" media="print" onload="this.media='all'">
        <link rel="stylesheet" href="{{ 'css/style-async.scss' | static_url }}" media="print" onload="this.media='all'">

        {# Loads custom CSS added from Advanced Settings on the admin´s theme customization screen #}

        <style>
            {{ settings.css_code | raw }}
        </style>

        {#/*============================================================================
            #Javascript: Needed before HTML loads
        ==============================================================================*/#}

        {# Defines if async JS will be used by using script_tag(true) #}

        {% set async_js = true %}

        {# Defines the usage of jquery loaded below, if nojquery = true is deleted it will fallback to jquery 1.5 #}

        {% set nojquery = true %}

        {# Jquery async by adding script_tag(true) #}

        {% if load_jquery %}

            {{ '//ajax.googleapis.com/ajax/libs/jquery/1.11.1/jquery.min.js' | script_tag(true) }}

        {% endif %}

        {# Loads private Tiendanube JS #}

        {% head_content %}

        {# Structured data to provide information for Google about the page content #}

        {{ component('structured-data') }}

        <script type="text/javascript">
            (function(c,l,a,r,i,t,y){
                c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
                t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
                y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
            })(window, document, "clarity", "script", "wb7jil6ddu");
        </script>
    </head>
    <body class="js-head-offset head-offset">

        {# Theme icons #}

        {% include "snipplets/svg/icons.tpl" %}

        {# Facebook comments on product page #}

        {% if template == 'product' %}

            {# Facebook comment box JS #}
            {% if settings.show_product_fb_comment_box %}
                {{ fb_js }}
            {% endif %}

            {# Pinterest share button JS #}
            {{ pin_js }}

        {% endif %}

        {# Back to admin bar #}

        {{back_to_admin}}

        {# Header = Advertising + Nav + Logo + Search + Ajax Cart #}

        {% snipplet "header/header.tpl" %}

        {# Page content #}

        {% template_content %}

        {# Quickshop modal #}

        {% snipplet "grid/quick-shop.tpl" %}

        {# WhatsApp chat button #}

        {% snipplet "whatsapp-chat.tpl" %}
        {# {% snipplet "button-popup.tpl" %} #}

        {# Footer #}

        {% snipplet "footer/footer.tpl" %}

        {% if cart.free_shipping.cart_has_free_shipping or cart.free_shipping.min_price_free_shipping.min_price %}

            {# Minimum used for free shipping progress messages. Located on header so it can be accesed everywhere with shipping calculator active or inactive #}

            <span class="js-ship-free-min hidden" data-pricemin="{{ cart.free_shipping.min_price_free_shipping.min_price_raw }}"></span>
            <span class="js-free-shipping-config hidden" data-config="{{ cart.free_shipping.allFreeConfigurations }}"></span>
            <span class="js-cart-subtotal hidden" data-priceraw="{{ cart.subtotal }}"></span>
            <span class="js-cart-discount hidden" data-priceraw="{{ cart.promotional_discount_amount }}"></span>
        {% endif %}

        {#/*============================================================================
            #Javascript: Needed after HTML loads
        ==============================================================================*/#}

        {# Javascript used in the store #}

        {# Critical libraries #}

        {{ 'js/external-no-dependencies.js.tpl' | static_url | script_tag }}

        <script type="text/javascript">

            {# LS.ready.then function waits to Jquery and private Tiendanube JS to be loaded before executing what´s inside #}

            LS.ready.then(function(){

                {# Non critical libraries #}

                {% include "static/js/external.js.tpl" %}

                {# Specific store JS functions: product variants, cart, shipping, etc #}

                {% include "static/js/store.js.tpl" %}
                
                {% if template == 'product' or settings.quick_shop %}
                    {% include "static/js/store-product.js.tpl" %}
                {% endif %}

                {% include "static/js/video-banner-image-side.js.tpl" %}
            });
        </script>

        {# Google survey JS for Tiendanube Survey #}

        {% include "static/js/google-survey.js.tpl" %}

        {# Store external codes added from admin #}

        {% if store.assorted_js %}
            <script>
                LS.ready.then(function() {
                    var externalScriptsLoaded = false;
                    function loadExternalScripts() {
                        if(externalScriptsLoaded) return;
                        externalScriptsLoaded = true;
                        var trackingCode = jQueryNuvem.parseHTML('{{ store.assorted_js| escape("js") }}', document, true);
                        jQueryNuvem('body').append(trackingCode);
                    }

                    // Load on user interaction
                    ['mouseover', 'keydown', 'touchmove', 'touchstart'].forEach(function(event) {
                        window.addEventListener(event, loadExternalScripts, {passive: true, once: true});
                    });

                    // Fallback: Load after 5 seconds
                    setTimeout(loadExternalScripts, 5000);
                });
            </script>
        {% endif %}

        {# Perfit/Nuvem Marketing Popup Script #}
        {% include 'snipplets/button-popup.tpl' %}

        {% if "home_popup_image.jpg" | has_custom_image or settings.home_popup_title or settings.home_popup_txt or settings.home_news_box or (settings.home_popup_btn and settings.home_popup_url) %}
            {% include 'snipplets/home/home-popup.tpl' %}
        {% else %}
            {# Force include for fallback purposes, even if empty #}
            {% include 'snipplets/home/home-popup.tpl' %}
        {% endif %}

        {# mKFashion Provador Virtual #}
        <script src="https://unpkg.com/mkfashion-sdk/src/mkfashion.js"></script>
        <style>
            .btn-provador-virtual {
                position: absolute;
                top: 10px;
                left: 10px;
                z-index: 10;
                background: rgba(255, 255, 255, 0.88);
                border: none;
                border-radius: 50%;
                width: 34px;
                height: 34px;
                display: flex;
                align-items: center;
                justify-content: center;
                cursor: pointer;
                padding: 0;
                color: #333;
                transition: background 0.2s, transform 0.15s;
                box-shadow: 0 1px 4px rgba(0,0,0,0.10);
            }
            #tip-card-provador.eora-always-visible { display: block !important; }
            .btn-tip-card {
                display: flex;
                align-items: center;
                justify-content: center;
                gap: 10px;
                width: 100%;
                padding: 14px 20px;
                background: transparent;
                border: 1.5px solid #222;
                font-size: 12px;
                font-weight: 500;
                letter-spacing: 0.12em;
                text-transform: uppercase;
                cursor: pointer;
                color: #222;
                transition: background 0.2s, color 0.2s;
            }
            .btn-tip-card:hover { background: #222; color: #fff; }
            .btn-tip-card:hover svg { stroke: #fff; }
            .btn-tip-card svg { flex-shrink: 0; transition: stroke 0.2s; }
            .btn-provador-virtual:hover {
                background: #fff;
                transform: scale(1.08);
            }
        </style>
        <script>
        (function() {
            document.querySelectorAll('.item-link').forEach(function(link) {
                if (!link.querySelector('.wrapper-variant-colors') && !link.querySelector('.item-colors')) {
                    var firstDiv = link.querySelector('div');
                    if (firstDiv) firstDiv.style.marginTop = '52px';
                }

            });

            // Intercepta clique nos cards LUAR fake → redireciona pra página LUAR com ?v=
            var URL_LUAR = 'https://www.eoraeyewear.com/produtos/luar/';
            var CORES_LUAR = ['prata', 'preto', 'dourado', 'cinza', 'rose', 'rosé', 'azul', 'verde', 'branco'];
            function extrairCorDeTexto(txt) {
                if (!txt) return '';
                var t = txt.toLowerCase();
                for (var i = 0; i < CORES_LUAR.length; i++) {
                    if (t.indexOf(CORES_LUAR[i]) !== -1) return CORES_LUAR[i];
                }
                return '';
            }
            document.addEventListener('click', function(e) {
                var item = e.target.closest('.js-item-product, .item-product');
                if (!item) return;
                var link = item.querySelector('a[href]');
                if (!link) return;
                try {
                    var caminho = new URL(link.href, window.location.origin).pathname.toLowerCase();
                    if (caminho.startsWith('/produtos/luar') && caminho !== '/produtos/luar' && caminho !== '/produtos/luar/') {
                        e.preventDefault();
                        e.stopImmediatePropagation();
                        var cor = '';
                        // 1. Tenta pelo nome do produto
                        var nomeEl = item.querySelector('.js-item-name, .item-name');
                        cor = extrairCorDeTexto(nomeEl ? nomeEl.textContent : '');
                        // 2. Tenta pelo src da imagem do card
                        if (!cor) {
                            var img = item.querySelector('img[src], img[data-src]');
                            var imgSrc = img ? (img.getAttribute('src') || img.getAttribute('data-src') || '') : '';
                            cor = extrairCorDeTexto(imgSrc);
                        }
                        // 3. Tenta pelo alt da imagem
                        if (!cor) {
                            var imgAlt = img ? img.getAttribute('alt') || '' : '';
                            cor = extrairCorDeTexto(imgAlt);
                        }
                        window.location.href = URL_LUAR + (cor ? '?v=' + encodeURIComponent(cor) : '');
                    }
                } catch(err) {}
            }, true);

            var PROJECT_ID = '69bbd36a44b548ccd0f965f4';

            // Pre-fetch real LUAR product variants (SKU → variant ID mapping)
            var luarVariantMap = {};
            var luarFetchReady = fetch('/produtos/luar.json')
                .then(function(r) { return r.ok ? r.json() : Promise.reject('no json'); })
                .then(function(data) {
                    var variants = (data && data.variants) || (data && data.product && data.product.variants) || [];
                    variants.forEach(function(v) {
                        var sku = (v.sku || '').toUpperCase().trim();
                        if (sku && v.id) luarVariantMap[sku] = v.id;
                    });
                    console.log('LUAR variant map:', luarVariantMap);
                })
                .catch(function() {});

            if (typeof mkfashion === 'undefined') return;

            mkfashion.addToCart(function(payload) {
                console.log('Provador Virtual - Produto:', payload);
                luarFetchReady.then(function() {
                    try {
                        var identifier = (payload && payload.mainIdentifier ? payload.mainIdentifier : '').toUpperCase().trim();
                        var realVariantId = luarVariantMap[identifier];

                        if (realVariantId && typeof jQueryNuvem !== 'undefined') {
                            // Add the real LUAR variant to cart
                            jQueryNuvem.post('/carrito', { add: 1, id: realVariantId, quantity: 1 }, function() {
                                if (typeof modalOpen === 'function') modalOpen('#modal-cart');
                            });
                            return;
                        }

                        // Fallback: product detail page form (real LUAR product page)
                        var form = null;
                        if (identifier) {
                            var btn = document.querySelector('.js-btn-provador-virtual[data-mkfashion-identifier="' + payload.mainIdentifier + '"], .js-tip-card-btn[data-mkfashion-identifier="' + payload.mainIdentifier + '"]');
                            if (btn) {
                                var pdpContainer = btn.closest('.js-product-container');
                                if (pdpContainer) form = pdpContainer.querySelector('form');
                                if (!form) {
                                    var gridItem = btn.closest('.js-item-product');
                                    if (gridItem) form = gridItem.querySelector('form');
                                }
                            }
                        }
                        if (!form) form = document.querySelector('.js-product-container form');
                        if (!form || typeof LS === 'undefined' || typeof LS.addToCartEnhanced !== 'function') return;
                        LS.addToCartEnhanced(
                            jQueryNuvem(form),
                            '{{ "Comprar" | translate }}',
                            '{{ "Agregando..." | translate }}',
                            '{{ "No hay más stock de este producto." | translate }}',
                            {{ store.editable_ajax_cart_enabled ? 'true' : 'false' }},
                            function() { if (typeof modalOpen === 'function') modalOpen('#modal-cart'); },
                            function() {}
                        );
                    } catch(e) { console.error('Provador Virtual - erro ao adicionar:', e); }
                });
            });

            document.querySelectorAll('.js-btn-provador-virtual').forEach(function(btn) {
                var identifier = btn.getAttribute('data-mkfashion-identifier');
                if (!identifier) return;

                mkfashion.isAvailable(PROJECT_ID, identifier).then(function(disponivel) {
                    if (!disponivel) return;

                    btn.style.display = btn.classList.contains('btn-provador-virtual') ? 'flex' : 'block';

                    btn.addEventListener('click', function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                        mkfashion.open({ projectId: PROJECT_ID, identifier: identifier });
                    });
                });
            });

            document.querySelectorAll('.js-tip-card-btn').forEach(function(btn) {
                var identifier = btn.getAttribute('data-mkfashion-identifier');
                if (!identifier) return;

                mkfashion.isAvailable(PROJECT_ID, identifier).then(function(disponivel) {
                    if (!disponivel) return;

                    var tipCard = document.getElementById('tip-card-provador');
                    if (tipCard) {
                        tipCard.classList.add('eora-always-visible');
                        tipCard.style.removeProperty('display');
                    }

                    // Garante que o botão permaneça visível mesmo após re-render
                    setInterval(function() {
                        var tc = document.getElementById('tip-card-provador');
                        if (tc && !tc.classList.contains('eora-always-visible')) {
                            tc.classList.add('eora-always-visible');
                        }
                        if (tc) tc.style.removeProperty('display');
                    }, 500);

                    btn.addEventListener('click', function(e) {
                        e.preventDefault();
                        e.stopPropagation();
                        mkfashion.open({ projectId: PROJECT_ID, identifier: identifier });
                    });
                });
            });
        })();
        </script>

    </body>
</html>
