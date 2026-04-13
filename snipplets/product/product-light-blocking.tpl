{% set light_blocking_title = settings.light_blocking_title | default('Capacidad de bloqueo de luz') %}
{% set light_blocking_low = settings.light_blocking_low | default('Low') %}
{% set light_blocking_medium = settings.light_blocking_medium | default('Medium') %}
{% set light_blocking_high = settings.light_blocking_high | default('High') %}

{# --- pega o tipo de bloqueio de luz indicator --- #}
{% set light_blocking_type = '' %}
{% for item in product.tags %}
    {% if item matches '/bloqueio-de-luz/' %}
        {% set parts = item|split(':') %}
        {% set type_light_blocking = parts[1]|trim|lower %}
        {% set light_blocking_type = type_light_blocking %}
    {% endif %}
{% endfor %}

{% if light_blocking_type is not empty %}
    <div class="col-12 d-flex flex-column pb-1 mb-2">
        <h5 class="indicator-title mb-3">{{ light_blocking_title | translate }}</h5>
        <div class="indicator-container">
            <div class="indicator-bar {% if light_blocking_type == 'low' %}active{% endif %}">
                <div class="bar"></div>
                <span>{{ light_blocking_low }}</span>
            </div>
            <div class="indicator-bar {% if light_blocking_type == 'medium' %}active{% endif %}">
                <div class="bar"></div>
                <span>{{ light_blocking_medium }}</span>
            </div>
            <div class="indicator-bar {% if light_blocking_type == 'high' %}active{% endif %}">
                <div class="bar"></div>
                <span>{{ light_blocking_high }}</span>
            </div>
        </div>
    </div>
{% endif %}