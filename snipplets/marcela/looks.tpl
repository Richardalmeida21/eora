{% set mf_looks_count = 0 %}
{% for i in 1..10 %}{% set mf_slot = 'marcela_look_' ~ i %}{% set mf_photo = attribute(settings, mf_slot ~ '_image') | first %}{% if attribute(settings, mf_slot ~ '_enabled') and mf_photo.image and attribute(sections, mf_slot).products %}{% set mf_looks_count = mf_looks_count + 1 %}{% endif %}{% endfor %}
{% if mf_looks_count %}
<section class="mf-looks mf-carousel" data-mf-carousel style="--mf-visible:2;--mf-count:{{ mf_looks_count }}" aria-labelledby="mf-looks-heading">
    <h2 class="mf-section-title" id="mf-looks-heading">{{ settings.marcela_looks_title | default('Shop the look') | escape }}</h2>
    <div class="mf-track" data-mf-track tabindex="0" aria-label="Percorrer looks da Marcela">
        {% for i in 1..10 %}
            {% set mf_slot = 'marcela_look_' ~ i %}
            {% set mf_photo = attribute(settings, mf_slot ~ '_image') | first %}
            {% set mf_photo_mobile = attribute(settings, mf_slot ~ '_mobile') | first %}
            {% set mf_items = attribute(sections, mf_slot).products | default([]) | take(2) %}
            {% set mf_title = attribute(settings, mf_slot ~ '_title') | default('Look da Marcela ' ~ i) %}
            {% if attribute(settings, mf_slot ~ '_enabled') and mf_photo.image and mf_items %}
                <article class="mf-look" data-mf-order="{{ attribute(settings, mf_slot ~ '_order') | default(i) | escape }}">
                    <button class="mf-look__open" type="button" data-mf-look="{{ i }}" aria-haspopup="dialog" aria-controls="mf-look-dialog" aria-label="Ver produtos: {{ mf_title | escape }}">
                        <picture>{% if mf_photo_mobile.image %}<source media="(max-width: 767px)" srcset="{{ mf_photo_mobile.image | settings_image_url('original') }}">{% endif %}<img src="{{ mf_photo.image | settings_image_url('original') }}" alt="{{ mf_title | escape }}" loading="lazy" decoding="async" width="1600" height="1600"></picture>
                        <span class="mf-look__caption"><strong>{{ mf_title | escape }}</strong><span>{{ attribute(settings, mf_slot ~ '_button') | default('Ver o look') | escape }}</span></span>
                    </button>
                    <template data-mf-look-content="{{ i }}"><div class="mf-look-detail"><picture class="mf-look-detail__photo">{% if mf_photo_mobile.image %}<source media="(max-width: 767px)" srcset="{{ mf_photo_mobile.image | settings_image_url('original') }}">{% endif %}<img src="{{ mf_photo.image | settings_image_url('original') }}" alt="{{ mf_title | escape }}" width="1600" height="1600"></picture><div class="mf-look-detail__selection"><h3>{{ mf_title | escape }}</h3><div class="mf-look-products">{% for product in mf_items %}{% include 'snipplets/bolsas-eora/product-card.tpl' with {be_product_image_limit: 1, be_product_high_quality: true} %}{% endfor %}</div></div></div></template>
                </article>
            {% endif %}
        {% endfor %}
    </div>
    {% include 'snipplets/bolsas-eora/controls.tpl' %}
</section>
<dialog class="mf-look-dialog" id="mf-look-dialog" aria-labelledby="mf-look-dialog-title">
    <header><h2 id="mf-look-dialog-title">{{ settings.marcela_looks_title | default('Shop the look') | escape }}</h2><button type="button" data-mf-close-look aria-label="Fechar look"><svg aria-hidden="true"><use xlink:href="#times"/></svg></button></header>
    <div class="mf-look-dialog__body" data-mf-dialog-body></div>
</dialog>
{% endif %}
