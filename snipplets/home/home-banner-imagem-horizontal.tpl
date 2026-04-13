{% set padding_bottom = 48 %}
{% set width_desktop = settings.banner_horizontal_width_desktop %}
{% set height_desktop = settings.banner_horizontal_height_desktop %}
{% set width_mobile = settings.banner_horizontal_width_mobile %}
{% set height_mobile = settings.banner_horizontal_height_mobile %}

{% if width_desktop > 0 and height_desktop > 0 and not mobile %}
	{% set padding_bottom = (height_desktop / width_desktop) * 100 %}
{% endif %}
{% if width_mobile > 0 and height_mobile > 0 and mobile %}
	{% set padding_bottom = (height_mobile / width_mobile) * 100 %}
{% endif %}

<div class="banner-imagem-horizontal container-fluid my-5">
	{% if settings.banner_horizontal_url != '' %}
		<a href="{{ settings.banner_horizontal_url }}">
		{% endif %}

		{% if mobile %}
			<figure class="image -custom d-md-none" style="--padding-bottom-banner-horizontal: {{ padding_bottom }}%">
				<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ "banner_horizontal_image_mobile.jpg" | static_url | settings_image_url("original") }} 1024w, {{ "banner_horizontal_image_mobile.jpg" | static_url | settings_image_url("1080p") }} 1920w' class='lazyload'/>
				<div class="banner-floating-wrapper">
					{% include 'snipplets/banner-floating-button.tpl' with {
						'title': settings.banner_horizontal_button_text_title,
						'description': settings.banner_horizontal_button_text_description,
						'url': null
					} %}
				</div>
			</figure>

		{% else %}
			<figure class="image -custom d-none d-md-flex" style="--padding-bottom-banner-horizontal: {{ padding_bottom }}%">
				<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ "banner_horizontal_image.jpg" | static_url | settings_image_url("original") }} 1024w, {{ "banner_horizontal_image.jpg" | static_url | settings_image_url("1080p") }} 1920w' class='lazyload'/>
				<div class="banner-floating-wrapper">
					{% include 'snipplets/banner-floating-button.tpl' with {
						'title': settings.banner_horizontal_button_text_title,
						'description': settings.banner_horizontal_button_text_description,
						'url': null
					} %}
				</div>
			</figure>
		{% endif %}

		{% if settings.banner_horizontal_url != '' %}
		</a>
	{% endif %}
</div>
