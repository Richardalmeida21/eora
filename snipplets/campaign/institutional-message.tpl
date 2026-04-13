{# {% set institutional_note = settings.institutional_note %} #}
{% set suffix = '' %}
{% if campaign_message_02 %}
    {% set suffix = '_02' %}
{% elseif campaign_message_03 %}
    {% set suffix = '_03' %}
{% endif %}

{% set institutional_note = attribute(settings,"#{settings_name}" ~ suffix ~ "_note") %}
{# {% set institutional_message = settings.institutional_message %} #}
{% set institutional_message = attribute(settings,"#{settings_name}" ~ suffix ~ "_message") %}
{% set institutional_message_active = attribute(settings,"#{settings_name}" ~ suffix ~ "_message_active") or attribute(settings,"#{settings_name}" ~ suffix ~ "_text_active") %}

{% if (institutional_message or institutional_note) and institutional_message_active %}
	{# {% set institutional_link = settings.institutional_link %} #}
	{% set institutional_link = attribute(settings,"#{settings_name}" ~ suffix ~ "_link") %}
	{# {% set institutional_button = settings.institutional_button %} #}
	{% set institutional_button = attribute(settings,"#{settings_name}" ~ suffix ~ "_button") %}

	<section class="container-fluid campaign-page-message institutional-container">
			<div class="institutional-left d-flex flex-column">
				{% if institutional_message %}
					<h3 class="institutional-title mb-0">{{ institutional_message}}</h3>
				{% endif %}
				{% if institutional_note %}
					<p class="institutional-text mb-0">{{ institutional_note }}</p>
				{% endif %}
			</div>

			{% if institutional_link and institutional_button %}
				<div class="institutional-right">
					<a href="{{ institutional_link }}" class="institutional-link" aria-label="{{ institutional_button }}">
						{{ institutional_button }}
						<svg class="institutional-link-icon icon-inline icon-md">
							<use xlink:href="#chevron"></use>
						</svg>
					</a>
				</div>
			{% endif %}

	</section>
{% endif %}
