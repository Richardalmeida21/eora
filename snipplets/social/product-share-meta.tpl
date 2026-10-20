{# Preserva o componente nativo (imagem, título, URL, preço etc.).
   Substitui somente as descrições, no HTML enviado aos robôs, sem JavaScript. #}
{% set oe_platform_social_meta = component('social-meta') %}
{% for oe_meta_part in oe_platform_social_meta | split('<meta') %}
    {% if loop.first %}
        {{ oe_meta_part | raw }}
    {% else %}
        {% set oe_meta_head = oe_meta_part | split('>') | first %}
        {% set oe_meta_attributes = oe_meta_head | lower %}
        {% if 'property="og:description"' in oe_meta_attributes or "property='og:description'" in oe_meta_attributes or 'name="twitter:description"' in oe_meta_attributes or "name='twitter:description'" in oe_meta_attributes %}
            {{ oe_meta_part | slice((oe_meta_head | length) + 1) | raw }}
        {% else %}
            <meta{{ oe_meta_part | raw }}
        {% endif %}
    {% endif %}
{% endfor %}
<meta property="og:description" content="{{ oe_share_description | escape }}" />
<meta name="twitter:description" content="{{ oe_share_description | escape }}" />
