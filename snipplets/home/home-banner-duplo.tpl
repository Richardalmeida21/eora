{#
====================================================================
  BANNER DUPLO — Dois banners lado a lado (50/50)
--------------------------------------------------------------------
  Configurado via painel: "Banner Duplo"
  Desktop: side-by-side | Mobile: empilhados
====================================================================
#}

{% set bd1_image = settings.banner_duplo_1_image %}
{% set bd1_link  = settings.banner_duplo_1_link %}
{% set bd1_label = settings.banner_duplo_1_label %}

{% set bd2_image = settings.banner_duplo_2_image %}
{% set bd2_link  = settings.banner_duplo_2_link %}
{% set bd2_label = settings.banner_duplo_2_label %}

{% if settings.banner_duplo_show and (bd1_image or bd2_image) %}

<section class="section-home section-banner-duplo"
         data-store="home-banner-duplo"
         data-transition="fade-in">
    <div class="banner-duplo-wrapper">

        {# --- Banner 1 --- #}
        {% if bd1_image %}
            <{% if bd1_link %}a href="{{ bd1_link | setting_url }}"{% else %}div{% endif %}
               class="banner-duplo-item">
                <div class="banner-duplo-image">
                    <img src="{{ 'images/empty-placeholder.png' | static_url }}"
                         data-src="{{ bd1_image | static_url | settings_image_url('huge') }}"
                         data-srcset="{{ bd1_image | static_url | settings_image_url('large') }} 640w, {{ bd1_image | static_url | settings_image_url('huge') }} 960w, {{ bd1_image | static_url | settings_image_url('original') }} 1280w"
                         data-sizes="auto"
                         class="lazyautosizes lazyload"
                         alt="{% if bd1_label %}{{ bd1_label }}{% else %}Banner 1{% endif %}">
                </div>
                {% if bd1_label %}
                    <div class="banner-duplo-label">{{ bd1_label }}</div>
                {% endif %}
            </{% if bd1_link %}a{% else %}div{% endif %}>
        {% endif %}

        {# --- Banner 2 --- #}
        {% if bd2_image %}
            <{% if bd2_link %}a href="{{ bd2_link | setting_url }}"{% else %}div{% endif %}
               class="banner-duplo-item">
                <div class="banner-duplo-image">
                    <img src="{{ 'images/empty-placeholder.png' | static_url }}"
                         data-src="{{ bd2_image | static_url | settings_image_url('huge') }}"
                         data-srcset="{{ bd2_image | static_url | settings_image_url('large') }} 640w, {{ bd2_image | static_url | settings_image_url('huge') }} 960w, {{ bd2_image | static_url | settings_image_url('original') }} 1280w"
                         data-sizes="auto"
                         class="lazyautosizes lazyload"
                         alt="{% if bd2_label %}{{ bd2_label }}{% else %}Banner 2{% endif %}">
                </div>
                {% if bd2_label %}
                    <div class="banner-duplo-label">{{ bd2_label }}</div>
                {% endif %}
            </{% if bd2_link %}a{% else %}div{% endif %}>
        {% endif %}

    </div>
</section>

<style>
    .section-banner-duplo { margin: 0; padding: 0; box-sizing: border-box; }
    .section-banner-duplo *,
    .section-banner-duplo *::before,
    .section-banner-duplo *::after { box-sizing: border-box; }

    .banner-duplo-wrapper {
        display: flex;
        gap: 4px;
        width: 100%;
        align-items: stretch;
    }
    .banner-duplo-item {
        flex: 1 1 50%;
        position: relative;
        overflow: hidden;
        display: block;
        text-decoration: none;
        color: inherit;
        background: #f5f5f5;
    }
    .banner-duplo-image {
        position: relative;
        width: 100%;
        padding-bottom: 125%; /* 4:5 */
        overflow: hidden;
    }
    .banner-duplo-image img {
        position: absolute;
        inset: 0;
        width: 100%;
        height: 100%;
        object-fit: cover;
        display: block;
        transition: transform .4s ease;
    }
    a.banner-duplo-item:hover .banner-duplo-image img {
        transform: scale(1.03);
    }
    .banner-duplo-label {
        position: absolute;
        bottom: 20px;
        left: 20px;
        color: #fff;
        font-size: .8rem;
        font-weight: 500;
        letter-spacing: 2px;
        text-transform: uppercase;
        background: rgba(255,255,255,.15);
        backdrop-filter: blur(6px);
        -webkit-backdrop-filter: blur(6px);
        border: 1px solid rgba(255,255,255,.35);
        padding: 7px 14px;
        border-radius: 3px;
    }
    @media (max-width: 767px) {
        .banner-duplo-wrapper { flex-direction: column; gap: 2px; }
        .banner-duplo-item { flex: 1 1 100%; }
        .banner-duplo-image { padding-bottom: 100%; }
        .banner-duplo-label { bottom: 14px; left: 14px; font-size: .72rem; padding: 5px 11px; }
    }
</style>

{% endif %}
