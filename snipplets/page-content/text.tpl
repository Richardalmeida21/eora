{% set text_active = attribute(settings,"#{settings_name}_text_active") %}

{% set text_title_align = attribute(settings,"#{settings_name}_align_title") %}
{% set text_description_align = attribute(settings,"#{settings_name}_align_description") %}

{% set text_title = attribute(settings,"#{settings_name}_text_title") %}
{% set text_description = attribute(settings,"#{settings_name}_text_description") %}

{% set title_size_mobile = attribute(settings,"#{settings_name}_title_size_mobile") %}
{% set title_size_desktop = attribute(settings,"#{settings_name}_title_size_desktop") %}

{% set text_title_size_mobile = title_size_mobile == 'small' ? 'h3-huge' : title_size_mobile == 'medium' ? 'h2-huge' : 'h1-huge' %}
{% set text_title_size_desktop = title_size_desktop == 'small' ? 'h2-huge-md' : title_size_desktop == 'medium' ? 'h1-huge-md' : 'h2-extra-huge-md'  %}

{% set description_size_mobile = attribute(settings,"#{settings_name}_description_size_mobile") %}
{% set description_size_desktop = attribute(settings,"#{settings_name}_description_size_desktop") %}

{% set text_description_size_mobile = description_size_mobile == 'small' ? 'font-big' : description_size_mobile == 'medium' ? 'font-extra-big' : 'h4-huge' %}
{% set text_description_size_desktop = description_size_desktop == 'small' ? 'font-md-big' : description_size_desktop == 'medium' ? 'font-md-extra-big' : 'h3-huge-md'  %}

{% set has_section_text = text_active and (text_title or text_description) %}
{% if has_section_text %}
  <section class="container-fluid my-4">
    <div class="row justify-content-center">
      {% if text_title %}
        <div class="col-12 text-center">
          <h2 class="{{ text_title_size_mobile }} {{ text_title_size_desktop }}">{{ text_title }}</h2>
        </div>
      {% endif %}
      {% if text_description %}
        <div class="col-12 {{ text_description_size_mobile }} {{ text_description_size_desktop }} text-center">{{text_description | raw }}</div>
      {% endif %}
    </div>
  </section>
{% endif %}
