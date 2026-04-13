{% if product.variations and not color_by_tags %}
    {% set own_color_variants = 0 %}
    {% set custom_color_variants = 0 %}

    {% for variation in product.variations %}
        <div class="js-color-variant-available-{{ loop.index }} {% if variation.name in ['Color', 'Cor'] %}js-color-variant-active{% endif %}" data-value="variation_{{ loop.index }}" data-option="{{ loop.index0 }}" >
            {% if variation.name in ['Color', 'Cor'] %}
                {% if variation.options | length > 1 %}
                    <div class="item-colors d-flex pb-1 mb-2">
                        {% for option in variation.options | take(3) if option.custom_data %}
                            <span title="{{ option.name }}" data-option="{{ option.id }}" data-variation-id="{{ variation.id }}" class="js-color-variant item-colors-bullet" style="background: {{ option.custom_data }}"></span>
                        {% endfor %}

                        {% for option in variation.options %}
                            {% if option.custom_data %}
                                {# Quantity of our colors #}
                                {% set own_color_variants = own_color_variants + 1 %}
                            {% else %}
                                {# Quantity of custom colors #}
                                {% set custom_color_variants = custom_color_variants + 1 %}
                            {% endif %}
                        {% endfor %}

                        {% set more_color_variants = (own_color_variants - 3) + custom_color_variants %}

                        {% if own_color_variants and custom_color_variants %}
                            <span class="item-colors-bullet item-colors-bullet-more w-auto" title="{{ 'Ver más colores' | translate }}">
                                {% if own_color_variants > 3 %}
                                    +{{ more_color_variants }}
                                {% else %}
                                    +{{ custom_color_variants }}
                                {% endif %}
                            </span>
                        {% elseif own_color_variants > 3 %}
                            <span class="item-colors-bullet item-colors-bullet-more w-auto" title="{{ 'Ver más colores' | translate }}">+{{ own_color_variants - 3 }}</span>
                        {% elseif custom_color_variants %}
                            <span class="item-colors-bullet item-colors-bullet-more w-auto px-2" title="{{ 'Ver más colores' | translate }}">{{ custom_color_variants }} {{ 'colores' | translate }}</span>
                        {% endif %}
                    </div>
                {% endif %}
            {% endif %}
        </div>
    {% endfor %}
{% endif %}

{% if color_by_tags %}
    <div class="wrapper-variant-colors d-flex">
        {% if product_color %}
            {% set parts  = product_color|split(':') %}
            {% set colors  = parts[1]|split('-') %}
            {% set qtd_colors = colors|length %}

            {# gera um gradiente conforme a quantidade de colors #}
            {% if qtd_colors == 1 %}
                {# só 1 cor → fundo sólido #}
                {% set bg_product = colors[0] %}
            {% elseif qtd_colors == 2 %}
                {# duas colors → gradiente entre elas #}
                {% set bg_product = 'linear-gradient(180deg,' ~ colors[0] ~ ',' ~ colors[1] ~ ')' %}
            {% elseif qtd_colors >= 3 %}
                {# 3 ou mais colors → gradiente com todas #}
                {% set bg_product = 'linear-gradient(180deg,' ~ colors|join(',') ~ ')' %}
            {% endif %}

            {% if bg_product %}
                <div class="color-variant-available color-variant active" data-value="variation">
                    {# <div class="item-colors"> #}
                        <span title="cor {{ bg_product }}" class="js-color-variant item-colors-bullet" style="background: {{ bg_product }};"></span>
                    </div>
                {# </div> #}
            {% endif %}
        {% endif %}

        {% for tag_color in array_tags_colors %}
            {# separa #}
            {% set parts  = tag_color|split(':') %}
            {% set colors  = parts[1]|split('-') %}
            {% set qtd_colors = colors|length %}

            {# gera um gradiente conforme a quantidade de colors #}
            {% if qtd_colors == 1 %}
                {# só 1 cor → fundo sólido #}
                {% set bg = colors[0] %}
            {% elseif qtd_colors == 2 %}
                {# duas colors → gradiente entre elas #}
                {% set bg = 'linear-gradient(180deg,' ~ colors[0] ~ ',' ~ colors[1] ~ ')' %}
            {% elseif qtd_colors >= 3 %}
                {# 3 ou mais colors → gradiente com todas #}
                {% set bg = 'linear-gradient(180deg,' ~ colors|join(',') ~ ')' %}
            {% endif %}

            <div class="js-color-variant-available-{{ loop.index }} color-variant" data-value="variation_{{ loop.index }}" data-option="{{ loop.index0 }}" >
                {# <div class="item-colors"> #}
                    <span title="cor {{ bg }}" class="js-color-variant item-colors-bullet" style="background: {{ bg }};"></span>
                {# </div> #}
            </div>
        {% endfor %}
    </div>
{% endif %}
