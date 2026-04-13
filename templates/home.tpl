{# Detect presence of features that remove empty placeholders #}

{% set has_main_slider = settings.slider and settings.slider is not empty %}
{% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}
{% set has_video = settings.video_embed %}
{% set has_main_categories = settings.main_categories and settings.slider_categories and settings.slider_categories is not empty %}
{% set has_banners = settings.banner and settings.banner is not empty %}
{% set has_promotional_banners = settings.banner_promotional and settings.banner_promotional is not empty %}
{% set has_news_banners = settings.banner_news and settings.banner_news is not empty %}
{% set has_image_and_text_module = settings.module and settings.module is not empty %}
{% set has_brands = settings.brands and settings.brands is not empty %}
{% set has_informative_banners = settings.banner_services and (settings.banner_services_01_title or settings.banner_services_02_title or settings.banner_services_03_title or settings.banner_services_01_description or settings.banner_services_02_description or settings.banner_services_03_description) %}
{% set has_instafeed = settings.show_instafeed and store.instagram and store.hasInstagramToken() %}
{% set has_institutional_message = settings.institutional_message or settings.institutional_text %}
{% set has_welcome_message = settings.welcome_message %}
{% set has_announcement_message = settings.announcement_01_message or settings.announcement_02_message or settings.announcement_03_message %}

{% set has_testimonial_01 = settings.testimonial_01_description or settings.testimonial_01_name or "testimonial_01.jpg" | has_custom_image %}
{% set has_testimonial_02 = settings.testimonial_02_description or settings.testimonial_02_name or "testimonial_02.jpg" | has_custom_image %}
{% set has_testimonial_03 = settings.testimonial_03_description or settings.testimonial_03_name or "testimonial_03.jpg" | has_custom_image %}
{% set has_testimonials = has_testimonial_01 or has_testimonial_02 or has_testimonial_03 %}

{% set has_banner_horizontal =  settings.colecoes_kings_show and settings.banner_horizontal and settings.banner_horizontal is not empty %}
{% set has_search_for =  settings.search_for and settings.search_for is not empty %}
{% set has_colecoes_kings = settings.colecoes_kings and settings.colecoes_kings is not empty %}
{% set has_banner_links =  settings.banner_links_show and settings.banner_links and settings.banner_links is not empty %}
{% set has_loja_midia = settings.loja_media_show and settings.loja_media_title and settings.loja_media_title is not empty  %}
{% set has_franqueados = settings.franqueados_show and settings.franqueados_title and settings.franqueados_title is not empty %}
{% set has_section_looks =  settings.looks_show  %}

{% set show_help = not (has_main_slider or has_mobile_slider or has_video or has_main_categories or has_banners or has_promotional_banners or has_news_banners or has_image_and_text_module or has_brands or has_informative_banners or has_instafeed or has_testimonials or has_institutional_message or has_welcome_message or has_announcement_message or has_banner_horizontal or has_search_for or has_colecoes_kings or has_banner_links or has_loja_midia or has_franqueados or has_section_looks) and not has_products %}

{% set show_component_help = params.preview %}

{% if show_help or show_component_help %}
	{% include "snipplets/svg/empty-placeholders.tpl" %}
{% endif %}

{% if not params.preview %}
	{% set admin_link = is_theme_draft ? '/admin/themes/settings/draft/' : '/admin/themes/settings/active/' %}
{% endif %}

{% set newArray = [] %}
<div class="js-home-sections-container">
	{% for i in 1..25 %}
		{% set section = 'home_order_position_' ~ i %}
		{% set section_select = attribute(settings, section) %}

		{% if section_select not in newArray %}
			{% include 'snipplets/home/home-section-switch.tpl' %}
			{% set newArray = newArray|merge([section_select]) %}
		{% endif %}

	{% endfor %}

	{#  **** Hidden Sections ****  #}
	{% if show_component_help %}
		<div style="display:none">
			{% for section_select in ['slider', 'main_categories', 'welcome', 'announcement', 'institutional', 'products', 'new', 'sale', 'informatives', 'categories','main_product', 'video', 'newsletter', 'instafeed', 'promotional', 'news_banners', 'brands' , 'testimonials', 'modules', 'BANNER_HORIZONTAL', 'SEARCH_FOR', 'COLECOES_KINGS', 'BANNER_LINKS', 'LOJA_NA_MIDIA', 'SECAO_FRANQUEADOS', 'LOOKS'] %}
				{% if section_select not in newArray %}
					{% include 'snipplets/home/home-section-switch.tpl' %}
				{% endif %}
			{% endfor %}
		</div>
	{% endif %}
</div>

{% if settings.home_promotional_popup and ("home_popup_image.jpg" | has_custom_image or settings.home_popup_title or settings.home_popup_txt or settings.home_news_box or (settings.home_popup_btn and settings.home_popup_url)) %}
	{# Moved to layout.tpl to be available globally for wishlist interception #}
{% endif %}

	{# {% include 'snipplets/button-popup.tpl' %} #}

