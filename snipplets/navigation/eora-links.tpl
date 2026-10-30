{% macro url(key, fallback, settings) %}{{- attribute(settings, 'eora_menu_' ~ key ~ '_url') | default(fallback) | setting_url -}}{% endmacro %}

{% macro primary(settings) %}
    {% import 'snipplets/navigation/eora-links.tpl' as links %}
    <a href="{{ links.url('best', '/best-sellers1/', settings) | trim }}">{{ settings.eora_menu_best_label | default('Best Sellers') }}</a>
    <a href="{{ links.url('about', '/sobre1/', settings) | trim }}">{{ settings.eora_menu_about_label | default('Sobre') }}</a>
    <a href="{{ links.url('shopper', '/personal-shopper/', settings) | trim }}">{{ settings.eora_menu_shopper_label | default('Personal Shopper') }}</a>
{% endmacro %}

{% macro mobile(settings, groups, shortcuts) %}
    {% import 'snipplets/navigation/eora-links.tpl' as links %}
    {% set defaults = ['shop', 'favorites', 'warranty', 'new', 'community', 'best', 'about', 'shopper'] %}
    {% set order = [] %}
    {% for position in 1..8 %}
        {% set item = attribute(settings, 'eora_mobile_menu_order_' ~ position) %}
        {% if item in defaults and item not in order %}{% set order = order | merge([item]) %}{% endif %}
    {% endfor %}
    {% for item in defaults %}
        {% if item not in order %}{% set order = order | merge([item]) %}{% endif %}
    {% endfor %}
    {% for item in order %}
        {% if shortcuts %}
            {% if item == 'best' %}<a href="{{ links.url('best', '/best-sellers1/', settings) | trim }}">{{ settings.eora_menu_best_label | default('Best Sellers') }}</a>{% endif %}
            {% if item == 'about' %}<a href="{{ links.url('about', '/sobre1/', settings) | trim }}">{{ settings.eora_menu_about_label | default('Sobre') }}</a>{% endif %}
            {% if item == 'shopper' %}<a href="{{ links.url('shopper', '/personal-shopper/', settings) | trim }}">{{ settings.eora_menu_shopper_label | default('Personal Shopper') }}</a>{% endif %}
        {% else %}
            {% for group in groups %}
                {% if item == group.key %}<button type="button" data-menu-go="{{ group.key }}" aria-expanded="false">{{ attribute(settings, 'eora_menu_' ~ group.key ~ '_title') | default(group.title) }}<span aria-hidden="true">›</span></button>{% endif %}
            {% endfor %}
        {% endif %}
    {% endfor %}
{% endmacro %}

{% macro children(items, settings) %}
    {% import 'snipplets/navigation/eora-links.tpl' as links %}
    <ul class="eora-menu__links">
        {% for item in items %}
            {% set item_label = attribute(settings, 'eora_menu_' ~ item.key ~ '_label') | default(item.label) %}
            {% if item.key == 'repair' and item_label | lower | trim == 'conserto' %}{% set item_label = 'Consertos' %}{% endif %}
            <li><a href="{{ links.url(item.key, item.url, settings) | trim }}">{{ item_label }}</a></li>
        {% endfor %}
    </ul>
{% endmacro %}
