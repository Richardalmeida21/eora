{# Componente Global - Banner Floating Button #}
{# 
Parâmetros aceitos:
- title: Título do botão (string)
- description: Descrição opcional (string) 
- url: URL para redirecionamento (string)
- show_icon: Mostrar ícone chevron (boolean, default: true)
- button_class: Classes CSS adicionais (string)
- wrapper_class: Classes CSS para o wrapper (string)
#}

{% set show_icon = show_icon is defined ? show_icon : true %}
{% set button_class = button_class is defined ? button_class : '' %}
{% set wrapper_class = wrapper_class is defined ? wrapper_class : '' %}

{% if title or description %}
<div class="banner-floating-button {{ button_class }}{% if title and description %} -with-content{% endif %} {{ wrapper_class }}">
    {% if url %}
        <a href="{{ url }}" class="banner-floating-button-link">
    {% endif %}
    
    {% if title or show_icon %}
    <div class="banner-floating-button-content">
        {% if title %}
        <div class="banner-floating-title">{{ title }}</div>
        {% endif %}
        {% if show_icon %}
        <svg class="banner-floating-icon" viewbox="0 0 10 10" fill="none" style="transform: scaleX(-1)">
            <use xlink:href="#chevron-diagonal"></use>
        </svg>
        {% endif %}
    </div>
    {% endif %}
    
    {% if description %}
    <div class="banner-floating-description">{{ description }}</div>
    {% endif %}
    
    {% if url %}
        </a>
    {% endif %}
</div>
{% endif %}