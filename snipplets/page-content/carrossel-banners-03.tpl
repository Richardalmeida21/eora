{% set sliders_imgs_active = attribute(settings,"#{settings_name}_sliders_imgs_active_terceiro") %}
{% set sliders_imgs = attribute(settings,"#{settings_name}_sliders_imgs_terceiro") %}
{% set sliders_imgs_format = attribute(settings,"#{settings_name}_sliders_imgs_format_terceiro") %}

{% if sliders_imgs_active and sliders_imgs and sliders_imgs is not empty %}
	{% set section_slider = sliders_imgs_format == 'slider' %}
	{% set brands_container_classes = section_slider ? 'swiper-slide slide-container' : 'col-md-1-5 col-4 mb-3' %}
	<section class="section-home section-brands-home section-sliders-imgs overflow-none" data-store="home-brands">
		<div class="container-fluid">
			{% if section_slider %}
				<div class="infinite-carousel-container">
					<div class="infinite-carousel-track" id="carousel-track-03">
						{% for slide in sliders_imgs %}
							<div class="infinite-carousel-slide">
								{% if slide.link %}
									<a href="{{ slide.link | setting_url }}" title="{{ 'Imagem {1} de' | translate(loop.index) }} {{ store.name }}" aria-label="{{ 'Imagem {1} de' | translate(loop.index) }} {{ store.name }}">
								{% endif %}
									<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset="{{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w" data-src="{{ slide.image | static_url | settings_image_url('1080p') }}" data-sizes="auto" class="lazyautosizes lazyload brand-image" alt="{{ 'Imagem {1} de' | translate(loop.index) }} {{ store.name }}">
								{% if slide.link %}
									</a>
								{% endif %}
							</div>
						{% endfor %}
					</div>
				</div>
			{% else %}
				<div class="row justify-content-center">
					{% for slide in sliders_imgs %}
						<div class="{{ brands_container_classes }} brand-image-container text-center">
							{% if slide.link %}
								<a href="{{ slide.link | setting_url }}" title="{{ 'Imagem {1} de' | translate(loop.index) }} {{ store.name }}" aria-label="{{ 'Imagem {1} de' | translate(loop.index) }} {{ store.name }}">
							{% endif %}
								<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset="{{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w" data-src="{{ slide.image | static_url | settings_image_url('1080p') }}" data-sizes="auto" class="lazyautosizes lazyload brand-image" alt="{{ 'Imagem {1} de' | translate(loop.index) }} {{ store.name }}">
							{% if slide.link %}
								</a>
							{% endif %}
						</div>
					{% endfor %}
				</div>
			{% endif %}
		</div>
	</section>
{% endif %}
