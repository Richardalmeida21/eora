{% set has_social_network = store.facebook or store.twitter or store.pinterest or store.instagram or store.tiktok or store.youtube %}
{% set has_footer_contact_info = (store.whatsapp or store.phone or store.email or store.address or store.blog) and settings.footer_contact_show %}          

{% set has_footer_menu = settings.footer_menu and settings.footer_menu_show %}
{% set has_footer_menu_secondary = settings.footer_menu_secondary and settings.footer_menu_secondary_show %}
{% set has_footer_menu_tertiary = settings.footer_menu_tertiary and settings.footer_menu_tertiary_show %}
{% set has_footer_about = settings.footer_about_show and (settings.footer_about_title or settings.footer_about_description) %}
{% set has_payment_logos = settings.payments %}
{% set has_shipping_logos = settings.shipping %}
{% set has_shipping_payment_logos = has_payment_logos or has_shipping_logos %}
{% set has_languages = languages | length > 1 and settings.languages_footer %}
{% set has_seal_logos = store.afip or ebit or settings.custom_seal_code or ("seal_img.jpg" | has_custom_image) %}
{% set show_right_md_col_logo = show_footer_logo and not settings.news_show %}
{% set has_right_md_col_content = (settings.news_show or has_footer_contact_info or has_shipping_payment_logos or has_languages or has_social_network) or show_right_md_col_logo %}
{% set vertical_spacing_classes = 'mb-4 pb-2 mb-md-5 pb-md-0' %}
{% set password_page = template == 'password' %}


<footer class="js-footer js-hide-footer-while-scrolling {% if settings.footer_colors %}footer-colors{% endif %} display-when-content-ready" data-store="footer" style="overflow-x:clip;">

{# {% if settings.footer_carousel_show and settings.footer_carousel and settings.footer_carousel is not empty %}
	<div class="footer-carousel" style="padding-top: 48px; padding-bottom: 48px;">
		<style>
			@media (max-width: 767px) {
				.footer-carousel {
					padding-bottom: 24px !important;
				}
			}

			.footer-carousel-gallery {
				display: flex;
				justify-content: flex-start;
				overflow-x: auto;
				scrollbar-width: none;
				-ms-overflow-style: none;
				scroll-snap-type: x mandatory;
				box-sizing: border-box;
				width: 100%;
				min-width: 100vw;
				padding: 0;
				margin: 0;
			}

			.footer-carousel-gallery::-webkit-scrollbar {
				display: none;
			}

			.footer-carousel-gallery > div {
				flex: 0 0 auto;
				display: flex;
				align-items: center;
				justify-content: center;
				scroll-snap-align: center;
			}

			/* Mínimo de 24px entre os itens, sem margens nas laterais */
			.footer-carousel-gallery > div:not(:first-child) {
				margin-left: 24px;
			}

			/* Em telas bem largas, distribui automaticamente para ocupar tudo */
			@media (min-width: 1400px) {
				.footer-carousel-gallery {
					justify-content: space-between;
				}
			}
		</style>

		<div class="footer-carousel-gallery" id="footerCarousel">
			{% for item in settings.footer_carousel %}
				<div>
					{% if item.link %}
						<a href="{{ item.link | setting_url }}" target="_blank">
					{% endif %}
							<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ item.image | static_url | settings_image_url('large') }}" alt="{{ item.more_info | default('Carrossel no rodapé') }}" class="lazyload" style="width:220px;height:220px;object-fit:cover;object-position:center;">
					{% if item.link %}
						</a>
					{% endif %}
					{% if item.more_info %}
						<div class="footer-carousel-info mt-1 font-small">
							{{ item.more_info }}
						</div>
					{% endif %}
				</div>
			{% endfor %}
		</div>

		<script>
			window.addEventListener('load', function () {
				const carousel = document.getElementById('footerCarousel');
				if (carousel && carousel.children.length > 0) {
					const middleIndex = Math.floor(carousel.children.length / 2);
					const middleItem = carousel.children[middleIndex];

					if (middleItem) {
						const itemOffsetLeft = middleItem.offsetLeft;
						const itemWidth = middleItem.offsetWidth;
						const containerWidth = carousel.offsetWidth;

						const scrollTo = itemOffsetLeft - (containerWidth / 2) + (itemWidth / 2);
						carousel.scrollLeft = scrollTo;
					}
				}
			});
		</script>
	</div>
{% endif %} #}
{% if template == 'password' %}
	{% else %}
	{# Instafeed no rodapé #}
		{% if settings.show_instafeed %}
    	{#  **** Instafeed ****  #}
    		{% if show_help or (show_component_help and not has_instafeed) %}
        		{% snipplet 'defaults/home/instafeed_help.tpl' %}
    		{% else %}
        {% include 'snipplets/home/home-instafeed.tpl' %}
    	{% endif %}
{% endif %}

{% endif %}

<div class="container-fluid-48-64-footer ">
	<div class="grid-footer">

		<div class="grid-menu-1">
			{% if settings.news_show %}
				<h4 class="footer-menu-title">
					NEWSLETTER
				</h4>
				{% include 'snipplets/newsletter.tpl' %}
			{% endif %}
		</div>

		<div class="footer-menu-row">
			<div class="grid-menu-2">
				<ul class="list">
					{% if has_footer_menu %}
						{% if settings.footer_menu_title_one %}
							<li class="footer-menu-title">
								{{ settings.footer_menu_title_one }}
							</li>
						{% endif %}
						{% for item in menus[settings.footer_menu] %}
							<li class="footer-menu-item">
								<a class="footer-menu-link" href="{{ item.url }}" {% if item.url | is_external %}target="_blank"{% endif %}>{{ item.name }}</a>
							</li>
						{% endfor %}
					{% else %}
						<li class="footer-menu-item" style="opacity:0;">&nbsp;</li>
					{% endif %}
				</ul>
			</div>
			<div class="grid-menu-3">
				<ul class="list">
					{% if has_footer_menu_secondary %}
						{% if settings.footer_menu_title_two %}
							<li class="footer-menu-title">
								{{ settings.footer_menu_title_two }}
							</li>
						{% endif %}
						{% for item in menus[settings.footer_menu_secondary] %}
							<li class="footer-menu-item">
								<a class="footer-menu-link" href="{{ item.url }}" {% if item.url | is_external %}target="_blank"{% endif %}>{{ item.name }}</a>
							</li>
						{% endfor %}
					{% else %}
						<li class="footer-menu-item" style="opacity:0;">&nbsp;</li>
					{% endif %}
				</ul>
			</div>
		</div>
		
		<div class="grid-menu-4">
			<h4 class="footer-menu-title">
				CONTATO
			</h4>
			<div class="footer-redes-sociais">
				{% for social in settings.redes_sociais_links %}
					<div class="item-rede-social">
						{% if social.link %}
							<a href="{{ social.link | setting_url }}" target="_blank" aria-label="{{ social.name | default('Rede social') }}">
						{% else %}
							<div>
						{% endif %}
								<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ social.image | static_url | settings_image_url('tiny') }}" class="lazyload" width="40" height="40" alt="{{ 'Ícone de' | translate }} {{ social.name | default('rede social') }}">
						{% if social.link %}
							</a>
						{% else %}
							</div>
						{% endif %}
					</div>
				{% endfor %}
			</div>
			{% if settings.footer_contact_show %}
				{% include "snipplets/contact-links.tpl" with {
					footer: true,
					show_address: settings.footer_contact_address,
					show_phone: settings.footer_contact_phone,
					show_email: settings.footer_contact_email
				} %}
			{% endif %}

			{% if has_shipping_payment_logos or (settings.custom_payments_show and settings.custom_payments) %}
			<div class="grid-menu-5 mt-5">
				<h4 class="footer-menu-title">
					formas de pagamento
				</h4>
				<div class="footer-payments-shipping-logos pr-3 pr-md-0">

					{% if settings.custom_payments_show and settings.custom_payments %}
						{# Formas de pagamento personalizadas #}
						{% for payment in settings.custom_payments %}
							<img src="{{ 'images/empty-placeholder.png' | static_url }}" 
								 data-src="{{ payment.image | static_url | settings_image_url('tiny') }}" 
								 class="lazyload card-img {% if settings.custom_payments_size == 'small' %}card-img-small{% else %}card-img-media{% endif %} mr-1 border-radius-8" 
								 alt="Forma de pagamento" 
								 width="40" height="25"
								 />
						{% endfor %}
					{% else %}
						{# Formas de pagamento automáticas da Nuvem #}
						{% if has_payment_logos %}
							{{ component('payment-shipping-logos', {'type' : 'payments', logo_img_classes : 'card-img card-img-small mr-1'}) }}
						{% endif %}
					{% endif %}

					{# Formas de envio automáticas da Nuvem #}
					{% if has_shipping_logos %}
						{{ component('payment-shipping-logos', {'type' : 'shipping', logo_img_classes : 'card-img card-img-small mr-1'}) }}
					{% endif %}

				</div>
			</div>
		{% endif %}
		</div>
		
	</div>

</div>

{# Redes sociais laterais fixas #}
{% include 'snipplets/social-fixed.tpl' %}

	{# Video no rodapé - estrutura igual ao home-banner-video-horizontal #}
	{% set footer_video_link = settings.footer_video_embed %}

	{% if footer_video_link and settings.footer_video_show %}
		<section class="js-section-footer-video-horizontal section-footer-video-horizontal position-relative section-home" data-store="footer-video-horizontal" data-transition="fade-in-up">
			<div class="footer-video-horizontal {% if settings.footer_video_size_option == 'zoom' %}-video-zoom{% else %}-video-original{% endif %}">
				<figure class="image -custom d-none d-md-block">
					<div class="js-video home-video embed-responsive embed-responsive-30by9 position-relative">
						{% if settings.footer_video_type == 'sound' %}
							<a href="javascript:void(0)" class="js-play-button video-player">
								<div class="video-player-icon">
									<svg class="icon-inline icon-3x svg-icon-text"><use xlink:href="#play"/></svg>
								</div>
							</a>
						{% endif %}
						
						{# Video thumbnail #}
						<div class="js-video-image">
							{% set video_url = footer_video_link %}
							{% set video_id = '' %}
							{% set video_platform = '' %}
							
							{# YouTube detection #}
							{% if '/watch?v=' in footer_video_link %}
								{% set video_id = video_url|split('/watch?v=')|last|split('&')|first %}
								{% set video_platform = 'youtube' %}
							{% elseif '/youtu.be/' in footer_video_link %}
								{% set video_id = video_url|split('/youtu.be/')|last|split('?')|first %}
								{% set video_platform = 'youtube' %}
							{% elseif '/shorts/' in footer_video_link %}
								{% set video_id = video_url|split('/shorts/')|last|split('?')|first %}
								{% set video_platform = 'youtube' %}
							{# Vimeo detection #}
							{% elseif 'vimeo.com/' in footer_video_link %}
								{% set video_id = video_url|split('vimeo.com/')|last|split('?')|first|split('/')[0] %}
								{% set video_platform = 'vimeo' %}
							{% endif %}
							
							{% if video_platform == 'youtube' %}
								{% set video_image_src = 'https://img.youtube.com/vi/' ~ video_id ~ '/maxresdefault.jpg' %}
							{% elseif video_platform == 'vimeo' %}
								{% set video_image_src = 'https://vumbnail.com/' ~ video_id ~ '.jpg' %}
							{% endif %}
							
							<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ video_image_src }}" class="lazyload video-image fade-in" alt="{{ 'Video de' | translate }} {{ store.name }}" />
							<div class="placeholder-fade"></div>
						</div>

						{# Empty iframe component: will be filled with JS on play button click #}
						<div class="js-video-iframe embed-responsive embed-responsive-30by9" style="display: none;" data-video-color="{{ settings.accent_color | trim('#') }}" data-video-url="{{ footer_video_link }}">
						</div>

						{# Footer logo floating in center of video #}
						{% if "footer_logo_image.jpg" | has_custom_image and settings.footer_logo_show %}
							<div class="footer-video-logo">
								<img src="{{ 'footer_logo_image.jpg' | static_url }}" alt="{{ store.name }}" />
							</div>
						{% endif %}

						{# Overlays para esconder controles do YouTube - igual ao banner #}
						<div class="video-overlay-blocker"></div>
						<div class="video-controls-mask top"></div>
						<div class="video-controls-mask bottom"></div>
						<div class="video-controls-mask left"></div>
						<div class="video-controls-mask right"></div>
					</div>
				</figure>

				<figure class="image -custom d-md-none">
					<div class="js-video home-video embed-responsive embed-responsive-30by9 position-relative">
						{% if settings.footer_video_type == 'sound' %}
							<a href="javascript:void(0)" class="js-play-button video-player">
								<div class="video-player-icon">
									<svg class="icon-inline icon-3x svg-icon-text"><use xlink:href="#play"/></svg>
								</div>
							</a>
						{% endif %}
						
						{# Video thumbnail #}
						<div class="js-video-image">
							<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ video_image_src }}" class="lazyload video-image fade-in" alt="{{ 'Vídeo institucional do rodapé' | translate }}" width="1200" height="360" />
							<div class="placeholder-fade"></div>
						</div>

						{# Empty iframe component: will be filled with JS on play button click #}
						<div class="js-video-iframe embed-responsive embed-responsive-30by9" style="display: none;" data-video-color="{{ settings.accent_color | trim('#') }}" data-video-url="{{ footer_video_link }}" title="{{ 'Player do vídeo institucional' | translate }}">
						</div>

						{# Footer logo floating in center of video #}
						{% if "footer_logo_image.jpg" | has_custom_image and settings.footer_logo_show %}
							<div class="footer-video-logo">
								<img 
									src="{{ 'footer_logo_image.jpg' | static_url }}" 
									alt="{{ store.name }}" 
								/>
							</div>
						{% endif %}


						{# Overlays para esconder controles do YouTube - igual ao banner #}
						<div class="video-overlay-blocker"></div>
						<div class="video-controls-mask top"></div>
						<div class="video-controls-mask bottom"></div>
						<div class="video-controls-mask left"></div>
						<div class="video-controls-mask right"></div>
					</div>
				</figure>
			</div>
		</section>

		<script>
			document.addEventListener('DOMContentLoaded', function() {
				var videoContainers = document.querySelectorAll('.js-section-footer-video-horizontal .js-video');
				var videoUrl = '{{ footer_video_link }}';
				var videoType = '{{ settings.footer_video_type }}';
				var videoSizeOption = '{{ settings.footer_video_size_option }}';
				
				if (videoContainers.length && videoUrl) {
					// Detectar plataforma e extrair ID do vídeo
					var videoId = '';
					var videoPlatform = '';
					
					if (videoUrl.includes('/watch?v=')) {
						videoId = videoUrl.split('/watch?v=')[1].split('&')[0];
						videoPlatform = 'youtube';
					} else if (videoUrl.includes('/youtu.be/')) {
						videoId = videoUrl.split('/youtu.be/')[1].split('?')[0];
						videoPlatform = 'youtube';
					} else if (videoUrl.includes('/shorts/')) {
						videoId = videoUrl.split('/shorts/')[1].split('?')[0];
						videoPlatform = 'youtube';
					} else if (videoUrl.includes('vimeo.com/')) {
						videoId = videoUrl.split('vimeo.com/')[1].split('?')[0].split('/')[0];
						videoPlatform = 'vimeo';
					}
					
					if (videoId && videoPlatform) {
						videoContainers.forEach(function(videoContainer) {
							var iframeContainer = videoContainer.querySelector('.js-video-iframe');
							var videoImage = videoContainer.querySelector('.js-video-image');
							var playButton = videoContainer.querySelector('.js-play-button');
							
							// Função para criar e carregar iframe
							function loadVideo(autoplay) {
								var iframe = document.createElement('iframe');
								var params = [];
								var embedUrl = '';
								
								if (videoPlatform === 'youtube') {
									embedUrl = 'https://www.youtube.com/embed/' + videoId;
									
									if (autoplay) {
										params.push('autoplay=1', 'mute=1');
									}
									
									if (videoType === 'autoplay') {
										params.push('controls=0', 'showinfo=0', 'rel=0', 'loop=1', 'playlist=' + videoId, 'modestbranding=1', 'playsinline=1', 'iv_load_policy=3', 'fs=0', 'disablekb=1', 'cc_load_policy=0', 'enablejsapi=1', 'start=0', 'end=0', 'version=3', 'wmode=transparent', 'origin=' + window.location.origin);
									} else {
										params.push('rel=0', 'modestbranding=1', 'playsinline=1');
									}
								} else if (videoPlatform === 'vimeo') {
									embedUrl = 'https://player.vimeo.com/video/' + videoId;
									var accentColor = '{{ settings.accent_color | trim('#') }}';
									
									if (autoplay) {
										params.push('autoplay=1', 'muted=1');
									}
									
									if (videoType === 'autoplay') {
										params.push('background=1', 'loop=1', 'controls=0');
									} else {
										params.push('title=0', 'byline=0', 'portrait=0');
									}
									
									if (accentColor) {
										params.push('color=' + accentColor);
									}
									
									params.push('dnt=1', 'playsinline=1');
								}
								
								iframe.src = embedUrl + (params.length ? '?' + params.join('&') : '');
								iframe.width = '100%';
								iframe.height = '100%';
								iframe.frameBorder = '0';
								iframe.allowFullscreen = true;
								iframe.allow = 'accelerometer; autoplay; clipboard-write; encrypted-media; gyroscope; picture-in-picture';
								
								if (videoType === 'autoplay') {
									iframe.style.pointerEvents = 'none';
								}
								
								// Aplicar estilos baseados na opção de tamanho selecionada
								// O CSS já aplica as transformações via classes, então apenas definimos position e border
								iframe.style.border = 'none';
								
								// Limpar container e adicionar iframe
								iframeContainer.innerHTML = '';
								iframeContainer.appendChild(iframe);
								
								// Mostrar iframe e esconder imagem
								iframeContainer.style.display = 'block';
								if (videoImage) {
									videoImage.style.display = 'none';
								}
								if (playButton) {
									playButton.style.display = 'none';
								}
								
								// API do YouTube para controlar o loop no autoplay
								if (videoPlatform === 'youtube' && videoType === 'autoplay') {
									window.addEventListener('message', function(event) {
										if (event.origin !== 'https://www.youtube.com') return;
										
										var data = {};
										try {
											data = JSON.parse(event.data);
										} catch (e) {
											return;
										}
										
										// Quando o vídeo termina, reinicia imediatamente
										if (data.event === 'video-progress' && data.info && data.info.currentTime) {
											var duration = data.info.duration;
											var currentTime = data.info.currentTime;
											
											// Se chegou perto do fim (últimos 0.1 segundos), reinicia
											if (duration && currentTime >= duration - 0.1) {
												iframe.contentWindow.postMessage('{"event":"command","func":"seekTo","args":[0,true]}', '*');
											}
										}
									});
								}
							}
							
							// Se for autoplay, carregar automaticamente
							if (videoType === 'autoplay') {
								// Carregar IMEDIATAMENTE sem esperar scroll ou delay
								loadVideo(true);
							}
							
							// Se for sound, carregar quando clicar no play
							if (playButton && videoType === 'sound') {
								playButton.addEventListener('click', function(e) {
									e.preventDefault();
									loadVideo(true);
								});
							}
						});
					}
				}
			});
		</script>
	{% endif %}

	{#<div class="divider-footer my-5"></div>#}

<div class="container-fluid-32-64">
	<div class="copyright d-flex flex-column flex-md-row align-items-start align-items-md-center justify-content-between w-100" style="gap:32px;">
		<div class="copyright-address">
			<div class="text-left opacity-50 font-small" style="margin-bottom: 6px; color: var(--neutral-white, #FFF); font-family: 'Hanken Grotesk'; font-size: 12px; font-style: normal; font-weight: 400; line-height: normal; white-space: normal; overflow-wrap: anywhere;">
				© 2025, Eora Brand SA. CNPJ: 51.595.087/0001-28. Todos os direitos reservados.
			</div>
			<div class="text-left opacity-50 font-small" style="color: var(--neutral-white, #FFF); font-family: 'Hanken Grotesk'; font-size: 12px; font-style: normal; font-weight: 400; line-height: normal; white-space: normal; overflow-wrap: anywhere;">
				Rua Líbero Badaró, 101, Segundo Andar, Centro Histórico de São Paulo, Cep 01011-100
			</div>
		</div>
		<div class="copyright-credits d-flex flex-column flex-md-row align-items-start align-items-md-center justify-content-end text-links-devs" style="gap:32px;">
		<div class="text-left text-md-right ml-0 ml-md-auto d-flex flex-column align-items-start justify-content-start flex-md-row align-items-md-center justify-content-md-end text-links-devs">
			{#
				La leyenda que aparece debajo de esta linea de código debe mantenerse
				con las mismas palabras y con su apropiado link a Tienda Nube;
				como especifican nuestros términos de uso: http://www.tiendanube.com/terminos-de-uso .
				Si quieres puedes modificar el estilo y posición de la leyenda para que se adapte a
				tu sitio. Pero debe mantenerse visible para los visitantes y con el link funcional.
				Os créditos que aparece debaixo da linha de código deverá ser mantida com as mesmas
				palavras e com seu link para Nuvem Shop; como especificam nossos Termos de Uso:
				http://www.nuvemshop.com.br/termos-de-uso. Se você quiser poderá alterar o estilo
				e a posição dos créditos para que ele se adque ao seu site. Porém você precisa
				manter visivél e com um link funcionando.
				#}
				
			<div class="d-flex align-items-center" style="margin-bottom: 6px;" class="mb-0 mb-md-0 mb-sm-2">
				<span class="opacity-50" style="color: var(--neutral-white, #FFF); font-family: 'Hanken Grotesk'; font-size: 12px; font-style: normal; font-weight: 400; line-height: normal;">Tecnologia de e-commerce</span>
				<a href="https://www.nuvemshop.com.br/next" target="_blank" class="ml-2">Nuvemshop Next</a>
				{# {{ new_powered_by_link }}
	
				{{ component('claim-info', {
						container_classes: 'font-small',
						divider_classes: "mx-1",
						text_classes: {text_consumer_defense: 'd-inline-block mb-1'},
						link_classes: {
							link_consumer_defense: "btn-link font-small",
							link_order_cancellation: "btn-link font-small",
						},
					})
				}} #}
			</div>
			{# <style>
				@media (max-width: 767px) {
					.d-flex.align-items-center {
						margin-bottom: 6px !important;
					}
				}
				@media (min-width: 768px) {
					.d-flex.align-items-center {
						margin-bottom: 0 !important;
					}
				}
			</style> #}

			<span class="mx-4 d-none d-md-flex">
				<svg width="5" height="6" viewBox="0 0 2 3" fill="none" xmlns="http://www.w3.org/2000/svg">
					<circle cx="1" cy="1.0625" r="1" fill="#F2F2F2"/>
				</svg>
			</span>
			<div class="d-flex align-items-center">
				<span class="opacity-50" style="color: var(--neutral-white, #FFF); font-family: 'Hanken Grotesk'; font-size: 12px; font-style: normal; font-weight: 400; line-height: normal;">Desenvolvido por</span>
				<span class="ml-2" style="color: var(--neutral-white, #FFF); font-family: 'Hanken Grotesk'; font-size: 12px; font-style: normal; font-weight: 400; line-height: normal;">Richard Camargo</span>
			</div>
		</div>
		</div>
	</div>
		{# <div class="text-footer">
			<p class="opacity-50">
				© 2025Loja Sneakers. Todos os direitos reservados.
			</p>
			<p class="opacity-50">
				De segunda à quinta-feira, das 8h às 18h. - CNPJ 26.636.428/0001-19
			</p>
		</div> #}
	</div>
</div>

	{# 
		{% if has_right_md_col_content %}
			<div class="{% if password_page %}col-md-12{% else %}col-md-6 {{ vertical_spacing_classes }} pr-0 {% if has_footer_menu %}pl-md-5 pr-md-3{% else %}pr-md-5{% endif %}{% endif %}">
				<div class="js-footer-col-sticky col-sticky-md">
					
					<div class="mb-4 pb-3 pr-3 pr-md-0">
						{% if has_footer_contact_info and not password_page %}
							{% include "snipplets/contact-links.tpl" with {footer: true} %}
						</div>
					{% endif %}

					
					{% if has_languages and not password_page %}
						<div class="mb-4">
							<a href="#" data-toggle="#languages" class="js-modal-open btn-link text-transform">
								{{ "Idiomas y monedas" | translate }}
							</a>
							{% embed "snipplets/modal.tpl" with{modal_id: 'languages', modal_class: 'bottom modal-centered-small', modal_position: 'center', modal_transition: 'slide', modal_header_title: true, modal_footer: false, modal_width: 'centered', modal_zindex_top: true} %}
								{% block modal_head %}
									{{ 'Idiomas y monedas' | translate }}
								{% endblock %}
								{% block modal_body %}
									{% include "snipplets/navigation/navigation-lang.tpl" %}
								{% endblock %}
							{% endembed %}
						</div>
					{% endif %}
				</div>
			</div>
		{% endif %}


		{% if has_seal_logos %}
			<div class="text-left text-md-center {{ vertical_spacing_classes }}">
				{% if store.afip or ebit %}
					{% if store.afip %}
						<span class="footer-logo afip seal-afip mr-3 mb-3">
							{{ store.afip | raw }}
						</span>
					{% endif %}
					{% if ebit %}
						<span class="footer-logo ebit seal-ebit mr-3 mb-3">
							{{ ebit }}
						</span>
					{% endif %}
				{% endif %}
				{% if "seal_img.jpg" | has_custom_image or settings.custom_seal_code %}
					{% if "seal_img.jpg" | has_custom_image %}
						<span class="footer-logo custom-seal mr-3 mb-3">
							{% if settings.seal_url != '' %}
								<a href="{{ settings.seal_url | setting_url }}" target="_blank">
							{% endif %}
								<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="{{ "seal_img.jpg" | static_url }}" class="custom-seal-img lazyload" alt="{{ 'Sello de' | translate }} {{ store.name }}"/>
							{% if settings.seal_url != '' %}
								</a>
							{% endif %}
						</span>
					{% endif %}
					{% if settings.custom_seal_code %}
						<span class="custom-seal custom-seal-code mr-3 mb-3">
							{{ settings.custom_seal_code | raw }}
						</span>
					{% endif %}
				{% endif %}
			</div>
		{% endif %}
	#}
	
</footer>