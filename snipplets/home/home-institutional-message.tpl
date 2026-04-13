{% set institutional_text = settings.institutional_text %}
{% set institutional_title = settings.institutional_message %}

{% if institutional_title or institutional_text %}
	{% set institutional_color_classes = settings.institutional_colors ? 'section-institutional-home-colors section-home-color' %}
	{% set institutional_text_classes = settings.institutional_size == 'huge'
		? 'h1-extra-huge-md'
		: settings.institutional_size == 'big'
			? 'h2-extra-huge-md'
			: settings.institutional_size == 'medium'
				? 'h1-huge-md'
				: 'h2-huge-md'
	%}
	{% set institutional_link = settings.institutional_link %}
	{% set institutional_button = settings.institutional_button %}

	<section class="section-home overflow-none my-5{{ institutional_color_classes }}" data-store="home-institutional-message">
		<div class="institutional-container container-fluid">
			<!-- Coluna esquerda -->
			<div class="institutional-left d-flex flex-column">
				{% if institutional_title %}
					<h3 class="institutional-title mb-0">{{ institutional_title }}</h3>
				{% endif %}
				{% if institutional_text %}
					<p class="institutional-text mb-0">{{ institutional_text }}</p>
				{% endif %}
			</div>

			<!-- Coluna direita -->
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

		</div>
	</section>
{% endif %}
