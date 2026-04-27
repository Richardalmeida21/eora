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
    <div class="clientes-eora-inner">
        <h3 class="clientes-eora-title">Clientes Eora</h3>

        <div class="clientes-eora-carousel">
            <button type="button"
                    class="clientes-eora-arrow clientes-eora-arrow-prev js-clientes-eora-prev"
                    aria-label="Anterior">
                <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="15 18 9 12 15 6"></polyline></svg>
            </button>

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
            </div>

            <button type="button"
                    class="clientes-eora-arrow clientes-eora-arrow-next js-clientes-eora-next"
                    aria-label="Próximo">
                <svg viewBox="0 0 24 24" width="18" height="18" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><polyline points="9 18 15 12 9 6"></polyline></svg>
            </button>
        </div>
    </div>
</section>

<style>
    .clientes-eora-section {
        width: 100%;
        margin: 60px 0;
        padding: 0;
        overflow: hidden; /* evita que slides "vazem" pra direita */
        box-sizing: border-box;
    }
    .clientes-eora-section *,
    .clientes-eora-section *::before,
    .clientes-eora-section *::after {
        box-sizing: border-box;
    }
    .clientes-eora-inner {
        max-width: 1200px;
        margin: 0 auto;
        padding: 0 20px;
    }
    .clientes-eora-title {
        text-align: center;
        font-size: 1.4rem;
        letter-spacing: 2px;
        text-transform: uppercase;
        font-weight: 500;
        color: #000;
        margin: 0 0 32px;
    }
    /* Wrapper relativo para posicionar as setas fora do .swiper */
    .clientes-eora-carousel {
        position: relative;
        width: 100%;
    }
    .clientes-eora-swiper {
        position: relative;
        width: 100%;
        max-width: 100%;
        margin: 0 auto;
        padding-bottom: 40px; /* espaço pra paginação */
        overflow: hidden;
    }
    .clientes-eora-swiper .swiper-wrapper {
        align-items: stretch;
    }
    .clientes-eora-swiper .swiper-slide {
        height: auto;
    }
    .clientes-eora-slide {
        position: relative;
        width: 100%;
        padding-bottom: 125%; /* proporção 4:5 */
        overflow: hidden;
        background: #f5f5f5;
    }
    .clientes-eora-slide img {
        position: absolute;
        top: 0;
        left: 0;
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: block;
    }
    /* Setas customizadas (fora do .swiper para não serem cortadas) */
    .clientes-eora-arrow {
        position: absolute;
        top: 50%;
        transform: translateY(-50%);
        z-index: 5;
        width: 44px;
        height: 44px;
        border-radius: 50%;
        border: 1px solid #000;
        background: #fff;
        color: #000;
        cursor: pointer;
        display: flex;
        align-items: center;
        justify-content: center;
        padding: 0;
        transition: background .2s ease, color .2s ease, opacity .2s ease;
        margin-top: -20px; /* compensa o padding-bottom da paginação */
    }
    .clientes-eora-arrow:hover {
        background: #000;
        color: #fff;
    }
    .clientes-eora-arrow:focus { outline: none; }
    .clientes-eora-arrow.swiper-button-disabled {
        opacity: .35;
        cursor: default;
    }
    .clientes-eora-arrow-prev { left: -8px; }
    .clientes-eora-arrow-next { right: -8px; }
    /* Paginação */
    .clientes-eora-swiper .swiper-pagination {
        bottom: 0;
    }
    .clientes-eora-swiper .swiper-pagination-bullet-active {
        background: #000;
    }
    /* Tablet */
    @media (max-width: 991px) {
        .clientes-eora-inner { padding: 0 16px; }
        .clientes-eora-arrow { width: 38px; height: 38px; }
        .clientes-eora-arrow-prev { left: 4px; }
        .clientes-eora-arrow-next { right: 4px; }
    }
    /* Mobile */
    @media (max-width: 767px) {
        .clientes-eora-section { margin: 40px 0; }
        .clientes-eora-inner { padding: 0 12px; }
        .clientes-eora-title { font-size: 1.1rem; margin-bottom: 20px; }
        .clientes-eora-arrow { width: 34px; height: 34px; }
        .clientes-eora-arrow-prev { left: 0; }
        .clientes-eora-arrow-next { right: 0; }
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
                watchOverflow: true,
                centerInsufficientSlides: true,
                observer: true,
                observeParents: true,
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
