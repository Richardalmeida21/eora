{# Slider and video presence for header transparency check #}
{% if template == 'home' %}
    {% set has_main_slider = settings.slider and settings.slider is not empty %}
    {% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}
    {% set has_slider = has_main_slider or has_mobile_slider %}
{% endif %}
{% set head_transparent_type_on_section = template == 'home' and settings.head_transparent and settings.head_transparent_type == 'slider_and_video' and (has_slider or settings.video_embed) %}
{% set head_transparent_type_always = settings.head_transparent and settings.head_transparent_type == 'all' %}
{% set head_transparent = (head_transparent_type_on_section or head_transparent_type_always) %}
{% set is_home_page = template == 'home' %}
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
        <script>
            (function () {
                try {
                    var url = new URL(window.location.href);
                    if (url.pathname.replace(/\/$/, '') === '/kits' && url.searchParams.get('mpage') === '2') {
                        document.documentElement.classList.add('eora-kits-campaign-2');
                    }
                } catch (e) {}
            })();
        </script>
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
        {% set page_current_04 = settings.campaign_page_04_url %}
        {% set page_current_05 = settings.campaign_page_05_url %}
        {% set page_current_06 = settings.campaign_page_06_url %}
        {% set page_current_07 = settings.campaign_page_07_url %}
        {% set page_current_08 = settings.campaign_page_08_url %}
        {% set page_current_09 = settings.campaign_page_09_url %}
        {% set page_current_10 = settings.campaign_page_10_url %}
        {% set is_on_campaign_page = page.handle == page_current_01 or page.handle == page_current_02 or page.handle == page_current_03 or page.handle == page_current_04 or page.handle == page_current_05 or page.handle == page_current_06 or page.handle == page_current_07 or page.handle == page_current_08 or page.handle == page_current_09 or page.handle == page_current_10 %}

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
                {% elseif page.handle == page_current_04 %} {% set current_settings_name = 'campaign_page_04' %}
                {% elseif page.handle == page_current_05 %} {% set current_settings_name = 'campaign_page_05' %}
                {% elseif page.handle == page_current_06 %} {% set current_settings_name = 'campaign_page_06' %}
                {% elseif page.handle == page_current_07 %} {% set current_settings_name = 'campaign_page_07' %}
                {% elseif page.handle == page_current_08 %} {% set current_settings_name = 'campaign_page_08' %}
                {% elseif page.handle == page_current_09 %} {% set current_settings_name = 'campaign_page_09' %}
                {% elseif page.handle == page_current_10 %} {% set current_settings_name = 'campaign_page_10' %}
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

        {# EORA BRAND CUSTOM FIXES FOR HORIZONTAL OVERFLOW AND FLOATING ELEMENTS #}
        <style>
            /* Force container-fluid and container to stay within the viewport bounds without horizontal overflow */
            .container-fluid {
                margin-left: auto !important;
                margin-right: auto !important;
                width: 100% !important;
                max-width: 100% !important;
            }
            .container {
                margin-left: auto !important;
                margin-right: auto !important;
            }
            /* Force row margins to match standard Bootstrap grid gutters, counteracting bad -3rem custom margins */
            .row {
                margin-left: -15px !important;
                margin-right: -15px !important;
            }
            @media (min-width: 768px) {
                .row {
                    margin-left: -30px !important;
                    margin-right: -30px !important;
                }
            }
            body.template-product #single-product > .container-fluid {
                padding-left: 0 !important;
                padding-right: 0 !important;
                max-width: 100vw !important;
                overflow-x: hidden !important;
            }
            body.template-product #single-product > .container-fluid > .row {
                margin-left: 0 !important;
                margin-right: 0 !important;
            }
            /* Exclude product grids (.row-grid) from standard row overrides, restoring their native gutters */
            .row-grid {
                margin-left: var(--gutter-half-negative) !important;
                margin-right: var(--gutter-half-negative) !important;
            }
            /* Override unconstrained margin filters bar */
            .category-controls {
                margin-left: 0 !important;
                margin-right: 0 !important;
                padding-left: 1rem !important;
                padding-right: 1rem !important;
                max-width: 100vw !important;
                width: 100% !important;
                box-sizing: border-box !important;
            }
            @media (min-width: 768px) {
                .category-controls {
                    padding-left: 3rem !important;
                    padding-right: 3rem !important;
                }
            }
            /* Strictly anchor the floating social bar to the viewport boundaries */
            .social-fixed-sidebar {
                position: fixed !important;
                right: 0 !important;
                top: 85% !important;
                transform: translateY(-50%) !important;
                z-index: 1000 !important;
                display: flex !important;
                flex-direction: column !important;
                gap: 0 !important;
            }

            /* ==============================================================
               EORA CAMPAIGN PAGES CENTERING & SYMMETRY OVERRIDES
               ============================================================== */
            @media (min-width: 992px) {
                .template-campaign-page main .container-fluid:not(.desktop):not(.mobile) {
                    max-width: 100% !important;
                    margin-left: auto !important;
                    margin-right: auto !important;
                    width: 100% !important;
                    padding-left: 30px !important;
                    padding-right: 30px !important;
                }
                .template-campaign-page main .container {
                    margin-left: auto !important;
                    margin-right: auto !important;
                    width: 100% !important;
                }
            }
            @media (max-width: 991px) {
                .template-campaign-page main .container-fluid:not(.desktop):not(.mobile) {
                    padding-left: 15px !important;
                    padding-right: 15px !important;
                    margin-left: auto !important;
                    margin-right: auto !important;
                    width: 100% !important;
                }
            }
            .template-campaign-page main .row {
                margin-left: -15px !important;
                margin-right: -15px !important;
            }
            @media (min-width: 768px) {
                .template-campaign-page main .row {
                    margin-left: -30px !important;
                    margin-right: -30px !important;
                }
            }
            .template-campaign-page main .row-grid {
                margin-left: var(--gutter-half-negative) !important;
                margin-right: var(--gutter-half-negative) !important;
            }
            .template-campaign-page main .section-title,
            .template-campaign-page main .section-title-products-home {
                text-align: center !important;
                margin-left: auto !important;
                margin-right: auto !important;
            }

            /* Enforce body top padding when header is opaque/fixed to prevent content overlap */
            body.head-offset-active {
                padding-top: 90px !important;
            }
            body.head-offset-active.has-ad-bar {
                padding-top: 125px !important;
            }
            @media (max-width: 991px) {
                body.head-offset-active {
                    padding-top: 70px !important;
                }
                body.head-offset-active.has-ad-bar {
                    padding-top: 105px !important;
                }
            }
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

        {# Martz must load after the GTM/GA4 integrations injected above. #}
        {% include "snipplets/martz-data-layer.tpl" %}

        {# Structured data to provide information for Google about the page content #}

        {{ component('structured-data') }}

        <script type="text/javascript">
            window.eoraLoadWhenIdle = window.eoraLoadWhenIdle || function(callback, timeout) {
                var scheduled = false;
                function schedule() {
                    if (scheduled) return;
                    scheduled = true;
                    if ('requestIdleCallback' in window) {
                        window.requestIdleCallback(callback, { timeout: timeout || 3000 });
                    } else {
                        window.setTimeout(callback, 0);
                    }
                }
                if (document.readyState === 'complete') {
                    schedule();
                } else {
                    window.addEventListener('load', schedule, { once: true });
                }
            };

            (function(c,l,a,r,i,t,y){
                c[a]=c[a]||function(){(c[a].q=c[a].q||[]).push(arguments)};
                t=l.createElement(r);t.async=1;t.src="https://www.clarity.ms/tag/"+i;
                y=l.getElementsByTagName(r)[0];y.parentNode.insertBefore(t,y);
            })(window, document, "clarity", "script", "wb7jil6ddu");
        </script>

        <!-- TikTok Pixel Code -->
        <script>
            !function (w, d, t) {
                w.TiktokAnalyticsObject = t;
                var ttq = w[t] = w[t] || [];
                ttq.methods = ["page", "track", "identify", "instances", "debug", "on", "off", "once", "ready", "alias", "group", "enableCookie", "disableCookie", "hold", "revoke", "consent"];
                ttq.setAndDefer = function (t, e) { t[e] = function () { t.push([e].concat(Array.prototype.slice.call(arguments, 0))); }; };
                for (var i = 0; i < ttq.methods.length; i++) ttq.setAndDefer(ttq, ttq.methods[i]);
                ttq.instance = function (t) { for (var e = ttq._i[t] || [], n = 0; n < ttq.methods.length; n++) ttq.setAndDefer(e, ttq.methods[n]); return e; };
                ttq.load = function (e, n) {
                    var i = "https://analytics.tiktok.com/i18n/pixel/events.js";
                    ttq._i = ttq._i || {}, ttq._i[e] = [], ttq._i[e]._u = i, ttq._t = ttq._t || {}, ttq._t[e] = +new Date, ttq._o = ttq._o || {}, ttq._o[e] = n || {};
                    var o = document.createElement("script");
                    o.type = "text/javascript", o.async = !0, o.src = i + "?sdkid=" + e + "&lib=" + t;
                    var a = document.getElementsByTagName("script")[0];
                    a.parentNode.insertBefore(o, a);
                };
                ttq.page();
                window.eoraLoadWhenIdle(function() {
                    ttq.load('D6DGMURC77U3L7SPB6C0');
                }, 3000);
            }(window, document, 'ttq');
        </script>

        <!-- Proteção máxima de layout e viewport contra quebras e encolhimento (squishing) -->
        <style>
            html, body {
                max-width: 100% !important;
                width: 100% !important;
                overflow-x: hidden !important;
                margin: 0 !important;
                padding-left: 0 !important;
                padding-right: 0 !important;
                padding-bottom: 0 !important;
                -webkit-text-size-adjust: 100% !important;
                text-size-adjust: 100% !important;
            }
            input, select, textarea, button, a {
                touch-action: manipulation !important;
            }
            img, iframe, video, .container, .container-fluid {
                max-width: 100% !important;
            }
        </style>
    </head>
    <body class="js-head-offset {% if not is_home_page %}head-offset-active{% else %}head-offset-transparent{% endif %} {% if settings.ad_bar %}has-ad-bar{% endif %} {% if is_on_campaign_page %}template-campaign-page{% endif %} template-{{ template }}">

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
                (function() {
                    var criticalLoaded = false;
                    var trackingLoaded = false;

                    function parseAndSplitScripts() {
                        var rawHtml = '{{ store.assorted_js| escape("js") }}';
                        var temp = document.createElement('div');
                        temp.innerHTML = rawHtml;

                        var criticalScripts = [];
                        var trackingScripts = [];

                        temp.querySelectorAll('script, link, iframe').forEach(function(el) {
                            var src = el.getAttribute('src') || el.src || '';
                            var content = el.textContent || el.innerHTML || '';
                            var str = (src + ' ' + content).toLowerCase();

                            // Cheguei app ou Empreender scripts funcionais essenciais
                            if (str.indexOf('cheguei') !== -1 || str.indexOf('empreender') !== -1 || str.indexOf('avise') !== -1) {
                                criticalScripts.push(el);
                            } else {
                                trackingScripts.push(el);
                            }
                        });

                        return {
                            critical: criticalScripts,
                            tracking: trackingScripts
                        };
                    }

                    var scripts = parseAndSplitScripts();

                    function loadCritical() {
                        if (criticalLoaded) return;
                        criticalLoaded = true;
                        
                        scripts.critical.forEach(function(el) {
                            var freshNode = document.createElement(el.tagName);
                            Array.from(el.attributes).forEach(function(attr) {
                                freshNode.setAttribute(attr.name, attr.value);
                            });
                            freshNode.innerHTML = el.innerHTML;
                            document.body.appendChild(freshNode);
                        });
                    }

                    function loadTracking() {
                        if (trackingLoaded) return;
                        trackingLoaded = true;

                        scripts.tracking.forEach(function(el) {
                            var freshNode = document.createElement(el.tagName);
                            Array.from(el.attributes).forEach(function(attr) {
                                freshNode.setAttribute(attr.name, attr.value);
                            });
                            freshNode.innerHTML = el.innerHTML;
                            document.body.appendChild(freshNode);
                        });
                    }

                    // Carrega scripts críticos e funcionais imediatamente (0ms)
                    loadCritical();

                    // Agenda os rastreadores não críticos de forma segura sem travar o mobile
                    function scheduleTracking() {
                        if (typeof LS !== 'undefined' && LS.ready) {
                            LS.ready.then(function() {
                                ['mouseover', 'keydown', 'touchmove', 'touchstart'].forEach(function(event) {
                                    window.addEventListener(event, loadTracking, {passive: true, once: true});
                                });
                                setTimeout(loadTracking, 2000);
                            });
                        } else {
                            setTimeout(scheduleTracking, 50);
                        }
                    }
                    scheduleTracking();
                })();
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
            .js-product-slide-link > .btn-provador-virtual {
                top: 54px;
            }
            @media (max-width: 767px) {
                .js-product-slide-link > .btn-provador-virtual {
                    top: 64px;
                }
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

            // Intercepta clique nos cards LUAR fake → redireciona pra página LUAR com ?vi=
            var URL_LUAR = 'https://www.eoraeyewear.com/produtos/luar/';
            // Mapa fixo: slug → índice do card (data-idx) na página do Luar
            var LUAR_SLUG_MAP = {
                'luar1':      1,  // Preto Fosco/Preto
                'luar-1rh88': 2,  // Prata/Cinza
                'luar-copia': 3,  // Dourado/Preto
                'luar3':      4,  // Prata/Rosa Fotocromática
                'luar2':      5   // Prata/Prata Fotocromática
            };
            var CORES_LUAR = ['prata', 'preto', 'dourado', 'cinza', 'rose', 'rosé', 'azul', 'verde', 'branco'];
            function extrairCorDeTexto(txt) {
                if (!txt) return '';
                var t = txt.toLowerCase();
                for (var i = 0; i < CORES_LUAR.length; i++) {
                    if (t.indexOf(CORES_LUAR[i]) !== -1) return CORES_LUAR[i];
                }
                return '';
            }
            // Mapa: slug do fake product → SKU real da variante Luar (para provador virtual)
            var LUAR_SKU_MAP = {
                'luar-copia': 'LUADC',   // Dourado/Preto
                'luar3':      'LUAPRF',  // Prata/Rosa Fotocromática
                'luar2':      'LUAPCF'   // Prata/Prata Fotocromática
            };

            // Interceptor: cliques gerais nos cards fake Luar → redireciona para /produtos/luar/?vi=N
            document.addEventListener('click', function(e) {
                if (e.target.closest('.js-btn-provador-virtual')) return; // tratado pelo interceptor acima
                var item = e.target.closest('.js-item-product, .item-product');
                if (!item) return;
                var link = item.querySelector('a[href]');
                if (!link) return;
                try {
                    var caminho = new URL(link.href, window.location.origin).pathname.toLowerCase().replace(/\/$/, '');
                    if (caminho.startsWith('/produtos/luar') && caminho !== '/produtos/luar') {
                        e.preventDefault();
                        e.stopImmediatePropagation();
                        var slug = caminho.replace('/produtos/', '');
                        var vi = LUAR_SLUG_MAP[slug];
                        window.location.href = URL_LUAR + (vi !== undefined ? '?vi=' + vi : '');
                    }
                } catch(err) {}
            }, true);

            /* EORA: alternador global de variacoes por referencia. */
            {% include "static/js/eora-variations.js.tpl" %}
        })();
        </script>

    </body>
</html>
