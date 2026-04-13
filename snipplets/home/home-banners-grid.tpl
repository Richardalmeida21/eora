{% set banner = banner | default(false) %}
{% set banner_promotional = banner_promotional | default(false) %}
{% set banner_news = banner_news | default(false) %}
{% set module = module | default(false) %}

{# === Configurações de Banner === #}
{% if banner %}
	{% set has_banners = settings.banner and settings.banner is not empty %}
	{% set has_mobile_banners = settings.toggle_banner_mobile and settings.banner_mobile and settings.banner_mobile is not empty %}
	{% set section_banner = mobile ? settings.banner_mobile : settings.banner %}
	{% set section_title = settings.banner_title %}
	{% set section_slider = settings.banner_format_mobile == 'slider' or settings.banner_format_desktop == 'slider' %}
	{% set section_slider_both = settings.banner_format_mobile == 'slider' and settings.banner_format_desktop == 'slider' %}
	{% set section_slider_mobile_only = settings.banner_format_mobile == 'slider' and settings.banner_format_desktop == 'grid' %}
	{% set section_slider_desktop_only = settings.banner_format_desktop == 'slider' and settings.banner_format_mobile == 'grid' %}
	{% set section_id = mobile ? 'banners-mobile' : 'banners' %}
	{% set section_columns_desktop_4 = settings.banner_columns_desktop == 4 %}
	{% set section_columns_desktop_3 = settings.banner_columns_desktop == 3 %}
	{% set section_columns_desktop_2 = settings.banner_columns_desktop == 2 %}
	{% set section_columns_desktop_1 = settings.banner_columns_desktop == 1 %}
	{% set section_same_size = settings.banner_same_size %}
	{% set section_align_text = settings.banner_align %}
	{% set section_title_size_mobile = settings.banner_title_size_mobile == 'small' ? 'h4-huge' : settings.banner_title_size_mobile == 'medium' ? 'h2-huge' : 'h1-huge'  %}
	{% set section_title_size_desktop = settings.banner_title_size_desktop == 'small' ? 'h3-huge-md' : settings.banner_title_size_desktop == 'medium' ? 'h1-huge-md' : 'h2-extra-huge-md' %}
	{% set section_without_margins = settings.banner_without_margins %}
	{% set section_text_outside = settings.banner_text_outside %}

	{% set padding_bottom_banner = 100 %}
	{% set width_desktop = settings.banner_width_desktop  %}
	{% set height_desktop = settings.banner_height_desktop  %}
	{% set width_mobile = settings.banner_width_mobile %}
	{% set height_mobile = settings.banner_height_mobile %}

	{% if width_desktop > 0 and height_desktop > 0 and not mobile %}
		{% set padding_bottom_banner = (height_desktop / width_desktop) * 100 %}
	{% endif %}
	{% if width_mobile > 0 and height_mobile > 0 and mobile %}
		{% set padding_bottom_banner = (height_mobile / width_mobile) * 100 %}
	{% endif %}
{% endif %}

{% if banner_promotional %}
	{% set has_banners = settings.banner_promotional and settings.banner_promotional is not empty %}
	{% set has_mobile_banners = settings.toggle_banner_promotional_mobile and settings.banner_promotional_mobile and settings.banner_promotional_mobile is not empty %}
	{% set section_banner = mobile ? settings.banner_promotional_mobile : settings.banner_promotional %}
	{% set section_title = settings.banner_promotional_title %}
	{% set section_slider = settings.banner_promotional_format_mobile == 'slider' or settings.banner_promotional_format_desktop == 'slider' %}
	{% set section_slider_both = settings.banner_promotional_format_mobile == 'slider' and settings.banner_promotional_format_desktop == 'slider' %}
	{% set section_slider_mobile_only = settings.banner_promotional_format_mobile == 'slider' and settings.banner_promotional_format_desktop == 'grid' %}
	{% set section_slider_desktop_only = settings.banner_promotional_format_desktop == 'slider' and settings.banner_promotional_format_mobile == 'grid' %}
	{% set section_id = mobile ? 'banners-promotional-mobile' : 'banners-promotional' %}
	{% set section_columns_desktop_4 = settings.banner_promotional_columns_desktop == 4 %}
	{% set section_columns_desktop_3 = settings.banner_promotional_columns_desktop == 3 %}
	{% set section_columns_desktop_2 = settings.banner_promotional_columns_desktop == 2 %}
	{% set section_columns_desktop_1 = settings.banner_promotional_columns_desktop == 1 %}
	{% set section_same_size = settings.banner_promotional_same_size %}
	{% set section_align_text = settings.banner_promotional_align %}
	{% set section_title_size_mobile = settings.banner_promotional_title_size_mobile == 'small' ? 'h4-huge' : settings.banner_promotional_title_size_mobile == 'medium' ? 'h2-huge' : 'h1-huge' %}
	{% set section_title_size_desktop = settings.banner_promotional_title_size_desktop == 'small' ? 'h3-huge-md' : settings.banner_promotional_title_size_desktop == 'medium' ? 'h1-huge-md' : 'h2-extra-huge-md' %}
	{% set section_without_margins = settings.banner_promotional_without_margins %}
	{% set section_text_outside = settings.banner_promotional_text_outside %}
{% endif %}

{% if banner_news %}
	{% set has_banners = settings.banner_news and settings.banner_news is not empty %}
	{% set has_mobile_banners = settings.toggle_banner_news_mobile and settings.banner_news_mobile and settings.banner_news_mobile is not empty %}
	{% set section_banner = mobile ? settings.banner_news_mobile : settings.banner_news %}
	{% set section_title = settings.banner_news_title %}
	{% set section_slider = settings.banner_news_format_mobile == 'slider' or settings.banner_news_format_desktop == 'slider' %}
	{% set section_slider_both = settings.banner_news_format_mobile == 'slider' and settings.banner_news_format_desktop == 'slider' %}
	{% set section_slider_mobile_only = settings.banner_news_format_mobile == 'slider' and settings.banner_news_format_desktop == 'grid' %}
	{% set section_slider_desktop_only = settings.banner_news_format_desktop == 'slider' and settings.banner_news_format_mobile == 'grid' %}
	{% set section_id = mobile ? 'banners-news-mobile' : 'banners-news' %}
	{% set section_columns_desktop_4 = settings.banner_news_columns_desktop == 4 %}
	{% set section_columns_desktop_3 = settings.banner_news_columns_desktop == 3 %}
	{% set section_columns_desktop_2 = settings.banner_news_columns_desktop == 2 %}
	{% set section_columns_desktop_1 = settings.banner_news_columns_desktop == 1 %}
	{% set section_same_size = settings.banner_news_same_size %}
	{% set section_align_text = settings.banner_news_align %}
	{% set section_title_size_mobile = settings.banner_news_title_size_mobile == 'small' ? 'h4-huge' : settings.banner_news_title_size_mobile == 'medium' ? 'h2-huge' : 'h1-huge' %}
	{% set section_title_size_desktop = settings.banner_news_title_size_desktop == 'small' ? 'h3-huge-md' : settings.banner_news_title_size_desktop == 'medium' ? 'h1-huge-md' : 'h2-extra-huge-md'  %}
	{% set section_without_margins = settings.banner_news_without_margins %}
	{% set section_text_outside = settings.banner_news_text_outside %}
{% endif %}

{% if module %}
	{% set section_banner = settings.module %}
	{% set section_slider = settings.module_slider %}
	{% set section_id = 'modules' %}
	{% set section_same_size = settings.module_same_size %}
	{% set section_text_outside = true %}
	{% set section_title_size_mobile = settings.module_title_size_mobile == 'small' ? 'h4-huge' : 'h2-huge'  %}
	{% set section_title_size_desktop = settings.module_title_size_desktop == 'small' ? 'h3-huge-md' : 'h1-huge-md' %}
	{% set section_first = settings.home_order_position_1 == 'modules' %}
{% endif %}

{% set visibility_classes = 
    has_banners and has_mobile_banners ? (mobile ? 'd-md-none' : 'd-none d-md-block') 
    : (not has_banners and has_mobile_banners and not mobile ? 'd-none' : '') 
%}

{% set container_classes = module ? 'container' : 'container-fluid' %}
{% set banner_classes = module ? 'mb-4 mb-md-5 pb-md-3' : section_without_margins ? 'm-0' : '' %}

{# === Renderização Condicional === #}
{% if section_banner and section_banner is not empty %}
<div class="banner-categorias {{ container_classes }} position-relative {% if module %}mt-4 pt-3{% else %} {{ visibility_classes }}{% endif %}">
	{% if section_title and not module %}
		<h2 class="section-title text-center h3 mb-4">{{ section_title }}</h2>
	{% endif %}

	{% if section_without_margins %}
	</div>
	<div class="banner-categorias {{ container_classes }} {% if not module %}p-0 overflow-none {{ visibility_classes }}{% endif %}">
	{% endif %}

	{% if section_slider %}
		{% set section_slider_classes = section_slider_both 
			? 'swiper-products-slider flex-nowrap' 
			: section_slider_mobile_only 
				? 'swiper-mobile-only flex-nowrap flex-md-wrap' 
				: section_slider_desktop_only 
					? 'swiper-desktop-only flex-wrap flex-md-nowrap ml-md-0' 
					: module and section_slider 
						? 'swiper-products-slider' 
						: '' %}
		<div class="js-swiper-{{ section_id }} swiper-container {% if module %}d-flex flex-column d-md-block{% endif %}">
			<div class="swiper-wrapper {{ section_slider_classes }} {% if not module %}row {% if section_without_margins %}no-gutters{% else %}row-grid{% endif %}{% endif %}">
	{% else %}
		{% if not module %}
			<div class="row {% if section_without_margins %}no-gutters{% else %}px-2{% endif %}">
		{% endif %}
	{% endif %}

		{% for slide in section_banner %}
			{% set has_banner_text = slide.title or slide.description or slide.button %}

			{% if not module or (module and section_slider) %}
				<div class="{% if section_slider %}swiper-slide {% endif %}col-grid '
				{% if section_columns_desktop_4 %}col-md-3
				{% elseif section_columns_desktop_3 %}col-md-4
				{% elseif section_columns_desktop_2 %}col-md-6
				{% elseif section_columns_desktop_1 %}col-md-12
				{% endif %}">
			{% endif %}

				<div class="textbanner {{ banner_classes }}">
					{% if module %}
						<div class="row no-gutters align-items-center">
					{% endif %}
					
					<div class="textbanner-image{% if not section_same_size %} p-0{% endif %} {% if module %} col-md-6{% if section_same_size %} textbanner-image-md{% endif %}{% else %}{% if has_banner_text and not section_text_outside %} overlay{% endif %}{% endif %} overflow-none">
						<figure class="image -custom" style="--padding-bottom-banner: {{ padding_bottom_banner }}%">
							<img {% if slide.width and slide.height %} width="{{ slide.width }}" height="{{ slide.height }}" {% endif %}
								src="{% if not section_slider %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}"
								data-sizes="auto" data-expand="-10"
								data-srcset="{{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w"
								class="textbanner-image-effect {% if section_same_size %}textbanner-image-background{% else %}img-fluid d-block w-100{% endif %} lazyautosizes lazyload fade-in"
								{% if slide.title %} alt="{{ slide.title }}" {% else %} alt="{{ 'Banner de' | translate }} {{ store.name }}" {% endif %} />

							{% if slide.title and slide.link %}
								<a href="{{ slide.link }}" class="banner-floating-button">
									<div class="banner-floating-button-content">
										<div class="banner-floating-title">{{ slide.title }}</div>
										<svg class="banner-floating-icon" viewbox="0 0 10 10" fill="none">
											<use xlink:href="#chevron-diagonal"></use>
										</svg>
									</div>
								</a>
							{% elseif slide.title %}
								<div class="banner-floating-button">
									<div class="banner-floating-button-content">
										<div class="banner-floating-title">{{ slide.title }}</div>
										<svg class="banner-floating-icon" viewbox="0 0 10 10" fill="none">
											<use xlink:href="#chevron-diagonal"></use>
										</svg>
									</div>
								</div>
							{% endif %}
						</figure>
						{% if section_text_outside %}
						</div>
						{% endif %}
						
						{% if has_banner_text %}
							<div class="textbanner-text text-{{ section_align_text }}"></div>
						{% endif %}
						
						{% if not section_text_outside or module %}
						</div>
						{% endif %}
					{% if module %}
						</div>
					{% endif %}
				</div>

			{% if not module or (module and section_slider) %}
				</div>
			{% endif %}
		{% endfor %}

	{% if section_slider %}
			</div>
			{% if (section_banner and section_banner is not empty and (not module and section_slider) or (module and section_slider)) %}
				{% set section_button_classes = section_slider_mobile_only ? 'd-block d-md-none' : section_slider_desktop_only ? 'd-none d-md-block' %}
				<div class="swiper-buttons {{ section_button_classes }}">
					<div class="js-swiper-{{ section_id }}-prev swiper-button-prev">
						<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
					</div>
					<div class="js-swiper-{{ section_id }}-next swiper-button-next">
						<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
					</div>
				</div>
			{% endif %}
		</div>
	{% elseif not module %}
		</div>
	{% endif %}
</div>
{% endif %}

<style>
.textbanner-image img {
  width: 100%;
  display: block;
}
</style>
