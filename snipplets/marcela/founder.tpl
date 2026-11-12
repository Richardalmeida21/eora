{% set mf_founder_count = 0 %}
{% for i in 1..10 %}{% set mf_slot = 'marcela_founder_' ~ i %}{% set mf_photo = attribute(settings, mf_slot ~ '_image') | first %}{% if attribute(settings, mf_slot ~ '_enabled') and mf_photo.image %}{% set mf_founder_count = mf_founder_count + 1 %}{% endif %}{% endfor %}
{% if mf_founder_count %}
<section class="mf-founder mf-carousel" data-mf-carousel style="--mf-visible:4;--mf-count:{{ mf_founder_count }}" aria-labelledby="mf-founder-heading">
    <h2 class="mf-section-title" id="mf-founder-heading">{{ settings.marcela_founder_title | default('Conteúdos da Marcela') | escape }}</h2>
    <div class="mf-track" data-mf-track tabindex="0" aria-label="Percorrer conteúdos da Marcela">
        {% for i in 1..10 %}
            {% set mf_slot = 'marcela_founder_' ~ i %}
            {% set mf_photo = attribute(settings, mf_slot ~ '_image') | first %}
            {% set mf_mobile = attribute(settings, mf_slot ~ '_mobile') | first %}
            {% if attribute(settings, mf_slot ~ '_enabled') and mf_photo.image %}
                <article class="mf-founder-card" data-mf-order="{{ attribute(settings, mf_slot ~ '_order') | default(i) | escape }}">
                    {% if attribute(settings, mf_slot ~ '_title') %}<h3>{{ attribute(settings, mf_slot ~ '_title') | escape }}</h3>{% endif %}
                    <picture>{% if mf_mobile.image %}<source media="(max-width: 767px)" srcset="{{ mf_mobile.image | escape }}">{% endif %}<img src="{{ mf_photo.image | escape }}" alt="{{ attribute(settings, mf_slot ~ '_title') | default('Conteúdo da Marcela') | escape }}" width="1600" height="2400" loading="lazy" decoding="async"></picture>
                    {% if attribute(settings, mf_slot ~ '_description') %}<p>{{ attribute(settings, mf_slot ~ '_description') | escape }}</p>{% endif %}
                    {% if attribute(settings, mf_slot ~ '_link') %}<a href="{{ attribute(settings, mf_slot ~ '_link') | escape }}">{{ attribute(settings, mf_slot ~ '_button') | default('Ver mais') | escape }}</a>{% endif %}
                </article>
            {% endif %}
        {% endfor %}
    </div>
    {% include 'snipplets/bolsas-eora/controls.tpl' %}
</section>
{% endif %}
