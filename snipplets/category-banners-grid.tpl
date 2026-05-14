{# === Configuração dos banners de categoria === #}
{% set has_banners = settings.category_banners_show and settings.category_banners_images and settings.category_banners_images is not empty %}
{% set section_banners = settings.category_banners_images %}
{% set section_title = settings.category_banners_images_title | default('') %}

{% if has_banners %}
<section class="section-category-banners">
	{% if section_title %}
		<h2 class="section-title-banners-scroll">{{ section_title }}</h2>
	{% endif %}

	<div class="cat-banners-wrapper">
		<button class="cat-banners-arrow js-cat-banners-prev" aria-label="Anterior">
			<svg width="8" height="14" viewBox="0 0 8 14" fill="none"><path d="M7 1L1 7L7 13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
		</button>
		<div class="js-swiper-cat-banners swiper-container">
			<div class="swiper-wrapper">
				{% for banner in section_banners %}
				<div class="swiper-slide">
					<div class="cat-banner-img-wrap">
						{% if loop.first %}
							<img src="{{ banner.image | static_url | settings_image_url('original') }}"
								class="img-fluid d-block w-100"
								alt="{{ banner.title|default('') }}"
								style="width:100%;display:block;" />
						{% else %}
							<img src="{{ 'images/empty-placeholder.png' | static_url }}"
								data-srcset="{{ banner.image | static_url | settings_image_url('original') }}"
								class="lazyload fade-in img-fluid d-block w-100"
								alt="{{ banner.title|default('') }}"
								style="width:100%;display:block;" />
						{% endif %}
						{% if banner.title %}
							<div class="banner-floating-button">
								<div class="banner-floating-button-content">
									<div class="banner-floating-title">{{ banner.title }}</div>
									<svg class="banner-floating-icon" viewBox="0 0 10 10" fill="none" style="transform:scaleX(-1)"><use xlink:href="#chevron-diagonal"></use></svg>
								</div>
							</div>
						{% endif %}
						{% if banner.link %}<a href="{{ banner.link }}" class="full-width-link"></a>{% endif %}
					</div>
				</div>
				{% endfor %}
			</div>
		</div>
		<button class="cat-banners-arrow js-cat-banners-next" aria-label="Próximo">
			<svg width="8" height="14" viewBox="0 0 8 14" fill="none"><path d="M1 1L7 7L1 13" stroke="currentColor" stroke-width="1.5" stroke-linecap="round" stroke-linejoin="round"/></svg>
		</button>
	</div>

	<style>
		.section-category-banners { margin: 40px 0; }
		.section-title-banners-scroll {
			display: block; text-align: center; font-size: 1.4rem;
			letter-spacing: 2px; text-transform: uppercase;
			font-weight: 800; color: #000; margin: 0 0 24px;
		}
		.cat-banners-wrapper {
			position: relative;
			padding: 0 56px;
		}
		.cat-banners-arrow {
			position: absolute; top: 50%; transform: translateY(-50%);
			z-index: 5; width: 44px; height: 44px; border-radius: 50%;
			border: 1px solid #000; background: #fff; color: #000;
			cursor: pointer; display: flex; align-items: center;
			justify-content: center; padding: 0;
			transition: background .2s ease, color .2s ease, opacity .2s ease;
		}
		.cat-banners-arrow:hover { background: #000; color: #fff; }
		.cat-banners-arrow:focus { outline: none; }
		.cat-banners-arrow.swiper-button-disabled { opacity: .35; cursor: default; }
		.js-cat-banners-prev { left: 4px; }
		.js-cat-banners-next { right: 4px; }
		.cat-banner-img-wrap { position: relative; overflow: hidden; }
		.cat-banner-img-wrap img { display: block; width: 100%; }
		.full-width-link { position: absolute; top:0; left:0; width:100%; height:100%; z-index:5; }
		@media (max-width: 991px) {
			.cat-banners-wrapper { padding: 0 40px; }
			.cat-banners-arrow { width: 38px; height: 38px; }
		}
		@media (max-width: 767px) {
			.section-category-banners { margin: 24px 0; }
			.section-title-banners-scroll { font-size: 1.1rem; margin-bottom: 16px; }
			.cat-banners-wrapper { padding: 0; overflow: hidden; }
			.cat-banners-arrow { display: none; }
			.js-swiper-cat-banners { overflow: visible; }
		}
	</style>

	<script>
	(function(){
		function initCatBanners() {
			if (typeof Swiper === 'undefined') return false;
			var el = document.querySelector('.js-swiper-cat-banners');
			if (!el || el.dataset.swiperInit === '1') return true;
			el.dataset.swiperInit = '1';
			new Swiper(el, {
				slidesPerView: 3,
				spaceBetween: 0,
				loop: false,
				observer: true,
				observeParents: true,
				centerInsufficientSlides: true,
				navigation: {
					prevEl: '.js-cat-banners-prev',
					nextEl: '.js-cat-banners-next'
				},
				breakpoints: {
					0:   { slidesPerView: 1.12, spaceBetween: 0, centeredSlides: false },
					768: { slidesPerView: 3, spaceBetween: 0 }
				}
			});
			return true;
		}
		if (!initCatBanners()) {
			document.addEventListener('DOMContentLoaded', function(){
				var tries = 0;
				var iv = setInterval(function(){
					tries++;
					if (initCatBanners() || tries > 20) clearInterval(iv);
				}, 250);
			});
		}
	})();
	</script>
</section>
{% endif %}
