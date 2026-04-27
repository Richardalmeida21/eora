{#
====================================================================
  CLIENTES EORA — Carrossel de fotos de clientes por produto
--------------------------------------------------------------------
  COMO CADASTRAR (2 formas, escolha a que preferir)

  ► Forma 1 (RECOMENDADA — mais fácil):
    Vá em "Editar produto" → "Imagens" e suba normalmente as fotos
    de clientes. Basta que o NOME DO ARQUIVO comece com:

         eora-cliente-

    Exemplos válidos:
         eora-cliente-ana.jpg
         eora-cliente-01.png
         eora-cliente-praia-verao.jpg

    Pronto. Essas imagens vão aparecer no carrossel "Clientes Eora"
    e serão automaticamente removidas da galeria principal.

  ► Forma 2 (fallback — para casos em que não dá pra renomear):
    Cole na descrição do produto:

         [clientes-eora]
         https://url1.jpg|https://url2.jpg|https://url3.jpg
         [/clientes-eora]

  Se o produto não tiver nem imagens com o prefixo nem o marcador,
  a seção simplesmente não aparece.
====================================================================
#}

{% set _cliente_prefix = 'eora-cliente-' %}
{% set _cliente_images = [] %}

{# === Forma 1: imagens da galeria com prefixo no nome do arquivo === #}
{% for image in product.images %}
    {% set _img_url = image | product_image_url('original') %}
    {% if _cliente_prefix in _img_url %}
        {% set _cliente_images = _cliente_images|merge([image]) %}
    {% endif %}
{% endfor %}

{% set _has_gallery_clients = _cliente_images|length > 0 %}

{# === Forma 2: marcador na descrição (fallback) === #}
{% set _marker_urls = [] %}
{% if not _has_gallery_clients and '[clientes-eora]' in product.description and '[/clientes-eora]' in product.description %}
    {% set _after_open  = product.description|split('[clientes-eora]')|last %}
    {% set _inner_block = _after_open|split('[/clientes-eora]')|first %}
    {% set _clean = _inner_block|striptags %}
    {% set _clean = _clean|replace({'\r': '', '\n': '|'}) %}
    {% for u in _clean|split('|') %}
        {% if u|trim is not empty %}
            {% set _marker_urls = _marker_urls|merge([u|trim]) %}
        {% endif %}
    {% endfor %}
{% endif %}

{% set _has_marker = _marker_urls|length > 0 %}

{% if _has_gallery_clients or _has_marker %}
<section class="clientes-eora-section" data-store="clientes-eora-{{ product.id }}">
    <div class="container">
        <h3 class="clientes-eora-title">Clientes Eora</h3>

        <div class="swiper js-swiper-clientes-eora clientes-eora-swiper">
            <div class="swiper-wrapper">
                {% if _has_gallery_clients %}
                    {% for image in _cliente_images %}
                        <div class="swiper-slide">
                            <div class="clientes-eora-slide">
                                <img src="{{ 'images/empty-placeholder.png' | static_url }}"
                                     data-srcset="{{ image | product_image_url('large') }} 480w, {{ image | product_image_url('huge') }} 800w, {{ image | product_image_url('original') }} 1200w"
                                     data-sizes="auto"
                                     class="lazyautosizes lazyload"
                                     alt="{% if image.alt %}{{ image.alt }}{% else %}Cliente Eora usando {{ product.name }}{% endif %}">
                            </div>
                        </div>
                    {% endfor %}
                {% else %}
                    {% for url in _marker_urls %}
                        <div class="swiper-slide">
                            <div class="clientes-eora-slide">
                                <img src="{{ url }}"
                                     alt="Cliente Eora usando {{ product.name }}"
                                     loading="lazy">
                            </div>
                        </div>
                    {% endfor %}
                {% endif %}
            </div>

            <div class="swiper-pagination js-clientes-eora-pagination"></div>
            <div class="swiper-button-prev js-clientes-eora-prev"></div>
            <div class="swiper-button-next js-clientes-eora-next"></div>
        </div>
    </div>
</section>

<style>
    .clientes-eora-section {
        margin: 60px auto;
        padding: 0 20px;
    }
    .clientes-eora-title {
        text-align: center;
        font-size: 1.4rem;
        letter-spacing: 2px;
        text-transform: uppercase;
        font-weight: 500;
        color: #000;
        margin-bottom: 32px;
    }
    .clientes-eora-swiper {
        position: relative;
        max-width: 1200px;
        margin: 0 auto;
        padding-bottom: 40px;
    }
    .clientes-eora-slide {
        position: relative;
        width: 100%;
        padding-bottom: 125%; /* 4:5 */
        overflow: hidden;
        background: #f5f5f5;
    }
    .clientes-eora-slide img {
        position: absolute;
        top: 0; left: 0;
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: block;
    }
    .clientes-eora-swiper .swiper-button-prev,
    .clientes-eora-swiper .swiper-button-next {
        color: #000;
    }
    .clientes-eora-swiper .swiper-pagination-bullet-active {
        background: #000;
    }
    @media (max-width: 767px) {
        .clientes-eora-section { margin: 40px auto; }
        .clientes-eora-title { font-size: 1.1rem; margin-bottom: 20px; }
        .clientes-eora-swiper .swiper-button-prev,
        .clientes-eora-swiper .swiper-button-next { display: none; }
    }
</style>

<script>
    (function () {
        function initClientesEora() {
            if (typeof Swiper === 'undefined') return false;
            var el = document.querySelector('.js-swiper-clientes-eora');
            if (!el || el.dataset.swiperInit === '1') return true;
            el.dataset.swiperInit = '1';
            new Swiper(el, {
                slidesPerView: 1,
                spaceBetween: 16,
                loop: false,
                pagination: { el: '.js-clientes-eora-pagination', clickable: true },
                navigation: { prevEl: '.js-clientes-eora-prev', nextEl: '.js-clientes-eora-next' },
                breakpoints: {
                    576: { slidesPerView: 2, spaceBetween: 16 },
                    992: { slidesPerView: 3, spaceBetween: 20 }
                }
            });
            return true;
        }
        if (!initClientesEora()) {
            document.addEventListener('DOMContentLoaded', function () {
                var tries = 0;
                var iv = setInterval(function () {
                    tries++;
                    if (initClientesEora() || tries > 20) clearInterval(iv);
                }, 250);
            });
        }
    })();
</script>
{% endif %}
