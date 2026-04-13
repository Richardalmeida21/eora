{# === Configuração dos banners de categoria === #}


{# {% set has_banners = settings.category_banners_show and settings.category_banners_images and settings.category_banners_images is not empty %} #}
{# {% set section_banners = settings.category_banners_images %} #}
{# {% set section_title = settings.category_banners_images_title | default('') %} #}

{% set section_banners = attribute(settings,"#{settings_name}_category_images") %}
{% set section_banners_show = attribute(settings,"#{settings_name}_category_banners_show") %}
{% set section_title = attribute(settings,"#{settings_name}_category_banners_title") %}

{% set has_banners = section_banners_show and section_banners and section_banners is not empty %}

{% if has_banners %}
<section class="position-relative no-x-padding pt-5 pb-0 pb-md-5">
	{% if section_title %}
		<h2 class="section-title text-center h3">{{ section_title }}</h2>
	{% endif %}
	<style>
		/* Remove padding lateral do container-fluid para colar nas bordas */
		.banner-categorias.container-fluid.no-x-padding {
			padding-left: 0 !important;
			padding-right: 0 !important;
		}
		/* ============================
			BOTÃO INTERNO DENTRO DO BANNER
		============================ */
		.category-banners-grid-img-wrapper {
			position: relative;
			width: 360px;
			height: 470px;
			overflow: hidden;
			background: #f7f7f7;
			margin: 0;
			padding: 0;
			display: block;
		}
		.category-banners-grid-img-wrapper img {
			width: 100%;
			height: 100%;
			object-fit: cover;
			display: block;
			margin: 0;
			box-shadow: none;
		}
		.banner-categorias .row,
		.banner-categorias .row.gx-0 {
			gap: 0 !important;
			margin: 0 !important;
		}
		.image {
			position: relative;
		}
		.banner-floating-button-category {
			position: absolute;
			left: 16px;
			bottom: 16px;
			display: flex;
			flex-direction: column;
			justify-content: center;
			align-items: flex-start;
			gap: 10px;
			padding: 16px;
			background: var(--banner-floating-background);
			backdrop-filter: blur(8px);
			width: 180px;
			text-decoration: none;
			color: var(--banner-floating-text);
			z-index: 2;
			cursor: pointer;
		}
		.banner-floating-button-category-content {
			display: flex;
			justify-content: space-between;
			align-items: center;
			gap: 25px;
		}
		.banner-floating-title {
			color: var(--banner-floating-text,#222);
			font-size: 14px;
			font-weight: 500;
			letter-spacing: 2px;
			text-transform: uppercase;
		}
		.banner-floating-icon {
			width: 12px;
			height: 12px;
			color: var(--banner-floating-text,#222);
			transform: scaleX(-1);
		}

		/* ============================
			BANNERS -- images -- carrossel
		============================ */

		.category-banners-dots {
			position: absolute;
			left: 0;
			right: 0;
			bottom: 32px;
			display: none;
			justify-content: center;
			z-index: 10;
			align-items: center;
			gap: 0;
			margin-top: 0;
			pointer-events: none;
		}
		@media (max-width: 1439px) {
			.category-banners-dots {
				position: relative;
				display: flex !important;
				margin: 32px 0;
				margin-top: 64px;
			}
		}
		.category-banners-dot {
			width: 80px;
			height: 2px;
			background: rgba(0, 0, 0, 0.12);
			border: none;
			border-radius: 0px;
			margin: 0 8px;
			transition: all 0.3s;
			display: inline-block;
			opacity: 1;
			pointer-events: auto;
			cursor: pointer;
			outline: none;
		}
		.category-banners-dot.active {
			background: #000000ff;
			opacity: 1;
		}
		.category-banners-gallery {
			width: 100%;
			margin: 0;
			padding: 0;
		}
		.category-banners-gallery-item {
			margin: 0;
			padding: 0;
		}
		/* Carrossel para telas menores que 1440px */
		@media (max-width: 1439px) {
			.category-banners-gallery {
				display: flex;
				justify-content: flex-start;
				overflow-x: auto;
				scrollbar-width: none;
				-ms-overflow-style: none;
				scroll-snap-type: x mandatory;
				min-width: 100vw;
				box-sizing: border-box;
			}
			.category-banners-gallery::-webkit-scrollbar { display: none; }
			.category-banners-gallery-item {
				flex: 0 0 auto;
				display: flex;
				align-items: center;
				justify-content: center;
				scroll-snap-align: center;
			}
		}
		/* Grid para telas a partir de 1440px */
		@media (min-width: 1440px) {
			.category-banners-gallery {
				display: grid;
				grid-template-columns: repeat(auto-fit, minmax(0, 1fr)); /* ocupa todo o espaço */
				gap: 0;
				width: 100%;
				height: 100%; /* deixa o grid crescer em altura */
			}
			.category-banners-gallery-item {
				width: 100%;
				height: 100%;
				margin: 0;
				padding: 0;
			}
			.category-banners-grid-img-wrapper {
				width: 100%;
				height: 100%;
				aspect-ratio: auto; /* remove trava do 360/470 */
			}
			.category-banners-grid-img-wrapper img {
				width: 100%;
				height: 100%;
				object-fit: cover; /* imagem cobre tudo sem distorcer */
			}
		}
	</style>
	<div class="category-banners-gallery" id="categoryBannersCarousel">
		{% for banner in section_banners %}
			{% if loop.first %}
			{% else %}
				<div class="category-banners-gallery-item">
					<div class="position-relative d-flex flex-column align-items-center">
						<a href="{{ banner.link|default('#') }}" class="w-100 h-100" {% if banner.link %}target="_blank"{% endif %} style="display:block;">
							<div class="category-banners-grid-img-wrapper">
								<img 
									src="{{ 'images/empty-placeholder.png' | static_url }}"
									data-srcset="{{ banner.image | static_url | settings_image_url('original') }} 1024w, {{ banner.image | static_url | settings_image_url('1080p') }} 1920w"
									data-sizes="auto"
									class="lazyautosizes lazyload fade-in"
									width="360" height="470"
									alt="{{ banner.title|default('Banner categoria') }}"
								/>
							</div>
							{% if banner.title %}
								<span class="banner-floating-button-category">
									<span class="banner-floating-button-category-content">
										<span class="banner-floating-title">{{ banner.title }}</span>
										<svg class="banner-floating-icon" viewBox="0 0 10 10" fill="none">
											<use xlink:href="#chevron-diagonal"></use>
										</svg>
									</span>
								</span>
							{% endif %}
						</a>
					</div>
				</div>
			{% endif %}
		{% endfor %}
	</div>
	<div class="category-banners-dots" id="categoryBannersDots"></div>
	<script>
		function renderCategoryBannersDots() {
			var carousel = document.getElementById('categoryBannersCarousel');
			var dotsContainer = document.getElementById('categoryBannersDots');
			var isMobile = window.innerWidth < 1440;
			if (carousel && carousel.children.length > 0 && dotsContainer) {
				if (isMobile) {
					// Centralizar item no mobile
					var middleIndex = Math.floor(carousel.children.length / 2);
					var middleItem = carousel.children[middleIndex];
					if (middleItem) {
						var itemOffsetLeft = middleItem.offsetLeft;
						var itemWidth = middleItem.offsetWidth;
						var containerWidth = carousel.offsetWidth;
						var scrollTo = itemOffsetLeft - (containerWidth / 2) + (itemWidth / 2);
						carousel.scrollLeft = scrollTo;
					}
					// Dot pagination
					var items = Array.from(carousel.children);
					dotsContainer.innerHTML = '';
					items.forEach(function(_, idx) {
						var dot = document.createElement('button');
						dot.className = 'category-banners-dot' + (idx === 0 ? ' active' : '');
						dot.setAttribute('aria-label', 'Ir para banner ' + (idx + 1));
						dot.addEventListener('click', function() {
							var item = items[idx];
							if (item) {
								var itemOffsetLeft = item.offsetLeft;
								var itemWidth = item.offsetWidth;
								var containerWidth = carousel.offsetWidth;
								var scrollTo = itemOffsetLeft - (containerWidth / 2) + (itemWidth / 2);
								carousel.scrollTo({ left: scrollTo, behavior: 'smooth' });
							}
						});
						dotsContainer.appendChild(dot);
					});
					// Atualizar dot ativo ao scroll
					carousel.addEventListener('scroll', function() {
						var scrollLeft = carousel.scrollLeft;
						var containerWidth = carousel.offsetWidth;
						var activeIdx = 0;
						items.forEach(function(item, idx) {
							var itemCenter = item.offsetLeft + item.offsetWidth / 2;
							if (itemCenter - scrollLeft < containerWidth / 2 + item.offsetWidth / 2) {
								activeIdx = idx;
							}
						});
						Array.from(dotsContainer.children).forEach(function(dot, idx) {
							dot.classList.toggle('active', idx === activeIdx);
						});
					});
					dotsContainer.style.display = 'flex';
				} else {
					dotsContainer.innerHTML = '';
					dotsContainer.style.display = 'none';
				}
			}
		}
		window.addEventListener('load', renderCategoryBannersDots);
		window.addEventListener('resize', function() {
			// Redesenhar dots ao redimensionar tela
			renderCategoryBannersDots();
		});
	</script>
</section>
{% endif %}
