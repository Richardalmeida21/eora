{% set has_multiple_slides = product.images_count > 1 or product.video_url %}

{# {% set product_grid_detail = not mobile and settings.product_image_format == 'grid' %} #}
{% set product_grid_detail = not mobile %}
{% set product_grid_detail_md_class = product_grid_detail ? 'd-md-none' %}

{% set product_img_height =  settings.product_img_height | default(100) %}
{% set product_img_width =  settings.product_img_width | default(100) %}

{% set is_coach_layout = 'layout_coach' in product.description %}
<div class="{% if mobile %}d-xl-none{% else %}d-none d-xl-block{% endif %} {% if is_coach_layout and not mobile %}coach-style-layout{% endif %}" data-store="product-image-{{ product.id }}">

    {% if product.images_count > 0 %}
        {% if is_coach_layout and not mobile and product.images_count > 1 %}
            <div class="custom-thumbnails-container">
                <button class="thumb-nav-arrow up js-thumb-nav-up">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M18 15l-6-6-6 6"></path></svg>
                </button>
                <div class="custom-thumbnails-strip">
                    {% for image in product.images %}
                        <button class="custom-thumb {% if loop.first %}active{% endif %}" data-index="{{ loop.index0 }}">
                            <img src="{{ image | product_image_url('tiny') }}" />
                        </button>
                    {% endfor %}
                </div>
                <button class="thumb-nav-arrow down js-thumb-nav-down">
                    <svg viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2"><path d="M6 9l6 6 6-6"></path></svg>
                </button>
            </div>
            <script>
            document.addEventListener('DOMContentLoaded', function() {
                var wrapper = document.querySelector('.coach-style-layout');
                if (!wrapper) return;
                
                var container = wrapper.querySelector('.custom-thumbnails-container');
                var strip = wrapper.querySelector('.custom-thumbnails-strip');
                var slider = wrapper.querySelector('.product-detail-slider');

                if (strip && slider) {
                    var thumbs = strip.querySelectorAll('.custom-thumb');
                    var slides = slider.querySelectorAll('.js-product-slide');
                    var btnUp = container.querySelector('.js-thumb-nav-up');
                    var btnDown = container.querySelector('.js-thumb-nav-down');
                    
                    // Sync Slide visibility
                    slides.forEach(function(slide, idx) {
                        if (idx === 0) slide.classList.add('coach-slide-active');
                        else slide.classList.remove('coach-slide-active');
                    });
                    
                    thumbs.forEach(function(thumb, index) {
                        thumb.addEventListener('click', function() {
                            thumbs.forEach(function(t) { t.classList.remove('active'); });
                            thumb.classList.add('active');
                            slides.forEach(function(slide, idx) {
                                if(idx === index) slide.classList.add('coach-slide-active');
                                else slide.classList.remove('coach-slide-active');
                            });
                        });
                    });

                    // Scroll logic for arrows
                    if (btnUp && btnDown) {
                        btnUp.addEventListener('click', function() { strip.scrollBy({ top: -100, behavior: 'smooth' }); });
                        btnDown.addEventListener('click', function() { strip.scrollBy({ top: 100, behavior: 'smooth' }); });
                    }
                }
            });
            </script>
        {% endif %}

		<div class="{% if product_grid_detail and mobile == false %} product-detail-slider {% endif %} {% if mobile %} js-swiper-product swiper-container px-3 {% endif %}" style="visibility:hidden; height:0;" data-product-images-amount="{{ product.images_count }}">
				{% include 'snipplets/labels.tpl' with {product_detail: true, label_custom_class: product_grid_detail_md_class} %}
			<div class="swiper-wrapper">
				{% for image in product.images %}
					<div class="js-product-slide swiper-slide{% if settings.product_image_format == 'slider' or home_main_product %} product-slide{% if home_main_product %}-small{% endif %}{% endif %} slider-slide{% if product_grid_detail and not mobile %} col-md-6 {% endif %}" data-image="{{image.id}}" data-image-position="{{loop.index0}}">
					{% if home_main_product %}
						<div class="js-product-slide-link d-block position-relative" style="padding-bottom: {{ image.dimensions['height'] / image.dimensions['width'] * 100}}%;">
					{% else %}
						<a href="{{ image | product_image_url('original') }}" data-fancybox="product-gallery" class="js-product-slide-link d-block position-relative"
						style="padding-bottom: {{ product_img_height / product_img_width * 100}}%;"
						>
					{% endif %}
					{% set has_free_shipping_msg_product = settings.free_shipping_msg_product %}
					{% if product_grid_detail and loop.first and has_free_shipping_msg_product %}
						{% include 'snipplets/labels.tpl' with {product_detail: true, label_custom_class: 'd-none d-md-block'} %}
					{% endif %}
						<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-srcset='{{  image | product_image_url('large') }} 480w, {{  image | product_image_url('huge') }} 640w, {{  image | product_image_url('original') }} 1024w' data-sizes="auto" class="js-product-slide-img product-slider-image img-absolute img-absolute-centered lazyautosizes lazyload" {% if image.alt %}alt="{{image.alt}}"{% endif %} />
						<img src="{{ image | product_image_url('tiny') }}" class="js-product-slide-img product-slider-image img-absolute img-absolute-centered blur-up" {% if image.alt %}alt="{{image.alt}}"{% endif %} />
					{% if loop.first and product.sku and not home_main_product %}
					<button
						type="button"
						class="js-btn-provador-virtual btn-provador-virtual"
						data-mkfashion-identifier="{{ product.sku }}"
						aria-label="Provador Virtual"
						style="display: none;"
					>
						<svg xmlns="http://www.w3.org/2000/svg" width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
							<path d="M23 19a2 2 0 0 1-2 2H3a2 2 0 0 1-2-2V8a2 2 0 0 1 2-2h4l2-3h6l2 3h4a2 2 0 0 1 2 2z"/>
							<circle cx="12" cy="13" r="4"/>
						</svg>
					</button>
					{% endif %}
				{% if home_main_product %}
					</div>
				{% else %}
					</a>
				{% endif %}
				</div>
				{% endfor %}
				{% if not home_main_product %}
					{% include 'snipplets/product/product-video.tpl' %}
				{% endif %}
			</div>
		</div>
		{% snipplet 'placeholders/product-detail-image-placeholder.tpl' %}
	{% endif %}
</div>