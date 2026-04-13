{% set banner_texts = [] %}

{% if settings.carrossell_text_1 %}
  {% set banner_texts = banner_texts | merge([settings.carrossell_text_1]) %}
{% endif %}
{% if settings.carrossell_text_2 %}
  {% set banner_texts = banner_texts | merge([settings.carrossell_text_2]) %}
{% endif %}
{% if settings.carrossell_text_3 %}
  {% set banner_texts = banner_texts | merge([settings.carrossell_text_3]) %}
{% endif %}
{% if settings.carrossell_text_4 %}
  {% set banner_texts = banner_texts | merge([settings.carrossell_text_4]) %}
{% endif %}

<style>
/* carrossel text */
.banner-strip {
  width: 100%;
  overflow: hidden;
  background: #000;
  height: 30px;
  display: flex; 
  align-items: center;
}
.banner-track {
  display: flex;
  white-space: nowrap;
  animation: banner-scroll 35s linear infinite;
}
.banner-item {
  font-size: 12px;
  color: #fff;
  font-family: "Hanken Grotesk";
  font-weight: 600;
  line-height: normal;
  text-transform: uppercase;
  padding: 0 32px;
  flex-shrink: 0;
  white-space: nowrap;
}
@keyframes banner-scroll {
  0% {
    transform: translateX(0);
  }
  100% {
    transform: translateX(-33.333%);
  }
}
</style>

{% if banner_texts %}
  <div class="banner-strip">
    <div class="banner-track">
    {% for i in 1..3 %}
      {% for text in banner_texts %}
        <span class="banner-item">{{ text | upper }}</span>
      {% endfor %}
    {% endfor %}
    </div>
  </div>
{% endif %}