{% if product_modal %}

	{# Product video modal wrapper #}

	<div id="product-video-modal" class="js-product-video-modal product-video" style="display: none;">
{% endif %}
		<div class="js-video {% if product_video and not product_modal %}js-video-product{% endif %} embed-responsive embed-responsive-1by1 visible-when-content-ready position-relative">
			{% if product_modal_trigger %}

				{# Open modal in mobile with product video inside #}

				<a href="#product-video-modal" data-fancybox="product-gallery" class="js-play-button video-player d-block d-md-none">
					<div class="video-player-text btn-link h1">
                        {{ 'Play' | translate }}
                    </div>
				</a>
			{% endif %}
			<a href="javascript:void(0)" class="js-play-button video-player {% if product_modal_trigger %}d-none d-md-block{% endif %}">
				<div class="video-player-text btn-link h3-huge">
                    {{ 'Play' | translate }}
                </div>
			</a>

			{# Video thumbnail #}
			
			<div class="js-video-image">
				<img src="{{ 'images/empty-placeholder.png' | static_url }}" data-src="" class="lazyload video-image fade-in" alt="{{ 'Video de' | translate }} {% if template != 'product' %}{{ product.name }}{% else %}{{ store.name }}{% endif %}" style="display: none;">
				<div class="placeholder-fade">
				</div>
			</div>
		</div>
			
		{# Empty iframe component: will be filled with JS on play button click #}

		{% if product.video_url %}
			{% set video_url = product.video_url %}
		{% endif %}

		<div class="js-video-iframe embed-responsive embed-responsive-1by1" style="display: none;" data-video-color="{{ settings.accent_color | trim('#') }}" data-video-url="{{ video_url }}">
		</div>

{% if product_modal %}
	</div>
{% endif %}