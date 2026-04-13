{% set name_setting = settings_name %}

{% if first_products %}
	{% set data_store_name = settings_name %}
  {% set name_setting = settings_name %}
{% endif %}

{% if second_products %}
	{% set data_store_name = settings_name ~ '_02' %}
  {% set name_setting = settings_name ~ '_02' %}
{% endif %}

{% if third_products %}
	{% set data_store_name = settings_name ~ '_03' %}
  {% set name_setting = settings_name ~ '_03' %}
{% endif %}

{% if fourth_products %}
	{% set data_store_name = settings_name ~ '_04' %}
  {% set name_setting = settings_name ~ '_04' %}
{% endif %}

{% if name_setting == 'campaign_page_01' %}
		{% set sections_products = sections.campaign_page_01_fpc.products %}
{% elseif name_setting == 'campaign_page_01_02' %}
		{% set sections_products = sections.campaign_page_01_spc.products %}
{% elseif name_setting == 'campaign_page_01_03' %}
		{% set sections_products = sections.campaign_page_01_tpc.products %}
{% elseif name_setting == 'campaign_page_01_04' %}
		{% set sections_products = sections.campaign_page_01_qpc.products %}
{% elseif name_setting == 'campaign_page_02' %}
		{% set sections_products = sections.campaign_page_02_fpc.products %}
{% elseif name_setting == 'campaign_page_02_02' %}
		{% set sections_products = sections.campaign_page_02_spc.products %}
{% elseif name_setting == 'campaign_page_02_03' %}
		{% set sections_products = sections.campaign_page_02_tpc.products %}
{% elseif name_setting == 'campaign_page_02_04' %}
		{% set sections_products = sections.campaign_page_02_qpc.products %}
{% elseif name_setting == 'campaign_page_03' %}
		{% set sections_products = sections.campaign_page_03_fpc.products %}
{% elseif name_setting == 'campaign_page_03_02' %}
		{% set sections_products = sections.campaign_page_03_spc.products %}
{% elseif name_setting == 'campaign_page_03_03' %}
		{% set sections_products = sections.campaign_page_03_tpc.products %}
{% elseif name_setting == 'campaign_page_03_04' %}
		{% set sections_products = sections.campaign_page_03_qpc.products %}
{% elseif name_setting == 'campaign_page_04' %}
		{% set sections_products = sections.campaign_page_04_fpc.products %}
{% elseif name_setting == 'campaign_page_04_02' %}
		{% set sections_products = sections.campaign_page_04_spc.products %}
{% elseif name_setting == 'campaign_page_04_03' %}
		{% set sections_products = sections.campaign_page_04_tpc.products %}
{% elseif name_setting == 'campaign_page_04_04' %}
		{% set sections_products = sections.campaign_page_04_qpc.products %}
{% elseif name_setting == 'campaign_page_05' %}
		{% set sections_products = sections.campaign_page_05_fpc.products %}
{% elseif name_setting == 'campaign_page_05_02' %}
		{% set sections_products = sections.campaign_page_05_spc.products %}
{% elseif name_setting == 'campaign_page_05_03' %}
		{% set sections_products = sections.campaign_page_05_tpc.products %}
{% elseif name_setting == 'campaign_page_05_04' %}
		{% set sections_products = sections.campaign_page_05_qpc.products %}
{% elseif name_setting == 'campaign_page_06' %}
		{% set sections_products = sections.campaign_page_06_fpc.products %}
{% elseif name_setting == 'campaign_page_06_02' %}
		{% set sections_products = sections.campaign_page_06_spc.products %}
{% elseif name_setting == 'campaign_page_06_03' %}
		{% set sections_products = sections.campaign_page_06_tpc.products %}
{% elseif name_setting == 'campaign_page_06_04' %}
		{% set sections_products = sections.campaign_page_06_qpc.products %}
{% elseif name_setting == 'campaign_page_07' %}
		{% set sections_products = sections.campaign_page_07_fpc.products %}
{% elseif name_setting == 'campaign_page_07_02' %}
		{% set sections_products = sections.campaign_page_07_spc.products %}
{% elseif name_setting == 'campaign_page_07_03' %}
		{% set sections_products = sections.campaign_page_07_tpc.products %}
{% elseif name_setting == 'campaign_page_07_04' %}
		{% set sections_products = sections.campaign_page_07_qpc.products %}
{% elseif name_setting == 'campaign_page_08' %}
		{% set sections_products = sections.campaign_page_08_fpc.products %}
{% elseif name_setting == 'campaign_page_08_02' %}
		{% set sections_products = sections.campaign_page_08_spc.products %}
{% elseif name_setting == 'campaign_page_08_03' %}
		{% set sections_products = sections.campaign_page_08_tpc.products %}
{% elseif name_setting == 'campaign_page_08_04' %}
		{% set sections_products = sections.campaign_page_08_qpc.products %}
{% elseif name_setting == 'campaign_page_09' %}
		{% set sections_products = sections.campaign_page_09_fpc.products %}
{% elseif name_setting == 'campaign_page_09_02' %}
		{% set sections_products = sections.campaign_page_09_spc.products %}
{% elseif name_setting == 'campaign_page_09_03' %}
		{% set sections_products = sections.campaign_page_09_tpc.products %}
{% elseif name_setting == 'campaign_page_09_04' %}
		{% set sections_products = sections.campaign_page_09_qpc.products %}
{% elseif name_setting == 'campaign_page_10' %}
		{% set sections_products = sections.campaign_page_10_fpc.products %}
{% elseif name_setting == 'campaign_page_10_02' %}
		{% set sections_products = sections.campaign_page_10_spc.products %}
{% elseif name_setting == 'campaign_page_10_03' %}
		{% set sections_products = sections.campaign_page_10_tpc.products %}
{% elseif name_setting == 'campaign_page_10_04' %}
		{% set sections_products = sections.campaign_page_10_qpc.products %}
{% endif %}

{% set section_active = attribute(settings,"#{name_setting}_products_active") %}
{% set has_section = sections_products is not empty and section_active %}

{% if has_section %}
	<section class="section-home section-featured-home" data-store="{{ data_store_name }}_products">
      {% include 'snipplets/campaign/featured-grid.tpl' with {settings_name: name_setting, sections_products: sections_products} %}
	</section>
{% endif %}


