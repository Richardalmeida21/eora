{% if primary_links %}
    <div class="nav-primary">
        {% if params.menu_revision == '1' %}
            {% include 'snipplets/navigation/eora-menu-next.tpl' with {mode: 'mobile'} %}
        {% else %}
            {% include 'snipplets/navigation/eora-menu.tpl' with {mode: 'mobile'} %}
        {% endif %}
    </div>
{% else %}
    <div class="nav-secondary text-left" data-store="account-links">
        <div class="p-3">
            {% include "snipplets/header/header-utilities.tpl" with {use_account: true} %}
        </div>
    </div>
{% endif %}
