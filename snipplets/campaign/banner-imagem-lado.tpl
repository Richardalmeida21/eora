<style>

@media (max-width: 1023px){
	.hidden-mobile{
		display: none;
	}
	.content-image.style_video_height{
		height: 116vw;
	}
}

@media (min-width: 1024px){
	.hidden-desktop{
		display: none;
	}
	.content-image.style_video_height{
		height: 40.25vw;
	}
}

</style>

{% if image_right_desktop %}
	{% set campaign_banner_lado_active = attribute(settings,"#{settings_name}_banner_lado_active") %}
	{% set campaign_banner_lado_title = attribute(settings,"#{settings_name}_banner_lado_title") %}
	{% set campaign_banner_lado_text = attribute(settings,"#{settings_name}_banner_lado_text") %}
	{% set campaign_banner_lado_button = attribute(settings,"#{settings_name}_banner_lado_button") %}
	{% set campaign_banner_lado_url = attribute(settings,"#{settings_name}_banner_lado_url") %}

	{% set campaign_banner_lado_url_video = attribute(settings,"#{settings_name}_banner_lado_url_video") %}
	{% set campaign_banner_lado_url_video_mobile = attribute(settings,"#{settings_name}_banner_lado_url_video_mobile") %}

	{% set campaign_banner_show_image = attribute(settings,"#{settings_name}_banner_visibility") %}

	{% set campaign_banner_lado_img = settings_name ~ '_banner_lado_img.jpg' %}
	{% set campaign_banner_lado_img_mobile = settings_name ~ '_banner_lado_img_mobile.jpg' %}
	{# {% set campaign_banner_lado_mobile_img = settings_name ~ '_banner_lado_mobile_img.jpg' %} #}
	{% set campaign_banner_lado_autoplay = true %}
{% endif %}
{% if image_left_desktop %}
	{% set campaign_banner_lado_active = attribute(settings,"#{settings_name}_02_banner_lado_active") %}
	{% set campaign_banner_lado_title = attribute(settings,"#{settings_name}_02_banner_lado_title") %}
	{% set campaign_banner_lado_text = attribute(settings,"#{settings_name}_02_banner_lado_text") %}
	{% set campaign_banner_lado_button = attribute(settings,"#{settings_name}_02_banner_lado_button") %}
	{% set campaign_banner_lado_url = attribute(settings,"#{settings_name}_02_banner_lado_url") %}

	{% set campaign_banner_lado_url_video = attribute(settings,"#{settings_name}_02_banner_lado_url_video") %}
	{% set campaign_banner_lado_url_video_mobile = attribute(settings,"#{settings_name}_02_banner_lado_url_video_mobile") %}
	{% set campaign_banner_lado_autoplay = true %}

	
	{% set campaign_banner_show_image = attribute(settings,"#{settings_name}_02_banner_visibility") %}
	{% set campaign_banner_lado_img = settings_name ~ '_02_banner_lado_img.jpg' %}
	{% set campaign_banner_lado_img_mobile = settings_name ~ '_02_banner_lado_img_mobile.jpg' %}
	{# {% set campaign_banner_lado_mobile_img = settings_name ~ '_banner_lado_mobile_img.jpg' %} #}
{% endif %}

{% if image_right_desktop_03 %}
	{% set campaign_banner_lado_active = attribute(settings,"#{settings_name}_03_banner_lado_active") %}
	{% set campaign_banner_lado_title = attribute(settings,"#{settings_name}_03_banner_lado_title") %}
	{% set campaign_banner_lado_text = attribute(settings,"#{settings_name}_03_banner_lado_text") %}
	{% set campaign_banner_lado_button = attribute(settings,"#{settings_name}_03_banner_lado_button") %}
	{% set campaign_banner_lado_url = attribute(settings,"#{settings_name}_03_banner_lado_url") %}

	{% set campaign_banner_lado_url_video = attribute(settings,"#{settings_name}_03_banner_lado_url_video") %}
	{% set campaign_banner_lado_url_video_mobile = attribute(settings,"#{settings_name}_03_banner_lado_url_video_mobile") %}
	{% set campaign_banner_lado_autoplay = true %}

	{% set campaign_banner_show_image = attribute(settings,"#{settings_name}_03_banner_visibility") %}
	{% set campaign_banner_lado_img = settings_name ~ '_03_banner_lado_img.jpg' %}
	{% set campaign_banner_lado_img_mobile = settings_name ~ '_03_banner_lado_img_mobile.jpg' %}
	{# {% set campaign_banner_lado_mobile_img = settings_name ~ '_banner_lado_mobile_img.jpg' %} #}
{% endif %}

{% if image_left_desktop_04 %}
	{% set campaign_banner_lado_active = attribute(settings, "#{settings_name}_04_banner_lado_active") %}
	{% set campaign_banner_lado_title = attribute(settings, "#{settings_name}_04_banner_lado_title") %}
	{% set campaign_banner_lado_text = attribute(settings, "#{settings_name}_04_banner_lado_text") %}
	{% set campaign_banner_lado_button = attribute(settings, "#{settings_name}_04_banner_lado_button") %}
	{% set campaign_banner_lado_url = attribute(settings, "#{settings_name}_04_banner_lado_url") %}

	{% set campaign_banner_lado_url_video = attribute(settings, "#{settings_name}_04_banner_lado_url_video") %}
	{% set campaign_banner_lado_url_video_mobile = attribute(settings, "#{settings_name}_04_banner_lado_url_video_mobile") %}
	{% set campaign_banner_lado_autoplay = true %}

	{% set campaign_banner_show_image = attribute(settings,"#{settings_name}_04_banner_visibility") %}
	{% set campaign_banner_lado_img = settings_name ~ '_04_banner_lado_img.jpg' %}
	{% set campaign_banner_lado_img_mobile = settings_name ~ '_04_banner_lado_img_mobile.jpg' %}
{% endif %}

{% if campaign_banner_lado_active %}
	<section class="section-banner-imagem-lado my-3 my-md-4">
		<div class="container-fluid">
			<div class="row">
				<div class="col-12 col-md-6" style="display: grid; align-items: center;">
				{% if campaign_banner_show_image %}
					{% set desktop_image = campaign_banner_lado_img | static_url | settings_image_url('1080p') %}
					{% set mobile_image = campaign_banner_lado_img_mobile | static_url | settings_image_url('1080p') %}

					<picture class="banner-full__image">
						<source media="(max-width: 767px)" srcset="{% if 'cdn-us.mitiendanube' in mobile_image %}{{ mobile_image }}{% else %}https://placehold.co/375x600{% endif %}">
						<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{% if 'cdn-us.mitiendanube' in desktop_image %}{{ desktop_image }}{% else %}https://placehold.co/905x780{% endif %}" class="lazyload w-100 h-auto d-block" loading="lazy" alt="{{ settings.banner_id_title|default('Banner') }}">
					</picture>
				
				{% else %}
					<div class="content-image style_video_height">
						<div class="banner-full__video hidden-mobile">
								{% set partes = campaign_banner_lado_url_video|split('/') %}
								{% set num_partes = partes|length %}
								{% set vimeo_id = '' %}

								{% if num_partes >= 5 %}
									{# Cenário com hash: 1133497728/e9b7412794 (5 ou mais partes) #}
									{% set id = partes[num_partes - 2] %}
									{% set hash = partes|last %}
									{% set vimeo_id = id ~ '?h=' ~ hash %}
								{% elseif num_partes == 4 %}
									{# Cenário sem hash: 1131913524 (4 partes) #}
									{% set vimeo_id = partes|last %}
								{% endif %}
								<iframe 
									src="https://player.vimeo.com/video/{{ vimeo_id }}{% if "?h=" in vimeo_id %}&{% else %}?{% endif %}background=1&autoplay=1&loop=1&byline=0&title=0&muted=1&controls=0" 
									frameborder="0" 
									allow="autoplay; fullscreen" 
									allowfullscreen
									style="
										position: absolute;
										top: 0;
										left: 0;
										height: 40.25vw;
										width: 100%;
									"
								></iframe>
								{# {% include "snipplets/home/video-full-banner.tpl" %} #}
						</div>
						{# Mobile Video #}
						<div class="banner-full__video hidden-desktop">
								{% set partes = campaign_banner_lado_url_video_mobile|split('/') %}
								{% set num_partes = partes|length %}
								{% set vimeo_id = '' %}

								{% if num_partes >= 5 %}
									{# Cenário com hash: 1133497728/e9b7412794 (5 ou mais partes) #}
									{% set id = partes[num_partes - 2] %}
									{% set hash = partes|last %}
									{% set vimeo_id = id ~ '?h=' ~ hash %}
								{% elseif num_partes == 4 %}
									{# Cenário sem hash: 1131913524 (4 partes) #}
									{% set vimeo_id = partes|last %}
								{% endif %}
							<iframe 
									src="https://player.vimeo.com/video/{{ vimeo_id }}{% if "?h=" in vimeo_id %}&{% else %}?{% endif %}background=1&autoplay=1&loop=1&byline=0&title=0&muted=1&controls=0" 
									frameborder="0" 
									allow="autoplay; fullscreen" 
									allowfullscreen
									style="
										position: absolute;
										top: 0;
										left: 0;
										height: 116vw;
										width: 100%;
									"
								></iframe>
						</div>
					</div>
				{% endif %}
				</div>

				<div class="col-12 col-md-6 wrapper-content-text d-flex align-items-center {% if image_right_desktop or image_right_desktop_03 %}order-md-first{% endif %}">
					<div class="content-text w-100">
						{% if campaign_banner_lado_title or campaign_banner_lado_text %}
							<div>
								{% if campaign_banner_lado_title %}
									<h2 class="title-franqueado">{{campaign_banner_lado_title}}</h2>
								{% endif %}
								{% if campaign_banner_lado_text %}
									<div class="text-campaign">{{campaign_banner_lado_text | raw }}</div>
								{% endif %}
							</div>

						{% endif %}

						{% if campaign_banner_lado_button and campaign_banner_lado_url %}
							<a href="{{campaign_banner_lado_url}}" class="btn-campaign btn-primary w-100">
								{{campaign_banner_lado_button}}
							</a>
						{% endif %}
					</div>
				</div>
			</div>
		</div>
	</section>
{% endif %}
