{% set banners = [
    {
        "image": "banner_categoria_01_image",
        "title": settings.banner_categoria_01_title,
        "link": settings.banner_categoria_01_image_link,
        "width": 930,
        "height": 465
    },
    {
        "image": "banner_categoria_02_image",
        "title": settings.banner_categoria_02_title,
        "link": settings.banner_categoria_02_image_link,
        "width": 930,
        "height": 465
    },
    {
        "image": "banner_categoria_03_image",
        "title": settings.banner_categoria_03_title,
        "link": settings.banner_categoria_03_image_link,
        "width": 930,
        "height": 465
    }
] %}

<div class="banner-categoria-section">
	{% for banner in banners %}
		{% set padding_bottom = 48 %}
		{% if banner.width > 0 and banner.height > 0 %}
			{% set padding_bottom = (banner.height / banner.width) * 100 %}
		{% endif %}

		<div class="banner-categoria-item">
			{% if attribute(settings, banner.image ~ '_link') %}
				<a href="{{ attribute(settings, banner.image ~ '_link') }}" class="overlay-link">
				{% endif %}

				<figure class="image -custom" style="--padding-bottom-banner-categoria: {{ padding_bottom }}%">
					<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{ (banner.image ~ ".jpg") | static_url | settings_image_url("large") }} 480w, {{ (banner.image ~ ".jpg") | static_url | settings_image_url("huge") }} 640w, {{ (banner.image ~ ".jpg") | static_url | settings_image_url("original") }} 1024w, {{ (banner.image ~ ".jpg") | static_url | settings_image_url("1080p") }} 1920w' class='lazyload'/>
					<div class="banner-categoria-content">
						<div class="banner-categoria-title">{{ banner.title }}</div>
						<svg class="banner-floating-icon" viewbox="0 0 10 10" fill="none" style="transform: scaleX(-1);">
							<use xlink:href="#chevron-diagonal"></use>
						</svg>
					</div>
				</figure>

				{% if attribute(settings, banner.image ~ '_link') %}
				</a>
			{% endif %}
		</div>
	{% endfor %}
</div>
{# Banner Categoria - inspirado no banner horizontal, com 3 banners configuráveis #}
<div class="banner-categoria-section">
	<div class="banner-categoria-grid">
		{% for i in [1,2,3] %}
			{% set image = settings['banner_categoria_0' ~ i ~ '_image'] %}
			{% set link = settings['banner_categoria_0' ~ i ~ '_image_link'] %}
			{% set title = settings['banner_categoria_0' ~ i ~ '_title'] %}
			<div class="banner-categoria-item">
				{% if link %}
					<a href="{{ link }}" class="banner-categoria-link">
					{% endif %}
					<figure class="banner-categoria-figure">
						<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ image | static_url | settings_image_url('1080p') }}" alt="{{ title }}" class="lazyload banner-categoria-img" width="930" height="465"/>
						<figcaption class="banner-categoria-caption">
							<span class="banner-categoria-title">{{ title }}</span>
						</figcaption>
					</figure>
					{% if link %}
					</a>
				{% endif %}
			</div>
		{% endfor %}
	</div>
</div>
<style>
	.banner-categoria-section {
		width: 100%;
		margin: 0 auto 32px;
	}
	.banner-categoria-grid {
		display: flex;
		gap: 24px;
		flex-wrap: wrap;
		justify-content: center;
	}
	.banner-categoria-item {
		flex: 1 1 300px;
		max-width: 32%;
		min-width: 280px;
		position: relative;
	}
	.banner-categoria-figure {
		width: 100%;
		aspect-ratio: 930 / 465;
		background: #f5f5f5;
		border-radius: 8px;
		overflow: hidden;
		margin: 0;
		position: relative;
	}
	.banner-categoria-img {
		width: 100%;
		height: auto;
		display: block;
		object-fit: cover;
	}
	.banner-categoria-caption {
		position: absolute;
		left: 0;
		right: 0;
		bottom: 0;
		background: rgba(0, 0, 0, 0.4);
		color: #fff;
		padding: 16px;
		font-size: 1.2rem;
		text-align: left;
	}
	.banner-categoria-title {
		font-weight: bold;
		font-size: 1.1em;
	}
	@media(max-width: 900px) {
		.banner-categoria-item {
			max-width: 100%;
		}
		.banner-categoria-grid {
			flex-direction: column;
			gap: 16px;
		}
	}
</style>
