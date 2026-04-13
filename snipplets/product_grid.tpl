{% if products and pages.is_last %}
	<div class="last-page" style="display:none;"></div>
{% endif %}
{% for product in products %}
    {# {% if loop.first %}
        {% include 'snipplets/grid/item.tpl' with {'first_imagem': true} %}    
    {% endif %}#}
    {% include 'snipplets/grid/item.tpl' %}
{% endfor %}