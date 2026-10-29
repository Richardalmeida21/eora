{% import 'snipplets/navigation/eora-links.tpl' as links %}
{% set groups = [
    {key: 'shop', title: 'Shop', items: [
        {key: 'glasses', label: 'Óculos', url: '/oculos-eora/'},
        {key: 'bags', label: 'Bolsas', url: '/bolsas-eora/'},
        {key: 'accessories', label: 'Acessórios', url: '/acessorios/'},
        {key: 'belts', label: 'Cintos', url: '/acessorios/cintos/'}
    ]},
    {key: 'favorites', title: 'Favoritos Marcela', items: [
        {key: 'favorites', label: 'Favoritos', url: '/favoritosdamarcela/'},
        {key: 'gifts', label: 'Gifts', url: '/presenteaveis-eora/'}
    ]},
    {key: 'warranty', title: 'Garantia EORA', items: [
        {key: 'care', label: 'Cuidados', url: '/garantia-eora/#cuidados-com-a-peca'},
        {key: 'repair', label: 'Consertos', url: '/garantia-eora/#reparos-e-consertos'},
        {key: 'exchange', label: 'Política de troca', url: '/politica-de-troca-e-reembolso/'}
    ]},
    {key: 'new', title: 'New in', items: [
        {key: 'launches', label: 'Lançamentos', url: '/best-sellers1/?bs_filters=%7B%22bs_new%22%3A%221%22%7D'},
        {key: 'preorder', label: 'Pré-venda', url: '/search/?eora_preorder=1'},
        {key: 'restock', label: 'De volta ao estoque', url: '/de-volta-ao-estoque/'}
    ]},
    {key: 'community', title: 'Quem usa', items: [
        {key: 'community', label: 'Quem usa', url: '/quem-usa1/'},
        {key: 'press', label: 'Press', url: '/sobre1/#se-press'}
    ]}
] %}
{% set default_images = [] %}
{% set standard_gallery = settings.eora_menu_default_images %}
{% if standard_gallery is empty %}{% set standard_gallery = settings.desktop_menu_images_first %}{% endif %}
{% for image in standard_gallery %}
    {% if image.image %}{% set default_images = default_images | merge([image]) %}{% endif %}
{% endfor %}
{% set default_images = default_images | slice(0, 4) %}

<nav class="eora-menu eora-menu--{{ mode }}" data-eora-menu="{{ mode }}" aria-label="{{ mode == 'desktop' ? 'Navegação principal' : 'Menu da loja' }}" data-store="navigation" data-component="menu">
    {% if mode == 'desktop' %}
        <div class="eora-menu__primary">
            <button type="button" data-menu-toggle aria-expanded="false" aria-controls="eora-menu-desktop">{{ settings.eora_menu_label | default('Menu') }}</button>
            {{ links.primary(settings) }}
        </div>
        <div class="eora-menu__overlay" data-menu-overlay hidden></div>
        <div class="eora-menu__desktop" id="eora-menu-desktop" data-menu-desktop hidden role="dialog" aria-modal="true" aria-label="Menu">
            <div class="eora-menu__heading"><span>{{ settings.eora_menu_label | default('Menu') }}</span><button type="button" class="eora-menu__close" data-menu-close aria-label="Fechar menu">×</button></div>
            <div class="eora-menu__groups">
    {% else %}
        <div data-menu-screen="primary" class="is-active">
            <div class="eora-menu__mobile-primary">
                <button type="button" data-menu-go="secondary" aria-expanded="false">{{ settings.eora_menu_label | default('Menu') }}<span aria-hidden="true">›</span></button>
                {{ links.primary(settings) }}
            </div>
            {% include 'snipplets/navigation/eora-gallery.tpl' with {images: default_images, image_fallback_url: '/shop/', image_fallback_title: 'Conheça EORA'} %}
        </div>
        <div data-menu-screen="secondary">
            <button type="button" class="eora-menu__back" data-menu-go="primary"><span aria-hidden="true">‹</span> Voltar</button>
            <h2 class="eora-menu__mobile-title">{{ settings.eora_menu_label | default('Menu') }}</h2>
            <ul class="eora-menu__sections">
                {% for group in groups %}
                    <li><button type="button" data-menu-go="{{ group.key }}" aria-expanded="false">{{ attribute(settings, 'eora_menu_' ~ group.key ~ '_title') | default(group.title) }}<span aria-hidden="true">›</span></button></li>
                {% endfor %}
            </ul>
            {% include 'snipplets/navigation/eora-gallery.tpl' with {images: default_images, image_fallback_url: '/shop/', image_fallback_title: 'Conheça EORA'} %}
        </div>
    {% endif %}

    {% for group in groups %}
        {% set group_title = attribute(settings, 'eora_menu_' ~ group.key ~ '_title') | default(group.title) %}
        {% set group_images = [] %}
        {% for image in attribute(settings, 'eora_menu_' ~ group.key ~ '_images') %}
            {% if image.image %}{% set group_images = group_images | merge([image]) %}{% endif %}
        {% endfor %}
        {# Reaproveitar uploads do menu anterior quando o novo grupo ainda não foi cadastrado. #}
        {% if group_images is empty %}
            {% for letter in ['a', 'b', 'c', 'd'] %}
                {% set legacy_name = attribute(settings, 'custom_menu_name_' ~ letter) | lower | trim %}
                {% if legacy_name and (legacy_name == group.title | lower or (group.key == 'favorites' and legacy_name == 'favoritos da marcela')) %}
                    {% for position in 1..4 %}
                        {% set legacy_image = 'custom_menu_' ~ letter ~ '_img_' ~ position ~ '.jpg' %}
                        {% if legacy_image | has_custom_image %}
                            {% set group_images = group_images | merge([{image: legacy_image, title: attribute(settings, 'custom_menu_' ~ letter ~ '_title_' ~ position), link: attribute(settings, 'custom_menu_' ~ letter ~ '_link_' ~ position)}]) %}
                        {% endif %}
                    {% endfor %}
                {% endif %}
            {% endfor %}
        {% endif %}
        {% if group_images is empty %}{% set group_images = default_images %}{% endif %}
        {% set group_images = group_images | slice(0, 4) %}
        {% if mode == 'desktop' %}
            {% set group_images = group_images | slice(0, 1) %}
            <section class="eora-menu__group" data-menu-group="{{ group.key }}">
                <div><h2>{{ group_title }}</h2>{{ links.children(group.items, settings) }}</div>
                {% include 'snipplets/navigation/eora-gallery.tpl' with {images: group_images, image_fallback_url: links.url(group.items[0].key, group.items[0].url, settings) | trim, image_fallback_title: group_title} %}
            </section>
        {% else %}
            <div data-menu-screen="{{ group.key }}">
                <button type="button" class="eora-menu__back" data-menu-go="secondary"><span aria-hidden="true">‹</span> Menu</button>
                <h2 class="eora-menu__mobile-title">{{ group_title }}</h2>
                {{ links.children(group.items, settings) }}
                {% include 'snipplets/navigation/eora-gallery.tpl' with {images: group_images, image_fallback_url: links.url(group.items[0].key, group.items[0].url, settings) | trim, image_fallback_title: group_title} %}
            </div>
        {% endif %}
    {% endfor %}
    {% if mode == 'desktop' %}</div></div>{% endif %}
</nav>
