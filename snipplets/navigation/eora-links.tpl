{% macro url(key, fallback, settings) %}{{- attribute(settings, 'eora_menu_' ~ key ~ '_url') | default(fallback) | setting_url -}}{% endmacro %}

{% macro primary(settings) %}
    {% import 'snipplets/navigation/eora-links.tpl' as links %}
    <a href="{{ links.url('best', '/best-sellers1/', settings) | trim }}">{{ settings.eora_menu_best_label | default('Best Sellers') }}</a>
    <a href="{{ links.url('about', '/sobre1/', settings) | trim }}">{{ settings.eora_menu_about_label | default('Sobre') }}</a>
    <a href="{{ links.url('shopper', '/personal-shopper/', settings) | trim }}">{{ settings.eora_menu_shopper_label | default('Personal Shopper') }}</a>
{% endmacro %}

{% macro children(items, settings) %}
    {% import 'snipplets/navigation/eora-links.tpl' as links %}
    <ul class="eora-menu__links">
        {% for item in items %}
            <li><a href="{{ links.url(item.key, item.url, settings) | trim }}">{{ attribute(settings, 'eora_menu_' ~ item.key ~ '_label') | default(item.label) }}</a></li>
        {% endfor %}
    </ul>
{% endmacro %}
