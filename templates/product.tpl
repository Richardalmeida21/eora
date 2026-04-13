{% set is_coach_layout = 'layout_coach' in product.description %}
<div id="single-product" class="js-has-new-shipping js-product-detail js-product-container js-shipping-calculator-container pb-4 pt-md-4 pb-md-3" data-variants="{{product.variants_object | json_encode }}" data-store="product-detail">
    <div class="container-fluid">
        <div class="row">
            <div class="col-12 {% if is_coach_layout %}col-md-9{% else %}col-md-auto{% endif %} product-image-column ">
                {% include 'snipplets/product/product-image.tpl' with {mobile: false} %}
                {% include 'snipplets/product/product-image.tpl' with {mobile: true} %}
            </div>
            <div class="{% if is_coach_layout %}col-md-3{% else %}col-md-auto{% endif %} product-info-column py-3" data-store="product-info-{{ product.id }}">
                {% include 'snipplets/product/product-form.tpl' %}
                {% if not settings.full_width_description %}
                    {% include 'snipplets/product/product-description.tpl' %}
                {% endif %}
            </div>
            {# Product description full width #}
        </div>
    </div>
</div>

{# {% set item_img_spacing = 150 %}

{% set product_img_height =  settings.product_img_height %}
{% set product_img_width =  settings.product_img_width %}

{% set item_img_spacing = product_img_height / product_img_width * 100 %} #}
{# 
<div class="container-fluid block-compre-junto-funsales" style="--padding-bottom-compre-junto: {{ item_img_spacing }}%;">
    <div id="compre-junto-block">
    </div>
</div> #}

{% include 'snipplets/home/home-institutional-message.tpl' %}

{% if settings.full_width_description %}
    <div class="container-fluid">
        {# {% include 'snipplets/product/product-description-tabs.tpl' %} #}
        {% include 'snipplets/product/product-description.tpl' %}
        
<div class="js-product-video mb-4">
    <div class="product-video-container">
        <!-- O vídeo será injetado aqui -->
        <div class="video-container">
            <iframe class="product-video-iframe"
                src="https://player.vimeo.com/video/1131913524?autoplay=1&muted=1&background=1&loop=1&controls=0&title=0&byline=0&portrait=0&dnt=1" 
                frameborder="0" 
                allow="autoplay; fullscreen; picture-in-picture" 
                allowfullscreen>
            </iframe>
        </div>
        <!-- Descrição do vídeo será injetada aqui -->
        <div class="product-video-description">
            {{ product.video_description|raw }}
        </div>
    </div>
</div>

        <div class="swiper js-swiper-banners-experiencia swiper-container d-none">
            <h3 class="js-banners-experiencia-title banners-experiencia-title mb-3 mb-md-0">Experiência eora</h3>
            <section class="js-banners-experiencia-eora swiper-wrapper row"></section>
        </div>
        <section class="js-experiencia-sem-banner row"></section>
        <section class="row js-banners-alternados-product py-md-4"></section>
        <!-- SEÇÃO: Banner Grande + Variantes + Fotos + Campanha (óculos) -->
        <div class="js-banner-produto"></div>
        <div class="js-variantes-produto"></div>
        <div class="js-sequencia-fotos-produto"></div>
        <div class="js-texto-campanha-produto"></div>
    </div>
{% endif %}

{# Related products #}
{% include 'snipplets/product/product-related.tpl' %}

{% include 'snipplets/product/product-faq.tpl' %}


<style>
.product-video-container {
    display: flex;
    justify-content: center;
    align-items: center;
    flex-direction: row-reverse;
    margin: 40px auto;
    background-color: transparent;
}

.product-video-container iframe {
    width: 960px; /* aumentado */
    height: 540px;
    border: none;
    display: block;
}

.product-video-description {
    max-width: 775px;
    margin: 0 auto;
    font-size: 1.1rem;
    line-height: 1.8;
    color: #333333e3;
    font-weight: 400;
    padding: 0 35px;
    text-emphasis: justify;
}
/* Responsividade */
@media (max-width: 1342px) {
    .product-video-container {
        flex-direction: column;
        align-items: center;
        gap: 2rem;
    }

    .product-video-container iframe {
        width: 800px;
        height: 450px;
    }

    .product-video-description {
        font-size: 1rem;
        line-height: 1.6;
        padding: 0 15px;
    }
}

/* =============================================
   BANNER PRODUTO (óculos / novo layout)
============================================= */
.js-banner-produto:not(:empty) {
    display: flex;
    align-items: center;
    justify-content: center;
    gap: 60px;
    padding: 60px 20px;
    max-width: 1200px;
    margin: 0 auto;
}
.banner-produto-img img {
    max-width: 380px;
    width: 100%;
    display: block;
}
.banner-produto-info {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 6px;
}
.banner-produto-texto-1 {
    font-size: 11px;
    letter-spacing: 3px;
    text-transform: uppercase;
    color: #999;
    margin: 0;
}
.banner-produto-texto-2 {
    font-size: 26px;
    font-weight: bold;
    letter-spacing: 1px;
    text-transform: uppercase;
    color: #000;
    margin: 4px 0;
}
.banner-produto-texto-3 {
    font-size: 13px;
    color: #555;
    margin: 0;
}
.banner-produto-texto-4 {
    font-size: 15px;
    color: #000;
    font-weight: 500;
    margin: 6px 0;
}
.banner-produto-btn {
    display: inline-block;
    margin-top: 20px;
    padding: 12px 36px;
    background: #000;
    color: #fff;
    text-decoration: none;
    font-weight: bold;
    letter-spacing: 2px;
    font-size: 12px;
    text-transform: uppercase;
    border: 2px solid #000;
    transition: background 0.2s, color 0.2s;
}
.banner-produto-btn:hover {
    background: #fff;
    color: #000;
}

/* =============================================
   VARIANTES PRODUTO
============================================= */
.js-variantes-produto:not(:empty) {
    padding: 40px 20px;
    max-width: 1200px;
    margin: 0 auto;
}
.variantes-titulo {
    font-size: 11px;
    letter-spacing: 3px;
    text-transform: uppercase;
    color: #999;
    text-align: center;
    margin-bottom: 24px;
}
.variantes-produto-grid {
    display: flex;
    gap: 16px;
    justify-content: center;
    flex-wrap: wrap;
}
.variante-item {
    display: flex;
    flex-direction: column;
    align-items: center;
    gap: 8px;
    cursor: pointer;
}
.variante-img img {
    width: 180px;
    height: auto;
    border: 1px solid #eee;
    transition: border-color 0.2s;
}
.variante-img img:hover {
    border-color: #000;
}
.variante-nome {
    font-size: 11px;
    color: #555;
    text-align: center;
    margin: 0;
    letter-spacing: 1px;
}

/* =============================================
   SEQUÊNCIA 3 FOTOS
============================================= */
.js-sequencia-fotos-produto:not(:empty) {
    padding: 20px 0;
}
.sequencia-fotos-grid {
    display: flex;
    gap: 0;
    justify-content: center;
    align-items: stretch;
}
.sequencia-foto-item {
    flex: 1;
    overflow: hidden;
}
.sequencia-foto-item img {
    width: 100%;
    height: 100%;
    object-fit: cover;
    display: block;
}

/* =============================================
   TEXTO CAMPANHA
============================================= */
.js-texto-campanha-produto:not(:empty) {
    padding: 60px 20px;
    max-width: 800px;
    margin: 0 auto;
}
.texto-campanha-content {
    display: flex;
    flex-direction: column;
    align-items: flex-start;
    gap: 16px;
}
.texto-campanha-texto {
    font-size: 14px;
    line-height: 1.9;
    color: #333;
    margin: 0;
}
.texto-campanha-assinatura {
    font-size: 12px;
    color: #999;
    font-style: italic;
    margin: 0;
    letter-spacing: 1px;
}

/* RESPONSIVO */
@media (max-width: 767px) {
    .js-banner-produto:not(:empty) {
        flex-direction: column;
        text-align: center;
        gap: 28px;
        padding: 40px 16px;
    }
    .banner-produto-info {
        align-items: center;
    }
    .variante-img img { width: 130px; }
    .sequencia-fotos-grid { flex-direction: column; }
    .js-texto-campanha-produto:not(:empty) {
        padding: 40px 16px;
    }
}
</style>
