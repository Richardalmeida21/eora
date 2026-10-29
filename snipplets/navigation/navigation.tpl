{% if params.menu_revision == '1' %}
    {% include 'snipplets/navigation/eora-menu-next.tpl' with {mode: 'desktop'} %}
{% else %}
    {% include 'snipplets/navigation/eora-menu.tpl' with {mode: 'desktop'} %}
{% endif %}
