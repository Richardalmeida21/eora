{% if campaign_banner_topo_01 %}
  {% set campaign_banner_topo = attribute(settings,"#{settings_name}_banner_topo") %}
  {% set campaign_banner_topo_img = settings_name ~ '_banner_topo_img.jpg' %}
  {% set campaign_banner_topo_mobile = attribute(settings,"#{settings_name}_banner_topo_mobile") %}
  {% set campaign_banner_topo_mobile_img = settings_name ~ '_banner_topo_mobile_img.jpg' %}
{% endif %}

{% if campaign_banner_topo_02 %}
  {% set campaign_banner_topo = attribute(settings,"#{settings_name}_02_banner_topo") %}
  {% set campaign_banner_topo_img = settings_name ~ '_02_banner_topo_img.jpg' %}
  {% set campaign_banner_topo_mobile = attribute(settings,"#{settings_name}_02_banner_topo_mobile") %}
  {% set campaign_banner_topo_mobile_img = settings_name ~ '_02_banner_topo_mobile_img.jpg' %}
{% endif %}

{# Set a conditional margin for the banner: apply -120px only for the first topo variant and not when the second is active #}
{% if campaign_banner_topo_01 and not campaign_banner_topo_02 %}
  {% set banner_topo_margin = '-130px' %}
{% else %}
  {% set banner_topo_margin = '0' %}
{% endif %}

<style>
/* Scoped override for banner-topo slider height */
.section-slider-banner-topo-fixed {
  position: relative;
  top: 0;
  margin-top: {{ banner_topo_margin }};
  width: 100%;
  height: 85vh !important;
  overflow: hidden;
}
</style>

{% if campaign_banner_topo %}
    <section class="section-banner-topo py-4">
        <div class="container-fluid desktop px-3 {% if campaign_banner_topo_mobile %} d-none d-md-block {% endif %}">
            <div class="row">
                <div class="col-12 px-0">
                    {% set image_url = campaign_banner_topo_img | static_url %}

                    <!-- Slider fixo no topo e atrás do header -->
                    <div class="section-slider position-relative slider-fixed-top section-slider-banner-topo-fixed" style="margin-top: {{ banner_topo_margin }};">
                      <div class="js-home-slider h-100 swiper-container">
                        <div class="swiper-wrapper">
                          <div class="swiper-slide slide-container">
                            <div class="slider-slide fullscreen">
                              <img src="{% if campaign_banner_topo %}{{ image_url }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Banner topo" style="position:absolute; inset:0; width:100%; height:100%; object-fit:cover;" />
                            </div>
                          </div>
                        </div>
                      </div>
                    </div>
                </div>
            </div>
        </div>
        {% if campaign_banner_topo_mobile %}
            <div class="container-fluid mobile d-block d-md-none">
                <div class="row">
                    <div class="col-12 px-0">
                        {% set image_url_mobile = campaign_banner_topo_mobile_img | static_url %}
                        
                        <!-- Slider fixo no topo e atrás do header (mobile) -->
                        <div class="section-slider position-relative slider-fixed-top section-slider-banner-topo-fixed" style="margin-top: {{ banner_topo_margin }};">
                          <div class="js-home-slider-mobile h-100 swiper-container">
                            <div class="swiper-wrapper">
                              <div class="swiper-slide slide-container">
                                <div class="slider-slide fullscreen">
                                  <img src="{% if campaign_banner_topo %}{{ image_url_mobile }}{% else %}{{ 'images/empty-placeholder.png' | static_url }}{% endif %}" alt="Banner topo" style="position:absolute; inset:0; width:100%; height:100%; object-fit:cover;" />
                                </div>
                              </div>
                            </div>
                          </div>
                        </div>

                    </div>
                </div>
            </div>
        {% endif %}
    </section>
{% endif %}