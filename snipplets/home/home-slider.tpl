
{% set has_main_slider = settings.slider and settings.slider is not empty %}
{% set has_mobile_slider = settings.toggle_slider_mobile and settings.slider_mobile and settings.slider_mobile is not empty %}
{% set has_left_text = settings.slider_align == 'left' %}
{% set has_centered_text = settings.slider_align == 'center' %}
{% set has_right_text = settings.slider_align == 'right' %}
{% set slider_title_size_mobile = settings.slider_title_size_mobile == 'small' ? 'h4-huge' : settings.slider_title_size_mobile == 'medium' ? 'h2-huge' : 'h1-huge' %}
{% set slider_title_size_desktop = settings.slider_title_size_desktop == 'small' ? 'h2-huge-md' : settings.slider_title_size_desktop == 'medium' ? 'h1-huge-md' : 'h2-extra-huge-md' %}

{% set padding_bottom = 48 %}
{% set width_desktop = settings.slider_width_desktop  %}
{% set height_desktop = settings.slider_height_desktop  %}

{% set width_mobile = settings.slider_width_mobile %}
{% set height_mobile = settings.slider_height_mobile %}

{% if width_desktop > 0 and height_desktop > 0 and not mobile %}
  {% set padding_bottom = (height_desktop / width_desktop) * 100 %}
{% endif %}

{% if width_mobile > 0 and height_mobile > 0 and mobile %}
  {% set padding_bottom = (height_mobile / width_mobile) * 100 %}
{% endif %}

{% if not mobile %}
<div class="js-home-main-slider-container {% if not has_main_slider %}hidden{% endif %}">
{% endif %}
	<div class="{% if mobile %}js-home-mobile-slider{% else %}js-home-main-slider{% endif %}-visibility {% if has_main_slider and has_mobile_slider %}{% if mobile %}d-md-none{% else %}d-none d-md-block{% endif %}{% elseif not settings.toggle_slider_mobile and mobile %}hidden{% endif %}">
		
		<!-- Slider fixo no topo e atrás do header -->
		<div class="section-slider position-relative slider-fixed-top">
			<div class="js-home-slider{% if mobile %}-mobile{% endif %} h-100 swiper-container swiper-container-horizontal">
				<div class="swiper-wrapper">
					{% if mobile %}
						{% set slider = settings.slider_mobile %}
					{% else %}
						{% set slider = settings.slider %}
					{% endif %}

					{# === Vídeo dedicado configurado no painel === #}
					{% if mobile %}
						{% set sv_url = settings.slider_video_mobile | default(settings.slider_video_desktop) %}
					{% else %}
						{% set sv_url = settings.slider_video_desktop %}
					{% endif %}
					{% if sv_url %}
						{% set sv_provider = '' %}
						{% set sv_id = '' %}
						{% set sv_embed = '' %}
						{% if '/watch?v=' in sv_url %}
							{% set sv_id = sv_url | split('/watch?v=') | last | split('&') | first %}
							{% set sv_provider = 'youtube' %}
						{% elseif 'youtu.be/' in sv_url %}
							{% set sv_id = sv_url | split('youtu.be/') | last | split('?') | first %}
							{% set sv_provider = 'youtube' %}
						{% elseif '/shorts/' in sv_url %}
							{% set sv_id = sv_url | split('/shorts/') | last | split('?') | first %}
							{% set sv_provider = 'youtube' %}
						{% elseif 'vimeo.com/' in sv_url %}
							{% set sv_id = sv_url | split('vimeo.com/') | last | split('?') | first | split('/') | first %}
							{% set sv_provider = 'vimeo' %}
						{% endif %}
						{% if sv_provider == 'youtube' %}
							{% set sv_embed = 'https://www.youtube.com/embed/' ~ sv_id ~ '?autoplay=1&mute=1&loop=1&playlist=' ~ sv_id ~ '&controls=0&modestbranding=1&rel=0&iv_load_policy=3&disablekb=1&fs=0&playsinline=1' %}
						{% elseif sv_provider == 'vimeo' %}
							{% set sv_embed = 'https://player.vimeo.com/video/' ~ sv_id ~ '?autoplay=1&muted=1&loop=1&background=1&controls=0&playsinline=1' %}
						{% endif %}
						<div class="swiper-slide slide-container swiper-dark" style="height:100vh;">
							<div class="slider-slide fullscreen video-wrapper">
								<iframe
									src="{{ sv_embed }}"
									title="Banner vídeo"
									frameborder="0"
									allow="autoplay; fullscreen; picture-in-picture"
									allowfullscreen
									class="video-iframe"
									loading="eager"
									width="100%"
									height="360"
								></iframe>
							</div>
						</div>
					{% else %}
					{% for slide in slider %}
  {% set slide_link = slide.link|default('') %}
  {% set video_provider = '' %}
  {% set video_id = '' %}
  {% set embed_url = '' %}

  {# --- YouTube formats --- #}
  {% if slide_link and '/watch?v=' in slide_link or '/youtu.be/' in slide_link or '/shorts/' in slide_link or '/embed/' in slide_link or 'youtube-nocookie.com' in slide_link or 'youtube.com' in slide_link %}
    {% set video_provider = 'youtube' %}
    {% if '/watch?v=' in slide_link %}
      {% set video_format = '/watch?v=' %}
    {% elseif '/shorts/' in slide_link %}
      {% set video_format = '/shorts/' %}
    {% elseif '/youtu.be/' in slide_link %}
      {% set video_format = '/youtu.be/' %}
    {% elseif '/embed/' in slide_link %}
      {% set video_format = '/embed/' %}
    {% else %}
      {% set video_format = '/watch?v=' %}
    {% endif %}
    {% set video_id = (slide_link|split(video_format)|last)|split('#')|first|split('?')|first|split('&')|first %}
    {% if 'youtube-nocookie.com' in slide_link %}
      {% set embed_url = 'https://www.youtube-nocookie.com/embed/' ~ video_id ~ '?rel=0&autoplay=1&mute=1&loop=1&playlist=' ~ video_id ~ '&controls=0&modestbranding=1&iv_load_policy=3&disablekb=1&fs=0&playsinline=1' %}
    {% else %}
      {% set embed_url = 'https://www.youtube.com/embed/' ~ video_id ~ '?autoplay=1&mute=1&loop=1&playlist=' ~ video_id ~ '&controls=0&modestbranding=1&rel=0&iv_load_policy=3&disablekb=1&fs=0&playsinline=1' %}
    {% endif %}

  {# --- Vimeo --- #}
  {% elseif slide_link and ('vimeo.com/' in slide_link) %}
    {% set video_provider = 'vimeo' %}
    {% set tail = (slide_link|split('vimeo.com/')|last)|split('#')|first|split('?')|first %}
    {% set video_id = tail|split('/')|last %}
    {% set embed_url = 'https://player.vimeo.com/video/' ~ video_id ~ '?autoplay=1&muted=1&loop=1&background=1&controls=0&playsinline=1' %}
  {% endif %}

  {% set is_video = video_provider == 'youtube' or video_provider == 'vimeo' %}
  {% set has_text = (not is_video) and (slide.title or slide.description or slide.button) %}

  <div class="swiper-slide slide-container swiper-{{ slide.color }}" style="height:100vh;">
    {% if slide.link and not is_video %}
      <a href="{{ slide.link | setting_url }}" aria-label="{{ 'Carrusel' | translate }} {{ loop.index }}">
    {% endif %}

{# --- VÍDEO: fullscreen --- #}
{% if is_video %}
  {% if video_provider == 'youtube' %}
    {% set thumbnail_url = 'https://img.youtube.com/vi/' ~ video_id ~ '/maxresdefault.jpg' %}
  {% elseif video_provider == 'vimeo' %}
    {% set thumbnail_url = 'https://vumbnail.com/' ~ video_id ~ '.jpg' %}
  {% endif %}
  <div class="slider-slide fullscreen video-wrapper"
      >
    <iframe
      {% if loop.first %}
        src="{{ embed_url }}"
        loading="eager"
      {% else %}
        data-src="{{ embed_url }}"
        loading="lazy"
      {% endif %}
      title="{{ 'Vídeo do carrossel' | translate }} {{ loop.index }}"
      frameborder="0"
      allow="autoplay; fullscreen; picture-in-picture"
      allowfullscreen
      class="video-iframe {% if not loop.first %}lazyload{% endif %}"
      width="100%"
      height="360"
    ></iframe>
  </div>

    {# --- IMAGEM: também fullscreen com object-fit:cover --- #}
    {% else %}
      <div class="slider-slide fullscreen">
      {% if loop.first %}
        <img
          src="{{ slide.image | static_url | settings_image_url('1080p') }}"
          srcset="{{ slide.image | static_url | settings_image_url('original') }} 1024w,
                  {{ slide.image | static_url | settings_image_url('1080p') }} 1920w"
          class="slider-image {% if settings.slider_animation %}slider-image-animation{% endif %}"
          alt="{{ 'Carrusel' | translate }} {{ loop.index }}"
          style="position:absolute; inset:0; width:100%; height:100%; object-fit:cover;"
          width="{{ mobile ? width_mobile : width_desktop }}"
          height="{{ mobile ? height_mobile : height_desktop }}"
          fetchpriority="high"
          loading="eager"
          sizes="100vw"
        />
      {% else %}
        <img
          src="{{ 'images/empty-placeholder.png' | static_url }}"
          data-src="{{ slide.image | static_url | settings_image_url('1080p') }}"
          data-srcset="{{ slide.image | static_url | settings_image_url('original') }} 1024w,
                  {{ slide.image | static_url | settings_image_url('1080p') }} 1920w"
          class="slider-image lazyload {% if settings.slider_animation %}slider-image-animation{% endif %}"
          alt="{{ 'Carrusel' | translate }} {{ loop.index }}"
          style="position:absolute; inset:0; width:100%; height:100%; object-fit:cover;"
          width="{{ mobile ? width_mobile : width_desktop }}"
          height="{{ mobile ? height_mobile : height_desktop }}"
          loading="lazy"
        />
      {% endif %}
        {% if has_text %}
          <div class="swiper-text{% if has_centered_text %} swiper-text-centered{% elseif has_right_text %} swiper-text-right{% endif %} swiper-text-{{ slide.color }}">
            {% if slider | length > 1 %}
              <div class="mb-1 mb-md-2">{{ loop.index }} / {{ loop.length }}</div>
            {% endif %}
            {% if slide.title %}
              <h2 class="{{ slider_title_size_mobile }} {{ slider_title_size_desktop }} mb-2 mb-md-3{% if has_left_text %} ml-neg-2{% elseif has_right_text %} mr-neg-1{% endif %}">{{ slide.title }}</h2>
            {% endif %}
            {% if slide.description %}
              <p class="mb-2 mb-md-3">{{ slide.description }}</p>
            {% endif %}
            {% if slide.button and slide.link %}
              <div class="btn btn-link d-inline-block mb-2 mb-md-3">{{ slide.button }}</div>
            {% endif %}
          </div>
        {% endif %}
      </div>
	
    {% endif %}

    {% if slide.link and not is_video %}
      </a>
    {% endif %}
  </div>
{% endfor %}
					{% endif %}

				</div>

				<div class="js-swiper-home-arrows">
					<div class="js-swiper-home-control js-swiper-home-prev{% if mobile %}-mobile{% endif %} swiper-button-prev svg-icon-text">
						<svg class="icon-inline icon-lg icon-flip-horizontal"><use xlink:href="#arrow-long"/></svg>
					</div>
					<div class="js-swiper-home-control js-swiper-home-next{% if mobile %}-mobile{% endif %} swiper-button-next svg-icon-text">
						<svg class="icon-inline icon-lg"><use xlink:href="#arrow-long"/></svg>
					</div>
				</div>

  <!-- Dot pagination -->
  {% set show_pagination = slider|length > 1 %}
  <div class="js-swiper-home-pagination swiper-pagination swiper-pagination-bullets" style="display: {{ show_pagination ? 'flex' : 'none' }};"></div>
			</div>

			{% if not mobile %}
				{% set so_button = settings.slider_overlay_button %}
				{% set so_link   = settings.slider_overlay_link %}
				{% if so_button %}
					<div class="slider-overlay-content{% if so_link %} slider-overlay-has-link{% endif %}">
						{% if so_link %}<a href="{{ so_link | setting_url }}" class="slider-overlay-link">{% endif %}
						<span class="slider-overlay-button">{{ so_button }}</span>
						{% if so_link %}</a>{% endif %}
					</div>
					<style>
						.slider-overlay-content {
							position: absolute;
							bottom: 48px;
							left: 48px;
							z-index: 10;
							pointer-events: none;
						}
						.slider-overlay-has-link { pointer-events: auto; }
						.slider-overlay-link {
							text-decoration: none;
							color: inherit;
							display: block;
						}
						span.slider-overlay-button {
							display: inline-block !important;
								padding: 20px 56px !important;
								border: 1.5px solid rgba(255,255,255,.8) !important;
								border-radius: 4px !important;
								color: #fff !important;
								font-size: 1.15rem !important;
								font-weight: 400 !important;
								letter-spacing: 2px !important;
							text-transform: uppercase !important;
							background: rgba(255,255,255,.15) !important;
							backdrop-filter: blur(10px);
							-webkit-backdrop-filter: blur(10px);
							cursor: pointer;
							line-height: normal !important;
							width: auto !important;
							height: auto !important;
							margin: 0 !important;
							transition: background .2s ease, border-color .2s ease;
						}
						.slider-overlay-link:hover span.slider-overlay-button {
							background: rgba(255,255,255,.28) !important;
							border-color: rgba(255,255,255,1) !important;
						}
						@media (max-width: 991px) {
							.slider-overlay-content { bottom: 36px; left: 32px; }
							span.slider-overlay-button { padding: 14px 32px !important; font-size: .9rem !important; }
						}
						@media (max-width: 767px) {
							.slider-overlay-content { bottom: 24px; left: 20px; }
							span.slider-overlay-button { padding: 12px 24px !important; font-size: .82rem !important; }
						}
					</style>
				{% endif %}
			{% endif %}
		</div>
	</div>
{% if not mobile %}
</div>
{% endif %}
