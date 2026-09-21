{% for banner in settings.bolsas_eora_banners %}
    {% if banner.image %}
        {# Descricao=tag[,todos]. Sem descricao, preserva temporariamente Link=tag e Botao=SIM. #}
        {% set banner_filter = banner.description | default('') | trim %}
        {% set legacy_banner = not banner_filter %}
        {% if legacy_banner %}
            {% set banner_filter = banner.link | default('') | trim %}
        {% endif %}
        {% set show_in_all_value = banner.button | default('') | trim | lower %}
        {% set legacy_show_in_all = legacy_banner and (show_in_all_value == 'sim' or show_in_all_value == 'sí' or show_in_all_value == 'yes' or show_in_all_value == 'true' or show_in_all_value == '1') %}
        <template data-be-banner-template data-be-banner-filter="{{ banner_filter | escape }}" data-be-banner-href="{% if not legacy_banner %}{{ banner.link | default('') | trim | escape }}{% endif %}" data-be-banner-legacy-all="{{ legacy_show_in_all ? 'true' : 'false' }}">
            <figure class="be-catalog-banner{% if banner.color %} be-catalog-banner--{{ banner.color | escape }}{% endif %}" data-be-catalog-banner>
                <div class="be-catalog-banner__body" data-be-banner-body{% if banner.title %} data-be-banner-label="{{ banner.title | escape }}"{% endif %}>
                    {# Usa o arquivo original: o banner pode mudar de largura na grade e nao deve receber uma miniatura ampliada. #}
                    <img src="{{ banner.image | static_url }}" alt="{{ banner.title | default('Bolsas Eora') | escape }}" width="{{ banner.width | default(2000) }}" height="{{ banner.height | default(2600) }}" loading="lazy" decoding="async">
                    {% if banner.title or (banner.button and not legacy_show_in_all) %}
                        <div class="be-catalog-banner__content">
                            {% if banner.title %}<strong>{{ banner.title }}</strong>{% endif %}
                            {% if banner.button and not legacy_show_in_all %}
                                <span class="be-catalog-banner__button">
                                    <span>{{ banner.button }}</span>
                                    <svg aria-hidden="true" viewBox="0 0 10 10" fill="none"><use href="#chevron-diagonal" xlink:href="#chevron-diagonal"></use></svg>
                                </span>
                            {% endif %}
                        </div>
                    {% endif %}
                </div>
            </figure>
        </template>
    {% endif %}
{% endfor %}
