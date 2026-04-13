{# product-description.tpl ---------------------------------------------------- #}

{% set desc_html = product.description|default('') %}

{# checagem simples e compatível #}
{% set has_hr_tag = '<hr' in desc_html|lower %}
{% set has_h2_tag = '<h2' in desc_html|lower %}
{% set is_structured = has_hr_tag and has_h2_tag %}

{# classes do container ------------------------------------------------------- #}
{% set container_cls = (not is_structured ? 'mt-2 mt-md-0' : '')
                    ~ (settings.full_width_description ? 'pt-md-3' : '')
                    ~ ' pb-md-3' %}

<div id="product-description" class="{{ container_cls|trim }}"
    data-store="product-description-{{ product.id }}"
    {% if is_structured %}data-structured="true"{% endif %}>

    {# descrição “crua” – o JS só entra se data-structured="true" #}
    {% if product.description is not empty %}
        <div class="user-content">{{ desc_html|raw }}</div>
    {% endif %}

    {# extras (comentários, share, reviews) ----------------------------------- #}
    {% if settings.show_product_fb_comment_box %}
        <div class="fb-comments section-fb-comments mb-3"
            data-href="{{ product.social_url }}"
            data-num-posts="5"
            data-width="100%"></div>
    {% endif %}
    <div id="reviewsapp"></div>
</div>

{% if settings.show_social_share %}
    {% include 'snipplets/social/social-share.tpl' %}
{% endif %}

