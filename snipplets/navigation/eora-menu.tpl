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
{# Previous storefront photos retained independently of removed editor fields. #}
{% set previous_menu_images = {
    default: [
        {"image":"menu-preserved-1.webp","title":"Óculos de sol","link":"https://www.eoraeyewear.com/oculos-eora"},
        {"image":"menu-preserved-2.webp","title":"ACESSÓRIOS","link":"https://www.eoraeyewear.com/acessorios/"},
        {"image":"menu-preserved-3.webp","title":"BOLSAS","link":"https://www.eoraeyewear.com/bolsas-eora"},
        {"image":"menu-preserved-4.webp","title":"LANÇAMENTO VÉRTICE","link":"https://www.eoraeyewear.com/produtos/vertice-bordo-prata/"}
    ],
    warranty: [
        {"image":"menu-preserved-5.webp","title":"SOBRE","link":"https://www.eoraeyewear.com/sobre1"},
        {"image":"menu-preserved-6.webp","title":"GARANTIA EORA","link":"https://www.eoraeyewear.com/garantia-eora"}
    ],
    community: [
        {"image":"menu-preserved-7.webp","title":"BRUNA TAVARES","link":"https://www.eoraeyewear.com/quem-usa1/"},
        {"image":"menu-preserved-8.webp","title":"JOÃO CAMARGO","link":"https://www.eoraeyewear.com/quem-usa1/"},
        {"image":"menu-preserved-9.webp","title":"BRUNA MALHEIROS","link":"https://www.eoraeyewear.com/quem-usa1/"},
        {"image":"menu-preserved-10.webp","title":"BIANCA ANDRADE","link":"https://www.eoraeyewear.com/quem-usa1/"}
    ]
} %}
{% set use_previous_images = settings.eora_menu_previous_images_enabled is not defined or settings.eora_menu_previous_images_enabled %}
{% set default_images = [] %}
{% set standard_gallery = settings.eora_menu_default_images %}
{% if standard_gallery is empty and use_previous_images %}{% set standard_gallery = previous_menu_images.default %}{% endif %}
{% for image in standard_gallery %}
    {% if image.image %}{% set default_images = default_images | merge([image]) %}{% endif %}
{% endfor %}
{% set default_images = default_images | slice(0, 4) %}

<nav class="eora-menu eora-menu--{{ mode }}" data-eora-menu="{{ mode }}" data-menu-revision="1" aria-label="{{ mode == 'desktop' ? 'Navegação principal' : 'Menu da loja' }}" data-store="navigation" data-component="menu">
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
                {% for group in groups %}
                    <button type="button" data-menu-go="{{ group.key }}" aria-expanded="false">{{ attribute(settings, 'eora_menu_' ~ group.key ~ '_title') | default(group.title) }}<span aria-hidden="true">›</span></button>
                {% endfor %}
                {{ links.primary(settings) }}
            </div>
            {% include 'snipplets/navigation/eora-gallery.tpl' with {images: default_images, image_fallback_url: '/shop/', image_fallback_title: 'Conheça EORA'} %}
        </div>
    {% endif %}

    {% for group in groups %}
        {% set group_title = attribute(settings, 'eora_menu_' ~ group.key ~ '_title') | default(group.title) %}
        {% set group_images = [] %}
        {% for image in attribute(settings, 'eora_menu_' ~ group.key ~ '_images') %}
            {% if image.image %}{% set group_images = group_images | merge([image]) %}{% endif %}
        {% endfor %}
        {% if group_images is empty and use_previous_images and attribute(previous_menu_images, group.key) %}
            {% set group_images = attribute(previous_menu_images, group.key) %}
        {% endif %}
        {% if group_images is empty %}{% set group_images = default_images %}{% endif %}
        {% set group_images = group_images | slice(0, 4) %}
        {% if mode == 'desktop' %}
            {% set group_images = group_images | slice(0, 2) %}
            <section class="eora-menu__group" data-menu-group="{{ group.key }}">
                <div><h2>{{ group_title }}</h2>{{ links.children(group.items, settings) }}</div>
                {% include 'snipplets/navigation/eora-gallery.tpl' with {images: group_images, image_fallback_url: links.url(group.items[0].key, group.items[0].url, settings) | trim, image_fallback_title: group_title} %}
            </section>
        {% else %}
            <div data-menu-screen="{{ group.key }}">
                <button type="button" class="eora-menu__back" data-menu-go="primary"><span aria-hidden="true">‹</span> Menu</button>
                <h2 class="eora-menu__mobile-title">{{ group_title }}</h2>
                {{ links.children(group.items, settings) }}
                {% include 'snipplets/navigation/eora-gallery.tpl' with {images: group_images, image_fallback_url: links.url(group.items[0].key, group.items[0].url, settings) | trim, image_fallback_title: group_title} %}
            </div>
        {% endif %}
    {% endfor %}
    {% if mode == 'desktop' %}</div></div>{% endif %}
</nav>
