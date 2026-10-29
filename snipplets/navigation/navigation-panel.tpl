{% if primary_links %}
    <div class="nav-primary">
        {% include 'snipplets/navigation/eora-menu.tpl' with {mode: 'mobile'} %}
    </div>
{% else %}
    <div class="nav-secondary text-left" data-store="account-links">
        <div class="p-3">
            {% include "snipplets/header/header-utilities.tpl" with {use_account: true} %}
        </div>
    </div>
{% endif %}
