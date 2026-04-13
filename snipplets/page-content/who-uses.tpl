
{% set page_current_who_uses = settings.who_uses_page_url %}
{% if page.handle == page_current_who_uses %}
  {% set who_uses_images = settings.who_uses_page_images %}

  {# size images #}
	{% set padding_bottom_banner = 100 %}
	{% set page_image_width = settings.who_uses_page_images_width  %}
	{% set page_image_height = settings.who_uses_page_images_height  %}

	{% if page_image_width > 0 and page_image_height > 0 %}
		{% set padding_bottom_banner = (page_image_height / page_image_width) * 100 %}
	{% endif %}

<section class="container-fluid px-0">
  <div class="row row-grid">
    {% for slide in who_uses_images %}
      {% set slide_link = slide.link %}
      {% set slide_title = slide.title %}
      {% set slide_description = slide.description %}
      {% set has_text = slide.title or slide.description %}

      <div class="col-6 col-md-4">
        {% if slide_link %}
          <a href="{{slide_link}}" class="no-text-underline" {% if has_text %}aria-label="ir para {{slide.title}} {{slide.description}}"{% endif %}>
        {% endif %}

          {% set slide_src = slide.image | static_url | settings_image_url('1080p') %}
          <figure class='image -topo'  style="padding-bottom: {{ padding_bottom_banner }}%">
            <img 
              src="{{ slide_src }}"
              srcset="{{ slide.image | static_url | settings_image_url('original') }} 1024w, {{ slide.image | static_url | settings_image_url('1080p') }} 1920w"
              sizes="(max-width: 768px) 50vw, 33vw"
              class="image mt-0"
              {% if has_text %}alt="{{slide.title}} {{slide.description}}"{% else %}alt="Imagem quem usa {{ loop.index }}"{% endif %}
            />
          </figure>

          {% if has_text %}
            <div class="d-flex flex-column align-items-center py-3">
              {% if slide_title %}
                <h3 class="mb-2">{{ slide_title }}</h3>
              {% endif %}
              {% if slide_description %}
                <p class="mb-0">{{slide_description}}</p>
              {% endif %}
            </div>
          {% endif %}
        {% if slide_link %}
          </a>
        {% endif %}
      </div>
    {% endfor %}
  </div>
</section>
{% endif %}
