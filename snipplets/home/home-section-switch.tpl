{% if section_select == 'slider' %}
	{#  **** Home slider ****  #}
	{% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}
	{% set head_transparent_section = (has_main_slider or has_mobile_slider) and settings.head_transparent %}

	<section class="section-home-color" data-store="home-slider" data-transition="fade-in" {% if head_transparent_section %}data-header-type="transparent-on-section"{% endif %}>
		{% if show_help or (show_component_help and not (has_main_slider or has_mobile_slider)) %}
			{% snipplet 'defaults/home/slider_help.tpl' %}
		{% else %}
			{% include 'snipplets/home/home-slider.tpl' %}
			{% if has_mobile_slider %}
				{% include 'snipplets/home/home-slider.tpl' with {mobile: true} %}
			{% endif %}
		{% endif %}
	</section>

{% elseif section_select == 'institutional' %}
	{#  **** Institutional message ****  #}
	{% set title_institutional = 'Mensaje institucional' | translate %}
	{% if show_help or (show_component_help and not has_institutional_message) %}
		{% include 'snipplets/defaults/home/institutional_message_help.tpl' with { title: title_institutional, institutional_message: true, data_store: 'home-institutional-message' }  %}
	{% else %}
		{% include 'snipplets/home/home-institutional-message.tpl' %}
	{% endif %}
{% elseif section_select == 'CARROSSEL_TEXT' %}
  {% if show_help or (show_component_help and false) %}
    VAZIO
  {% else %}
    {% if settings.banner_horizontal_mobile %}
      {% include 'snipplets/home/home-carrossel-text.tpl' with {mobile: true} %}
    {% else %}
      {% include 'snipplets/home/home-carrossel-text.tpl' %}
    {% endif %}
  {% endif %}
{% elseif section_select == 'BANNER_HORIZONTAL' %}
	{% if show_help or (show_component_help and false) %}
		VAZIO	
	{% else %}
		{% include 'snipplets/home/home-banner-imagem-horizontal.tpl' %}
		{% if settings.banner_horizontal_mobile %}
			{% include 'snipplets/home/home-banner-imagem-horizontal.tpl' with {mobile: true} %}
		{% endif %}
	{% endif %}

{% elseif section_select == 'categories' %}
	{#  **** Categories banners ****  #}
	{% set banner_title_cat = 'Categoría' | translate %}
	{% set help_text_cat = 'Podés destacar categorías de tu tienda desde' | translate %}
	{% set section_name_cat = 'Banners de categorías' | translate %}
	{% if show_help or (show_component_help and not has_banners) %}
		{% include 'snipplets/defaults/home/banners_help.tpl' with { banner_name: 'category', banner_title: banner_title_cat, help_text: help_text_cat, section_name: section_name_cat, data_store: 'home-banner-categories' }  %}
	{% else %}
		{% include 'snipplets/home/home-banners.tpl' with {'has_banner': true} %}
	{% endif %}
{% elseif section_select == 'BANNER_HORIZONTAL_VIDEO' %}
	{% if show_help or (show_component_help and false) %}
		VAZIO
	{% else %}
		{% if settings.banner_video_horizontal_mobile %}
			{% include 'snipplets/home/home-banner-video-horizontal.tpl' with {mobile: true} %}
		{% else %}
			{% include 'snipplets/home/home-banner-video-horizontal.tpl' %}
		{% endif %}
	{% endif %}
{% elseif section_select == 'BANNER_VIDEO_BOTAO' %}
	{% if show_help or (show_component_help and false) %}
		VAZIO
	{% else %}
		{% include 'snipplets/home/home-banner-video-botao.tpl' %}
	{% endif %}
{% elseif section_select == 'BANNER_DUPLO' %}
	{% if show_help or (show_component_help and false) %}
		VAZIO
	{% else %}
		{% include 'snipplets/home/home-banner-duplo.tpl' %}
	{% endif %}
{% elseif section_select == 'SECAO_FRANQUEADOS' %}
	{% if show_help or (show_component_help and not has_franqueados and not has_franqueados) %}
		VAZIO	
	{% else %}
		{% include 'snipplets/home/home-franqueados.tpl' %}
	{% endif %}
{% elseif section_select == 'products' %}
	{#  **** Featured products ****  #}
	{% set title_featured = 'Destacados' | translate %}
	{% if show_help or (show_component_help and not has_products) %}
		{% include 'snipplets/defaults/home/featured_products_help.tpl' with { products_title: title_featured, section_id: 'featured', slider: true }  %}
	{% else %}
		{% include 'snipplets/home/home-featured-products.tpl' with {'has_featured': true} %}
	{% endif %}

{% elseif section_select == 'new' %}
	{#  **** New products ****  #}
	{% set title_new = 'Novedades' | translate %}
	{% if show_help or (show_component_help and not has_products) %}
		{% include 'snipplets/defaults/home/featured_products_help.tpl' with { products_title: title_new, section_id: 'new' } %}
	{% else %}
		{% include 'snipplets/home/home-featured-products.tpl' with { has_new: true } %}
	{% endif %}
{% elseif section_select == 'showcase' %}
	{#  **** showcase products ****  #}
	{% set title_new = 'Vitrine de produtos' | translate %}
	{% if show_help or (show_component_help and not has_products) %}
		{% include 'snipplets/defaults/home/featured_products_help.tpl' with { products_title: title_new, section_id: 'new' } %}
	{% else %}
		{% include 'snipplets/home/home-featured-products.tpl' with { has_product_showcase: true } %}
	{% endif %}
{% elseif section_select == 'showcase_02' %}
	{#  **** showcase_02 products ****  #}
	{% set title_new = 'Vitrine de produtos' | translate %}
	{% if show_help or (show_component_help and not has_products) %}
		{% include 'snipplets/defaults/home/featured_products_help.tpl' with { products_title: title_new, section_id: 'new' } %}
	{% else %}
		{% include 'snipplets/home/home-featured-products.tpl' with { has_product_showcase_02: true } %}
	{% endif %}
{% elseif section_select == 'showcase_03' %}
	{#  **** showcase_03 products ****  #}
	{% set title_new = 'Vitrine de produtos' | translate %}
	{% if show_help or (show_component_help and not has_products) %}
		{% include 'snipplets/defaults/home/featured_products_help.tpl' with { products_title: title_new, section_id: 'new' } %}
	{% else %}
		{% include 'snipplets/home/home-featured-products.tpl' with { has_product_showcase_03: true } %}
	{% endif %}
{# 
{% elseif section_select == 'instafeed' %}
    **** Instafeed ****
    {% if show_help or (show_component_help and not has_instafeed) %}
        {% snipplet 'defaults/home/instafeed_help.tpl' %}
    {% else %}
        {% include 'snipplets/home/home-instafeed.tpl' %}
    {% endif %}
#}
{% elseif section_select == 'LOJA_NA_MIDIA' %}
	{% if show_help or (show_component_help and false) %}
		VAZIO	
	{% else %}
		{% include 'snipplets/home/home-loja-na-midia.tpl' %}
		{# {% if settings.loja_midia_mobile %}
			{% include 'snipplets/home/home-loja-na-midia.tpl' with {mobile: true} %}
		{% endif %} #}
	{% endif %}

{% elseif section_select == 'SEARCH_FOR' %}
	{% if show_help or (show_component_help and not has_search_for and not has_search_for) %}
		VAZIO	
	{% else %}
		{% include 'snipplets/home/home-most-search.tpl' %}
	{% endif %}
{% elseif section_select == 'BANNER_LINKS' %}
	{% if show_help or (show_component_help and false) %}
		VAZIO	
	{% else %}
		{% include 'snipplets/home/home-banners-links.tpl' %}
		{% if settings.banner_horizontal_mobile %}
			{% include 'snipplets/home/home-banners-links.tpl' with {mobile: true} %}
		{% endif %}
	{% endif %}
	
{% elseif section_select == 'COLECOES_KINGS' %}
	{% if show_help or (show_component_help and not has_colecoes_kings and not has_colecoes_kings) %}
		VAZIO	
	{% else %}
		{% include 'snipplets/home/home-colecoes-kings.tpl' %}
		{% if settings.toggle_colecoes_kings_mobile %}
			{% include 'snipplets/home/home-colecoes-kings.tpl' with {mobile: true} %}
		{% endif %}
	{% endif %}

{% elseif section_select == 'main_categories' %}
	{% if show_help or (show_component_help and not has_main_categories) %}
		{% snipplet 'defaults/home/main_categories_help.tpl' %}
	{% else %}
		{% include 'snipplets/home/home-categories.tpl' %}
	{% endif %}
{% elseif section_select == 'BANNERS_SCROLL' %}
	{% include 'snipplets/home/home-banners-scroll.tpl' %}
{% elseif section_select == 'welcome' %}
	{% set title_welcome = 'Mensaje de bienvenida' | translate %}
	{% if show_help or (show_component_help and not has_welcome_message) %}
		{% include 'snipplets/defaults/home/institutional_message_help.tpl' with { title: title_welcome, data_store: 'home-welcome-message' }  %}
	{% else %}
		{% include 'snipplets/home/home-messages.tpl' with {'has_welcome': true} %}
	{% endif %}


{% elseif section_select == 'announcement' %}
	{% set title_announcement = 'Mensaje de anuncios' | translate %}
	{% if show_help or (show_component_help and not has_announcement_message) %}
		{% include 'snipplets/defaults/home/institutional_message_help.tpl' with { title: title_announcement, data_store: 'home-announcement-message' }  %}
	{% else %}
		{% include 'snipplets/home/home-messages.tpl' with {'has_announcement': true} %}
	{% endif %}
{% elseif section_select == 'sale' %}
	{% set title_sale = 'Ofertas' | translate %}
	{% if show_help or (show_component_help and not has_products) %}
		{% include 'snipplets/defaults/home/featured_products_help.tpl' with { products_title: title_sale, section_id: 'sale' }  %}
	{% else %}
		{% include 'snipplets/home/home-featured-products.tpl' with { has_sale: true } %}
	{% endif %}

{% elseif section_select == 'informatives' %}
	{% if show_help or (show_component_help and not has_informative_banners) %}
		{% snipplet 'defaults/home/informative_banners_help.tpl' %}
	{% else %}
		{% include 'snipplets/banner-services/banner-services.tpl' %}
	{% endif %}
{% elseif section_select == 'video' %}	
	{% set has_video = settings.video and settings.video is not empty %}
	{% if show_help or (show_component_help and not has_video) %}
	{% else %}
		{% include 'snipplets/home/home-video.tpl' %}
		{% if settings.video_mobile %}
			{% include 'snipplets/home/home-video.tpl' with {mobile: true} %}
		{% endif %}
	{% endif %}
{% elseif section_select == 'newsletter' %}
	{% include 'snipplets/home/home-newsletter.tpl' %}


{% elseif section_select == 'LOOKS' %}
	{% if show_help or (show_component_help and false) %}
		VAZIO
	{% elseif settings.looks_show %}
		{% include 'snipplets/home/home-looks.tpl' %}
	{% endif %}
{% elseif section_select == 'promotional' %}
	{% set banner_title_promo = 'Promoción' | translate %}
	{% set help_text_promo = 'Podés mostrar tus promociones desde' | translate %}
	{% set section_name_promo = 'Banners promocionales' | translate %}
	{% if show_help or (show_component_help and not has_promotional_banners) %}
		{% include 'snipplets/defaults/home/banners_help.tpl' with { banner_name: 'promotional', banner_title: banner_title_promo, help_text: help_text_promo, section_name: section_name_promo, data_store: 'home-banner-promotional' }  %}
	{% else %}
		{% include 'snipplets/home/home-banners.tpl' with {'has_banner_promotional': true} %}
	{% endif %}

{% elseif section_select == 'news_banners' %}
	{% set banner_title_news = 'Nuevo' | translate %}
	{% set help_text_news = 'Podés mostrar tus últimas novedades desde' | translate %}
	{% set section_name_news = 'Banners de novedades' | translate %}
	{% if show_help or (show_component_help and not has_news_banners) %}
		{% include 'snipplets/defaults/home/banners_help.tpl' with { banner_name: 'news', banner_title: banner_title_news, help_text: help_text_news, section_name: section_name_news, data_store: 'home-banner-news' }  %}
	{% else %}
		{% include 'snipplets/home/home-banners.tpl' with {'has_banner_news': true} %}
	{% endif %}

{% elseif section_select == 'modules' %}
	{% if show_help or (show_component_help and not has_image_and_text_module) %}
		{% include 'snipplets/defaults/home/image_text_modules_help.tpl' %}
	{% else %}
		{% include 'snipplets/home/home-banners.tpl' with {'has_module': true} %}
	{% endif %}
{% elseif section_select == 'brands' %}
	{% if show_help or (show_component_help and not has_brands) %}
		{% snipplet 'defaults/home/brands_help.tpl' %}
	{% else %}
		{% include 'snipplets/home/home-brands.tpl' %}
	{% endif %}

{% elseif section_select == 'testimonials' %}
	{% if show_help or (show_component_help and not has_testimonials) %}
		{% snipplet 'defaults/home/testimonials_help.tpl' %}
	{% else %}
		{% include 'snipplets/home/home-testimonials.tpl' %}
	{% endif %}
{% endif %}
